import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../enums/pregnancy_enums.dart';

part 'prenatal_vaccine_model.g.dart';

// TypeId 19

@HiveType(typeId: 19)
class PrenatalVaccineModel {
  @HiveField(0)
  PrenatalVaccineType type;

  @HiveField(1)
  DateTime? date;

  @HiveField(2)
  bool administered;

  @HiveField(3)
  String id;

  @HiveField(4)
  String? customName;

  @HiveField(5)
  String? notes;

  PrenatalVaccineModel({
    String? id,
    required this.type,
    this.date,
    this.administered = false,
    this.customName,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  PrenatalVaccineModel copyWith({
    DateTime? date,
    bool? administered,
    String? customName,
    String? notes,
  }) {
    return PrenatalVaccineModel(
      id: id,
      type: type,
      date: date ?? this.date,
      administered: administered ?? this.administered,
      customName: customName ?? this.customName, 
      notes: notes ?? this.notes,              
    );
  }
}