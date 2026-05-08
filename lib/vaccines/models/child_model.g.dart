// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChildModelAdapter extends TypeAdapter<ChildModel> {
  @override
  final int typeId = 1;

  @override
  ChildModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChildModel(
      name: fields[0] as String,
      birthDate: fields[1] as DateTime,
      guardianName: fields[2] as String?,
      cpf: fields[3] as String?,
      notes: fields[4] as String?,
      status: fields[5] as ChildHealthStatus,
      imagePaths: (fields[6] as List).cast<String>(),
      vaccines: (fields[7] as List).cast<VaccineRecord>(),
    );
  }

  @override
  void write(BinaryWriter writer, ChildModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.birthDate)
      ..writeByte(2)
      ..write(obj.guardianName)
      ..writeByte(3)
      ..write(obj.cpf)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.imagePaths)
      ..writeByte(7)
      ..write(obj.vaccines);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChildModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChildHealthStatusAdapter extends TypeAdapter<ChildHealthStatus> {
  @override
  final int typeId = 0;

  @override
  ChildHealthStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChildHealthStatus.overdue;
      case 1:
        return ChildHealthStatus.warning;
      case 2:
        return ChildHealthStatus.upToDate;
      case 3:
        return ChildHealthStatus.pending;
      default:
        return ChildHealthStatus.overdue;
    }
  }

  @override
  void write(BinaryWriter writer, ChildHealthStatus obj) {
    switch (obj) {
      case ChildHealthStatus.overdue:
        writer.writeByte(0);
        break;
      case ChildHealthStatus.warning:
        writer.writeByte(1);
        break;
      case ChildHealthStatus.upToDate:
        writer.writeByte(2);
        break;
      case ChildHealthStatus.pending:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChildHealthStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
