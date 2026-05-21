// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pregnant_woman_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PregnantWomanModelAdapter extends TypeAdapter<PregnantWomanModel> {
  @override
  final int typeId = 15;

  @override
  PregnantWomanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PregnantWomanModel()
      ..name = fields[0] as String
      ..birthDate = fields[1] as DateTime
      ..notes = fields[2] as String?
      ..dum = fields[3] as DateTime?
      ..dpp = fields[4] as DateTime?
      ..riskLevel = fields[5] as PregnancyRisk
      ..isActive = fields[6] as bool
      ..consultations = (fields[7] as List).cast<PrenatalConsultationModel>()
      ..ultrasounds = (fields[8] as List).cast<UltrasoundExamModel>()
      ..labExams = (fields[9] as List).cast<LabExamModel>()
      ..vaccines = (fields[10] as List).cast<PrenatalVaccineModel>()
      ..photoPaths = (fields[11] as List).cast<String>()
      ..createdAt = fields[12] as DateTime;
  }

  @override
  void write(BinaryWriter writer, PregnantWomanModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.birthDate)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.dum)
      ..writeByte(4)
      ..write(obj.dpp)
      ..writeByte(5)
      ..write(obj.riskLevel)
      ..writeByte(6)
      ..write(obj.isActive)
      ..writeByte(7)
      ..write(obj.consultations)
      ..writeByte(8)
      ..write(obj.ultrasounds)
      ..writeByte(9)
      ..write(obj.labExams)
      ..writeByte(10)
      ..write(obj.vaccines)
      ..writeByte(11)
      ..write(obj.photoPaths)
      ..writeByte(12)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PregnantWomanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
