import '../vaccines/models/child_model.dart';
import '../vaccines/models/vaccine_record_model.dart';
import '../vaccines/providers/calendar_controller.dart';
import '../enums/health_status.dart';

class HealthStatusService {
  HealthStatusService._();

  /// RN05: Calcula a data de vencimento de um grupo para uma criança.
  /// Agora delega para o próprio modelo do grupo (ageValue/ageUnit),
  /// eliminando o parsing frágil de string que existia antes
  /// (ex.: `group.split(' ').first` em cima do label "2 meses").
  static DateTime calculateDueDate(DateTime birthDate, VaccineGroupWithVaccines group) {
    return group.group.calculateDueDate(birthDate);
  }

  /// RF10: Calcula o status geral da criança.
  ///
  /// IMPORTANTE: `calendarStructure` deve ser o resultado de
  /// `activeCalendarStructureProvider` (ou seja, só grupos/vacinas ATIVOS
  /// no catálogo atual). Vacinas arquivadas não entram no cálculo de
  /// atraso — elas continuam no histórico, mas não geram cobrança de
  /// pendência para novos cadastros.
  static HealthStatus calculateOverallStatus({
    required ChildModel child,
    required List<VaccineRecord> patientRecords,
    required List<VaccineGroupWithVaccines> calendarStructure,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    bool hasWarning = false;

    for (final groupWithVaccines in calendarStructure) {
      final dueDate = calculateDueDate(child.birthDate, groupWithVaccines);
      final differenceInDays = dueDate.difference(today).inDays;

      for (final vaccine in groupWithVaccines.vaccines) {
        final vaccineKey = vaccine.key as int;

        for (var doseNumber = 1; doseNumber <= vaccine.totalDoses; doseNumber++) {
          // Resolve o registro por ID (vaccineDefinitionKey), não mais
          // por nome/grupo em texto.
          final record = patientRecords.where(
            (r) => r.vaccineDefinitionKey == vaccineKey && r.doseNumber == doseNumber,
          ).firstOrNull;

          if (record != null && record.applied) continue;

          if (differenceInDays < 0) {
            return HealthStatus.overdue;
          }

          if (differenceInDays >= 0 && differenceInDays <= 3) {
            hasWarning = true;
          }
        }
      }
    }

    if (hasWarning) return HealthStatus.warning;
    return HealthStatus.upToDate;
  }
}