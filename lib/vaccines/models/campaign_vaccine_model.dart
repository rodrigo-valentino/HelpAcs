import 'package:hive/hive.dart';

part 'campaign_vaccine_model.g.dart';

@HiveType(typeId: 4) // Próximo ID disponível
class CampaignVaccineModel {
  @HiveField(0)
  String name;

  @HiveField(1)
  int year;

  @HiveField(2)
  DateTime createdAt;

  CampaignVaccineModel({
    required this.name,
    required this.year,
    required this.createdAt,
  });
}