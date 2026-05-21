// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prenatal_consultation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrenatalConsultationModelAdapter
    extends TypeAdapter<PrenatalConsultationModel> {
  @override
  final int typeId = 16;

  @override
  PrenatalConsultationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrenatalConsultationModel(
      id: fields[6] as String?,
      type: fields[0] as ConsultationType,
      date: fields[1] as DateTime?,
      professional: fields[2] as String?,
      notes: fields[3] as String?,
      completed: fields[4] as bool,
      customName: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PrenatalConsultationModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.professional)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.completed)
      ..writeByte(5)
      ..write(obj.customName)
      ..writeByte(6)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrenatalConsultationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
