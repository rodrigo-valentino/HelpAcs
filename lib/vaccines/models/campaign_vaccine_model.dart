import 'package:hive/hive.dart';

part 'campaign_vaccine_model.g.dart';

@HiveType(typeId: 4)
class CampaignVaccineModel {
  @HiveField(0)
  String name;

  @HiveField(1)
  int year;

  @HiveField(2)
  DateTime createdAt;

  /// Se a vacina foi de fato aplicada.
  /// Para entradas criadas pelo fluxo LIVRE (CampaignVaccineDialog), o
  /// padrão é `true` — a própria existência do registro já significava
  /// "foi tomada" (comportamento original, mantido).
  /// Para os itens PADRÃO (toggle por idade), o registro pode existir
  /// com applied = false quando o usuário desmarca.
  /// `defaultValue: true` garante compatibilidade com registros salvos
  /// antes deste campo existir.
  @HiveField(3, defaultValue: true)
  bool applied;

  /// Preenchido SOMENTE para vacinas de campanha PADRÃO (predefinidas),
  /// vinculadas à idade da criança em meses (ex.: 6, 7).
  /// Nulo para entradas livres criadas manualmente via CampaignVaccineDialog.
  @HiveField(4)
  int? dueAgeMonths;

  CampaignVaccineModel({
    required this.name,
    required this.year,
    required this.createdAt,
    this.applied = true,
    this.dueAgeMonths,
  });
}