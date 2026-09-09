import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/nutrition_record_model.dart';
import '../../utils/hive_keys.dart';

final nutritionHistoryControllerProvider = AutoDisposeAsyncNotifierProviderFamily<NutritionHistoryController, List<NutritionRecordModel>, int>(() {
  return NutritionHistoryController();
});

class NutritionHistoryController extends AutoDisposeFamilyAsyncNotifier<List<NutritionRecordModel>, int> {
  Box<NutritionRecordModel>? _box;

  @override
  Future<List<NutritionRecordModel>> build(int arg) async {
    _box = await Hive.openBox<NutritionRecordModel>(HiveKeys.nutritionBox);
    return _fetchSortedRecords();
  }

  List<NutritionRecordModel> _fetchSortedRecords() {
    if (_box == null) return [];
    final records = _box!.values.where((record) => record.childKey == arg).toList();
    records.sort((a, b) => b.assessmentDate.compareTo(a.assessmentDate));
    return records;
  }

  // Garante que o Box está aberto antes de deletar
  Future<bool> deleteRecord(int recordKey) async {
    try {
      _box ??= await Hive.openBox<NutritionRecordModel>(HiveKeys.nutritionBox);
      await _box!.delete(recordKey);
      state = AsyncValue.data(_fetchSortedRecords()); 
      return true; 
    } catch (e) {
      return false; 
    }
  }
}