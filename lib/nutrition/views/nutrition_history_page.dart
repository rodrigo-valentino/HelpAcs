import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../vaccines/models/child_model.dart';
import '../../theme/app_colors.dart';
import '../../utils/feedback_helper.dart'; // Assumindo que você tem o seu FeedbackHelper
import '../models/nutrition_record_model.dart';
import '../providers/nutrition_history_controller.dart';
import 'nutrition_form_page.dart'; 
import '../models/nutrition_display_extension.dart';

class NutritionHistoryPage extends ConsumerWidget {
  final ChildModel child;

  const NutritionHistoryPage({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuta apenas o histórico desta criança
    final asyncHistory = ref.watch(nutritionHistoryControllerProvider(child.key));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Histórico Alimentar'),
            Text(
              child.name,
              style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      body: asyncHistory.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro ao carregar histórico: $err')),
        data: (records) {
          if (records.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final record = records[index];
              return _HistoryCardWidget(
                record: record, 
                onDelete: () => _confirmDelete(context, ref, record),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NutritionFormPage(child: child)),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nova Avaliação'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Nenhuma avaliação registrada\npara ${child.name}.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, NutritionRecordModel record) async {
    // Utilizando o seu FeedbackHelper padrão
    final confirm = await FeedbackHelper.showDeleteConfirmation(
      context,
      title: 'Excluir Avaliação',
      itemName: 'esta avaliação alimentar',
    );

    if (confirm) {
      final success = await ref.read(nutritionHistoryControllerProvider(child.key).notifier).deleteRecord(record.key);
      if (context.mounted && success) {
        FeedbackHelper.showSuccess(context, 'Avaliação removida com sucesso!');
      } else if (context.mounted) {
        FeedbackHelper.showError(context, 'Erro ao remover avaliação.');
      }
    }
  }
}

// ========================================
// 🧩 WIDGET: CARD DE HISTÓRICO EXPANSÍVEL
// ========================================
class _HistoryCardWidget extends StatelessWidget {
  final NutritionRecordModel record;
  final VoidCallback onDelete;

  const _HistoryCardWidget({required this.record, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          shape: const Border(), // Remove bordas nativas do ExpansionTile
          collapsedShape: const Border(),
          iconColor: AppColors.primary,
          collapsedIconColor: Colors.grey.shade600,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.restaurant_menu, color: AppColors.primary, size: 24),
          ),
          title: Text(
            _formatDate(record.assessmentDate),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            _getAgeCategoryLabel(record.ageCategory),
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          children: [
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Respostas:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  _buildAnswersList(),
                  const SizedBox(height: 16),
                  
                  // Botão de deletar no final do card expandido
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                      label: const Text('Excluir', style: TextStyle(color: AppColors.error)),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Renderiza as respostas baseadas na faixa etária
  Widget _buildAnswersList() {
    final validAnswers = record.validAnswers; // Usa a extension

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: validAnswers.map((item) {
        // Se for String (ex: a lista de refeições unidas)
        if (item.answer is String) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 8),
            child: Text('${item.label}: ${item.answer}', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
          );
        }
        
        // Se for Enum (Sim, Não, N. Sabe, Frequencia, Consistencia)
        return _buildAnswerRow(item.label, item.answer);
      }).toList(),
    );
  }

  // Ajustamos para receber dynamic, pois pode ser NutritionAnswer, FoodFrequency ou FoodConsistency
  Widget _buildAnswerRow(String label, dynamic answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: TextStyle(color: Colors.grey.shade700))),
          _buildBadge(answer),
        ],
      ),
    );
  }

  // Tratamos a exibição das novas categorias
  Widget _buildBadge(dynamic answer) {
    Color bgColor = AppColors.infoSurface;
    Color textColor = AppColors.primary;
    String text = '';

    if (answer is NutritionAnswer) {
      if (answer == NutritionAnswer.yes) {
        bgColor = AppColors.successSurface; textColor = AppColors.success; text = "Sim";
      } else if (answer == NutritionAnswer.no) {
        bgColor = AppColors.errorSurface; textColor = AppColors.error; text = "Não";
      } else if (answer == NutritionAnswer.dontKnow) {
        bgColor = AppColors.warningSurface; textColor = Colors.orange.shade900; text = "?";
      }
    } else if (answer is FoodFrequency) {
      text = switch (answer) {
        FoodFrequency.once => "1x",
        FoodFrequency.twice => "2x",
        FoodFrequency.threeOrMore => "3x+",
        FoodFrequency.unanswered => "",
      };
    } else if (answer is FoodConsistency) {
       text = switch (answer) {
        FoodConsistency.pieces => "Pedaços",
        FoodConsistency.mashed => "Amassada",
        FoodConsistency.sieved => "Peneirada",
        FoodConsistency.blended => "Liquidif.",
        FoodConsistency.onlyBroth => "Só Caldo",
        FoodConsistency.unanswered => "",
      };
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: textColor.withAlpha(50))),
      child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  String _getAgeCategoryLabel(AgeCategory category) {
    switch (category) {
      case AgeCategory.underSixMonths: return "Menor de 6 meses";
      case AgeCategory.sixToTwentyThree: return "6 a 23 meses";
      case AgeCategory.twoToTenYears: return "2 a 10 anos";
    }
  }
}