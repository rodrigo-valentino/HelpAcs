import 'package:hive/hive.dart';
import '../enums/pregnancy_enums.dart';
import 'package:uuid/uuid.dart';

part 'ultrasound_exam_model.g.dart';

// TypeId 17

@HiveType(typeId: 17)
class UltrasoundExamModel {
  @HiveField(0)
  UltrasoundType type;

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

  UltrasoundExamModel({
    required this.type,
    this.date,
    this.result,
    this.completed = false,
    String? id,
    this.customName,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  UltrasoundExamModel copyWith({
    DateTime? date,
    String? result,
    bool? completed,
    String? customName,
    String? notes,
  }) {
    return UltrasoundExamModel(
      id: id,
      type: type,
      date: date ?? this.date,
      result: result ?? this.result,
      completed: completed ?? this.completed,
      customName: customName ?? this.customName, 
      notes: notes ?? this.notes,
    );
  }
}