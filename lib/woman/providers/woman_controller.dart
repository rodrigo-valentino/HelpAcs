// lib/woman/providers/woman_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/woman_model.dart';
import '../services/woman_status_service.dart';
import '../../utils/hive_keys.dart';

final womanListControllerProvider =
    AsyncNotifierProvider<WomanController, List<WomanModel>>(
  WomanController.new,
);

class WomanController extends AsyncNotifier<List<WomanModel>> {
  late Box<WomanModel> _box;

  @override
  Future<List<WomanModel>> build() async {
    _box = Hive.box<WomanModel>(HiveKeys.womanBox);
    return _fetchAll();
  }

  List<WomanModel> _fetchAll() => _box.values.toList();

  // ── CRUD ───────────────────────────────────────────────────────────────────

  Future<void> addWoman(
    String name,
    DateTime birthDate, {
    String? notes,
    bool isSus = true,
  }) async {
    final normalizedName = name.toLowerCase().trim();
    final alreadyExists = _box.values
        .any((w) => w.name.toLowerCase().trim() == normalizedName);

    if (alreadyExists) {
      throw Exception('Paciente "$name" já está cadastrada.');
    }

    final woman = WomanModel()
      ..name = name
      ..birthDate = birthDate
      ..notes = notes
      ..isSus = isSus;

    await _box.add(woman);

    state = AsyncValue.data(_fetchAll());
  }

  Future<void> updateExamDate(
    int id, {
    required DateTime lastDate,
    required bool isPreventivo,
    DateTime? nextDate,
  }) async {
    final woman = _box.get(id);
    if (woman == null) return;

    if (isPreventivo) {
      woman.lastPreventivoDate = lastDate;
      woman.nextPreventivoDate = nextDate ??
          lastDate.add(
            const Duration(days: WomanStatusService.preventivoPeriodDays),
          );
    } else {
      woman.lastMammographyDate = lastDate;
      woman.nextMammographyDate = nextDate ??
          lastDate.add(
            const Duration(days: WomanStatusService.mammographyPeriodDays),
          );
    }

    await woman.save();

    state = AsyncValue.data(_fetchAll());
  }

  Future<void> deleteWomen(Set<int> ids) async {
    await _box.deleteAll(ids);
    state = AsyncValue.data(_fetchAll());
  }

  Future<void> updateWomanInfo(
    int id, {
    required String name,
    required DateTime birthDate,
    String? notes,
    required bool isSus,
  }) async {
    final woman = _box.get(id);
    if (woman == null) return;

    woman.name = name;
    woman.birthDate = birthDate;
    woman.notes = notes;
    woman.isSus = isSus;

    await woman.save();

    state = AsyncValue.data(_fetchAll());
  }
}