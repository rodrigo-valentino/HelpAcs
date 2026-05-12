// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'woman_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WomanModelAdapter extends TypeAdapter<WomanModel> {
  @override
  final int typeId = 5;

  @override
  WomanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WomanModel()
      ..name = fields[0] as String
      ..birthDate = fields[1] as DateTime
      ..lastPreventivoDate = fields[2] as DateTime?
      ..nextPreventivoDate = fields[3] as DateTime?
      ..lastMammographyDate = fields[4] as DateTime?
      ..nextMammographyDate = fields[5] as DateTime?
      ..notes = fields[6] as String?
      ..isSus = fields[7] as bool;
  }

  @override
  void write(BinaryWriter writer, WomanModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.birthDate)
      ..writeByte(2)
      ..write(obj.lastPreventivoDate)
      ..writeByte(3)
      ..write(obj.nextPreventivoDate)
      ..writeByte(4)
      ..write(obj.lastMammographyDate)
      ..writeByte(5)
      ..write(obj.nextMammographyDate)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.isSus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WomanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
