import 'package:hive/hive.dart';

import 'vaccine_record_model.dart';
import '/utils/date_formatter.dart';
import '../../enums/health_status.dart';
import 'campaign_vaccine_model.dart';

part 'child_model.g.dart';

@HiveType(typeId: 1)
class ChildModel extends HiveObject {

  @HiveField(0)
  String name;

  @HiveField(1)
  DateTime birthDate;

  @HiveField(2)
  String? guardianName;

  @HiveField(3)
  String? cpf;

  @HiveField(4)
  String? notes;

  @HiveField(5)
  HealthStatus status;

  @HiveField(6)
  List<String> imagePaths;

  @HiveField(7)
  List<VaccineRecord> vaccines;

  @HiveField(8) // Use o próximo número disponível no seu ChildModel
  List<CampaignVaccineModel> campaignVaccines;

  ChildModel({
    required this.name,
    required this.birthDate,
    this.guardianName,
    this.cpf,
    this.notes,
    this.status = HealthStatus.pending,
    List<String>? imagePaths,
    List<VaccineRecord>? vaccines,
    List<CampaignVaccineModel>? campaignVaccines,
  })  : imagePaths = imagePaths ?? [],
        vaccines = vaccines ?? [],
        campaignVaccines = campaignVaccines ?? [];

  // =========================
  // Helpers
  // =========================

  int get ageInDays =>
      DateTime.now().difference(birthDate).inDays;

  int get ageInMonths =>
      ageInDays ~/ 30;

  int get ageInYears =>
      DateFormatter.calculateAge(birthDate);

  String get ageLabel {
    final days = ageInDays;
    final months = ageInMonths;
    final years = ageInYears;

    if (years >= 1) {
      return years == 1 ? '1 ano' : '$years anos';
    }

    if (months >= 1) {
      return months == 1 ? '1 mês' : '$months meses';
    }

    return days <= 1
        ? 'Recém-nascido'
        : '$days dias';
  }
}