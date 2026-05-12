// lib/woman/models/woman_model.dart

import 'package:hive/hive.dart';
import '../../utils/date_formatter.dart';
import '../../enums/health_status.dart';
import '../services/woman_status_service.dart';

part 'woman_model.g.dart';

@HiveType(typeId: 5)
class WomanModel extends HiveObject {
  // ── Identificador ──────────────────────────────────────────────────────────

  /// Chave Hive convertida para int.
  ///
  /// ⚠️ Acesso antes do primeiro [save]/[add] retorna -1 (estado inválido).
  /// O assert em modo debug ajuda a detectar esse uso acidental.
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

  // Nota de migration: campo adicionado após a versão inicial.
  // Dados gravados antes deste campo existir serão lidos pelo adapter gerado
  // como o valor padrão do Dart para bool (false), e NÃO como true.
  // Se isso for um problema, considere migrar com: isSus ??= true no controller.
  @HiveField(7)
  bool isSus = true;

  // ── Getters simples ────────────────────────────────────────────────────────

  int get age => DateFormatter.calculateAge(birthDate);

  // ── Delegação ao WomanStatusService ───────────────────────────────────────
  //
  // A lógica clínica (faixas etárias, períodos, cálculo de status) vive em
  // WomanStatusService. O model apenas expõe os resultados para conveniência
  // de uso nas widgets e no ListFilterService.

  /// Status do preventivo. `null` = fora da faixa etária (25–64 anos).
  HealthStatus? get preventivoStatus =>
      WomanStatusService.getPreventivoStatus(this);

  /// Status da mamografia. `null` = fora da faixa etária (50–74 anos).
  HealthStatus? get mammographyStatus =>
      WomanStatusService.getMammographyStatus(this);

  /// Status mais crítico para exibição no badge da lista.
  /// `null` = nenhum exame aplicável para esta paciente.
  HealthStatus? get badgeStatus => WomanStatusService.getBadgeStatus(this);

  /// Peso numérico para ordenação por prioridade (4 = mais crítico).
  int get generalStatusWeight =>
      WomanStatusService.getGeneralStatusWeight(this);
}

// ── Extensões ──────────────────────────────────────────────────────────────

extension WomanListExtensions on List<WomanModel> {
  /// Busca uma paciente pelo id sem lançar exceção.
  /// Retorna `null` se não encontrada.
  WomanModel? lookup(int id) {
    try {
      return firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}