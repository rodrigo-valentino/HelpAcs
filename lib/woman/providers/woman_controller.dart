import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/woman_model.dart';
import '../../utils/hive_keys.dart';

final womanListControllerProvider = AsyncNotifierProvider<WomanController, List<WomanModel>>(
  WomanController.new,
);

class WomanController extends AsyncNotifier<List<WomanModel>> {
  late Box<WomanModel> _box;

  @override
  Future<List<WomanModel>> build() async {
    _box = Hive.box<WomanModel>(HiveKeys.womanBox);
    return _fetchAll();
  }

  Future<List<WomanModel>> _fetchAll() async {
    final womenList = _box.values.toList();
    
    // Substituição do sortByName() do Isar pela ordenação nativa do Dart
    womenList.sort((a, b) => a.name.compareTo(b.name));
    
    return womenList;
  }

  Future<void> addWoman(String name, DateTime birthDate, {String? notes, bool isSus = true}) async {
    final woman = WomanModel()
      ..name = name
      ..birthDate = birthDate
      ..notes = notes
      ..isSus = isSus;

    state = const AsyncValue.loading();
    
    // Salva no Hive
    await _box.add(woman);
    
    state = await AsyncValue.guard(() => _fetchAll());
  }

  Future<void> updateExamDate(
    int id, {
    required DateTime lastDate, 
    required bool isPreventivo,
    DateTime? nextDate,
  }) async {
    state = const AsyncValue.loading();
    
    // No Hive, o get busca pela chave gerada
    final woman = _box.get(id);
    
    if (woman != null) {
      if (isPreventivo) {
        woman.lastPreventivoDate = lastDate;
        woman.nextPreventivoDate = nextDate ?? lastDate.add(const Duration(days: 365));
      } else {
        woman.lastMammographyDate = lastDate;
        woman.nextMammographyDate = nextDate ?? lastDate.add(const Duration(days: 730));
      }
      
      // O put sobrescreve o objeto na chave (id) específica
      await _box.put(id, woman);
    }
    
    state = await AsyncValue.guard(() => _fetchAll());
  }
  
  Future<void> deleteWomen(Set<int> ids) async {
    state = const AsyncValue.loading();
    
    // O Hive possui um método direto para deletar múltiplos itens por chave
    await _box.deleteAll(ids);
    
    state = await AsyncValue.guard(() => _fetchAll());
  }

  Future<void> updateWomanInfo(
    int id, {
    required String name,
    required DateTime birthDate,
    String? notes,
    required bool isSus,
  }) async {
    state = const AsyncValue.loading();
    
    final woman = _box.get(id);
    if (woman != null) {
      woman.name = name;
      woman.birthDate = birthDate;
      woman.notes = notes;
      woman.isSus = isSus;
      
      await woman.save(); // Graças ao HiveObject
    }

    state = await AsyncValue.guard(() => _fetchAll());
  }
}