import 'package:hive/hive.dart';
import '../enums/pregnancy_enums.dart';
import 'package:uuid/uuid.dart';

part 'lab_exam_model.g.dart';

// TypeId 18

@HiveType(typeId: 18)
class LabExamModel {
  @HiveField(0)
  LabExamType type;

  @HiveField(1)
  DateTime? date;

  @HiveField(2)
  String? result;

  @HiveField(3)
  bool completed;

  @HiveField(4)
  String id;

  @HiveField(5)
  String? customName;

  @HiveField(6)
  String? notes;

  LabExamModel({
    required this.type,
    this.date,
    this.result,
    this.completed = false,
    String? id,
    this.customName,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  LabExamModel copyWith({
    DateTime? date,
    String? result,
    bool? completed,
    String? customName,
    String? notes,
  }) {
    return LabExamModel(
      type: type,
      date: date ?? this.date,
      result: result ?? this.result,
      completed: completed ?? this.completed,
      id: id,
      customName: customName ?? this.customName,
      notes: notes ?? this.notes,
    );
  }
}