// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notice_enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoticeTypeAdapter extends TypeAdapter<NoticeType> {
  @override
  final int typeId = 25;

  @override
  NoticeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NoticeType.campaign;
      case 1:
        return NoticeType.meeting;
      case 2:
        return NoticeType.training;
      case 3:
        return NoticeType.event;
      default:
        return NoticeType.campaign;
    }
  }

  @override
  void write(BinaryWriter writer, NoticeType obj) {
    switch (obj) {
      case NoticeType.campaign:
        writer.writeByte(0);
        break;
      case NoticeType.meeting:
        writer.writeByte(1);
        break;
      case NoticeType.training:
        writer.writeByte(2);
        break;
      case NoticeType.event:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoticeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
