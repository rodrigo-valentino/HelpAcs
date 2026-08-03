import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/child_model.dart';
import '../models/vaccine_record_model.dart';
import '../../services/health_status_service.dart';
import '../../utils/hive_keys.dart';
import 'calendar_controller.dart';
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
    // Lê a estrutura ATIVA e atual do calendário para recalcular o status.
    // Como o calendário é editável, isso garante que o status sempre reflita
    // as regras vigentes, não uma cópia congelada.
    final calendarStructure = ref.read(activeCalendarStructureProvider);

    _child.status = HealthStatusService.calculateOverallStatus(
      child: _child,
      patientRecords: _child.vaccines,
      calendarStructure: calendarStructure,
    );
    await _child.save();
    state = AsyncValue.data(_child);

    ref.invalidate(childListControllerProvider);
  }

  /// Marca/desmarca uma dose oficial do catálogo (não-custom).
  /// Agora identificada por vaccineDefinitionKey + doseNumber, não mais
  /// por comparação de texto (name/group).
  Future<void> toggleVaccine({
    required int vaccineDefinitionKey,
    required int groupKey,
    required int doseNumber,
  }) async {
    var recordIndex = _child.vaccines.indexWhere((r) =>
        r.vaccineDefinitionKey == vaccineDefinitionKey && r.doseNumber == doseNumber);

    if (recordIndex >= 0) {
      _child.vaccines[recordIndex].applied = !_child.vaccines[recordIndex].applied;
    } else {
      // Resolve nome/grupo atuais para gravar como snapshot inicial.
      final vaccines = ref.read(calendarVaccinesProvider).valueOrNull ?? [];
      final groups = ref.read(calendarGroupsProvider).valueOrNull ?? [];
      final vaccine = vaccines.where((v) => v.key == vaccineDefinitionKey).firstOrNull;
      final group = groups.where((g) => g.key == groupKey).firstOrNull;

      _child.vaccines.add(VaccineRecord(
        name: vaccine?.name ?? 'Vacina',
        group: group?.label ?? 'Grupo',
        doseNumber: doseNumber,
        applied: true,
        vaccineDefinitionKey: vaccineDefinitionKey,
        groupKey: groupKey,
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

  /// Vacina personalizada (fora do catálogo — não vira VaccineDefinitionModel).
  /// Fica vinculada a um `groupKey` só para efeito de AGRUPAMENTO visual na
  /// tela (aparece junto das vacinas oficiais daquele grupo). `groupLabel`
  /// é gravado como snapshot de exibição, igual às vacinas oficiais.
  Future<void> addCustomVaccine({
    required int groupKey,
    required String groupLabel,
    required String vaccineName,
    String? observation,
  }) async {
    final sameName = _child.vaccines.where((r) =>
        r.isCustom && r.name.toLowerCase() == vaccineName.toLowerCase() && r.groupKey == groupKey);
    final nextDose = sameName.isEmpty ? 1 : sameName.map((r) => r.doseNumber).reduce(max) + 1;

    _child.vaccines.add(
      VaccineRecord(
        group: groupLabel,
        name: vaccineName,
        doseNumber: nextDose,
        applied: false,
        isCustom: true,
        observation: observation,
        groupKey: groupKey,
      ),
    );
    await _saveAndSync();
  }

  /// Marca/desmarca todas as doses de todas as vacinas de um grupo.
  Future<void> toggleGroupVaccines({
    required int groupKey,
    required bool markAll,
  }) async {
    final vaccines = ref.read(calendarVaccinesProvider).valueOrNull ?? [];
    final groups = ref.read(calendarGroupsProvider).valueOrNull ?? [];
    final group = groups.where((g) => g.key == groupKey).firstOrNull;
    final vaccinesInGroup = vaccines.where((v) => v.groupKey == groupKey && v.active);

    for (final vaccine in vaccinesInGroup) {
      final vaccineKey = vaccine.key as int;

      for (var doseNumber = 1; doseNumber <= vaccine.totalDoses; doseNumber++) {
        final idx = _child.vaccines.indexWhere(
          (r) => r.vaccineDefinitionKey == vaccineKey && r.doseNumber == doseNumber,
        );

        if (idx >= 0) {
          _child.vaccines[idx].applied = markAll;
        } else if (markAll) {
          _child.vaccines.add(VaccineRecord(
            name: vaccine.name,
            group: group?.label ?? 'Grupo',
            doseNumber: doseNumber,
            applied: true,
            vaccineDefinitionKey: vaccineKey,
            groupKey: groupKey,
          ));
        }
      }
    }
    await _saveAndSync();
  }
}