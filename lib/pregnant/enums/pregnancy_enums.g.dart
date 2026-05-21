// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pregnancy_enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PregnancyRiskAdapter extends TypeAdapter<PregnancyRisk> {
  @override
  final int typeId = 20;

  @override
  PregnancyRisk read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PregnancyRisk.habitual;
      case 1:
        return PregnancyRisk.highRisk;
      default:
        return PregnancyRisk.habitual;
    }
  }

  @override
  void write(BinaryWriter writer, PregnancyRisk obj) {
    switch (obj) {
      case PregnancyRisk.habitual:
        writer.writeByte(0);
        break;
      case PregnancyRisk.highRisk:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PregnancyRiskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConsultationTypeAdapter extends TypeAdapter<ConsultationType> {
  @override
  final int typeId = 21;

  @override
  ConsultationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ConsultationType.first;
      case 1:
        return ConsultationType.second;
      case 2:
        return ConsultationType.third;
      case 3:
        return ConsultationType.fourth;
      case 4:
        return ConsultationType.fifth;
      case 5:
        return ConsultationType.sixth;
      case 6:
        return ConsultationType.dental;
      default:
        return ConsultationType.first;
    }
  }

  @override
  void write(BinaryWriter writer, ConsultationType obj) {
    switch (obj) {
      case ConsultationType.first:
        writer.writeByte(0);
        break;
      case ConsultationType.second:
        writer.writeByte(1);
        break;
      case ConsultationType.third:
        writer.writeByte(2);
        break;
      case ConsultationType.fourth:
        writer.writeByte(3);
        break;
      case ConsultationType.fifth:
        writer.writeByte(4);
        break;
      case ConsultationType.sixth:
        writer.writeByte(5);
        break;
      case ConsultationType.dental:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsultationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UltrasoundTypeAdapter extends TypeAdapter<UltrasoundType> {
  @override
  final int typeId = 22;

  @override
  UltrasoundType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UltrasoundType.dating;
      case 1:
        return UltrasoundType.morphologicalFirst;
      case 2:
        return UltrasoundType.morphologicalSecond;
      case 3:
        return UltrasoundType.growth;
      default:
        return UltrasoundType.dating;
    }
  }

  @override
  void write(BinaryWriter writer, UltrasoundType obj) {
    switch (obj) {
      case UltrasoundType.dating:
        writer.writeByte(0);
        break;
      case UltrasoundType.morphologicalFirst:
        writer.writeByte(1);
        break;
      case UltrasoundType.morphologicalSecond:
        writer.writeByte(2);
        break;
      case UltrasoundType.growth:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UltrasoundTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LabExamTypeAdapter extends TypeAdapter<LabExamType> {
  @override
  final int typeId = 23;

  @override
  LabExamType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LabExamType.bloodCount;
      case 1:
        return LabExamType.bloodType;
      case 2:
        return LabExamType.glucose;
      case 3:
        return LabExamType.urine;
      case 4:
        return LabExamType.serology;
      default:
        return LabExamType.bloodCount;
    }
  }

  @override
  void write(BinaryWriter writer, LabExamType obj) {
    switch (obj) {
      case LabExamType.bloodCount:
        writer.writeByte(0);
        break;
      case LabExamType.bloodType:
        writer.writeByte(1);
        break;
      case LabExamType.glucose:
        writer.writeByte(2);
        break;
      case LabExamType.urine:
        writer.writeByte(3);
        break;
      case LabExamType.serology:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabExamTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PrenatalVaccineTypeAdapter extends TypeAdapter<PrenatalVaccineType> {
  @override
  final int typeId = 24;

  @override
  PrenatalVaccineType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PrenatalVaccineType.dtpa;
      case 1:
        return PrenatalVaccineType.influenza;
      case 2:
        return PrenatalVaccineType.hepatitisB;
      default:
        return PrenatalVaccineType.dtpa;
    }
  }

  @override
  void write(BinaryWriter writer, PrenatalVaccineType obj) {
    switch (obj) {
      case PrenatalVaccineType.dtpa:
        writer.writeByte(0);
        break;
      case PrenatalVaccineType.influenza:
        writer.writeByte(1);
        break;
      case PrenatalVaccineType.hepatitisB:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrenatalVaccineTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
