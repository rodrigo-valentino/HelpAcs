// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NutritionRecordModelAdapter extends TypeAdapter<NutritionRecordModel> {
  @override
  final int typeId = 14;

  @override
  NutritionRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NutritionRecordModel(
      childKey: fields[0] as int,
      assessmentDate: fields[1] as DateTime,
      ageCategory: fields[2] as AgeCategory,
      breastMilk: fields[3] as NutritionAnswer,
      porridge: fields[4] as NutritionAnswer,
      waterTeaJuice: fields[5] as NutritionAnswer,
      cowMilk: fields[6] as NutritionAnswer,
      infantFormula: fields[7] as NutritionAnswer,
      fruitJuiceOrMashed: fields[8] as NutritionAnswer,
      saltFood: fields[9] as NutritionAnswer,
      otherFoodsOrDrinks: fields[10] as NutritionAnswer,
      fruitwhole: fields[34] as NutritionAnswer,
      fruit: fields[11] as NutritionAnswer,
      fruitFrequency: fields[12] as FoodFrequency,
      saltFoodFrequency: fields[13] as FoodFrequency,
      saltFoodConsistency: fields[14] as FoodConsistency,
      otherMilk: fields[15] as NutritionAnswer,
      porridgeWithMilk: fields[16] as NutritionAnswer,
      yogurt: fields[17] as NutritionAnswer,
      vegetables: fields[18] as NutritionAnswer,
      orangeVegetableOrFruit: fields[19] as NutritionAnswer,
      darkGreenLeaves: fields[20] as NutritionAnswer,
      meatOrEgg: fields[21] as NutritionAnswer,
      liver: fields[22] as NutritionAnswer,
      beans: fields[23] as NutritionAnswer,
      carbs: fields[24] as NutritionAnswer,
      processedMeats: fields[25] as NutritionAnswer,
      sweetenedBeverages: fields[26] as NutritionAnswer,
      snacksOrCookies: fields[27] as NutritionAnswer,
      sweets: fields[28] as NutritionAnswer,
      eatsWatchingTv: fields[29] as NutritionAnswer,
      dailyMeals: (fields[30] as List).cast<String>(),
      freshFruits: fields[31] as NutritionAnswer,
      vegetablesAndLegumes: fields[32] as NutritionAnswer,
      instantNoodlesOrSnacks: fields[33] as NutritionAnswer,
    );
  }

  @override
  void write(BinaryWriter writer, NutritionRecordModel obj) {
    writer
      ..writeByte(35)
      ..writeByte(0)
      ..write(obj.childKey)
      ..writeByte(1)
      ..write(obj.assessmentDate)
      ..writeByte(2)
      ..write(obj.ageCategory)
      ..writeByte(3)
      ..write(obj.breastMilk)
      ..writeByte(4)
      ..write(obj.porridge)
      ..writeByte(5)
      ..write(obj.waterTeaJuice)
      ..writeByte(6)
      ..write(obj.cowMilk)
      ..writeByte(7)
      ..write(obj.infantFormula)
      ..writeByte(8)
      ..write(obj.fruitJuiceOrMashed)
      ..writeByte(9)
      ..write(obj.saltFood)
      ..writeByte(10)
      ..write(obj.otherFoodsOrDrinks)
      ..writeByte(11)
      ..write(obj.fruit)
      ..writeByte(12)
      ..write(obj.fruitFrequency)
      ..writeByte(13)
      ..write(obj.saltFoodFrequency)
      ..writeByte(14)
      ..write(obj.saltFoodConsistency)
      ..writeByte(15)
      ..write(obj.otherMilk)
      ..writeByte(16)
      ..write(obj.porridgeWithMilk)
      ..writeByte(17)
      ..write(obj.yogurt)
      ..writeByte(18)
      ..write(obj.vegetables)
      ..writeByte(19)
      ..write(obj.orangeVegetableOrFruit)
      ..writeByte(20)
      ..write(obj.darkGreenLeaves)
      ..writeByte(21)
      ..write(obj.meatOrEgg)
      ..writeByte(22)
      ..write(obj.liver)
      ..writeByte(23)
      ..write(obj.beans)
      ..writeByte(24)
      ..write(obj.carbs)
      ..writeByte(25)
      ..write(obj.processedMeats)
      ..writeByte(26)
      ..write(obj.sweetenedBeverages)
      ..writeByte(27)
      ..write(obj.snacksOrCookies)
      ..writeByte(28)
      ..write(obj.sweets)
      ..writeByte(29)
      ..write(obj.eatsWatchingTv)
      ..writeByte(30)
      ..write(obj.dailyMeals)
      ..writeByte(31)
      ..write(obj.freshFruits)
      ..writeByte(32)
      ..write(obj.vegetablesAndLegumes)
      ..writeByte(33)
      ..write(obj.instantNoodlesOrSnacks)
      ..writeByte(34)
      ..write(obj.fruitwhole);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NutritionAnswerAdapter extends TypeAdapter<NutritionAnswer> {
  @override
  final int typeId = 10;

  @override
  NutritionAnswer read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NutritionAnswer.yes;
      case 1:
        return NutritionAnswer.no;
      case 2:
        return NutritionAnswer.dontKnow;
      case 3:
        return NutritionAnswer.unanswered;
      default:
        return NutritionAnswer.yes;
    }
  }

  @override
  void write(BinaryWriter writer, NutritionAnswer obj) {
    switch (obj) {
      case NutritionAnswer.yes:
        writer.writeByte(0);
        break;
      case NutritionAnswer.no:
        writer.writeByte(1);
        break;
      case NutritionAnswer.dontKnow:
        writer.writeByte(2);
        break;
      case NutritionAnswer.unanswered:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionAnswerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FoodFrequencyAdapter extends TypeAdapter<FoodFrequency> {
  @override
  final int typeId = 11;

  @override
  FoodFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FoodFrequency.once;
      case 1:
        return FoodFrequency.twice;
      case 2:
        return FoodFrequency.threeOrMore;
      case 3:
        return FoodFrequency.unanswered;
      default:
        return FoodFrequency.once;
    }
  }

  @override
  void write(BinaryWriter writer, FoodFrequency obj) {
    switch (obj) {
      case FoodFrequency.once:
        writer.writeByte(0);
        break;
      case FoodFrequency.twice:
        writer.writeByte(1);
        break;
      case FoodFrequency.threeOrMore:
        writer.writeByte(2);
        break;
      case FoodFrequency.unanswered:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FoodConsistencyAdapter extends TypeAdapter<FoodConsistency> {
  @override
  final int typeId = 7;

  @override
  FoodConsistency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FoodConsistency.pieces;
      case 1:
        return FoodConsistency.mashed;
      case 2:
        return FoodConsistency.sieved;
      case 3:
        return FoodConsistency.blended;
      case 4:
        return FoodConsistency.onlyBroth;
      case 5:
        return FoodConsistency.unanswered;
      default:
        return FoodConsistency.pieces;
    }
  }

  @override
  void write(BinaryWriter writer, FoodConsistency obj) {
    switch (obj) {
      case FoodConsistency.pieces:
        writer.writeByte(0);
        break;
      case FoodConsistency.mashed:
        writer.writeByte(1);
        break;
      case FoodConsistency.sieved:
        writer.writeByte(2);
        break;
      case FoodConsistency.blended:
        writer.writeByte(3);
        break;
      case FoodConsistency.onlyBroth:
        writer.writeByte(4);
        break;
      case FoodConsistency.unanswered:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodConsistencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AgeCategoryAdapter extends TypeAdapter<AgeCategory> {
  @override
  final int typeId = 13;

  @override
  AgeCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AgeCategory.underSixMonths;
      case 1:
        return AgeCategory.sixToTwentyThree;
      case 2:
        return AgeCategory.twoToTenYears;
      default:
        return AgeCategory.underSixMonths;
    }
  }

  @override
  void write(BinaryWriter writer, AgeCategory obj) {
    switch (obj) {
      case AgeCategory.underSixMonths:
        writer.writeByte(0);
        break;
      case AgeCategory.sixToTwentyThree:
        writer.writeByte(1);
        break;
      case AgeCategory.twoToTenYears:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgeCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
