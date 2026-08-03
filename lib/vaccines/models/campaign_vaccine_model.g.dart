// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign_vaccine_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CampaignVaccineModelAdapter extends TypeAdapter<CampaignVaccineModel> {
  @override
  final int typeId = 4;

  @override
  CampaignVaccineModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CampaignVaccineModel(
      name: fields[0] as String,
      year: fields[1] as int,
      createdAt: fields[2] as DateTime,
      applied: fields[3] == null ? true : fields[3] as bool,
      dueAgeMonths: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, CampaignVaccineModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.year)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.applied)
      ..writeByte(4)
      ..write(obj.dueAgeMonths);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CampaignVaccineModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
