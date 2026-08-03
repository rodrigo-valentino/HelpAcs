// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vaccine_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VaccineRecordAdapter extends TypeAdapter<VaccineRecord> {
  @override
  final int typeId = 3;

  @override
  VaccineRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VaccineRecord(
      name: fields[0] as String,
      doseNumber: fields[1] as int,
      applied: fields[2] as bool,
      isCustom: fields[3] as bool,
      observation: fields[4] as String?,
      group: fields[5] as String,
      vaccineDefinitionKey: fields[6] as int?,
      groupKey: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, VaccineRecord obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.doseNumber)
      ..writeByte(2)
      ..write(obj.applied)
      ..writeByte(3)
      ..write(obj.isCustom)
      ..writeByte(4)
      ..write(obj.observation)
      ..writeByte(5)
      ..write(obj.group)
      ..writeByte(6)
      ..write(obj.vaccineDefinitionKey)
      ..writeByte(7)
      ..write(obj.groupKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaccineRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
