import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../vaccines/models/child_model.dart';
import '../models/nutrition_record_model.dart';
import 'nutrition_history_controller.dart';
import '../../utils/hive_keys.dart';

enum FormSaveResult { success, incomplete, error }

class SaveResult {
  final FormSaveResult status;
  final List<String> missingFields;
  const SaveResult(this.status, [this.missingFields = const []]);
}

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

  List<String> _getMissingFields() {
    final missing = <String>[];

    void check(String label, dynamic answer) {
      if (answer == NutritionAnswer.unanswered ||
          answer == FoodFrequency.unanswered ||
          answer == FoodConsistency.unanswered) {
        missing.add(label);
      }
    }

    switch (state.ageCategory) {
      case AgeCategory.underSixMonths:
        check('Leite do peito', state.breastMilk);
        check('Mingau', state.porridge);
        check('Água, chá ou suco', state.waterTeaJuice);
        check('Leite de vaca/caixinha', state.cowMilk);
        check('Fórmula infantil', state.infantFormula);
        check('Suco de fruta ou papinha', state.fruitJuiceOrMashed);
        check('Fruta', state.fruitwhole);
        check('Comida de sal', state.saltFood);
        check('Outros alimentos/bebidas', state.otherFoodsOrDrinks);
        break;

      case AgeCategory.sixToTwentyThree:
        check('Leite do peito', state.breastMilk);
        check('Fruta', state.fruit);
        if (state.fruit == NutritionAnswer.yes) {
          check('Frequência (Fruta)', state.fruitFrequency);
        }
        check('Comida de sal', state.saltFood);
        if (state.saltFood == NutritionAnswer.yes) {
          check('Frequência (Sal)', state.saltFoodFrequency);
          check('Consistência (Sal)', state.saltFoodConsistency);
        }
        check('Outro leite', state.otherMilk);
        check('Mingau com leite', state.porridgeWithMilk);
        check('Iogurte', state.yogurt);
        check('Legumes', state.vegetables);
        check('Vegetal/fruta alaranjada ou folhas verdes', state.orangeVegetableOrFruit);
        check('Verdura de folha', state.darkGreenLeaves);
        check('Carne ou ovo', state.meatOrEgg);
        check('Fígado', state.liver);
        check('Feijão', state.beans);
        check('Arroz, batata, macarrão', state.carbs);
        check('Hambúrguer/Embutidos', state.processedMeats);
        check('Bebidas adoçadas', state.sweetenedBeverages);
        check('Salgadinhos/Biscoitos', state.snacksOrCookies);
        check('Doces/Guloseimas', state.sweets);
        break;

      case AgeCategory.twoToTenYears:
        check('Assistindo TV/Celular', state.eatsWatchingTv);
        if (state.dailyMeals.isEmpty) missing.add('Refeições realizadas');
        check('Feijão', state.beans);
        check('Frutas frescas', state.freshFruits);
        check('Verduras e/ou legumes', state.vegetablesAndLegumes);
        check('Hambúrguer/Embutidos', state.processedMeats);
        check('Bebidas adoçadas', state.sweetenedBeverages);
        check('Macarrão instantâneo/Salgadinhos', state.instantNoodlesOrSnacks);
        check('Doces/Guloseimas', state.sweets);
        break;
    }

    return missing;
  }

  Future<SaveResult> saveRecord() async {
    try {
      final missing = _getMissingFields();
      if (missing.isNotEmpty) {
        return SaveResult(FormSaveResult.incomplete, missing);
      }

      final box = await Hive.openBox<NutritionRecordModel>(HiveKeys.nutritionBox);
      await box.add(state);

      ref.invalidate(nutritionHistoryControllerProvider(arg.childKey));
      ref.invalidateSelf();

      return const SaveResult(FormSaveResult.success);
    } catch (e, stackTrace) {
      debugPrint('Erro crítico ao salvar no Hive: $e\n$stackTrace');
      return const SaveResult(FormSaveResult.error);
    }
  }
}