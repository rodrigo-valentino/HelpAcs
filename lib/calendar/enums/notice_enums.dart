import 'package:hive/hive.dart';

part 'notice_enums.g.dart';

// ─────────────────────────────────────────────
// TypeId 25 — Tipo de Aviso / Evento
// ─────────────────────────────────────────────

@HiveType(typeId: 25)
enum NoticeType {
  @HiveField(0)
  campaign, // Campanha (ex: Dia D de Vacinação)

  @HiveField(1)
  meeting, // Reunião de equipe

  @HiveField(2)
  training, // Treinamento / Capacitação

  @HiveField(3)
  event, // Evento geral
}

// ─────────────────────────────────────────────
// EXTENSÕES — Labels em português
// ─────────────────────────────────────────────

extension NoticeTypeLabel on NoticeType {
  String get label {
    switch (this) {
      case NoticeType.campaign:
        return 'Campanha';
      case NoticeType.meeting:
        return 'Reunião';
      case NoticeType.training:
        return 'Treinamento';
      case NoticeType.event:
        return 'Evento';
    }
  }
}