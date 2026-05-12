import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../vaccines/models/child_model.dart';
import '../models/nutrition_record_model.dart';
import 'nutrition_history_controller.dart';
import '../../utils/hive_keys.dart';

enum FormSaveResult { success, emptyForm, error }

typedef NutritionFormKey = ({int childKey, int ageInDays});

NutritionFormKey nutritionFormKeyOf(ChildModel child) =>
    (childKey: child.key as int, ageInDays: child.ageInDays);

final nutritionFormControllerProvider =
    NotifierProviderFamily<NutritionFormController, NutritionRecordModel, NutritionFormKey>(
  () => NutritionFormController(),
);

class NutritionFormController
    extends FamilyNotifier<NutritionRecordModel, NutritionFormKey> {
  @override
  NutritionRecordModel build(NutritionFormKey arg) {
    return NutritionRecordModel(
      childKey: arg.childKey,
      assessmentDate: DateTime.now(),
      ageCategory: _determineAgeCategory(arg.ageInDays),
    );
  }

  AgeCategory _determineAgeCategory(int ageInDays) {
    if (ageInDays < 182) return AgeCategory.underSixMonths;
    if (ageInDays < 730) return AgeCategory.sixToTwentyThree;
    return AgeCategory.twoToTenYears;
  }

  void updateField(NutritionRecordModel Function(NutritionRecordModel) updater) {
    state = updater(state);
  }

  bool _hasAtLeastOneAnswer() {
    final allEnums = [
      state.breastMilk,
      state.porridge,
      state.waterTeaJuice,
      state.cowMilk,
      state.infantFormula,
      state.fruitJuiceOrMashed,
      state.saltFood,
      state.otherFoodsOrDrinks,
      state.fruitwhole,
      state.fruit,
      state.otherMilk,
      state.porridgeWithMilk,
      state.yogurt,
      state.vegetables,
      state.orangeVegetableOrFruit,
      state.darkGreenLeaves,
      state.meatOrEgg,
      state.liver,
      state.beans,
      state.carbs,
      state.processedMeats,
      state.sweetenedBeverages,
      state.snacksOrCookies,
      state.sweets,
      state.eatsWatchingTv,
      state.freshFruits,
      state.vegetablesAndLegumes,
      state.instantNoodlesOrSnacks,
    ];

    final hasEnumAnswer   = allEnums.any((a) => a != NutritionAnswer.unanswered);
    final hasFreqAnswer   = state.fruitFrequency != FoodFrequency.unanswered ||
                            state.saltFoodFrequency != FoodFrequency.unanswered;
    final hasConsAnswer   = state.saltFoodConsistency != FoodConsistency.unanswered;
    final hasMealAnswer   = state.dailyMeals.isNotEmpty;

    return hasEnumAnswer || hasFreqAnswer || hasConsAnswer || hasMealAnswer;
  }

  Future<FormSaveResult> saveRecord() async {
    try {
      if (!_hasAtLeastOneAnswer()) return FormSaveResult.emptyForm;

      final box = await Hive.openBox<NutritionRecordModel>(HiveKeys.nutritionBox);
      await box.add(state);

      ref.invalidate(nutritionHistoryControllerProvider(arg.childKey));
      ref.invalidateSelf();

      return FormSaveResult.success;
    } catch (e, stackTrace) {
      debugPrint('Erro crítico ao salvar no Hive: $e\n$stackTrace');
      return FormSaveResult.error;
    }
  }
}