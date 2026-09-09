import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/calendar_models.dart';
import '../../utils/hive_keys.dart';

class VaccineGroupWithVaccines {
  final VaccineGroupModel group;
  final List<VaccineDefinitionModel> vaccines;

  const VaccineGroupWithVaccines({required this.group, required this.vaccines});

  int get groupKey => group.key as int;
}

// GRUPOS

final calendarGroupsProvider =
    AsyncNotifierProvider<CalendarGroupsController, List<VaccineGroupModel>>(
  () => CalendarGroupsController(),
);

class CalendarGroupsController extends AsyncNotifier<List<VaccineGroupModel>> {
  @override
  Future<List<VaccineGroupModel>> build() async {
    final box = await Hive.openBox<VaccineGroupModel>(HiveKeys.calendarGroupsBox);
    return _sorted(box.values.toList());
  }

  List<VaccineGroupModel> _sorted(List<VaccineGroupModel> list) {
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  Box<VaccineGroupModel> get _box => Hive.box<VaccineGroupModel>(HiveKeys.calendarGroupsBox);

  Future<void> _refresh() async {
    state = AsyncValue.data(_sorted(_box.values.toList()));
  }

  Future<void> addGroup({
    required String label,
    required int ageValue,
    required AgeUnit ageUnit,
  }) async {
    final currentMaxOrder =
        _box.values.fold<int>(-1, (max, g) => g.order > max ? g.order : max);

    await _box.add(
      VaccineGroupModel(
        label: label.trim(),
        ageValue: ageValue,
        ageUnit: ageUnit,
        order: currentMaxOrder + 1,
      ),
    );
    await _refresh();
  }

  Future<void> updateGroup({
    required int groupKey,
    String? label,
    int? ageValue,
    AgeUnit? ageUnit,
  }) async {
    final group = _box.get(groupKey);
    if (group == null) return;

    if (label != null) group.label = label.trim();
    if (ageValue != null) group.ageValue = ageValue;
    if (ageUnit != null) group.ageUnit = ageUnit;
    group.updatedAt = DateTime.now();

    await group.save();
    await _refresh();
  }

  Future<void> archiveGroup(int groupKey) async {
    final group = _box.get(groupKey);
    if (group == null) return;
    group.active = false;
    group.updatedAt = DateTime.now();
    await group.save();
    await _refresh();
  }

  Future<void> restoreGroup(int groupKey) async {
    final group = _box.get(groupKey);
    if (group == null) return;
    group.active = true;
    group.updatedAt = DateTime.now();
    await group.save();
    await _refresh();
  }

  Future<void> deleteGroup(int groupKey) async {
    final vaccinesBox = Hive.box<VaccineDefinitionModel>(HiveKeys.calendarVaccinesBox);
    final vaccineKeysToDelete =
        vaccinesBox.values.where((v) => v.groupKey == groupKey).map((v) => v.key as int).toList();

    await vaccinesBox.deleteAll(vaccineKeysToDelete);
    await _box.delete(groupKey);

    await _refresh();
    ref.invalidate(calendarVaccinesProvider);
  }

  Future<void> reorderGroups(List<int> orderedGroupKeys) async {
    for (var i = 0; i < orderedGroupKeys.length; i++) {
      final group = _box.get(orderedGroupKeys[i]);
      if (group != null) {
        group.order = i;
        await group.save();
      }
    }
    await _refresh();
  }
}

// VACINAS

final calendarVaccinesProvider = AsyncNotifierProvider<CalendarVaccinesController,
    List<VaccineDefinitionModel>>(
  () => CalendarVaccinesController(),
);

class CalendarVaccinesController extends AsyncNotifier<List<VaccineDefinitionModel>> {
  @override
  Future<List<VaccineDefinitionModel>> build() async {
    final box = await Hive.openBox<VaccineDefinitionModel>(HiveKeys.calendarVaccinesBox);
    return _sorted(box.values.toList());
  }

  List<VaccineDefinitionModel> _sorted(List<VaccineDefinitionModel> list) {
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  Box<VaccineDefinitionModel> get _box =>
      Hive.box<VaccineDefinitionModel>(HiveKeys.calendarVaccinesBox);

  Future<void> _refresh() async {
    state = AsyncValue.data(_sorted(_box.values.toList()));
  }

  Future<void> addVaccine({
    required int groupKey,
    required String name,
    required int totalDoses,
    String? notes,
  }) async {
    final siblingsMaxOrder = _box.values
        .where((v) => v.groupKey == groupKey)
        .fold<int>(-1, (max, v) => v.order > max ? v.order : max);

    await _box.add(
      VaccineDefinitionModel(
        groupKey: groupKey,
        name: name.trim(),
        totalDoses: totalDoses,
        order: siblingsMaxOrder + 1,
        notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      ),
    );
    await _refresh();
  }

  Future<void> updateVaccine({
    required int vaccineKey,
    String? name,
    int? totalDoses,
    String? notes,
    int? groupKey, 
  }) async {
    final vaccine = _box.get(vaccineKey);
    if (vaccine == null) return;

    if (name != null) vaccine.name = name.trim();
    if (totalDoses != null) vaccine.totalDoses = totalDoses;
    if (notes != null) vaccine.notes = notes.trim().isEmpty ? null : notes.trim();
    if (groupKey != null) vaccine.groupKey = groupKey;
    vaccine.updatedAt = DateTime.now();

    await vaccine.save();
    await _refresh();
  }

  Future<void> archiveVaccine(int vaccineKey) async {
    final vaccine = _box.get(vaccineKey);
    if (vaccine == null) return;
    vaccine.active = false;
    vaccine.updatedAt = DateTime.now();
    await vaccine.save();
    await _refresh();
  }

  Future<void> restoreVaccine(int vaccineKey) async {
    final vaccine = _box.get(vaccineKey);
    if (vaccine == null) return;
    vaccine.active = true;
    vaccine.updatedAt = DateTime.now();
    await vaccine.save();
    await _refresh();
  }

  Future<void> deleteVaccine(int vaccineKey) async {
    await _box.delete(vaccineKey);
    await _refresh();
  }

  Future<void> reorderVaccinesInGroup(int groupKey, List<int> orderedVaccineKeys) async {
    for (var i = 0; i < orderedVaccineKeys.length; i++) {
      final vaccine = _box.get(orderedVaccineKeys[i]);
      if (vaccine != null) {
        vaccine.order = i;
        await vaccine.save();
      }
    }
    await _refresh();
  }
}

final fullCalendarStructureProvider = Provider<List<VaccineGroupWithVaccines>>((ref) {
  final groups = ref.watch(calendarGroupsProvider).valueOrNull ?? [];
  final vaccines = ref.watch(calendarVaccinesProvider).valueOrNull ?? [];

  return groups.map((g) {
    final groupKey = g.key as int;
    final groupVaccines = vaccines.where((v) => v.groupKey == groupKey).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return VaccineGroupWithVaccines(group: g, vaccines: groupVaccines);
  }).toList();
});

final activeCalendarStructureProvider = Provider<List<VaccineGroupWithVaccines>>((ref) {
  final full = ref.watch(fullCalendarStructureProvider);
  return full
      .where((g) => g.group.active)
      .map((g) => VaccineGroupWithVaccines(
            group: g.group,
            vaccines: g.vaccines.where((v) => v.active).toList(),
          ))
      .where((g) => g.vaccines.isNotEmpty)
      .toList();
});