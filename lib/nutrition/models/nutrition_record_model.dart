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

extension NutritionAnswerLabel on NutritionAnswer {
  String get label => switch (this) {
    NutritionAnswer.yes        => 'Sim',
    NutritionAnswer.no         => 'Não',
    NutritionAnswer.dontKnow   => 'Não Sabe',
    NutritionAnswer.unanswered => '',
  };
}

@HiveType(typeId: 11)
enum FoodFrequency {
  @HiveField(0) once,
  @HiveField(1) twice,
  @HiveField(2) threeOrMore,
  @HiveField(3) unanswered,
}

extension FoodFrequencyLabel on FoodFrequency {
  String get label => switch (this) {
    FoodFrequency.once        => '1x',
    FoodFrequency.twice       => '2x',
    FoodFrequency.threeOrMore => '3x+',
    FoodFrequency.unanswered  => '',
  };
}

@HiveType(typeId: 7)
enum FoodConsistency {
  @HiveField(0) pieces,
  @HiveField(1) mashed,
  @HiveField(2) sieved,
  @HiveField(3) blended,
  @HiveField(4) onlyBroth,
  @HiveField(5) unanswered,
}

extension FoodConsistencyLabel on FoodConsistency {
  String get label => switch (this) {
    FoodConsistency.pieces     => 'Pedaços',
    FoodConsistency.mashed     => 'Amassada',
    FoodConsistency.sieved     => 'Peneirada',
    FoodConsistency.blended    => 'Liquidificada',
    FoodConsistency.onlyBroth  => 'Só o caldo',
    FoodConsistency.unanswered => 'Não sabe',
  };
}

@HiveType(typeId: 13)
enum AgeCategory {
  @HiveField(0) underSixMonths,
  @HiveField(1) sixToTwentyThree,
  @HiveField(2) twoToTenYears,
}

extension AgeCategoryLabel on AgeCategory {
  String get label => switch (this) {
    AgeCategory.underSixMonths  => 'Menor de 6 meses',
    AgeCategory.sixToTwentyThree => '6 a 23 meses',
    AgeCategory.twoToTenYears   => '2 a 10 anos',
  };
}

// ========================================
// 📝 MODELO PRINCIPAL
// ========================================

@HiveType(typeId: 14)
class NutritionRecordModel extends HiveObject {
  @HiveField(0)  int childKey;
  @HiveField(1)  DateTime assessmentDate;
  @HiveField(2)  AgeCategory ageCategory;

  @HiveField(3)  NutritionAnswer breastMilk;
  @HiveField(4)  NutritionAnswer porridge;
  @HiveField(5)  NutritionAnswer waterTeaJuice;
  @HiveField(6)  NutritionAnswer cowMilk;
  @HiveField(7)  NutritionAnswer infantFormula;
  @HiveField(8)  NutritionAnswer fruitJuiceOrMashed;
  @HiveField(9)  NutritionAnswer saltFood;
  @HiveField(10) NutritionAnswer otherFoodsOrDrinks;

  // Faixa 2: 6 a 23 meses
  @HiveField(11) NutritionAnswer fruit;
  @HiveField(12) FoodFrequency fruitFrequency;
  @HiveField(13) FoodFrequency saltFoodFrequency;
  @HiveField(14) FoodConsistency saltFoodConsistency;
  @HiveField(15) NutritionAnswer otherMilk;
  @HiveField(16) NutritionAnswer porridgeWithMilk;
  @HiveField(17) NutritionAnswer yogurt;
  @HiveField(18) NutritionAnswer vegetables;
  @HiveField(19) NutritionAnswer orangeVegetableOrFruit;
  @HiveField(20) NutritionAnswer darkGreenLeaves;
  @HiveField(21) NutritionAnswer meatOrEgg;
  @HiveField(22) NutritionAnswer liver;
  @HiveField(23) NutritionAnswer beans;
  @HiveField(24) NutritionAnswer carbs;
  @HiveField(25) NutritionAnswer processedMeats;
  @HiveField(26) NutritionAnswer sweetenedBeverages;
  @HiveField(27) NutritionAnswer snacksOrCookies;
  @HiveField(28) NutritionAnswer sweets;

  // Faixa 3: 2 a 10 anos
  @HiveField(29) NutritionAnswer eatsWatchingTv;
  @HiveField(30) List<String> dailyMeals;
  @HiveField(31) NutritionAnswer freshFruits;
  @HiveField(32) NutritionAnswer vegetablesAndLegumes;
  @HiveField(33) NutritionAnswer instantNoodlesOrSnacks;
  @HiveField(34) NutritionAnswer fruitwhole;

  NutritionRecordModel({
    required this.childKey,
    required this.assessmentDate,
    required this.ageCategory,
    this.breastMilk          = NutritionAnswer.unanswered,
    this.porridge             = NutritionAnswer.unanswered,
    this.waterTeaJuice        = NutritionAnswer.unanswered,
    this.cowMilk              = NutritionAnswer.unanswered,
    this.infantFormula        = NutritionAnswer.unanswered,
    this.fruitJuiceOrMashed   = NutritionAnswer.unanswered,
    this.saltFood             = NutritionAnswer.unanswered,
    this.otherFoodsOrDrinks   = NutritionAnswer.unanswered,
    this.fruitwhole           = NutritionAnswer.unanswered,
    this.fruit                = NutritionAnswer.unanswered,
    this.fruitFrequency       = FoodFrequency.unanswered,
    this.saltFoodFrequency    = FoodFrequency.unanswered,
    this.saltFoodConsistency  = FoodConsistency.unanswered,
    this.otherMilk            = NutritionAnswer.unanswered,
    this.porridgeWithMilk     = NutritionAnswer.unanswered,
    this.yogurt               = NutritionAnswer.unanswered,
    this.vegetables           = NutritionAnswer.unanswered,
    this.orangeVegetableOrFruit = NutritionAnswer.unanswered,
    this.darkGreenLeaves      = NutritionAnswer.unanswered,
    this.meatOrEgg            = NutritionAnswer.unanswered,
    this.liver                = NutritionAnswer.unanswered,
    this.beans                = NutritionAnswer.unanswered,
    this.carbs                = NutritionAnswer.unanswered,
    this.processedMeats       = NutritionAnswer.unanswered,
    this.sweetenedBeverages   = NutritionAnswer.unanswered,
    this.snacksOrCookies      = NutritionAnswer.unanswered,
    this.sweets               = NutritionAnswer.unanswered,
    this.eatsWatchingTv       = NutritionAnswer.unanswered,
    this.dailyMeals           = const [],
    this.freshFruits          = NutritionAnswer.unanswered,
    this.vegetablesAndLegumes = NutritionAnswer.unanswered,
    this.instantNoodlesOrSnacks = NutritionAnswer.unanswered,
  });

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
      childKey:              childKey              ?? this.childKey,
      assessmentDate:        assessmentDate        ?? this.assessmentDate,
      ageCategory:           ageCategory           ?? this.ageCategory,
      breastMilk:            breastMilk            ?? this.breastMilk,
      porridge:              porridge              ?? this.porridge,
      waterTeaJuice:         waterTeaJuice         ?? this.waterTeaJuice,
      cowMilk:               cowMilk               ?? this.cowMilk,
      infantFormula:         infantFormula         ?? this.infantFormula,
      fruitJuiceOrMashed:    fruitJuiceOrMashed    ?? this.fruitJuiceOrMashed,
      saltFood:              saltFood              ?? this.saltFood,
      otherFoodsOrDrinks:    otherFoodsOrDrinks    ?? this.otherFoodsOrDrinks,
      fruitwhole:            fruitwhole            ?? this.fruitwhole,
      fruit:                 fruit                 ?? this.fruit,
      fruitFrequency:        fruitFrequency        ?? this.fruitFrequency,
      saltFoodFrequency:     saltFoodFrequency     ?? this.saltFoodFrequency,
      saltFoodConsistency:   saltFoodConsistency   ?? this.saltFoodConsistency,
      otherMilk:             otherMilk             ?? this.otherMilk,
      porridgeWithMilk:      porridgeWithMilk      ?? this.porridgeWithMilk,
      yogurt:                yogurt                ?? this.yogurt,
      vegetables:            vegetables            ?? this.vegetables,
      orangeVegetableOrFruit: orangeVegetableOrFruit ?? this.orangeVegetableOrFruit,
      darkGreenLeaves:       darkGreenLeaves       ?? this.darkGreenLeaves,
      meatOrEgg:             meatOrEgg             ?? this.meatOrEgg,
      liver:                 liver                 ?? this.liver,
      beans:                 beans                 ?? this.beans,
      carbs:                 carbs                 ?? this.carbs,
      processedMeats:        processedMeats        ?? this.processedMeats,
      sweetenedBeverages:    sweetenedBeverages    ?? this.sweetenedBeverages,
      snacksOrCookies:       snacksOrCookies       ?? this.snacksOrCookies,
      sweets:                sweets                ?? this.sweets,
      eatsWatchingTv:        eatsWatchingTv        ?? this.eatsWatchingTv,
      dailyMeals:            dailyMeals            ?? this.dailyMeals,
      freshFruits:           freshFruits           ?? this.freshFruits,
      vegetablesAndLegumes:  vegetablesAndLegumes  ?? this.vegetablesAndLegumes,
      instantNoodlesOrSnacks: instantNoodlesOrSnacks ?? this.instantNoodlesOrSnacks,
    );
  }
}