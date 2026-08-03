import 'package:hive/hive.dart';

part 'calendar_models.g.dart';

/// Unidade de tempo usada para calcular a data de vencimento de um grupo,
/// em relação à data de nascimento da criança.
///
/// Substitui o parsing de string que existia em `HealthStatusService`
/// (ex.: `group.split(' ').first` em cima de "2 meses"), que só funcionava
/// porque os nomes dos grupos eram fixos e conhecidos no código.
/// Agora que o nome do grupo é editável pelo usuário (ex.: "Reforço Escolar"),
/// não podemos mais extrair a idade a partir do texto do label.
@HiveType(typeId: 28)
enum AgeUnit {
  @HiveField(0)
  days,

  @HiveField(1)
  months,

  @HiveField(2)
  years,
}

/// Representa uma ETAPA do calendário vacinal (ex.: "Ao nascer", "2 meses").
///
/// O `key` (herdado de HiveObject, atribuído automaticamente pelo Hive
/// quando o objeto é adicionado à box) é o ID IMUTÁVEL deste grupo.
/// Nunca comparar/relacionar grupos pelo `label` — ele pode ser editado
/// livremente pelo usuário sem afetar nada que já referencia este grupo.
@HiveType(typeId: 29)
class VaccineGroupModel extends HiveObject {
  /// Nome exibido. Editável livremente pelo usuário.
  @HiveField(0)
  String label;

  /// Quantidade de tempo após o nascimento em que este grupo vence.
  /// Ex.: ageValue = 2, ageUnit = AgeUnit.months -> "2 meses de vida".
  @HiveField(1)
  int ageValue;

  @HiveField(2)
  AgeUnit ageUnit;

  /// Posição de exibição (drag-and-drop na tela de gerenciamento).
  @HiveField(3)
  int order;

  /// Soft delete. Grupos inativos não aparecem em novos cálculos de
  /// cronograma, mas continuam existindo no banco para não quebrar
  /// registros históricos que ainda apontam para eles.
  @HiveField(4)
  bool active;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  VaccineGroupModel({
    required this.label,
    required this.ageValue,
    required this.ageUnit,
    required this.order,
    this.active = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  DateTime calculateDueDate(DateTime birthDate) {
    final base = DateTime(birthDate.year, birthDate.month, birthDate.day);
    switch (ageUnit) {
      case AgeUnit.days:
        return base.add(Duration(days: ageValue));
      case AgeUnit.months:
        return DateTime(base.year, base.month + ageValue, base.day);
      case AgeUnit.years:
        return DateTime(base.year + ageValue, base.month, base.day);
    }
  }
}

/// Representa UMA VACINA dentro de um grupo (ex.: "Penta", "VIP").
///
/// Assim como o grupo, o `key` (HiveObject) é o ID imutável. `groupKey`
/// referencia o grupo atual — pode ser alterado livremente (mover a vacina
/// de grupo) sem quebrar nenhum registro histórico, porque o histórico
/// (`VaccineRecord`) referencia a VACINA por ID, não o grupo diretamente.
@HiveType(typeId: 30)
class VaccineDefinitionModel extends HiveObject {
  /// Key do VaccineGroupModel ao qual esta vacina pertence atualmente.
  @HiveField(0)
  int groupKey;

  /// Nome exibido. Editável livremente.
  @HiveField(1)
  String name;

  /// Quantas doses esta vacina possui no esquema vacinal (>= 1).
  @HiveField(2)
  int totalDoses;

  /// Posição de exibição dentro do grupo.
  @HiveField(3)
  int order;

  /// Soft delete — mesma lógica do grupo.
  @HiveField(4)
  bool active;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  VaccineDefinitionModel({
    required this.groupKey,
    required this.name,
    required this.totalDoses,
    required this.order,
    this.active = true,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
}