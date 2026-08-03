import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/calendar_models.dart';
import '../providers/calendar_controller.dart';
import '../dialogs/group_form_dialog.dart';
import '../dialogs/vaccine_form_dialog.dart';
import '../../theme/app_colors.dart';
import '../../utils/feedback_helper.dart';

/// Tela DEDICADA de gerenciamento do calendário vacinal.
///
/// Fica separada da tela de cronograma da criança (VaccinationPage) de
/// propósito: são contextos diferentes (edição GLOBAL vs. registro de UM
/// paciente), e misturar os dois aumenta o risco do usuário editar o
/// calendário de todo mundo pensando que está mexendo só naquela criança.
class CalendarManagementPage extends ConsumerStatefulWidget {
  const CalendarManagementPage({super.key});

  @override
  ConsumerState<CalendarManagementPage> createState() => _CalendarManagementPageState();
}

class _CalendarManagementPageState extends ConsumerState<CalendarManagementPage> {
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final structure = ref.watch(fullCalendarStructureProvider);
    final visibleGroups =
        _showArchived ? structure : structure.where((g) => g.group.active).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Calendário Vacinal'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_showArchived ? Icons.visibility_off : Icons.archive_outlined),
            tooltip: _showArchived ? 'Ocultar arquivados' : 'Mostrar arquivados',
            onPressed: () => setState(() => _showArchived = !_showArchived),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(context: context, builder: (_) => const GroupFormDialog()),
        icon: const Icon(Icons.add),
        label: const Text('Novo Grupo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: visibleGroups.isEmpty
          ? _buildEmptyState()
          : ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: visibleGroups.length,
              onReorder: (oldIndex, newIndex) async {
                if (newIndex > oldIndex) newIndex -= 1;
                final reordered = List<VaccineGroupWithVaccines>.from(visibleGroups);
                final moved = reordered.removeAt(oldIndex);
                reordered.insert(newIndex, moved);

                await ref
                    .read(calendarGroupsProvider.notifier)
                    .reorderGroups(reordered.map((g) => g.groupKey).toList());
              },
              itemBuilder: (context, index) {
                final groupData = visibleGroups[index];
                return _GroupTile(
                  key: ValueKey(groupData.groupKey),
                  groupData: groupData,
                  showArchived: _showArchived,
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Nenhum grupo cadastrado ainda.\nToque em "Novo Grupo" para começar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupTile extends ConsumerWidget {
  final VaccineGroupWithVaccines groupData;
  final bool showArchived;

  const _GroupTile({super.key, required this.groupData, required this.showArchived});

  String _ageLabel(VaccineGroupModel g) {
    final unit = switch (g.ageUnit) {
      AgeUnit.days => g.ageValue == 1 ? 'dia' : 'dias',
      AgeUnit.months => g.ageValue == 1 ? 'mês' : 'meses',
      AgeUnit.years => g.ageValue == 1 ? 'ano' : 'anos',
    };
    return '${g.ageValue} $unit após o nascimento';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = groupData.group;
    final vaccines = showArchived ? groupData.vaccines : groupData.vaccines.where((v) => v.active).toList();
    final isArchived = !group.active;

    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: isArchived ? Colors.grey.shade100 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        leading: const Icon(Icons.drag_indicator, color: Colors.grey),
        title: Row(
          children: [
            Flexible(
              child: Text(
                group.label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: isArchived ? TextDecoration.lineThrough : null,
                  color: isArchived ? Colors.grey.shade600 : Colors.black87,
                ),
              ),
            ),
            if (isArchived) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Arquivado', style: TextStyle(fontSize: 10)),
              ),
            ],
          ],
        ),
        subtitle: Text(_ageLabel(group), style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'edit':
                showDialog(context: context, builder: (_) => GroupFormDialog(groupToEdit: group));
                break;
              case 'archive':
                final confirm = await FeedbackHelper.showConfirmation(
                  context,
                  title: 'Arquivar Grupo?',
                  message: 'O grupo "${group.label}" deixará de aparecer em novos cronogramas. '
                      'O histórico de pacientes que já têm vacinas deste grupo NÃO será apagado.',
                  confirmText: 'Arquivar',
                  confirmColor: AppColors.warning,
                );
                if (confirm) {
                  await ref.read(calendarGroupsProvider.notifier).archiveGroup(group.key as int);
                }
                break;
              case 'restore':
                await ref.read(calendarGroupsProvider.notifier).restoreGroup(group.key as int);
                break;
              case 'delete':
                final confirm = await FeedbackHelper.showDeleteConfirmation(
                  context,
                  title: 'Excluir Grupo Permanentemente',
                  itemName: group.label,
                  warningMessage: 'Isso também exclui TODAS as vacinas cadastradas dentro deste '
                      'grupo. Diferente de "Arquivar", esta ação NÃO pode ser desfeita. '
                      'O histórico de pacientes que já têm vacinas deste grupo continua salvo '
                      '(o nome fica registrado), mas o grupo em si não poderá ser restaurado.',
                );
                if (confirm) {
                  await ref.read(calendarGroupsProvider.notifier).deleteGroup(group.key as int);
                }
                break;
              case 'add_vaccine':
                showDialog(
                  context: context,
                  builder: (_) => VaccineFormDialog(groupKey: group.key as int),
                );
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'add_vaccine', child: Text('Adicionar vacina')),
            const PopupMenuItem(value: 'edit', child: Text('Editar grupo')),
            if (isArchived)
              const PopupMenuItem(value: 'restore', child: Text('Restaurar grupo'))
            else
              const PopupMenuItem(value: 'archive', child: Text('Arquivar grupo')),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Excluir permanentemente', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
        children: vaccines.isEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Nenhuma vacina neste grupo.', style: TextStyle(color: Colors.grey.shade500)),
                ),
              ]
            : vaccines.map((v) => _VaccineTile(vaccine: v)).toList(),
      ),
    );
  }
}

class _VaccineTile extends ConsumerWidget {
  final VaccineDefinitionModel vaccine;

  const _VaccineTile({required this.vaccine});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArchived = !vaccine.active;

    return ListTile(
      dense: true,
      title: Text(
        vaccine.name,
        style: TextStyle(
          decoration: isArchived ? TextDecoration.lineThrough : null,
          color: isArchived ? Colors.grey.shade600 : Colors.black87,
        ),
      ),
      subtitle: Text(
        '${vaccine.totalDoses} dose${vaccine.totalDoses > 1 ? 's' : ''}'
        '${vaccine.notes != null ? ' • ${vaccine.notes}' : ''}',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          switch (value) {
            case 'edit':
              showDialog(
                context: context,
                builder: (_) => VaccineFormDialog(groupKey: vaccine.groupKey, vaccineToEdit: vaccine),
              );
              break;
            case 'archive':
              final confirm = await FeedbackHelper.showConfirmation(
                context,
                title: 'Arquivar Vacina?',
                message: 'A vacina "${vaccine.name}" deixará de aparecer em novos cronogramas. '
                    'O histórico de pacientes que já a tomaram NÃO será apagado.',
                confirmText: 'Arquivar',
                confirmColor: AppColors.warning,
              );
              if (confirm) {
                await ref.read(calendarVaccinesProvider.notifier).archiveVaccine(vaccine.key as int);
              }
              break;
            case 'restore':
              await ref.read(calendarVaccinesProvider.notifier).restoreVaccine(vaccine.key as int);
              break;
            case 'delete':
              final confirm = await FeedbackHelper.showDeleteConfirmation(
                context,
                title: 'Excluir Vacina Permanentemente',
                itemName: vaccine.name,
                warningMessage: 'Diferente de "Arquivar", esta ação NÃO pode ser desfeita. '
                    'O histórico de pacientes que já tomaram esta vacina continua salvo '
                    '(o nome fica registrado), mas a vacina em si não poderá ser restaurada '
                    'no catálogo.',
              );
              if (confirm) {
                await ref.read(calendarVaccinesProvider.notifier).deleteVaccine(vaccine.key as int);
              }
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'edit', child: Text('Editar')),
          if (isArchived)
            const PopupMenuItem(value: 'restore', child: Text('Restaurar'))
          else
            const PopupMenuItem(value: 'archive', child: Text('Arquivar')),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 'delete',
            child: Text('Excluir permanentemente', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}