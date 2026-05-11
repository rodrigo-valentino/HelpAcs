import 'dart:math'; // 🆕 Necessário para calcular a próxima dose
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/child_model.dart';
import '../models/vaccine_record_model.dart';
import '../../services/health_status_service.dart';
import '../../utils/hive_keys.dart';
import './child_list_controller.dart';

final vaccinationControllerProvider = AsyncNotifierProvider.family<VaccinationController, ChildModel, int>(() {
  return VaccinationController();
});

class VaccinationController extends FamilyAsyncNotifier<ChildModel, int> {
  late ChildModel _child;

  @override
  Future<ChildModel> build(int arg) async {
    final box = await Hive.openBox<ChildModel>(HiveKeys.childrenBox);
    final child = box.get(arg);
    if (child == null) throw StateError('Paciente não encontrado na base de dados (ID: $arg).');
    
    _child = child;
    return _child;
  }

  Future<void> _saveAndSync() async {
    _child.status = HealthStatusService.calculateOverallStatus(
      child: _child, 
      patientRecords: _child.vaccines,
    );
    await _child.save(); 
    state = AsyncValue.data(_child); 
    
    ref.invalidate(childListControllerProvider); 
  }

  Future<void> toggleVaccine({
    required String groupName,
    required String vaccineName,
    required int doseNumber,
  }) async {
    var recordIndex = _child.vaccines.indexWhere((r) => 
      r.group == groupName && r.name == vaccineName && r.doseNumber == doseNumber
    );

    if (recordIndex >= 0) {
      _child.vaccines[recordIndex].applied = !_child.vaccines[recordIndex].applied;
    } else {
      _child.vaccines.add(VaccineRecord(
        group: groupName, name: vaccineName, doseNumber: doseNumber, applied: true,
      ));
    }
    await _saveAndSync();
  }

  Future<void> addImage(String path) async {
    final currentImages = List<String>.from(_child.imagePaths);
    currentImages.add(path);
    _child.imagePaths = currentImages;
    await _saveAndSync(); 
  }

  Future<void> removeImage(int index) async {
    final currentImages = List<String>.from(_child.imagePaths);
    currentImages.removeAt(index);
    _child.imagePaths = currentImages;
    await _saveAndSync();
  }

  Future<void> addCustomVaccine({
    required String groupName,
    required String vaccineName,
    String? observation,
  }) async {
    final sameName = _child.vaccines.where((r) => 
      r.isCustom && r.name.toLowerCase() == vaccineName.toLowerCase() && r.group == groupName
    );
    final nextDose = sameName.isEmpty ? 1 : sameName.map((r) => r.doseNumber).reduce(max) + 1;

    _child.vaccines.add(
      VaccineRecord(
        group: groupName,
        name: vaccineName,
        doseNumber: nextDose,
        applied: false, 
        isCustom: true, 
        observation: observation,
      )
    );
    await _saveAndSync(); 
  }

  Future<void> toggleGroupVaccines({
    required String groupName,
    required bool markAll,
  }) async {
    final rulesForGroup = HealthStatusService.vaccineRules
        .where((r) => r.group == groupName).toList();

    for (final rule in rulesForGroup) {
      final idx = _child.vaccines.indexWhere(
        (r) => r.group == groupName && r.name == rule.name && r.doseNumber == rule.doseNumber,
      );

      if (idx >= 0) {
        _child.vaccines[idx].applied = markAll;
      } else if (markAll) {
        _child.vaccines.add(VaccineRecord(
          group: groupName, name: rule.name, doseNumber: rule.doseNumber, applied: true,
        ));
      }
    }
    await _saveAndSync();
  }
}