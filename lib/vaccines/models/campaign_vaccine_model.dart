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

  @HiveField(3, defaultValue: true)
  bool applied;

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