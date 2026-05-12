// lib/woman/services/woman_status_service.dart

import '../../enums/health_status.dart';
import '../../utils/date_formatter.dart';
import '../models/woman_model.dart';

/// Centraliza todas as regras clínicas do módulo Saúde da Mulher.
///
/// Mantém o [WomanModel] como simples container de dados e concentra
/// aqui faixas etárias, períodos e cálculo de status — facilitando
/// testes unitários e futuras mudanças de protocolo clínico.
class WomanStatusService {
  WomanStatusService._();

  // ── Períodos clínicos ──────────────────────────────────────────────────────

  /// Periodicidade do preventivo: anual.
  static const int preventivoPeriodDays = 365;

  /// Periodicidade da mamografia: bienal.
  static const int mammographyPeriodDays = 730;

  // ── Faixas etárias ─────────────────────────────────────────────────────────

  static const int preventivoMinAge = 25;
  static const int preventivoMaxAge = 64;

  static const int mammographyMinAge = 50;
  static const int mammographyMaxAge = 74;

  // ── Janela de atenção ──────────────────────────────────────────────────────

  /// Exames que vencem em até 30 dias recebem status [HealthStatus.warning].
  static const int warningWindowDays = 30;

  // ── Status por exame ───────────────────────────────────────────────────────

  /// Retorna o status do preventivo.
  /// Retorna `null` se a paciente estiver fora da faixa etária (25–64 anos).
  static HealthStatus? getPreventivoStatus(WomanModel woman) {
    final age = DateFormatter.calculateAge(woman.birthDate);
    if (age < preventivoMinAge || age > preventivoMaxAge) return null;
    if (woman.lastPreventivoDate == null) return HealthStatus.pending;

    final dueDate = woman.nextPreventivoDate ??
        woman.lastPreventivoDate!
            .add(const Duration(days: preventivoPeriodDays));

    return _calculateStatus(dueDate);
  }

  /// Retorna o status da mamografia.
  /// Retorna `null` se a paciente estiver fora da faixa etária (50–74 anos).
  static HealthStatus? getMammographyStatus(WomanModel woman) {
    final age = DateFormatter.calculateAge(woman.birthDate);
    if (age < mammographyMinAge || age > mammographyMaxAge) return null;
    if (woman.lastMammographyDate == null) return HealthStatus.pending;

    final dueDate = woman.nextMammographyDate ??
        woman.lastMammographyDate!
            .add(const Duration(days: mammographyPeriodDays));

    return _calculateStatus(dueDate);
  }

  // ── Status agregado ────────────────────────────────────────────────────────

  /// Status mais crítico entre os exames aplicáveis, para exibição no badge.
  ///
  /// Prioridade: overdue › warning › pending › upToDate
  ///
  /// Retorna `null` se nenhum exame for aplicável para a faixa etária.
  static HealthStatus? getBadgeStatus(WomanModel woman) {
    final applicable = _applicableStatuses(woman);
    if (applicable.isEmpty) return null;

    if (applicable.contains(HealthStatus.overdue)) return HealthStatus.overdue;
    if (applicable.contains(HealthStatus.warning)) return HealthStatus.warning;
    if (applicable.contains(HealthStatus.pending)) return HealthStatus.pending;
    return HealthStatus.upToDate;
  }

  /// Peso numérico para ordenação por prioridade clínica na lista.
  ///
  /// 4 = Atrasado · 3 = Atenção · 2 = Pendente · 1 = Em Dia · 0 = Fora da faixa
  ///
  /// Corrige o bug anterior onde pacientes com exames pendentes (nunca
  /// realizados) recebiam peso 0, ficando misturadas com pacientes sem
  /// exames aplicáveis.
  static int getGeneralStatusWeight(WomanModel woman) {
    final applicable = _applicableStatuses(woman);
    if (applicable.isEmpty) return 0;

    if (applicable.contains(HealthStatus.overdue)) return 4;
    if (applicable.contains(HealthStatus.warning)) return 3;
    if (applicable.contains(HealthStatus.pending)) return 2;
    if (applicable.contains(HealthStatus.upToDate)) return 1;
    return 0;
  }

  // ── Privados ───────────────────────────────────────────────────────────────

  static List<HealthStatus> _applicableStatuses(WomanModel woman) {
    return [
      getPreventivoStatus(woman),
      getMammographyStatus(woman),
    ].whereType<HealthStatus>().toList();
  }

  static HealthStatus _calculateStatus(DateTime nextDue) {
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final dueNorm = DateTime(nextDue.year, nextDue.month, nextDue.day);

    if (todayNorm.isAfter(dueNorm)) return HealthStatus.overdue;

    final daysLeft = dueNorm.difference(todayNorm).inDays;
    if (daysLeft <= warningWindowDays) return HealthStatus.warning;

    return HealthStatus.upToDate;
  }
}