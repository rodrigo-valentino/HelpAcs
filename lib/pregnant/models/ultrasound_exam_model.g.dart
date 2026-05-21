// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ultrasound_exam_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UltrasoundExamModelAdapter extends TypeAdapter<UltrasoundExamModel> {
  @override
  final int typeId = 17;

  @override
  UltrasoundExamModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UltrasoundExamModel(
      type: fields[0] as UltrasoundType,
      date: fields[1] as DateTime?,
      result: fields[2] as String?,
      completed: fields[3] as bool,
      id: fields[4] as String?,
      customName: fields[5] as String?,
      notes: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UltrasoundExamModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.result)
      ..writeByte(3)
      ..write(obj.completed)
      ..writeByte(4)
      ..write(obj.id)
      ..writeByte(5)
      ..write(obj.customName)
      ..writeByte(6)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UltrasoundExamModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
