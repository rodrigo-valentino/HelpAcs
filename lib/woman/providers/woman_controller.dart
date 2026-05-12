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

  // Hive é síncrono internamente; _fetchAll não precisa ser async.
  // A ordenação final é responsabilidade da UI (ListFilterService),
  // portanto não ordenamos aqui para evitar trabalho duplicado.
  List<WomanModel> _fetchAll() => _box.values.toList();

  // ── CRUD ───────────────────────────────────────────────────────────────────

  /// Adiciona uma nova paciente.
  ///
  /// Lança [Exception] se já existir cadastro com o mesmo nome
  /// (comparação case-insensitive e sem espaços extras), permitindo que
  /// a UI — inclusive a importação em lote — exiba o erro corretamente.
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

    // Atualiza o estado diretamente, sem passar por AsyncValue.loading,
    // evitando o flash de spinner na UI para operações síncronas do Hive.
    state = AsyncValue.data(_fetchAll());
  }

  /// Atualiza a data de realização e próximo vencimento de um exame.
  ///
  /// Se [nextDate] não for fornecida, o sistema calcula automaticamente
  /// usando os períodos definidos em [WomanStatusService].
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

    // save() é o correto para HiveObjects já linkados à box.
    // put() seria redundante e potencialmente inconsistente.
    await woman.save();

    state = AsyncValue.data(_fetchAll());
  }

  /// Exclui múltiplas pacientes pelos seus ids Hive.
  Future<void> deleteWomen(Set<int> ids) async {
    await _box.deleteAll(ids);
    state = AsyncValue.data(_fetchAll());
  }

  /// Atualiza dados cadastrais (nome, nascimento, notas, tipo de atendimento).
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