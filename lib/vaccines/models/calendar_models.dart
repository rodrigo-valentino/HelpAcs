import 'package:hive/hive.dart';

part 'calendar_models.g.dart';

@HiveType(typeId: 28)
enum AgeUnit {
  @HiveField(0)
  days,

  @HiveField(1)
  months,

  @HiveField(2)
  years,
}

@HiveType(typeId: 29)
class VaccineGroupModel extends HiveObject {

  @HiveField(0)
  String label;

  @HiveField(1)
  int ageValue;

  @HiveField(2)
  AgeUnit ageUnit;

  @HiveField(3)
  int order;

  @HiveField(4)
  bool active;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  VaccineGroupModel({
    required this.label,
    required this.ageValue,
    required this.ageUnit,
    required this.order,
    this.active = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  DateTime calculateDueDate(DateTime birthDate) {
    final base = DateTime(birthDate.year, birthDate.month, birthDate.day);
    switch (ageUnit) {
      case AgeUnit.days:
        return base.add(Duration(days: ageValue));
      case AgeUnit.months:
        return DateTime(base.year, base.month + ageValue, base.day);
      case AgeUnit.years:
        return DateTime(base.year + ageValue, base.month, base.day);
    }
  }
}

@HiveType(typeId: 30)
class VaccineDefinitionModel extends HiveObject {

  @HiveField(0)
  int groupKey;

  @HiveField(1)
  String name;

  @HiveField(2)
  int totalDoses;

  @HiveField(3)
  int order;

  @HiveField(4)
  bool active;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  VaccineDefinitionModel({
    required this.groupKey,
    required this.name,
    required this.totalDoses,
    required this.order,
    this.active = true,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
}