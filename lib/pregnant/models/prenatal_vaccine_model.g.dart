// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prenatal_vaccine_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrenatalVaccineModelAdapter extends TypeAdapter<PrenatalVaccineModel> {
  @override
  final int typeId = 19;

  @override
  PrenatalVaccineModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrenatalVaccineModel(
      id: fields[3] as String?,
      type: fields[0] as PrenatalVaccineType,
      date: fields[1] as DateTime?,
      administered: fields[2] as bool,
      customName: fields[4] as String?,
      notes: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PrenatalVaccineModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.administered)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.customName)
      ..writeByte(5)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrenatalVaccineModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
