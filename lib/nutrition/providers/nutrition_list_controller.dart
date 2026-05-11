import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../vaccines/models/child_model.dart';
import '../../utils/hive_keys.dart';
import '../../utils/list_filter_service.dart'; // 🚀 Adicionado para ter acesso ao seu serviço

// 1. Provedor Base: Apenas busca as crianças do banco (Leva a carga de I/O)
final nutritionListControllerProvider = AutoDisposeAsyncNotifierProvider<NutritionListController, List<ChildModel>>(() {
  return NutritionListController();
});

class NutritionListController extends AutoDisposeAsyncNotifier<List<ChildModel>> {
  @override
  Future<List<ChildModel>> build() async {
    final box = await Hive.openBox<ChildModel>(HiveKeys.childrenBox);
    final allChildren = box.values.toList();
    return allChildren.where((child) => child.ageInYears < 10).toList();
  }
}

// 🚀 2. Provedor de Busca: Guarda o texto digitado pelo usuário
final nutritionSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

// 🚀 3. Estado Derivado: O coração da performance.
// Ele só roda o filtro quando a lista original MUDA ou quando a busca MUDA.
final filteredNutritionChildrenProvider = Provider.autoDispose<AsyncValue<List<ChildModel>>>((ref) {
  final query = ref.watch(nutritionSearchQueryProvider);
  final asyncChildren = ref.watch(nutritionListControllerProvider);

  // Usa o whenData para só tentar filtrar se os dados já estiverem carregados
  return asyncChildren.whenData((children) {
    // 1. Filtra
    final filteredList = ListFilterService.filter(
      items: children,
      query: query,
      selectors: (child) => [child.name, child.guardianName ?? ''],
    );

    // 2. Ordena
    return ListFilterService.sort(
      items: filteredList,
      sortType: SortType.nameAZ,
      getName: (child) => child.name,
      getAge: (child) => child.ageInDays,
    );
  });
});