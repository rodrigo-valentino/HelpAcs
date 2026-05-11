import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../vaccines/models/child_model.dart';
import '../../theme/app_colors.dart';
import '../../utils/feedback_helper.dart';
import '../models/nutrition_record_model.dart';
import '../providers/nutrition_form_controller.dart';

class NutritionFormPage extends ConsumerStatefulWidget {
  final ChildModel child;

  const NutritionFormPage({super.key, required this.child});

  @override
  ConsumerState<NutritionFormPage> createState() => _NutritionFormPageState();
}

class _NutritionFormPageState extends ConsumerState<NutritionFormPage> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final recordState = ref.watch(nutritionFormControllerProvider(widget.child));
    final controller = ref.read(nutritionFormControllerProvider(widget.child).notifier);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await FeedbackHelper.showDeleteConfirmation(
          context,
          title: 'Sair sem salvar?',
          itemName: 'todo o progresso desta avaliação',
        );
        if (context.mounted && shouldPop) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Consumo Alimentar'),
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: [
            _buildHeaderInfo(recordState.ageCategory),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (recordState.ageCategory == AgeCategory.underSixMonths)
                      _buildUnderSixMonthsSection(recordState, controller),
                    if (recordState.ageCategory == AgeCategory.sixToTwentyThree)
                      _buildSixToTwentyThreeMonthsSection(recordState, controller),
                    if (recordState.ageCategory == AgeCategory.twoToTenYears)
                      _buildTwoToTenYearsSection(recordState, controller),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildSaveButton(context, controller),
          ],
        ),
      ),
    );
  }

  // ========================================
  // 🍼 FAIXA 1: Menores de 6 Meses
  // ========================================
  Widget _buildUnderSixMonthsSection(NutritionRecordModel state, NutritionFormController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestionRow('Leite do peito?', state.breastMilk, (val) => controller.updateField((s) => s.copyWith(breastMilk: val))),
        _buildQuestionRow('Mingau?', state.porridge, (val) => controller.updateField((s) => s.copyWith(porridge: val))),
        _buildQuestionRow('Água, chá ou suco?', state.waterTeaJuice, (val) => controller.updateField((s) => s.copyWith(waterTeaJuice: val))),
        _buildQuestionRow('Leite de vaca/caixinha?', state.cowMilk, (val) => controller.updateField((s) => s.copyWith(cowMilk: val))),
        _buildQuestionRow('Fórmula infantil?', state.infantFormula, (val) => controller.updateField((s) => s.copyWith(infantFormula: val))),
        _buildQuestionRow('Suco de fruta ou papinha?', state.fruitJuiceOrMashed, (val) => controller.updateField((s) => s.copyWith(fruitJuiceOrMashed: val))),
        _buildQuestionRow('Fruta?', state.fruitwhole, (val) => controller.updateField((s) => s.copyWith(fruitwhole: val))),
        _buildQuestionRow('Comida de sal (sopa/janta)?', state.saltFood, (val) => controller.updateField((s) => s.copyWith(saltFood: val))),
        _buildQuestionRow('Outros alimentos/bebidas?', state.otherFoodsOrDrinks, (val) => controller.updateField((s) => s.copyWith(otherFoodsOrDrinks: val))),
      ],
    );
  }

  // ========================================
  // 🥄 FAIXA 2: 6 a 23 Meses
  // ========================================
  Widget _buildSixToTwentyThreeMonthsSection(NutritionRecordModel state, NutritionFormController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Parte 1 — Alimentação Principal", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        const Divider(),
        const SizedBox(height: 16),
        _buildQuestionRow('Ontem a criança tomou leite do peito?', state.breastMilk, (val) => controller.updateField((s) => s.copyWith(breastMilk: val))),
        _buildQuestionRow('Ontem a criança comeu fruta inteira/amassada?', state.fruit, (val) => controller.updateField((s) => s.copyWith(fruit: val))),
        
        if (state.fruit == NutritionAnswer.yes)
          _buildFrequencyOptions('Quantas vezes comeu fruta?', state.fruitFrequency, (val) => controller.updateField((s) => s.copyWith(fruitFrequency: val))),

        _buildQuestionRow('Ontem a criança comeu comida de sal?', state.saltFood, (val) => controller.updateField((s) => s.copyWith(saltFood: val))),
        
        if (state.saltFood == NutritionAnswer.yes) ...[
          _buildFrequencyOptions('Quantas vezes comeu comida de sal?', state.saltFoodFrequency, (val) => controller.updateField((s) => s.copyWith(saltFoodFrequency: val))),
          _buildConsistencyOptions('Qual a consistência?', state.saltFoodConsistency, (val) => controller.updateField((s) => s.copyWith(saltFoodConsistency: val))),
        ],

        const SizedBox(height: 24),
        const Text("Parte 2 — Consumo Alimentar", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        const Divider(),
        const SizedBox(height: 16),
        _buildQuestionRow('Outro leite?', state.otherMilk, (val) => controller.updateField((s) => s.copyWith(otherMilk: val))),
        _buildQuestionRow('Mingau com leite?', state.porridgeWithMilk, (val) => controller.updateField((s) => s.copyWith(porridgeWithMilk: val))),
        _buildQuestionRow('Iogurte?', state.yogurt, (val) => controller.updateField((s) => s.copyWith(yogurt: val))),
        _buildQuestionRow('Legumes?', state.vegetables, (val) => controller.updateField((s) => s.copyWith(vegetables: val))),
        _buildQuestionRow('Vegetal/fruta alaranjada ou folhas verdes?', state.orangeVegetableOrFruit, (val) => controller.updateField((s) => s.copyWith(orangeVegetableOrFruit: val))), // 🚀 Novo campo na UI
        _buildQuestionRow('Verdura de folha?', state.darkGreenLeaves, (val) => controller.updateField((s) => s.copyWith(darkGreenLeaves: val))), // 🚀 Novo campo na UI
        _buildQuestionRow('Carne ou ovo?', state.meatOrEgg, (val) => controller.updateField((s) => s.copyWith(meatOrEgg: val))),
        _buildQuestionRow('Fígado?', state.liver, (val) => controller.updateField((s) => s.copyWith(liver: val))), // 🚀 Novo campo na UI
        _buildQuestionRow('Feijão?', state.beans, (val) => controller.updateField((s) => s.copyWith(beans: val))),
        _buildQuestionRow('Arroz, batata, macarrão?', state.carbs, (val) => controller.updateField((s) => s.copyWith(carbs: val))), // 🚀 Novo campo na UI
        _buildQuestionRow('Hambúrguer/Embutidos?', state.processedMeats, (val) => controller.updateField((s) => s.copyWith(processedMeats: val))),
        _buildQuestionRow('Bebidas adoçadas?', state.sweetenedBeverages, (val) => controller.updateField((s) => s.copyWith(sweetenedBeverages: val))),
        _buildQuestionRow('Salgadinhos/Biscoitos?', state.snacksOrCookies, (val) => controller.updateField((s) => s.copyWith(snacksOrCookies: val))), // 🚀 Novo campo na UI
        _buildQuestionRow('Doces/Guloseimas?', state.sweets, (val) => controller.updateField((s) => s.copyWith(sweets: val))),
      ],
    );
  }

  // ========================================
  // 🧒 FAIXA 3: 2 a 10 Anos
  // ========================================
  Widget _buildTwoToTenYearsSection(NutritionRecordModel state, NutritionFormController controller) {
    final meals = ['Café da Manhã', 'Lanche Manhã', 'Almoço', 'Lanche Tarde', 'Jantar', 'Ceia'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Parte 1 — Hábitos e Refeições", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        const Divider(),
        const SizedBox(height: 16),
        _buildQuestionRow('Come assistindo TV/Celular?', state.eatsWatchingTv, (val) => controller.updateField((s) => s.copyWith(eatsWatchingTv: val))),
        
        const Text('Quais refeições fez ontem?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: meals.map((meal) {
            final isSelected = state.dailyMeals.contains(meal);
            return FilterChip(
              label: Text(meal, style: TextStyle(fontSize: 12, color: isSelected ? AppColors.primary : Colors.black87)),
              selected: isSelected,
              selectedColor: AppColors.infoSurface,
              checkmarkColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onSelected: (selected) {
                final list = List<String>.from(state.dailyMeals);
                selected ? list.add(meal) : list.remove(meal);
                controller.updateField((s) => s.copyWith(dailyMeals: list));
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 32),
        const Text("Parte 3 — Consumo Alimentar", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        const Divider(),
        const SizedBox(height: 16),
        _buildQuestionRow('Feijão?', state.beans, (val) => controller.updateField((s) => s.copyWith(beans: val))),
        _buildQuestionRow('Frutas frescas?', state.freshFruits, (val) => controller.updateField((s) => s.copyWith(freshFruits: val))),
        _buildQuestionRow('Verduras e/ou legumes?', state.vegetablesAndLegumes, (val) => controller.updateField((s) => s.copyWith(vegetablesAndLegumes: val))),
        _buildQuestionRow('Hambúrguer/Embutidos?', state.processedMeats, (val) => controller.updateField((s) => s.copyWith(processedMeats: val))),
        _buildQuestionRow('Bebidas adoçadas?', state.sweetenedBeverages, (val) => controller.updateField((s) => s.copyWith(sweetenedBeverages: val))),
        _buildQuestionRow('Macarrão instantâneo/Salgadinhos?', state.instantNoodlesOrSnacks, (val) => controller.updateField((s) => s.copyWith(instantNoodlesOrSnacks: val))),
        _buildQuestionRow('Doces/Guloseimas?', state.sweets, (val) => controller.updateField((s) => s.copyWith(sweets: val))),
      ],
    );
  }

  // ========================================
  // 🔘 WIDGETS DE OPÇÕES (ATUALIZADOS)
  // ========================================
  Widget _buildConsistencyOptions(String label, FoodConsistency currentValue, ValueChanged<FoodConsistency> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.primary)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              _buildOptionBtnSmall('Pedaços', currentValue == FoodConsistency.pieces, () => onChanged(FoodConsistency.pieces)),
              _buildOptionBtnSmall('Amassada', currentValue == FoodConsistency.mashed, () => onChanged(FoodConsistency.mashed)),
              _buildOptionBtnSmall('Peneirada', currentValue == FoodConsistency.sieved, () => onChanged(FoodConsistency.sieved)), // 🚀 Novo
              _buildOptionBtnSmall('Liquidificada', currentValue == FoodConsistency.blended, () => onChanged(FoodConsistency.blended)), // 🚀 Novo
              _buildOptionBtnSmall('Só o caldo', currentValue == FoodConsistency.onlyBroth, () => onChanged(FoodConsistency.onlyBroth)),
              _buildOptionBtnSmall('Não sabe', currentValue == FoodConsistency.unanswered, () => onChanged(FoodConsistency.unanswered)), // 🚀 Novo
            ],
          )
        ],
      ),
    );
  }

  // ... (Mantenha os outros métodos auxiliares _buildQuestionRow, _buildHeaderInfo, etc.)
  
  Widget _buildOptionBtnSmall(String text, bool isSelected, VoidCallback onTap) {
     return SizedBox(
       width: 140,
       child: _buildOptionButton(text, null, null, isSelected, onTap),
     );
  }

  Widget _buildQuestionRow(String label, NutritionAnswer currentValue, ValueChanged<NutritionAnswer> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildOptionButton('Sim', Icons.check, NutritionAnswer.yes, currentValue == NutritionAnswer.yes, () => onChanged(NutritionAnswer.yes))),
              const SizedBox(width: 8),
              Expanded(child: _buildOptionButton('Não', Icons.remove, NutritionAnswer.no, currentValue == NutritionAnswer.no, () => onChanged(NutritionAnswer.no))),
              const SizedBox(width: 8),
              Expanded(child: _buildOptionButton('N. Sabe', Icons.help_outline, NutritionAnswer.dontKnow, currentValue == NutritionAnswer.dontKnow, () => onChanged(NutritionAnswer.dontKnow))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFrequencyOptions(String label, FoodFrequency currentValue, ValueChanged<FoodFrequency> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.primary)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildOptionButton('1x', null, null, currentValue == FoodFrequency.once, () => onChanged(FoodFrequency.once))),
              const SizedBox(width: 8),
              Expanded(child: _buildOptionButton('2x', null, null, currentValue == FoodFrequency.twice, () => onChanged(FoodFrequency.twice))),
              const SizedBox(width: 8),
              Expanded(child: _buildOptionButton('3x+', null, null, currentValue == FoodFrequency.threeOrMore, () => onChanged(FoodFrequency.threeOrMore))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildOptionButton(String text, IconData? icon, dynamic value, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 16, color: isSelected ? AppColors.primary : AppColors.textSecondary), const SizedBox(width: 6)],
            Text(text, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppColors.primary : AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(AgeCategory category) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.infoSurface, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.infoContainer,
                  child: Text(widget.child.name[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.child.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(widget.child.ageLabel, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(category.label, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text("A criança ONTEM consumiu:", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, NutritionFormController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, -5))]),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: _isSaving ? null : () async {
              setState(() => _isSaving = true);
              
              final result = await controller.saveRecord();
              
              // ✅ Verifica o contexto ESPECÍFICO antes de qualquer operação
              if (!context.mounted) return;
              
              setState(() => _isSaving = false);

              // 🚀 Dart 3 Pattern Matching para UI/UX
              switch (result) {
                case FormSaveResult.success:
                  FeedbackHelper.showSuccess(context, 'Avaliação salva com sucesso!');
                  if (context.mounted) Navigator.pop(context);
                  break;
                case FormSaveResult.emptyForm:
                  FeedbackHelper.showError(context, 'Preencha pelo menos um campo para salvar.');
                  break;
                case FormSaveResult.error:
                  FeedbackHelper.showError(context, 'Falha no banco de dados. Tente novamente.');
                  break;
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSaving 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Salvar Avaliação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ),
    );
  }
}