import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../vaccines/models/child_model.dart';
import '../models/nutrition_record_model.dart';
import '../../utils/hive_keys.dart';

class NutritionReportItem {
  final NutritionRecordModel record;
  final ChildModel child;
  NutritionReportItem({required this.record, required this.child});
}

final nutritionReportControllerProvider = AutoDisposeAsyncNotifierProvider<NutritionReportController, List<NutritionReportItem>>(() {
  return NutritionReportController();
});

class NutritionReportController extends AutoDisposeAsyncNotifier<List<NutritionReportItem>> {
  @override
  Future<List<NutritionReportItem>> build() async {
    final nutritionBox = await Hive.openBox<NutritionRecordModel>(HiveKeys.nutritionBox);
    final childrenBox = await Hive.openBox<ChildModel>(HiveKeys.childrenBox);

    final records = nutritionBox.values.toList();
    
    // Ordena do mais recente para o mais antigo
    records.sort((a, b) => b.assessmentDate.compareTo(a.assessmentDate));

    final List<NutritionReportItem> reportItems = [];
    final List<int> orphanedKeys = []; 

    for (final record in records) {
      final child = childrenBox.get(record.childKey);
      
      if (child != null) {
        reportItems.add(NutritionReportItem(record: record, child: child));
      } else {
        if (record.key != null) {
           orphanedKeys.add(record.key);
        }
      }
    }

    if (orphanedKeys.isNotEmpty) {
      await nutritionBox.deleteAll(orphanedKeys);
    }

    return reportItems;
  }
}