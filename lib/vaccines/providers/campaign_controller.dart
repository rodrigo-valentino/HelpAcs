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
      // Adiciona o novo registro histórico
      child.campaignVaccines.add(
        CampaignVaccineModel(
          name: vaccineName,
          year: year,
          createdAt: DateTime.now(),
        ),
      );

      await child.save();
      
      // Atualiza a tela de vacinação atual
      ref.invalidate(vaccinationControllerProvider(childKey));
    }
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

// Provider simples para injetar a classe onde precisarmos
final campaignControllerProvider = Provider((ref) => CampaignController(ref));