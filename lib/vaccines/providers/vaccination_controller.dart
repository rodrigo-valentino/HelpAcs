import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/child_model.dart';
import '../models/vaccine_record_model.dart';
import '../../services/health_status_service.dart';
import '../../utils/hive_keys.dart';

final vaccinationControllerProvider = AsyncNotifierProvider.family<VaccinationController, ChildModel, int>(() {
  return VaccinationController();
});

class VaccinationController extends FamilyAsyncNotifier<ChildModel, int> {
  late ChildModel _child;

  @override
  Future<ChildModel> build(int arg) async {
    final box = await Hive.openBox<ChildModel>(HiveKeys.childrenBox);
    
    final child = box.get(arg);
    if (child == null) {
      throw StateError('Paciente não encontrado na base de dados (ID: $arg).');
    }
    
    _child = child;
    return _child;
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
      _child.vaccines.add(
        VaccineRecord(
          group: groupName,
          name: vaccineName,
          doseNumber: doseNumber,
          applied: true,
        )
      );
    }

    _child.status = HealthStatusService.calculateOverallStatus(
      child: _child, 
      patientRecords: _child.vaccines,
    );

    await _child.save();
    
    state = AsyncValue.data(_child);
  }

  /// Adiciona uma nova foto à caderneta da criança
  Future<void> addImage(String path) async {
    // Como imagePaths pode ser const [] na primeira vez, garantimos que é mutável
    final currentImages = List<String>.from(_child.imagePaths);
    currentImages.add(path);
    
    _child.imagePaths = currentImages;
    await _child.save(); // Salva no Hive
    
    state = AsyncValue.data(_child); // Atualiza a UI
  }


  /// Remove uma foto da caderneta da criança
  Future<void> removeImage(int index) async {
    final currentImages = List<String>.from(_child.imagePaths);
    currentImages.removeAt(index);
    
    _child.imagePaths = currentImages;
    await _child.save(); // Salva no Hive
    
    state = AsyncValue.data(_child); // Atualiza a UI
  }

  Future<void> addCustomVaccine({
    required String groupName,
    required String vaccineName,
    String? observation,
  }) async {
    _child.vaccines.add(
      VaccineRecord(
        group: groupName,
        name: vaccineName,
        doseNumber: 1, // Padrão para dose única em personalizadas
        applied: false, // Inicia desmarcada para o utilizador poder marcar quando quiser
        isCustom: true, // Marca com a flag de personalizada
        observation: observation,
      )
    );

    // Salva a nova vacina na base de dados Hive
    await _child.save(); 
    
    // Atualiza o ecrã instantaneamente
    state = AsyncValue.data(_child); 
  }
}