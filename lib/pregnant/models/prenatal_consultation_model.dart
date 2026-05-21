import 'package:hive/hive.dart';
import '../enums/pregnancy_enums.dart';
import 'package:uuid/uuid.dart';

part 'prenatal_consultation_model.g.dart';

// TypeId 16

@HiveType(typeId: 16)
class PrenatalConsultationModel {
  @HiveField(0)
  ConsultationType type;

  @HiveField(1)
  DateTime? date;

  @HiveField(2)
  String? professional;

  @HiveField(3)
  String? notes;

  @HiveField(4)
  bool completed;

  @HiveField(5)
  String? customName;

  @HiveField(6)
  String id;

  PrenatalConsultationModel({
    String? id,
    required this.type,
    this.date,
    this.professional,
    this.notes,
    this.completed = false,
    this.customName,
  }) : id = id ?? const Uuid().v4();

  PrenatalConsultationModel copyWith({
    DateTime? date,
    String? professional,
    String? notes,
    bool? completed,
    String? customName,
  }) {
    return PrenatalConsultationModel(
      id: id,
      type: type,
      date: date ?? this.date,
      professional: professional ?? this.professional,
      notes: notes ?? this.notes,
      completed: completed ?? this.completed,
      customName: customName ?? this.customName,
    );
  }
}