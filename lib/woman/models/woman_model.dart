// lib/woman/models/woman_model.dart

import 'package:hive/hive.dart';
import '../../utils/date_formatter.dart';
import '../../enums/health_status.dart';
import '../services/woman_status_service.dart';

part 'woman_model.g.dart';

@HiveType(typeId: 5)
class WomanModel extends HiveObject {

  int get id {
    assert(
      key != null,
      'WomanModel.id foi acessado antes do objeto ser salvo na box. '
      'Certifique-se de chamar box.add() antes de usar o id.',
    );
    return key as int? ?? -1;
  }

  // ── Campos persistidos ─────────────────────────────────────────────────────

  @HiveField(0)
  late String name;

  @HiveField(1)
  late DateTime birthDate;

  @HiveField(2)
  DateTime? lastPreventivoDate;

  @HiveField(3)
  DateTime? nextPreventivoDate;

  @HiveField(4)
  DateTime? lastMammographyDate;

  @HiveField(5)
  DateTime? nextMammographyDate;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  bool isSus = true;

  // ── Getters simples ────────────────────────────────────────────────────────

  int get age => DateFormatter.calculateAge(birthDate);

  // ── Delegação ao WomanStatusService ───────────────────────────────────────

  HealthStatus? get preventivoStatus =>
      WomanStatusService.getPreventivoStatus(this);

  HealthStatus? get mammographyStatus =>
      WomanStatusService.getMammographyStatus(this);

  HealthStatus? get badgeStatus => WomanStatusService.getBadgeStatus(this);

  int get generalStatusWeight =>
      WomanStatusService.getGeneralStatusWeight(this);
}

// ── Extensões ──────────────────────────────────────────────────────────────

extension WomanListExtensions on List<WomanModel> {

  WomanModel? lookup(int id) {
    try {
      return firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}