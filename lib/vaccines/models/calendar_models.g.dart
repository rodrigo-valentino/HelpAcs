// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VaccineGroupModelAdapter extends TypeAdapter<VaccineGroupModel> {
  @override
  final int typeId = 29;

  @override
  VaccineGroupModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VaccineGroupModel(
      label: fields[0] as String,
      ageValue: fields[1] as int,
      ageUnit: fields[2] as AgeUnit,
      order: fields[3] as int,
      active: fields[4] as bool,
      createdAt: fields[5] as DateTime?,
      updatedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, VaccineGroupModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.ageValue)
      ..writeByte(2)
      ..write(obj.ageUnit)
      ..writeByte(3)
      ..write(obj.order)
      ..writeByte(4)
      ..write(obj.active)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaccineGroupModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VaccineDefinitionModelAdapter
    extends TypeAdapter<VaccineDefinitionModel> {
  @override
  final int typeId = 30;

  @override
  VaccineDefinitionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VaccineDefinitionModel(
      groupKey: fields[0] as int,
      name: fields[1] as String,
      totalDoses: fields[2] as int,
      order: fields[3] as int,
      active: fields[4] as bool,
      notes: fields[5] as String?,
      createdAt: fields[6] as DateTime?,
      updatedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, VaccineDefinitionModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.groupKey)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.totalDoses)
      ..writeByte(3)
      ..write(obj.order)
      ..writeByte(4)
      ..write(obj.active)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaccineDefinitionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AgeUnitAdapter extends TypeAdapter<AgeUnit> {
  @override
  final int typeId = 28;

  @override
  AgeUnit read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AgeUnit.days;
      case 1:
        return AgeUnit.months;
      case 2:
        return AgeUnit.years;
      default:
        return AgeUnit.days;
    }
  }

  @override
  void write(BinaryWriter writer, AgeUnit obj) {
    switch (obj) {
      case AgeUnit.days:
        writer.writeByte(0);
        break;
      case AgeUnit.months:
        writer.writeByte(1);
        break;
      case AgeUnit.years:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgeUnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
