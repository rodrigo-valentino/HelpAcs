import 'package:hive/hive.dart';

part 'pregnancy_enums.g.dart';

// ─────────────────────────────────────────────
// TypeId 20 — Risco da Gestação
// ─────────────────────────────────────────────

@HiveType(typeId: 20)
enum PregnancyRisk {
  @HiveField(0)
  habitual,

  @HiveField(1)
  highRisk,
}

// ─────────────────────────────────────────────
// TypeId 21 — Tipo de Consulta (6 fixas)
// ─────────────────────────────────────────────

@HiveType(typeId: 21)
enum ConsultationType {
  @HiveField(0)
  first,

  @HiveField(1)
  second,

  @HiveField(2)
  third,

  @HiveField(3)
  fourth,

  @HiveField(4)
  fifth,

  @HiveField(5)
  sixth,

  @HiveField(6)
  dental,
}

// ─────────────────────────────────────────────
// TypeId 22 — Tipo de Ultrassom (4 fixos)
// ─────────────────────────────────────────────

@HiveType(typeId: 22)
enum UltrasoundType {
  @HiveField(0)
  dating, // Datação (início)

  @HiveField(1)
  morphologicalFirst, // Morfológico 1º Trimestre

  @HiveField(2)
  morphologicalSecond, // Morfológico 2º Trimestre

  @HiveField(3)
  growth, // Crescimento (3º Trimestre)

}

// ─────────────────────────────────────────────
// TypeId 23 — Tipo de Exame Laboratorial (6 fixos)
// ─────────────────────────────────────────────

@HiveType(typeId: 23)
enum LabExamType {
  @HiveField(0)
  bloodCount, // Hemograma Completo

  @HiveField(1)
  bloodType, // Tipagem Sanguínea / Rh

  @HiveField(2)
  glucose, // Glicemia / TOTG

  @HiveField(3)
  urine, // Urina (EAS / Urocultura)

  @HiveField(4)
  serology, // Sorologias

}

// ─────────────────────────────────────────────
// TypeId 24 — Tipo de Vacina Pré-Natal (3 fixas)
// ─────────────────────────────────────────────

@HiveType(typeId: 24)
enum PrenatalVaccineType {
  @HiveField(0)
  dtpa,

  @HiveField(1)
  influenza,

  @HiveField(2)
  hepatitisB,

}

// ─────────────────────────────────────────────
// EXTENSÕES — Labels em português
// ─────────────────────────────────────────────

extension PregnancyRiskLabel on PregnancyRisk {
  String get label {
    switch (this) {
      case PregnancyRisk.habitual:
        return 'Risco Habitual';
      case PregnancyRisk.highRisk:
        return 'Alto Risco';
    }
  }
}

extension ConsultationTypeLabel on ConsultationType {
  String get label {
    const labels = [
      '1ª Consulta',
      '2ª Consulta',
      '3ª Consulta',
      '4ª Consulta',
      '5ª Consulta',
      '6ª Consulta',
      'Consulta Odontológica',
    ];
    return labels[index];
  }
}

extension UltrasoundTypeLabel on UltrasoundType {
  String get label {
    switch (this) {
      case UltrasoundType.dating:
        return 'Datação (Início da Gestação)';
      case UltrasoundType.morphologicalFirst:
        return 'Morfológico — 1º Trimestre';
      case UltrasoundType.morphologicalSecond:
        return 'Morfológico Detalhado — 2º Trimestre';
      case UltrasoundType.growth:
        return 'Crescimento — 3º Trimestre';
    }
  }
}

extension LabExamTypeLabel on LabExamType {
  String get label {
    switch (this) {
      case LabExamType.bloodCount:
        return 'Hemograma Completo';
      case LabExamType.bloodType:
        return 'Tipagem Sanguínea / Rh';
      case LabExamType.glucose:
        return 'Glicemia / TOTG';
      case LabExamType.urine:
        return 'Urina (EAS / Urocultura)';
      case LabExamType.serology:
        return 'Sorologias';
    }
  }
}

extension PrenatalVaccineTypeLabel on PrenatalVaccineType {
  String get label {
    switch (this) {
      case PrenatalVaccineType.dtpa:
        return 'DTPa (Difteria, Tétano, Coqueluche)';
      case PrenatalVaccineType.influenza:
        return 'Influenza';
      case PrenatalVaccineType.hepatitisB:
        return 'Hepatite B';
    }
  }
}