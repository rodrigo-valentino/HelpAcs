import 'package:hive/hive.dart';

part 'vaccine_record_model.g.dart';

@HiveType(typeId: 3)
class VaccineRecord {
  /// SNAPSHOT: nome da vacina no momento em que este registro foi
  /// criado/editado. Usado como exibição de fallback quando a definição
  /// original (vaccineDefinitionKey) não existe mais no catálogo
  /// (foi excluída) ou quando isCustom = true (vacina sem catálogo).
  @HiveField(0)
  String name;

  @HiveField(1)
  int doseNumber;

  @HiveField(2)
  bool applied;

  @HiveField(3)
  bool isCustom;

  @HiveField(4)
  String? observation;

  /// SNAPSHOT: nome do grupo no momento do registro. Mesmo racional do
  /// campo `name` acima.
  @HiveField(5)
  String group;

  /// Referência imutável à VaccineDefinitionModel do catálogo.
  /// NULL quando isCustom = true (vacina personalizada não tem catálogo).
  /// Esta é a fonte da verdade "estrutural" — a UI deve preferir resolver
  /// o nome/grupo atuais a partir deste ID, e só cair para `name`/`group`
  /// (snapshot) se a definição não existir mais.
  @HiveField(6)
  int? vaccineDefinitionKey;

  /// Referência imutável ao VaccineGroupModel no momento da aplicação.
  /// Guardamos aqui (e não só via vaccineDefinitionKey.groupKey) porque
  /// a vacina pode ser MOVIDA de grupo depois — e queremos poder decidir,
  /// no futuro, se o histórico deve "seguir" a vacina para o novo grupo
  /// ou preservar em qual grupo ela estava quando foi aplicada. Por ora,
  /// a tela resolve o grupo atual via vaccineDefinitionKey; este campo
  /// fica disponível para reforçar o snapshot caso decidam mudar essa regra.
  @HiveField(7)
  int? groupKey;

  VaccineRecord({
    required this.name,
    required this.doseNumber,
    this.applied = false,
    this.isCustom = false,
    this.observation,
    required this.group,
    this.vaccineDefinitionKey,
    this.groupKey,
  });
}