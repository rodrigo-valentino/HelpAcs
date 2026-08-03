import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/child_model.dart';
import '../models/vaccine_record_model.dart';
import '../providers/vaccination_controller.dart';
import '../providers/calendar_controller.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/document_gallery_widget.dart';
import '../dialogs/custom_vaccine_dialog.dart';
import '../../theme/app_colors.dart';
import '../models/campaign_vaccine_model.dart';
import '../dialogs/campaign_vaccine_dialog.dart';
import '../providers/campaign_controller.dart';
import '../models/campaign_vaccine_templates.dart';

class VaccinationPage extends ConsumerStatefulWidget {
  final ChildModel child;

  const VaccinationPage({super.key, required this.child});

  @override
  ConsumerState<VaccinationPage> createState() => _VaccinationPageState();
}

class _VaccinationPageState extends ConsumerState<VaccinationPage> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final asyncChild = ref.watch(vaccinationControllerProvider(widget.child.key as int));
    // Estrutura ATIVA do calendário — dinâmica, editável pelo usuário.
    final calendarStructure = ref.watch(activeCalendarStructureProvider);

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
              Expanded(
                child: _currentTabIndex == 0
                    ? _buildVaccineTimeline(context, ref, currentChild, calendarStructure)
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

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
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
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTabIndex = 2),
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
          maxImages: 10,
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

  /// Monta o cronograma a partir do CALENDÁRIO DINÂMICO (calendarStructure),
  /// não mais da lista estática HealthStatusService.vaccineRules.
  /// Vacinas personalizadas (isCustom) são mescladas por groupKey.
  Widget _buildVaccineTimeline(
    BuildContext context,
    WidgetRef ref,
    ChildModel currentChild,
    List<VaccineGroupWithVaccines> calendarStructure,
  ) {
    final customByGroupKey = <int, List<VaccineRecord>>{};
    for (final record in currentChild.vaccines.where((r) => r.isCustom && r.groupKey != null)) {
      customByGroupKey.putIfAbsent(record.groupKey!, () => []).add(record);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final groupList = [];

    for (final groupWithVaccines in calendarStructure) {
      final groupKey = groupWithVaccines.groupKey;
      final groupLabel = groupWithVaccines.group.label;
      final dueDate = groupWithVaccines.group.calculateDueDate(currentChild.birthDate);
      final isFuture = dueDate.isAfter(today);

      bool allApplied = true;
      final vaccineCards = <Widget>[];

      // Vacinas OFICIAIS do catálogo
      for (final vaccine in groupWithVaccines.vaccines) {
        final vaccineKey = vaccine.key as int;

        for (var doseNumber = 1; doseNumber <= vaccine.totalDoses; doseNumber++) {
          final record = currentChild.vaccines
              .where((r) => r.vaccineDefinitionKey == vaccineKey && r.doseNumber == doseNumber)
              .firstOrNull;

          final isApplied = record?.applied ?? false;
          if (!isApplied) allApplied = false;

          vaccineCards.add(
            _VaccineCardWidget(
              childKey: currentChild.key,
              displayName: vaccine.name,
              groupKey: groupKey,
              vaccineDefinitionKey: vaccineKey,
              doseNumber: doseNumber,
              dueDate: dueDate,
              isApplied: isApplied,
              isFuture: isFuture,
              isCustom: false,
              observation: record?.observation,
            ),
          );
        }
      }

      // Vacinas PERSONALIZADAS vinculadas a este grupo
      final customRecords = customByGroupKey[groupKey] ?? [];
      for (final custom in customRecords) {
        if (!custom.applied) allApplied = false;

        vaccineCards.add(
          _VaccineCardWidget(
            childKey: currentChild.key,
            displayName: custom.name,
            groupKey: groupKey,
            vaccineDefinitionKey: null,
            doseNumber: custom.doseNumber,
            dueDate: dueDate,
            isApplied: custom.applied,
            isFuture: isFuture,
            isCustom: true,
            observation: custom.observation,
          ),
        );
      }

      groupList.add({
        'groupKey': groupKey,
        'name': groupLabel,
        'isCompleted': allApplied && vaccineCards.isNotEmpty,
        'isFuture': isFuture,
        'cards': vaccineCards,
      });
    }

    groupList.sort((a, b) {
      if (a['isCompleted'] != b['isCompleted']) return a['isCompleted'] ? 1 : -1;
      if (a['isFuture'] != b['isFuture']) return a['isFuture'] ? 1 : -1;
      return 0;
    });

    if (groupList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Nenhum grupo cadastrado no calendário vacinal.\n'
            'Configure o calendário em Configurações > Calendário Vacinal.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupList.length,
      itemBuilder: (context, index) {
        final group = groupList[index];
        return _buildGroupSection(
          context,
          groupKey: group['groupKey'],
          groupLabel: group['name'],
          cards: group['cards'],
          isCompleted: group['isCompleted'],
          isFutureGroup: group['isFuture'],
          currentChild: currentChild,
        );
      },
    );
  }

  Widget _buildGroupSection(
    BuildContext context, {
    required int groupKey,
    required String groupLabel,
    required List<Widget> cards,
    required bool isCompleted,
    required bool isFutureGroup,
    required ChildModel currentChild,
  }) {
    final officialCards = cards.whereType<_VaccineCardWidget>().where((c) => !c.isCustom).toList();
    final appliedCount = officialCards.where((c) => c.isApplied).length;
    final total = officialCards.length;
    final allDone = total > 0 && appliedCount == total;
    final noneDone = appliedCount == 0;

    return Opacity(
      opacity: isCompleted ? 0.6 : 1.0,
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
                    onTap: (total == 0 || (isFutureGroup && !allDone))
                        ? null
                        : () {
                            ref
                                .read(vaccinationControllerProvider(currentChild.key as int).notifier)
                                .toggleGroupVaccines(groupKey: groupKey, markAll: !allDone);
                          },
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: allDone ? AppColors.primary : Colors.white,
                        border: Border.all(
                          color: allDone ? AppColors.primary : (noneDone ? Colors.grey.shade400 : AppColors.warning),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: allDone
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : (!noneDone ? const Icon(Icons.remove, color: AppColors.warning, size: 16) : null),
                    ),
                  ),
                  Text(groupLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => CustomVaccineDialog(
                          childKey: currentChild.key as int,
                          groupKey: groupKey,
                          groupLabel: groupLabel,
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
    // Lista LIVRE: exclui os registros que pertencem aos itens PADRÃO
    // (dueAgeMonths != null), pois esses já são exibidos na seção de toggle.
    final freeList = currentChild.campaignVaccines.where((r) => r.dueAgeMonths == null).toList();
    freeList.sort((a, b) => b.year.compareTo(a.year));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        Text(
          'Vacinas padrão de campanha',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...campaignVaccineTemplates.map(
          (template) => _CampaignTemplateCard(
            childKey: currentChild.key as int,
            template: template,
            birthDate: currentChild.birthDate,
            record: currentChild.campaignVaccines
                .where((r) => r.name == template.name && r.dueAgeMonths == template.ageMonths)
                .firstOrNull,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Outras vacinas de campanha',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600),
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
        const SizedBox(height: 12),
        if (freeList.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text('Nenhuma vacina de campanha registrada.',
                  style: TextStyle(color: Colors.grey.shade500)),
            ),
          )
        else
          ...freeList.map((record) => Container(
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
              )),
      ],
    );
  }
}

/// Card de toggle para uma vacina de campanha PADRÃO (Influenza, COVID...),
/// calculada pela idade da criança. Segue o mesmo padrão visual das doses
/// oficiais do cronograma, para consistência.
class _CampaignTemplateCard extends ConsumerWidget {
  final int childKey;
  final CampaignVaccineTemplate template;
  final DateTime birthDate;
  final CampaignVaccineModel? record;

  const _CampaignTemplateCard({
    required this.childKey,
    required this.template,
    required this.birthDate,
    required this.record,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueDate = DateTime(birthDate.year, birthDate.month + template.totalMonths, birthDate.day,);
    final now = DateTime.now(); 
    final today = DateTime(now.year, now.month, now.day);
    final isFuture = dueDate.isAfter(today);
    final isApplied = record?.applied ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isApplied ? Colors.green.withAlpha(20) : (isFuture ? Colors.grey.shade50 : Colors.white),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isApplied ? Colors.green.shade300 : Colors.grey.shade300),
      ),
      child: ListTile(
        leading: InkWell(
          onTap: isFuture && !isApplied
              ? null
              : () {
                  ref.read(campaignControllerProvider).toggleTemplateVaccine(
                        childKey: childKey,
                        name: template.name,
                        ageMonths: template.totalMonths,
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
          template.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isFuture && !isApplied ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: Text(
          '${template.ageYears != null
              ? 'A partir de ${template.ageYears} anos'
              : 'A partir de ${template.ageMonths} meses'} • ${DateFormatter.format(dueDate)}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ),
    );
  }
}

/// Card visual de cada dose. Identifica a vacina/dose por
/// vaccineDefinitionKey + doseNumber (oficiais) em vez de nome/grupo em texto.
class _VaccineCardWidget extends ConsumerWidget {
  final dynamic childKey;
  final String displayName;
  final int groupKey;
  final int? vaccineDefinitionKey;
  final int doseNumber;
  final DateTime dueDate;
  final bool isApplied;
  final bool isFuture;
  final bool isCustom;
  final String? observation;

  const _VaccineCardWidget({
    required this.childKey,
    required this.displayName,
    required this.groupKey,
    required this.vaccineDefinitionKey,
    required this.doseNumber,
    required this.dueDate,
    required this.isApplied,
    required this.isFuture,
    this.isCustom = false,
    this.observation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diffDays = dueDate.difference(today).inDays;

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
          onTap: isFuture && !isApplied
              ? null
              : () {
                  if (isCustom) {
                    // Toggle de vacina personalizada fica como próximo passo
                    // (hoje o controller só cria; ver README_ETAPAS).
                    return;
                  }
                  ref.read(vaccinationControllerProvider(childKey as int).notifier).toggleVaccine(
                        vaccineDefinitionKey: vaccineDefinitionKey!,
                        groupKey: groupKey,
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
          displayName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isFuture && !isApplied ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aprazamento: ${DateFormatter.format(dueDate)}',
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
            if (observation != null && observation!.isNotEmpty)
              IconButton(
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
                          Text('Observação - $displayName',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text(observation!, style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
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