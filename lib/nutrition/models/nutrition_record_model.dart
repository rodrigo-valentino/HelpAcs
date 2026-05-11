import 'package:hive/hive.dart';

part 'nutrition_record_model.g.dart';

// ========================================
// 📊 ENUMS DE RESPOSTAS & EXTENSIONS
// ========================================

@HiveType(typeId: 10)
enum NutritionAnswer {
  @HiveField(0) yes,
  @HiveField(1) no,
  @HiveField(2) dontKnow,
  @HiveField(3) unanswered,
}

@HiveType(typeId: 11)
enum FoodFrequency {
  @HiveField(0) once,
  @HiveField(1) twice,
  @HiveField(2) threeOrMore,
  @HiveField(3) unanswered,
}

@HiveType(typeId: 7)
enum FoodConsistency {
  @HiveField(0) pieces,        // Pedaços
  @HiveField(1) mashed,        // Amassada
  @HiveField(2) sieved,        // Peneirada
  @HiveField(3) blended,       // Misturada
  @HiveField(4) onlyBroth,     // Só o caldo
  @HiveField(5) unanswered,    // Não sabe
}

@HiveType(typeId: 13)
enum AgeCategory {
  @HiveField(0) underSixMonths,
  @HiveField(1) sixToTwentyThree,
  @HiveField(2) twoToTenYears,
}

// 🚀 DRY #2 e DRY #17: Extension para limpar a UI de repetições de ifs/switches
extension AgeCategoryLabel on AgeCategory {
  String get label => switch (this) {
    AgeCategory.underSixMonths => 'Menor de 6 meses',
    AgeCategory.sixToTwentyThree => '6 a 23 meses',
    AgeCategory.twoToTenYears => '2 a 10 anos',
  };
}

// ========================================
// 📝 MODELO PRINCIPAL
// ========================================

@HiveType(typeId: 14)
class NutritionRecordModel extends HiveObject {
  @HiveField(0) int childKey;
  @HiveField(1) DateTime assessmentDate;
  @HiveField(2) AgeCategory ageCategory;

  // Faixa 1: Menores de 6 meses
  @HiveField(3) NutritionAnswer breastMilk; // leite materno
  @HiveField(4) NutritionAnswer porridge; // mingau
  @HiveField(5) NutritionAnswer waterTeaJuice; // água, chá ou suco
  @HiveField(6) NutritionAnswer cowMilk; // leite de vaca 
  @HiveField(7) NutritionAnswer infantFormula; // fórmula infantil
  @HiveField(8) NutritionAnswer fruitJuiceOrMashed; // suco de fruta ou fruta amassada
  @HiveField(9) NutritionAnswer fruitwhole; // fruta inteira/amassada
  @HiveField(10) NutritionAnswer saltFood; // comida de sal (sopa/janta)
  @HiveField(11) NutritionAnswer otherFoodsOrDrinks; // outros alimentos/bebidas

  // Faixa 2: 6 a 23 meses
  @HiveField(12) NutritionAnswer fruit;
  @HiveField(13) FoodFrequency fruitFrequency;
  @HiveField(14) FoodFrequency saltFoodFrequency;
  @HiveField(15) FoodConsistency saltFoodConsistency;
  @HiveField(16) NutritionAnswer otherMilk;
  @HiveField(17) NutritionAnswer porridgeWithMilk;
  @HiveField(18) NutritionAnswer yogurt;
  @HiveField(19) NutritionAnswer vegetables;
  @HiveField(20) NutritionAnswer orangeVegetableOrFruit;
  @HiveField(21) NutritionAnswer darkGreenLeaves;
  @HiveField(22) NutritionAnswer meatOrEgg;
  @HiveField(23) NutritionAnswer liver;
  @HiveField(24) NutritionAnswer beans;
  @HiveField(25) NutritionAnswer carbs;
  @HiveField(26) NutritionAnswer processedMeats;
  @HiveField(27) NutritionAnswer sweetenedBeverages;
  @HiveField(28) NutritionAnswer snacksOrCookies;
  @HiveField(29) NutritionAnswer sweets;

  // Faixa 3: 2 a 10 anos
  @HiveField(30) NutritionAnswer eatsWatchingTv;
  @HiveField(31) List<String> dailyMeals;
  @HiveField(32) NutritionAnswer freshFruits;
  @HiveField(33) NutritionAnswer vegetablesAndLegumes;
  @HiveField(34) NutritionAnswer instantNoodlesOrSnacks;

  NutritionRecordModel({
    required this.childKey,
    required this.assessmentDate,
    required this.ageCategory,
    this.breastMilk = NutritionAnswer.unanswered,
    this.porridge = NutritionAnswer.unanswered,
    this.waterTeaJuice = NutritionAnswer.unanswered,
    this.cowMilk = NutritionAnswer.unanswered,
    this.infantFormula = NutritionAnswer.unanswered,
    this.fruitJuiceOrMashed = NutritionAnswer.unanswered,
    this.saltFood = NutritionAnswer.unanswered,
    this.otherFoodsOrDrinks = NutritionAnswer.unanswered,
    this.fruitwhole = NutritionAnswer.unanswered,
    this.fruit = NutritionAnswer.unanswered,
    this.fruitFrequency = FoodFrequency.unanswered,
    this.saltFoodFrequency = FoodFrequency.unanswered,
    this.saltFoodConsistency = FoodConsistency.unanswered,
    this.otherMilk = NutritionAnswer.unanswered,
    this.porridgeWithMilk = NutritionAnswer.unanswered,
    this.yogurt = NutritionAnswer.unanswered,
    this.vegetables = NutritionAnswer.unanswered,
    this.orangeVegetableOrFruit = NutritionAnswer.unanswered,
    this.darkGreenLeaves = NutritionAnswer.unanswered,
    this.meatOrEgg = NutritionAnswer.unanswered,
    this.liver = NutritionAnswer.unanswered,
    this.beans = NutritionAnswer.unanswered,
    this.carbs = NutritionAnswer.unanswered,
    this.processedMeats = NutritionAnswer.unanswered,
    this.sweetenedBeverages = NutritionAnswer.unanswered,
    this.snacksOrCookies = NutritionAnswer.unanswered,
    this.sweets = NutritionAnswer.unanswered,
    this.eatsWatchingTv = NutritionAnswer.unanswered,
    this.dailyMeals = const [],
    this.freshFruits = NutritionAnswer.unanswered,
    this.vegetablesAndLegumes = NutritionAnswer.unanswered,
    this.instantNoodlesOrSnacks = NutritionAnswer.unanswered,
  });

  // 🚀 BUG #2: copyWith para garantir a imutabilidade do Riverpod sem perder dados
  NutritionRecordModel copyWith({
    int? childKey,
    DateTime? assessmentDate,
    AgeCategory? ageCategory,
    NutritionAnswer? breastMilk,
    NutritionAnswer? porridge,
    NutritionAnswer? waterTeaJuice,
    NutritionAnswer? cowMilk,
    NutritionAnswer? infantFormula,
    NutritionAnswer? fruitJuiceOrMashed,
    NutritionAnswer? saltFood,
    NutritionAnswer? otherFoodsOrDrinks,
    NutritionAnswer? fruitwhole,
    NutritionAnswer? fruit,
    FoodFrequency? fruitFrequency,
    FoodFrequency? saltFoodFrequency,
    FoodConsistency? saltFoodConsistency,
    NutritionAnswer? otherMilk,
    NutritionAnswer? porridgeWithMilk,
    NutritionAnswer? yogurt,
    NutritionAnswer? vegetables,
    NutritionAnswer? orangeVegetableOrFruit,
    NutritionAnswer? darkGreenLeaves,
    NutritionAnswer? meatOrEgg,
    NutritionAnswer? liver,
    NutritionAnswer? beans,
    NutritionAnswer? carbs,
    NutritionAnswer? processedMeats,
    NutritionAnswer? sweetenedBeverages,
    NutritionAnswer? snacksOrCookies,
    NutritionAnswer? sweets,
    NutritionAnswer? eatsWatchingTv,
    List<String>? dailyMeals,
    NutritionAnswer? freshFruits,
    NutritionAnswer? vegetablesAndLegumes,
    NutritionAnswer? instantNoodlesOrSnacks,
  }) {
    return NutritionRecordModel(
      childKey: childKey ?? this.childKey,
      assessmentDate: assessmentDate ?? this.assessmentDate,
      ageCategory: ageCategory ?? this.ageCategory,
      breastMilk: breastMilk ?? this.breastMilk,
      porridge: porridge ?? this.porridge,
      waterTeaJuice: waterTeaJuice ?? this.waterTeaJuice,
      cowMilk: cowMilk ?? this.cowMilk,
      infantFormula: infantFormula ?? this.infantFormula,
      fruitJuiceOrMashed: fruitJuiceOrMashed ?? this.fruitJuiceOrMashed,
      saltFood: saltFood ?? this.saltFood,
      otherFoodsOrDrinks: otherFoodsOrDrinks ?? this.otherFoodsOrDrinks,
      fruitwhole: fruitwhole ?? this.fruitwhole,
      fruit: fruit ?? this.fruit,
      fruitFrequency: fruitFrequency ?? this.fruitFrequency,
      saltFoodFrequency: saltFoodFrequency ?? this.saltFoodFrequency,
      saltFoodConsistency: saltFoodConsistency ?? this.saltFoodConsistency,
      otherMilk: otherMilk ?? this.otherMilk,
      porridgeWithMilk: porridgeWithMilk ?? this.porridgeWithMilk,
      yogurt: yogurt ?? this.yogurt,
      vegetables: vegetables ?? this.vegetables,
      orangeVegetableOrFruit: orangeVegetableOrFruit ?? this.orangeVegetableOrFruit,
      darkGreenLeaves: darkGreenLeaves ?? this.darkGreenLeaves,
      meatOrEgg: meatOrEgg ?? this.meatOrEgg,
      liver: liver ?? this.liver,
      beans: beans ?? this.beans,
      carbs: carbs ?? this.carbs,
      processedMeats: processedMeats ?? this.processedMeats,
      sweetenedBeverages: sweetenedBeverages ?? this.sweetenedBeverages,
      snacksOrCookies: snacksOrCookies ?? this.snacksOrCookies,
      sweets: sweets ?? this.sweets,
      eatsWatchingTv: eatsWatchingTv ?? this.eatsWatchingTv,
      dailyMeals: dailyMeals ?? this.dailyMeals,
      freshFruits: freshFruits ?? this.freshFruits,
      vegetablesAndLegumes: vegetablesAndLegumes ?? this.vegetablesAndLegumes,
      instantNoodlesOrSnacks: instantNoodlesOrSnacks ?? this.instantNoodlesOrSnacks,
    );
  }
}