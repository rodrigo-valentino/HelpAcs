// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notice_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoticeModelAdapter extends TypeAdapter<NoticeModel> {
  @override
  final int typeId = 26;

  @override
  NoticeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoticeModel()
      ..id = fields[0] as String
      ..title = fields[1] as String
      ..description = fields[2] as String?
      ..type = fields[3] as NoticeType
      ..date = fields[4] as DateTime
      ..createdAt = fields[5] as DateTime;
  }

  @override
  void write(BinaryWriter writer, NoticeModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoticeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
