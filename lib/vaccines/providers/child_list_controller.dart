import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/child_model.dart';
import '../../services/health_status_service.dart';
import '../../utils/hive_keys.dart';
import 'calendar_controller.dart';

final childListControllerProvider = AsyncNotifierProvider<ChildListController, List<ChildModel>>(() {
  return ChildListController();
});

final childSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredChildrenProvider = Provider<List<ChildModel>>((ref) {
  final allChildren = ref.watch(childListControllerProvider).valueOrNull ?? [];
  final query = ref.watch(childSearchQueryProvider).toLowerCase();

  if (query.isEmpty) return allChildren;

  return allChildren.where((child) {
    return child.name.toLowerCase().contains(query) ||
        (child.guardianName?.toLowerCase().contains(query) ?? false);
  }).toList();
});

class ChildListController extends AsyncNotifier<List<ChildModel>> {
  @override
  Future<List<ChildModel>> build() async {
    final box = await Hive.openBox<ChildModel>(HiveKeys.childrenBox);
    final children = box.values.toList();

    // Garante que o catálogo esteja carregado antes de recalcular status.
    // Como calendarGroupsProvider/calendarVaccinesProvider já fazem
    // Hive.openBox internamente, isso também abre as boxes se necessário.
    await ref.read(calendarGroupsProvider.future);
    await ref.read(calendarVaccinesProvider.future);
    final calendarStructure = ref.read(activeCalendarStructureProvider);

    bool needsSave = false;

    for (final child in children) {
      final calculatedStatus = HealthStatusService.calculateOverallStatus(
        child: child,
        patientRecords: child.vaccines,
        calendarStructure: calendarStructure,
      );

      if (child.status != calculatedStatus) {
        child.status = calculatedStatus;
        await child.save();
        needsSave = true;
      }
    }

    return needsSave ? box.values.toList() : children;
  }

  Future<void> addChild(ChildModel child) async {
    final box = Hive.box<ChildModel>(HiveKeys.childrenBox);
    await box.add(child);
    state = AsyncValue.data(box.values.toList());
  }

  Future<void> importChild(ChildModel child) async {
    final box = Hive.box<ChildModel>(HiveKeys.childrenBox);
    final existing = box.values.toList();

    final String? incomingCpf = _normalizeCpf(child.cpf);

    for (final record in existing) {
      final String? recordCpf = _normalizeCpf(record.cpf);

      if (incomingCpf != null && incomingCpf.isNotEmpty &&
          recordCpf != null && recordCpf.isNotEmpty &&
          incomingCpf == recordCpf) {
        throw Exception('já existe um paciente com o CPF ${child.cpf} cadastrado.');
      }

      if ((incomingCpf == null || incomingCpf.isEmpty) &&
          (recordCpf == null || recordCpf.isEmpty)) {
        final sameDate = _sameDate(child.birthDate, record.birthDate);
        final sameName = child.name.trim().toLowerCase() == record.name.trim().toLowerCase();

        if (sameName && sameDate) {
          throw Exception(
            'já existe um paciente com o nome "${record.name}" e a mesma data de nascimento.',
          );
        }
      }
    }

    await box.add(child);
    state = AsyncValue.data(box.values.toList());
  }

  static String? _normalizeCpf(String? cpf) {
    if (cpf == null) return null;
    return cpf.replaceAll(RegExp(r'[\s.\-/]'), '').trim();
  }

  static bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> deleteChildren(List<dynamic> keys) async {
    final box = Hive.box<ChildModel>(HiveKeys.childrenBox);
    await box.deleteAll(keys);
    state = AsyncValue.data(box.values.toList());
  }

  Future<void> updateChild({
    required dynamic key,
    required String name,
    required DateTime birthDate,
    String? guardian,
    String? notes,
    String? cpf,
  }) async {
    final box = Hive.box<ChildModel>(HiveKeys.childrenBox);
    final child = box.get(key);

    if (child != null) {
      child.name = name;
      child.birthDate = birthDate;
      child.guardianName = guardian;
      child.notes = notes;
      child.cpf = cpf;

      await child.save();
      state = AsyncValue.data(box.values.toList());
    }
  }
}