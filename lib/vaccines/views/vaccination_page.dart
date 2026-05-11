import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/child_model.dart';
import '../models/vaccine_record_model.dart';
import '../providers/vaccination_controller.dart';
import '../../services/health_status_service.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/document_gallery_widget.dart'; 
import '../dialogs/custom_vaccine_dialog.dart';
import '../../theme/app_colors.dart';
import '../models/campaign_vaccine_model.dart';
import '../dialogs/campaign_vaccine_dialog.dart';
import '../providers/campaign_controller.dart';

class VaccinationPage extends ConsumerStatefulWidget {
  final ChildModel child;

  const VaccinationPage({super.key, required this.child});

  @override
  ConsumerState<VaccinationPage> createState() => _VaccinationPageState();
}

class _VaccinationPageState extends ConsumerState<VaccinationPage> {
  // 0 = Cronograma, 1 = Caderneta 2 = Campanhas
  int _currentTabIndex = 0; 

  @override
  Widget build(BuildContext context) {
    final asyncChild = ref.watch(vaccinationControllerProvider(widget.child.key as int));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Acompanhamento'),
        centerTitle: true,
      ),
      body: asyncChild.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
        data: (currentChild) {
          return Column(
            children: [
              _buildPatientHeader(currentChild),
              
              _buildTabs(),

              // O conteúdo muda dependendo da aba selecionada
              Expanded(
                child: _currentTabIndex == 0
                    ? _buildVaccineTimeline(context, ref, currentChild)
                    : _currentTabIndex == 1
                        ? _buildCampaignsView(currentChild)
                        : _buildCadernetaView(currentChild),
              ),
            ],
          );
        },
      ),
    );
  }

 // --- Abas Clicáveis ---
  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 1. Aba: Cronograma (Index 0)
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTabIndex = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _currentTabIndex == 0 ? AppColors.primary : Colors.white,
                  border: _currentTabIndex == 0 ? null : Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Cronograma', 
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _currentTabIndex == 0 ? Colors.white : AppColors.primary, 
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 2. Aba: Campanhas (Index 1) - NOVA ABA
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTabIndex = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _currentTabIndex == 1 ? AppColors.primary : Colors.white,
                  border: _currentTabIndex == 1 ? null : Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Campanhas', 
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _currentTabIndex == 1 ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 3. Aba: Caderneta (Index 2)
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTabIndex = 2), // Atualizado para index 2
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _currentTabIndex == 2 ? AppColors.primary : Colors.white,
                  border: _currentTabIndex == 2 ? null : Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Caderneta', 
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _currentTabIndex == 2 ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- O Seu Widget Genérico em Ação ---
  Widget _buildCadernetaView(ChildModel currentChild) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: DocumentGalleryWidget(
          title: "Fotos da Caderneta",
          imagePaths: currentChild.imagePaths,
          maxImages: 10, // Um número razoável para várias páginas da caderneta
          onAddImage: (path) {
            ref.read(vaccinationControllerProvider(currentChild.key).notifier).addImage(path);
          },
          onRemoveImage: (index) {
            ref.read(vaccinationControllerProvider(currentChild.key).notifier).removeImage(index);
          },
        ),
      ),
    );
  }

  Widget _buildPatientHeader(ChildModel currentChild) {
    // Construa o Card branco com o Nome, Idade e o Badge de Status igual ao seu design
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentChild.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              // Aqui você pode reutilizar o seu _buildStatusBadge que já fez na lista!
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${DateFormatter.format(currentChild.birthDate)} (${currentChild.ageLabel})',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVaccineTimeline(BuildContext context, WidgetRef ref, ChildModel currentChild) {
    // 1. Agrupa as regras oficiais do calendário
    final groupedRules = <String, List<VaccineRule>>{};
    for (var rule in HealthStatusService.vaccineRules) {
      groupedRules.putIfAbsent(rule.group, () => []).add(rule);
    }

    // ✅ 2. Agrupa as vacinas personalizadas da criança (BUG 1 Corrigido)
    final customByGroup = <String, List<VaccineRecord>>{};
    for (final record in currentChild.vaccines.where((r) => r.isCustom)) {
      customByGroup.putIfAbsent(record.group, () => []).add(record);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final groupList = [];

    // ✅ 3. Une todos os grupos (oficiais + customizados)
    final allGroups = {...groupedRules.keys, ...customByGroup.keys}.toList();

    for (final groupName in allGroups) {
      final officialRules = groupedRules[groupName] ?? [];
      final customRecords = customByGroup[groupName] ?? [];

      final dueDate = HealthStatusService.calculateDueDate(currentChild.birthDate, groupName);
      final isFuture = dueDate.isAfter(today);

      bool allApplied = true;
      final vaccineCards = <Widget>[];

      // Renderiza as vacinas OFICIAIS
      for (var rule in officialRules) {
        final record = currentChild.vaccines.firstWhere(
          (r) => r.name == rule.name && r.doseNumber == rule.doseNumber && r.group == groupName,
          orElse: () => VaccineRecord(name: rule.name, doseNumber: rule.doseNumber, group: groupName),
        );

        if (!record.applied) allApplied = false;

        vaccineCards.add(
          _VaccineCardWidget(
            childKey: currentChild.key,
            ruleName: rule.name,
            groupName: groupName,
            doseNumber: rule.doseNumber,
            dueDate: dueDate,
            isApplied: record.applied,
            isFuture: isFuture,
            isCustom: false,
          )
        );
      }

      // ✅ Renderiza as vacinas PERSONALIZADAS
      for (var custom in customRecords) {
        if (!custom.applied) allApplied = false;

        vaccineCards.add(
          _VaccineCardWidget(
            childKey: currentChild.key,
            ruleName: custom.name,
            groupName: custom.group,
            doseNumber: custom.doseNumber,
            dueDate: dueDate, // Usa a mesma data base do grupo
            isApplied: custom.applied,
            isFuture: isFuture,
            isCustom: true,
          )
        );
      }

      groupList.add({
        'name': groupName,
        'isCompleted': allApplied && vaccineCards.isNotEmpty, // Garante que grupos vazios não fiquem "completos"
        'isFuture': isFuture,
        'cards': vaccineCards,
      });
    }

    groupList.sort((a, b) {
      if (a['isCompleted'] != b['isCompleted']) return a['isCompleted'] ? 1 : -1;
      if (a['isFuture'] != b['isFuture']) return a['isFuture'] ? 1 : -1;
      return 0; 
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupList.length,
      itemBuilder: (context, index) {
        final group = groupList[index];
        return _buildGroupSection(context, group['name'], group['cards'], group['isCompleted'], group['isFuture'], currentChild);
      },
    );
  }

  Widget _buildGroupSection(BuildContext context, String groupName, List<Widget> cards, bool isCompleted, bool isFutureGroup, ChildModel currentChild) {
   
    final officialCards = cards.whereType<_VaccineCardWidget>().where((c) => !c.isCustom).toList();
    final appliedCount = officialCards.where((c) => c.isApplied).length;
    final total = officialCards.length;
    final allDone = total > 0 && appliedCount == total;
    final noneDone = appliedCount == 0;
   
    return Opacity(
      opacity: isCompleted ? 0.6 : 1.0, // Suaviza o grupo inteiro se estiver finalizado
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                        onTap: (total == 0 || (isFutureGroup && !allDone)) ? null : () {
                          ref.read(vaccinationControllerProvider(currentChild.key as int).notifier)
                             .toggleGroupVaccines(groupName: groupName, markAll: !allDone);
                        },
                    child: Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        color: allDone ? AppColors.primary : Colors.white,
                        border: Border.all(
                          color: allDone ? AppColors.primary : (noneDone ? Colors.grey.shade400 : AppColors.warning),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: allDone ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : (!noneDone ? const Icon(Icons.remove, color: AppColors.warning, size: 16) : null),
                    ),
                  ),
                  Text(groupName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => CustomVaccineDialog(
                          childKey: currentChild.key as int, // Passamos a chave do Hive do paciente atual
                          groupName: groupName,       // Passamos o grupo (ex: "2 meses")
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Adicionar vacina'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...cards,
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignsView(ChildModel currentChild) {
    // Ordena da mais recente para a mais antiga
    final list = List<CampaignVaccineModel>.from(currentChild.campaignVaccines);
    list.sort((a, b) => b.year.compareTo(a.year));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vacinas de campanhas anuais e sazonais',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              FilledButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => CampaignVaccineDialog(childKey: currentChild.key as int),
                  );
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Nova Vacina'),
              ),
            ],
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? Center(
                  child: Text('Nenhuma vacina de campanha registrada.',
                      style: TextStyle(color: Colors.grey.shade500)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final record = list[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.vaccines, color: AppColors.primary),
                        title: Text(record.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Ano: ${record.year}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            ref.read(campaignControllerProvider).deleteCampaignVaccine(
                              childKey: currentChild.key as int,
                              record: record,
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// RV01: O Card Visual de cada Vacina
class _VaccineCardWidget extends ConsumerWidget {
  final dynamic childKey;
  final String ruleName;
  final String groupName;
  final int doseNumber;
  final DateTime dueDate;
  final bool isApplied;
  final bool isFuture;
  final bool isCustom;

  const _VaccineCardWidget({
    required this.childKey,
    required this.ruleName,
    required this.groupName,
    required this.doseNumber,
    required this.dueDate,
    required this.isApplied,
    required this.isFuture,
    this.isCustom = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diffDays = dueDate.difference(today).inDays;

    // Definição das Cores baseada no status (RV01)
    Color borderColor = Colors.grey.shade300;
    Color bgColor = Colors.white;
    IconData? trailingIcon;
    Color trailingColor = Colors.transparent;

    if (isApplied) {
      borderColor = Colors.green.shade300;
      bgColor = Colors.green.withAlpha(20);
      trailingIcon = Icons.check_circle_outline;
      trailingColor = Colors.green;
    } else if (isFuture) {
      bgColor = Colors.grey.shade50;
    } else if (diffDays < 0) {
      borderColor = Colors.red.shade300;
      bgColor = Colors.red.withAlpha(20);
      trailingIcon = Icons.error_outline;
      trailingColor = Colors.red;
    } else if (diffDays <= 3) {
      borderColor = Colors.orange.shade300;
      bgColor = Colors.orange.withAlpha(20);
      trailingIcon = Icons.access_time;
      trailingColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: ListTile(
        leading: InkWell(
          onTap: isFuture && !isApplied ? null : () {
            // Chama o método para alterar o status da vacina
            ref.read(vaccinationControllerProvider(childKey as int).notifier).toggleVaccine(
              groupName: groupName,
              vaccineName: ruleName,
              doseNumber: doseNumber,
            );
          },
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isApplied ? AppColors.primary : (isFuture ? Colors.grey.shade300 : Colors.grey.shade700),
              borderRadius: BorderRadius.circular(4),
            ),
            child: isApplied ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
          ),
        ),
        title: Text(
          ruleName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isFuture && !isApplied ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$doseNumberª dose', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 2),
            Text(
              'Vencimento: ${DateFormatter.format(dueDate)}',
              style: TextStyle(
                color: (diffDays < 0 && !isApplied) ? Colors.red : Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Precisamos buscar o record real na lista para ver se tem observação
            Builder(
              builder: (context) {
                final child = ref.watch(vaccinationControllerProvider(childKey as int)).valueOrNull;
                final record = child?.vaccines.where((r) => r.name == ruleName && r.group == groupName && r.doseNumber == doseNumber).firstOrNull;
                
                if (record?.observation != null && record!.observation!.isNotEmpty) {
                  return IconButton(
                    icon: Icon(Icons.info_outline, color: AppColors.primary, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Observação - $ruleName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Text(record.observation!, style: const TextStyle(fontSize: 16)),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              }
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 12),
              Icon(trailingIcon, color: trailingColor),
            ]
          ],
        ),
      ),
    );
  }
}