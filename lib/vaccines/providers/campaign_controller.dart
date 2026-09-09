import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/child_model.dart';
import '../models/campaign_vaccine_model.dart';
import '../../utils/hive_keys.dart';
import './vaccination_controller.dart';

class CampaignController {
  final Ref ref;
  CampaignController(this.ref);

  Future<void> addCampaignVaccine({
    required int childKey,
    required String vaccineName,
    required int year,
  }) async {
    final box = Hive.box<ChildModel>(HiveKeys.childrenBox);
    final child = box.get(childKey);

    if (child != null) {
      child.campaignVaccines.add(
        CampaignVaccineModel(
          name: vaccineName,
          year: year,
          createdAt: DateTime.now(),
        ),
      );

      await child.save();
      ref.invalidate(vaccinationControllerProvider(childKey));
    }
  }

  Future<void> toggleTemplateVaccine({
    required int childKey,
    required String name,
    required int ageMonths,
  }) async {
    final box = Hive.box<ChildModel>(HiveKeys.childrenBox);
    final child = box.get(childKey);
    if (child == null) return;

    final index = child.campaignVaccines.indexWhere(
      (r) => r.name == name && r.dueAgeMonths == ageMonths,
    );

    if (index >= 0) {
      child.campaignVaccines[index].applied = !child.campaignVaccines[index].applied;
    } else {
      child.campaignVaccines.add(
        CampaignVaccineModel(
          name: name,
          year: DateTime.now().year,
          createdAt: DateTime.now(),
          applied: true,
          dueAgeMonths: ageMonths,
        ),
      );
    }

    await child.save();
    ref.invalidate(vaccinationControllerProvider(childKey));
  }

  Future<void> deleteCampaignVaccine({
    required int childKey,
    required CampaignVaccineModel record,
  }) async {
    final box = Hive.box<ChildModel>(HiveKeys.childrenBox);
    final child = box.get(childKey);

    if (child != null) {
      child.campaignVaccines.remove(record);
      await child.save();
      ref.invalidate(vaccinationControllerProvider(childKey));
    }
  }
}

final campaignControllerProvider = Provider((ref) => CampaignController(ref));