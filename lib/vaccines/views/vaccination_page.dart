import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/child_model.dart';
import '../models/vaccine_record_model.dart';
import '../providers/vaccination_controller.dart';
import '../../services/health_status_service.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/document_gallery_widget.dart'; 
import '../dialogs/custom_vaccine_dialog.dart';

class VaccinationPage extends ConsumerStatefulWidget {
  final ChildModel child;

  const VaccinationPage({super.key, required this.child});

  @override
  ConsumerState<VaccinationPage> createState() => _VaccinationPageState();
}

class _VaccinationPageState extends ConsumerState<VaccinationPage> {
  // 0 = Cronograma, 1 = Caderneta
  int _currentTabIndex = 0; 

  @override
  Widget build(BuildContext context) {
    final asyncChild = ref.watch(vaccinationControllerProvider(widget.child.key));

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
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTabIndex = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _currentTabIndex == 0 ? Colors.blue : Colors.white,
                  border: _currentTabIndex == 0 ? null : Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Cronograma de Vacinas', 
                  style: TextStyle(
                    color: _currentTabIndex == 0 ? Colors.white : Colors.blue, 
                    fontWeight: FontWeight.bold
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
                  color: _currentTabIndex == 1 ? Colors.blue : Colors.white,
                  border: _currentTabIndex == 1 ? null : Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Caderneta de Vacinação', 
                  style: TextStyle(
                    color: _currentTabIndex == 1 ? Colors.white : Colors.blue,
                    fontWeight: FontWeight.bold
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
    // Agrupamento de Vacinas pela regra oficial
    final groupedRules = <String, List<dynamic>>{};
    for (var rule in HealthStatusService.vaccineRules) {
      groupedRules.putIfAbsent(rule.group, () => []).add(rule);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Estrutura para ordenar: [GroupName, isCompleted, isFuture, widgets]
    final groupList = [];

    for (var entry in groupedRules.entries) {
      final groupName = entry.key;
      final rules = entry.value;

      final dueDate = HealthStatusService.calculateDueDate(currentChild.birthDate, groupName);
      final isFuture = dueDate.isAfter(today); // RF06

      bool allApplied = true;
      final vaccineCards = <Widget>[];

      for (var rule in rules) {
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
          )
        );
      }

      groupList.add({
        'name': groupName,
        'isCompleted': allApplied,
        'isFuture': isFuture,
        'cards': vaccineCards,
      });
    }

    // RF05: Organização Inteligente da Lista
    groupList.sort((a, b) {
      // 1. Grupos Concluídos vão para o final
      if (a['isCompleted'] != b['isCompleted']) {
        return a['isCompleted'] ? 1 : -1;
      }
      // 2. Grupos Futuros vão para o meio (abaixo dos pendentes, acima dos concluídos)
      if (a['isFuture'] != b['isFuture']) {
        return a['isFuture'] ? 1 : -1;
      }
      return 0; // Mantém a ordem original do calendário para os empatados
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupList.length,
      itemBuilder: (context, index) {
        final group = groupList[index];
        // 👇 1. Passamos o context e o currentChild aqui!
        return _buildGroupSection(context, group['name'], group['cards'], group['isCompleted'], currentChild);
      },
    );
  }

  Widget _buildGroupSection(BuildContext context, String groupName, List<Widget> cards, bool isCompleted, ChildModel currentChild) {
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
                  Text(groupName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => CustomVaccineDialog(
                          childKey: currentChild.key, // Passamos a chave do Hive do paciente atual
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

  const _VaccineCardWidget({
    required this.childKey,
    required this.ruleName,
    required this.groupName,
    required this.doseNumber,
    required this.dueDate,
    required this.isApplied,
    required this.isFuture,
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
            ref.read(vaccinationControllerProvider(childKey).notifier).toggleVaccine(
              groupName: groupName,
              vaccineName: ruleName,
              doseNumber: doseNumber,
            );
          },
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isApplied ? Colors.blue : (isFuture ? Colors.grey.shade300 : Colors.grey.shade700),
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
        trailing: trailingIcon != null ? Icon(trailingIcon, color: trailingColor) : null,
      ),
    );
  }
}