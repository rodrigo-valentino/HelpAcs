import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../vaccines/models/child_model.dart';
import '../../theme/app_colors.dart';
import '../providers/nutrition_list_controller.dart';
import 'nutrition_history_page.dart';
import 'nutrition_general_report_page.dart';

class NutritionChildrenListPage extends ConsumerStatefulWidget {
  const NutritionChildrenListPage({super.key});

  @override
  ConsumerState<NutritionChildrenListPage> createState() => _NutritionChildrenListPageState();
}

class _NutritionChildrenListPageState extends ConsumerState<NutritionChildrenListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 🚀 Atualiza o provedor de busca do Riverpod sem dar setState na tela inteira
    _searchController.addListener(() {
      ref.read(nutritionSearchQueryProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🚀 Assiste diretamente a lista JÁ FILTRADA E ORDENADA do provedor derivado
    final asyncFilteredChildren = ref.watch(filteredNutritionChildrenProvider);
    final currentQuery = ref.watch(nutritionSearchQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nutrição Infantil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: AppColors.primary),
            tooltip: 'Ver Relatório Geral',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NutritionGeneralReportPage(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(currentQuery),
          Expanded(
            child: asyncFilteredChildren.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erro: $err')),
              data: (children) => _buildChildrenList(children, currentQuery),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(String query) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por nome...',
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    // O listener do initState já vai atualizar o provedor para ''
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildChildrenList(List<ChildModel> children, String query) {
    if (children.isEmpty) return _buildEmptyState(query);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: children.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildChildCard(children[index]);
      },
    );
  }

  Widget _buildChildCard(ChildModel child) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: Colors.black.withAlpha(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NutritionHistoryPage(child: child),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.infoSurface,
                child: Text(
                  child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${child.ageLabel} • Resp: ${child.guardianName ?? "-"}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
             query.isEmpty 
                 ? 'Nenhuma criança menor de 10 anos encontrada.' 
                 : 'Nenhum resultado para "$query"',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}