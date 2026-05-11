import 'package:flutter/foundation.dart'; // Para o debugPrint
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../vaccines/models/child_model.dart';
import '../models/nutrition_record_model.dart';
import 'nutrition_history_controller.dart';
import '../../utils/hive_keys.dart';

// 🚀 Modernização Dart 3: Enum para resultados explícitos
enum FormSaveResult { success, emptyForm, error }

// 🚀 Mudança 1: Removido o AutoDispose. O estado sobrevive a pausas do sistema.
final nutritionFormControllerProvider = NotifierProviderFamily<NutritionFormController, NutritionRecordModel, ChildModel>(() {
  return NutritionFormController();
});

class NutritionFormController extends FamilyNotifier<NutritionRecordModel, ChildModel> {
  @override
  NutritionRecordModel build(ChildModel arg) {
    final ageCategory = _determineAgeCategory(arg.ageInDays);

    return NutritionRecordModel(
      childKey: arg.key as int, 
      assessmentDate: DateTime.now(),
      ageCategory: ageCategory,
    );
  }

  AgeCategory _determineAgeCategory(int ageInDays) {
    if (ageInDays < 182) { 
      return AgeCategory.underSixMonths;
    } else if (ageInDays < 730) { 
      return AgeCategory.sixToTwentyThree;
    } else {
      return AgeCategory.twoToTenYears;
    }
  }

  void updateField(NutritionRecordModel Function(NutritionRecordModel) updater) {
    state = updater(state);
  }

  bool _hasAtLeastOneAnswer() {
    final allEnums = [
      state.breastMilk, state.porridge, state.waterTeaJuice, state.cowMilk,
      state.infantFormula, state.fruitJuiceOrMashed, state.saltFood,
      state.otherFoodsOrDrinks, state.fruit, state.otherMilk, state.porridgeWithMilk,
      state.yogurt, state.vegetables, state.orangeVegetableOrFruit,
      state.darkGreenLeaves, state.meatOrEgg, state.liver, state.beans,
      state.carbs, state.processedMeats, state.sweetenedBeverages,
      state.snacksOrCookies, state.sweets, state.eatsWatchingTv,
      state.freshFruits, state.vegetablesAndLegumes, state.instantNoodlesOrSnacks,
    ];
    
    final hasEnumAnswer = allEnums.any((a) => a != NutritionAnswer.unanswered);
    final hasFreqAnswer = state.fruitFrequency != FoodFrequency.unanswered || state.saltFoodFrequency != FoodFrequency.unanswered;
    final hasConsAnswer = state.saltFoodConsistency != FoodConsistency.unanswered;
    final hasMealAnswer = state.dailyMeals.isNotEmpty;

    return hasEnumAnswer || hasFreqAnswer || hasConsAnswer || hasMealAnswer;
  }

  // 🚀 Mudança 2: Retorno explícito e limpeza inteligente
  Future<FormSaveResult> saveRecord() async {
    try {
      if (!_hasAtLeastOneAnswer()) return FormSaveResult.emptyForm;

      final box = await Hive.openBox<NutritionRecordModel>(HiveKeys.nutritionBox);
      await box.add(state);
      
      // Atualiza o histórico
      ref.invalidate(nutritionHistoryControllerProvider(arg.key as int));
      
      // Limpa a memória DESTE formulário apenas após o sucesso
      ref.invalidateSelf(); 

      return FormSaveResult.success;
    } catch (e, stackTrace) {
      // Em um app 2024+, integramos com Crashlytics/Sentry aqui
      debugPrint('Erro crítico ao salvar no Hive: $e\n$stackTrace');
      return FormSaveResult.error;
    }
  }
}