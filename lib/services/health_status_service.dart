import '../vaccines/models/child_model.dart';
import '../vaccines/models/vaccine_record_model.dart';
import '../enums/health_status.dart';

class VaccineRule {
  final String group;
  final String name;
  final int doseNumber;

  const VaccineRule({
    required this.group,
    required this.name,
    required this.doseNumber,
  });
}

class HealthStatusService {
  HealthStatusService._();

  static const List<VaccineRule> vaccineRules = [
 VaccineRule(group: 'Ao nascer', name: 'BCG', doseNumber: 1),
 VaccineRule(group: 'Ao nascer', name: 'Hepatite B', doseNumber: 1),

 VaccineRule(group: '2 meses', name: 'Penta (DTP+Hib+HepB)', doseNumber: 1),
 VaccineRule(group: '2 meses', name: 'VIP (Pólio Inativada)', doseNumber: 1),
 VaccineRule(group: '2 meses', name: 'Pneumocócica 10v', doseNumber: 1),
 VaccineRule(group: '2 meses', name: 'Rotavírus', doseNumber: 1),

 VaccineRule(group: '3 meses', name: 'Meningocócica C', doseNumber: 1),

 VaccineRule(group: '4 meses', name: 'Rotavírus', doseNumber: 2),

 VaccineRule(group: '5 meses', name: 'Meningocócica C', doseNumber: 2),

 VaccineRule(group: '6 meses', name: 'Penta (DTP+Hib+HepB)', doseNumber: 3),
 VaccineRule(group: '6 meses', name: 'VIP (Pólio Inativada)', doseNumber: 3),

 VaccineRule(group: '9 meses', name: 'Febre Amarela', doseNumber: 1),

 VaccineRule(group: '12 meses', name: 'Tríplice Viral (SCR)', doseNumber: 1),
 VaccineRule(group: '12 meses', name: 'Pneumocócica 10v', doseNumber: 3),
 VaccineRule(group: '12 meses', name: 'Meningocócica C', doseNumber: 3),

 VaccineRule(group: '15 meses', name: 'Tetraviral (SCRV)', doseNumber: 1),
 VaccineRule(group: '15 meses', name: 'Hepatite A', doseNumber: 1),
 VaccineRule(group: '15 meses', name: 'DTP (Tríplice Bacteriana)', doseNumber: 1),
 VaccineRule(group: '15 meses', name: 'VIP (Pólio Inativada)', doseNumber: 4),

 VaccineRule(group: '4 anos', name: 'DTP (Tríplice Bacteriana)', doseNumber: 2),
 VaccineRule(group: '4 anos', name: 'VIP (Pólio Inativada)', doseNumber: 5),
 VaccineRule(group: '4 anos', name: 'Varicela', doseNumber: 2),
 VaccineRule(group: '4 anos', name: 'Febre Amarela', doseNumber: 2),

 VaccineRule(group: '11 a 14 anos', name: 'HPV', doseNumber: 2),
];

  /// RN05: Calcula a data exata em que a vacina deve ser tomada com base no nascimento
  static DateTime calculateDueDate(DateTime birthDate, String group) {
    // Zera as horas para cálculos justos
    final baseDate = DateTime(birthDate.year, birthDate.month, birthDate.day);

    if (group == 'Ao nascer') return baseDate;
    
    if (group.contains('meses') || group.contains('mês')) {
      final months = int.tryParse(group.split(' ').first) ?? 0;
      // O Dart é inteligente: se o mês passar de 12, ele avança o ano automaticamente!
      return DateTime(baseDate.year, baseDate.month + months, baseDate.day);
    }
    
    if (group.contains('ano') || group.contains('anos')) {
      final years = int.tryParse(group.split(' ').first) ?? 0;
      return DateTime(baseDate.year + years, baseDate.month, baseDate.day);
    }
    
    if (group == '11 a 14 anos') {
      return DateTime(baseDate.year + 11, baseDate.month, baseDate.day);
    }

    return baseDate;
  }

  /// RF10: Calcula o status geral da criança
  static HealthStatus calculateOverallStatus({
    required ChildModel child,
    required List<VaccineRecord> patientRecords, // As vacinas que já estão no banco para esta criança
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    bool hasWarning = false;

    // Varre todas as regras do calendário oficial
    for (final rule in vaccineRules) {
      // Procura se a criança tem um registro salvo para esta vacina específica
      final record = patientRecords.where(
        (r) => r.name == rule.name && r.group == rule.group && r.doseNumber == rule.doseNumber
      ).firstOrNull;

      // Se a vacina já foi aplicada, pulamos para a próxima
      if (record != null && record.applied) {
        continue;
      }

      // Calcula a data de vencimento desta vacina (RF09)
      final dueDate = calculateDueDate(child.birthDate, rule.group);
      
      // Diferença em dias: (Vencimento - Hoje)
      final differenceInDays = dueDate.difference(today).inDays;

      // REGRA: Atrasado (Existe vacina vencida sem aplicação)
      if (differenceInDays < 0) {
        // Encontrou UMA atrasada? O status geral já vira "Overdue" imediatamente (Prioridade Máxima)
        return HealthStatus.overdue; 
      }

      // REGRA: Atenção (Existe vacina próxima do vencimento, <= 3 dias)
      if (differenceInDays >= 0 && differenceInDays <= 3) {
        hasWarning = true; // Guarda a flag, mas continua checando se tem alguma atrasada
      }
    }

    // Se varreu tudo e achou aviso de 3 dias...
    if (hasWarning) {
      return HealthStatus.warning;
    }

    // Se não tem atrasadas nem avisos próximos, está EM DIA (RF10)
    return HealthStatus.upToDate;
  }
}