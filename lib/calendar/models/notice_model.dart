import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../enums/notice_enums.dart';

part 'notice_model.g.dart';

// ─────────────────────────────────────────────
// TypeId 26 — Modelo do Aviso/Evento
// ─────────────────────────────────────────────

@HiveType(typeId: 26)
class NoticeModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  late NoticeType type;

  @HiveField(4)
  late DateTime date;

  @HiveField(5)
  late DateTime createdAt;

  // ─────────────────────────────────────────────────────
  // FACTORY — Criação de novo aviso
  // ─────────────────────────────────────────────────────

  static NoticeModel create({
    required String title,
    String? description,
    required NoticeType type,
    required DateTime date,
  }) {
    return NoticeModel()
      ..id = const Uuid().v4()
      ..title = title
      ..description = description
      ..type = type
      ..date = date
      ..createdAt = DateTime.now();
  }


  NoticeModel copyWith({
    String? title,
    String? description,
    NoticeType? type,
    DateTime? date,
  }) {
    return NoticeModel()
      ..id = id
      ..title = title ?? this.title
      ..description = description ?? this.description
      ..type = type ?? this.type
      ..date = date ?? this.date
      ..createdAt = createdAt;
  }
}