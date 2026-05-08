// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HealthStatusAdapter extends TypeAdapter<HealthStatus> {
  @override
  final int typeId = 0;

  @override
  HealthStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HealthStatus.upToDate;
      case 1:
        return HealthStatus.warning;
      case 2:
        return HealthStatus.overdue;
      case 3:
        return HealthStatus.pending;
      default:
        return HealthStatus.upToDate;
    }
  }

  @override
  void write(BinaryWriter writer, HealthStatus obj) {
    switch (obj) {
      case HealthStatus.upToDate:
        writer.writeByte(0);
        break;
      case HealthStatus.warning:
        writer.writeByte(1);
        break;
      case HealthStatus.overdue:
        writer.writeByte(2);
        break;
      case HealthStatus.pending:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
