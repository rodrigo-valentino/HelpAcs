import '../models/nutrition_record_model.dart';

class NutritionDisplayItem {
  final String label;
  final dynamic answer;

  NutritionDisplayItem({required this.label, required this.answer});
}

extension NutritionRecordDisplay on NutritionRecordModel {
  List<NutritionDisplayItem> get validAnswers {
    final List<NutritionDisplayItem> list = [];

    void addIfAnswered(String label, dynamic answer) {
      if (answer == NutritionAnswer.unanswered || 
          answer == FoodFrequency.unanswered || 
          answer == FoodConsistency.unanswered) {
        return;
      }
      if (answer is List && answer.isEmpty) return;
      
      list.add(NutritionDisplayItem(label: label, answer: answer));
    }

    if (ageCategory == AgeCategory.underSixMonths) {
      addIfAnswered('Leite do peito', breastMilk);
      addIfAnswered('Mingau', porridge);
      addIfAnswered('Água, chá ou suco', waterTeaJuice);
      addIfAnswered('Leite de vaca/caixinha', cowMilk);
      addIfAnswered('Fórmula infantil', infantFormula);
      addIfAnswered('Suco de fruta ou papinha', fruitJuiceOrMashed);
      addIfAnswered('Fruta', fruitwhole);
      addIfAnswered('Comida de sal', saltFood);
      addIfAnswered('Outros alimentos', otherFoodsOrDrinks);
    } 
    else if (ageCategory == AgeCategory.sixToTwentyThree) {
      addIfAnswered('Leite Materno', breastMilk);
      addIfAnswered('Fruta', fruit);
      if (fruit == NutritionAnswer.yes) addIfAnswered('Frequência (Fruta)', fruitFrequency);
      
      addIfAnswered('Comida de Sal', saltFood);
      if (saltFood == NutritionAnswer.yes) {
        addIfAnswered('Frequência (Sal)', saltFoodFrequency);
        addIfAnswered('Consistência', saltFoodConsistency);
      }
      
      addIfAnswered('Outro leite', otherMilk);
      addIfAnswered('Mingau com leite', porridgeWithMilk);
      addIfAnswered('Iogurte', yogurt);
      addIfAnswered('Legumes', vegetables);
      addIfAnswered('Vegetal alaranjado/folhas verdes', orangeVegetableOrFruit);
      addIfAnswered('Verdura de folha', darkGreenLeaves);
      addIfAnswered('Carne ou ovo', meatOrEgg);
      addIfAnswered('Fígado', liver);
      addIfAnswered('Feijão', beans);
      addIfAnswered('Arroz, batata, macarrão', carbs);
      addIfAnswered('Hambúrguer/Embutidos', processedMeats);
      addIfAnswered('Bebidas adoçadas', sweetenedBeverages);
      addIfAnswered('Salgadinhos/Biscoitos', snacksOrCookies);
      addIfAnswered('Doces/Guloseimas', sweets);
    } 
    else if (ageCategory == AgeCategory.twoToTenYears) {
      addIfAnswered('Assistindo TV/Celular', eatsWatchingTv);
      if (dailyMeals.isNotEmpty) addIfAnswered('Refeições', dailyMeals.join(", "));
      
      addIfAnswered('Feijão', beans);
      addIfAnswered('Frutas frescas', freshFruits);
      addIfAnswered('Verduras/Legumes', vegetablesAndLegumes);
      addIfAnswered('Hambúrguer/Embutidos', processedMeats);
      addIfAnswered('Bebidas adoçadas', sweetenedBeverages);
      addIfAnswered('Salgadinhos/Macarrão Inst.', instantNoodlesOrSnacks);
      addIfAnswered('Doces/Guloseimas', sweets);
    }

    return list;
  }
}