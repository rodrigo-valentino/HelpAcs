import 'package:hive/hive.dart';

part 'vaccine_record_model.g.dart';

@HiveType(typeId: 3) // Próximo ID disponível no seu banco
class VaccineRecord extends HiveObject {
  @HiveField(0)
  String name; // Nome da vacina (ex: "BCG")

  @HiveField(1)
  int doseNumber; // 1ª dose, 2ª dose...

  @HiveField(2)
  bool applied; // Checkbox marcado?

  @HiveField(3)
  bool isCustom; // É uma vacina personalizada (RF08)?

  @HiveField(4)
  String? observation;

  @HiveField(5)
  String group; // Faixa etária (ex: "2 meses")

  VaccineRecord({
    required this.name,
    required this.doseNumber,
    this.applied = false,
    this.isCustom = false,
    this.observation,
    required this.group,
  });
}