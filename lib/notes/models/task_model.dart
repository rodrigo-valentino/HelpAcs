import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task_model.g.dart';

// ─────────────────────────────────────────────
// TypeId 27 — Modelo de Tarefa / Pendência
// ─────────────────────────────────────────────

@HiveType(typeId: 27)
class TaskModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  late bool isCompleted;

  @HiveField(4)
  late DateTime createdAt;

  // ─────────────────────────────────────────────────────
  // FACTORY
  // ─────────────────────────────────────────────────────

  static TaskModel create({
    required String title,
    String? description,
  }) {
    return TaskModel()
      ..id = const Uuid().v4()
      ..title = title
      ..description = description
      ..isCompleted = false
      ..createdAt = DateTime.now();
  }
}