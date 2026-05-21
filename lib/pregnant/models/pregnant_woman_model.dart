import 'package:hive/hive.dart';
import '../enums/pregnancy_enums.dart';
import 'prenatal_consultation_model.dart';
import 'ultrasound_exam_model.dart';
import 'lab_exam_model.dart';
import 'prenatal_vaccine_model.dart';

part 'pregnant_woman_model.g.dart';

@HiveType(typeId: 15)
class PregnantWomanModel extends HiveObject {
  // ── Dados pessoais ─────────────────────────

  @HiveField(0)
  late String name;

  @HiveField(1)
  late DateTime birthDate;

  @HiveField(2)
  String? notes;

  // ── Dados da gestação ──────────────────────

  @HiveField(3)
  DateTime? dum;

  @HiveField(4)
  DateTime? dpp;

  @HiveField(5)
  PregnancyRisk riskLevel = PregnancyRisk.habitual;

  @HiveField(6)
  bool isActive = true;

  // ── Sub-listas ─────────────────────────────

  @HiveField(7)
  List<PrenatalConsultationModel> consultations = [];

  @HiveField(8)
  List<UltrasoundExamModel> ultrasounds = [];

  @HiveField(9)
  List<LabExamModel> labExams = [];

  @HiveField(10)
  List<PrenatalVaccineModel> vaccines = [];

  @HiveField(11)
  List<String> photoPaths = [];

  @HiveField(12)
  DateTime createdAt = DateTime.now();

  // ─────────────────────────────────────────────────────
  // GETTERS — Idade da mulher
  // ─────────────────────────────────────────────────────

  int get age {
    final now = DateTime.now();
    int a = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      a--;
    }
    return a;
  }

  String get ageLabel => '$age anos';

  // ─────────────────────────────────────────────────────
  // GETTERS — Datas de gestação
  // ─────────────────────────────────────────────────────

  DateTime? get effectiveDum {
    if (dum != null) return dum;
    if (dpp != null) return dpp!.subtract(const Duration(days: 280));
    return null;
  }

  DateTime? get effectiveDpp {
    if (dpp != null) return dpp;
    if (dum != null) return dum!.add(const Duration(days: 280));
    return null;
  }

  // ─────────────────────────────────────────────────────
  // GETTERS — Idade gestacional
  // ─────────────────────────────────────────────────────

  int? get gestationalAgeDays {
    final dumDate = effectiveDum;
    if (dumDate == null) return null;
    final days = DateTime.now().difference(dumDate).inDays;
    return days < 0 ? 0 : days;
  }

  (int weeks, int days)? get gestationalAgeBreakdown {
    final total = gestationalAgeDays;
    if (total == null) return null;
    return (total ~/ 7, total % 7);
  }

  int? get trimester {
    final breakdown = gestationalAgeBreakdown;
    if (breakdown == null) return null;
    final weeks = breakdown.$1;
    if (weeks < 13) return 1;
    if (weeks < 27) return 2;
    return 3;
  }

  String get trimesterLabel {
    switch (trimester) {
      case 1:
        return '1º Trimestre';
      case 2:
        return '2º Trimestre';
      case 3:
        return '3º Trimestre';
      default:
        return 'Sem DUM/DPP';
    }
  }

  String get gestationalAgeLabel {
    final breakdown = gestationalAgeBreakdown;
    if (breakdown == null) return 'Sem DUM/DPP';
    final (weeks, days) = breakdown;
    if (weeks == 0) return '$days dias';
    if (days == 0) return '$weeks semanas';
    return '$weeks semanas e $days dias';
  }

  // ─────────────────────────────────────────────────────
  // GETTERS — Progresso do pré-natal (✅ Passo 5)
  // ─────────────────────────────────────────────────────

  // Considera estritamente apenas as consultas de 1 a 6
  int get completedFixedConsultations => consultations.where((c) =>
      (c.type == ConsultationType.first || c.type == ConsultationType.second ||
       c.type == ConsultationType.third || c.type == ConsultationType.fourth ||
       c.type == ConsultationType.fifth || c.type == ConsultationType.sixth) &&
      c.completed).length;

  // Considera apenas ultrassons que não são itens adicionados manualmente
  int get completedFixedUltrasounds => ultrasounds.where((u) => 
      u.customName == null && 
      u.completed).length;

  // Considera estritamente DTPa e Influenza
  int get administeredFixedVaccines => vaccines.where((v) =>
      (v.type == PrenatalVaccineType.dtpa || v.type == PrenatalVaccineType.influenza) &&
      v.administered).length;

  int get totalItems => 12; // 6 consultas + 4 ultrassons + 2 vacinas

  int get completedItems =>
      completedFixedConsultations + completedFixedUltrasounds + administeredFixedVaccines;

  double get overallProgress {
    if (totalItems == 0) return 0.0;
    return completedItems / totalItems;
  }

  String get progressLabel => '${(overallProgress * 100).round()}%';

  String get progressSummaryLabel =>
      '$completedFixedConsultations/6 Médicas  •  '
      '$completedFixedUltrasounds/4 Ultrassons  •  '
      '$administeredFixedVaccines/2 Vacinas';

  // ─────────────────────────────────────────────────────
  // FACTORY
  // ─────────────────────────────────────────────────────

  static PregnantWomanModel create({
    required String name,
    required DateTime birthDate,
    String? notes,
    DateTime? dum,
    DateTime? dpp,
    PregnancyRisk riskLevel = PregnancyRisk.habitual,
  }) {
    return PregnantWomanModel()
      ..name = name
      ..birthDate = birthDate
      ..notes = notes
      ..dum = dum
      ..dpp = dpp
      ..riskLevel = riskLevel
      ..isActive = true
      ..createdAt = DateTime.now()
      ..consultations = ConsultationType.values
          .map((t) => PrenatalConsultationModel(type: t))
          .toList()
      ..ultrasounds = UltrasoundType.values
          .map((t) => UltrasoundExamModel(type: t))
          .toList()
      ..labExams = LabExamType.values
          .map((t) => LabExamModel(type: t))
          .toList()
      ..vaccines = PrenatalVaccineType.values
          .map((t) => PrenatalVaccineModel(type: t))
          .toList()
      ..photoPaths = [];
  }
}