import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../models/nutrition_record_model.dart';
import '../providers/nutrition_report_controller.dart';
import 'nutrition_history_page.dart';
import '../models/nutrition_display_extension.dart';

class NutritionGeneralReportPage extends ConsumerWidget {
  const NutritionGeneralReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncReport = ref.watch(nutritionReportControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: asyncReport.when(
          data: (items) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Relatório Geral'),
              Text(
                '${items.length} avaliações registradas',
                style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          loading: () => const Text('Relatório Geral'),
          error: (_, __) => const Text('Relatório Geral'),
        ),
        backgroundColor: Colors.white,
      ),
      body: asyncReport.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro ao carregar relatório: $err')),
        data: (items) {
          if (items.isEmpty) return _buildEmptyState();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _ReportCardWidget(item: items[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Nenhuma avaliação encontrada no sistema.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _ReportCardWidget extends StatelessWidget {
  final NutritionReportItem item;

  const _ReportCardWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    final record = item.record;
    final child = item.child;

    final String dob = "${child.birthDate.day.toString().padLeft(2, '0')}/${child.birthDate.month.toString().padLeft(2, '0')}/${child.birthDate.year}";
    final String cpf = (child.cpf != null && child.cpf!.isNotEmpty) ? child.cpf! : "Não informado";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          iconColor: AppColors.primary,
          collapsedIconColor: Colors.grey.shade600,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          
          // 🧑 HEADER COM FOTO E DADOS DA CRIANÇA
          title: GestureDetector(
            behavior: HitTestBehavior.opaque, 
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NutritionHistoryPage(child: child),
                ),
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.infoSurface,
                  radius: 20,
                  child: Text(
                    child.name[0].toUpperCase(),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(child.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      
                      // 📌 LINHA 1: CPF (esquerda) e Data Nascimento (direita)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "📄 CPF: ${_formatCpf(cpf)}", 
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text("DN: $dob", 
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      
                      Row(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(
                                _formatAssessmentDate(record.assessmentDate),
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                            ],
                          ),
                          const Spacer(),
                          _buildAgeBadge(record.ageCategory),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 📝 RESPOSTAS EXPANSÍVEIS
          children: [
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Respostas:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  _buildAnswersGrid(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
 
  Widget _buildAnswersGrid() {
    final answers = item.record.validAnswers;

    if (answers.isEmpty) {
      return Text(
        'Nenhuma resposta registrada.',
        style: TextStyle(
          color: Colors.grey.shade600,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: answers.map((answerItem) {
        return _buildAnswerChip(
          answerItem.label,
          answerItem.answer,
        );
      }).toList(),
    );
  }

  // 🚀 ÚNICA versão do método de Chip
  Widget _buildAnswerChip(String label, dynamic answer) {
    Color iconColor;
    IconData icon;
    String text;

    switch (answer) {
      case NutritionAnswer.yes:
        iconColor = AppColors.success;
        icon = Icons.check_circle_outline;
        text = "Sim";
        break;
      case NutritionAnswer.no:
        iconColor = AppColors.error;
        icon = Icons.cancel_outlined;
        text = "Não";
        break;
      case NutritionAnswer.dontKnow:
        iconColor = AppColors.warning;
        icon = Icons.help_outline;
        text = "Não Sabe";
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      width: 140, 
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Text(text, style: TextStyle(fontSize: 12, color: iconColor, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAgeBadge(AgeCategory category) {
    String label = switch (category) {
      AgeCategory.underSixMonths => "Menor de 6 meses",
      AgeCategory.sixToTwentyThree => "6 a 23 meses",
      AgeCategory.twoToTenYears => "2 a 10 anos",
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppColors.infoSurface, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  String _formatAssessmentDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  String _formatCpf(String cpf) {
    // Remove caracteres não numéricos
    final numbers = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Se não tiver 11 dígitos, retorna o original
    if (numbers.length != 11) return cpf;
    
    // Formata como XXX.XXX.XXX-XX
    return '${numbers.substring(0, 3)}.${numbers.substring(3, 6)}.${numbers.substring(6, 9)}-${numbers.substring(9)}';
  }
}