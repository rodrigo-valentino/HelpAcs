import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../utils/list_filter_service.dart';
import '../../utils/feedback_helper.dart';
import '../../imports/import_button.dart';
import '../../imports/import_preview_dialog.dart';
import '../../services/health_status_badge.dart';
import '../models/woman_model.dart';
import '../providers/woman_controller.dart';
import '../dialogs/woman_form_dialog.dart'; 
import '../dialogs/woman_details_dialog.dart';
import '../components/woman_dashboard.dart';

class WomanListPage extends ConsumerStatefulWidget {
  const WomanListPage({super.key});

  @override
  ConsumerState<WomanListPage> createState() => _WomanListPageState();
}

class _WomanListPageState extends ConsumerState<WomanListPage> {
  final TextEditingController _searchController = TextEditingController();
  final SelectionController<int> _selectionController = SelectionController<int>();
  SortType _currentSort = SortType.nameAZ;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() => _query = _searchController.text));
    _selectionController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _selectionController.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => const WomanFormDialog(),
    );
  }

  Future<void> _deleteSelected() async {
    final confirm = await FeedbackHelper.showDeleteConfirmation(
      context, 
      title: 'Excluir Pacientes', 
      itemName: '${_selectionController.count} selecionada(s)',
      warningMessage: 'Isso apagará todo o histórico de exames delas.'
    );
    
    if (confirm) {
      await ref.read(womanListControllerProvider.notifier)
          .deleteWomen(_selectionController.selectedIds);
      
      _selectionController.clear();
      if (mounted) {
        FeedbackHelper.showSuccess(context, "Pacientes removidas com sucesso");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncWomen = ref.watch(womanListControllerProvider);
    const themeColor = Colors.purple;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: _selectionController.isSelectionMode
            ? Text('${_selectionController.count} selecionada(s)')
            : asyncWomen.when(
                data: (allWomen) {
                  final filteredCount = _query.isEmpty
                      ? allWomen.length
                      : ListFilterService.filter<WomanModel>(
                          items: allWomen,
                          query: _query,
                          selectors: (w) => [w.name],
                        ).length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Saúde da Mulher'),
                      Text(
                        _query.isEmpty
                            ? '$filteredCount pacientes cadastradas'
                            : '$filteredCount resultado${filteredCount == 1 ? '' : 's'} encontrado${filteredCount == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: themeColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Text('Saúde da Mulher'),
                error: (_, __) => const Text('Saúde da Mulher'),
              ),
        leading: _selectionController.isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close), 
                onPressed: _selectionController.clear
              )
            : null,
        actions: [
          if (_selectionController.isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error), 
              onPressed: _deleteSelected,
              tooltip: 'Excluir selecionadas',
            )
          else ...[
            ImportButton(
              type: ImportPatientType.woman,
              onImportRow: (row) async {
                await ref.read(womanListControllerProvider.notifier).addWoman(
                  row.name,
                  row.birthDate,
                );
              },
            ),
            PopupMenuButton<SortType>(
              icon: const Icon(Icons.sort_rounded),
              tooltip: "Ordenar lista",
              initialValue: _currentSort,
              onSelected: (SortType newValue) {
                setState(() => _currentSort = newValue);
              },
              itemBuilder: (context) => [
                _buildSortItem(SortType.nameAZ, "Nome (A-Z)", Icons.sort_by_alpha),
                _buildSortItem(SortType.statusWorstFirst, "Prioridade (Atrasados)", Icons.priority_high),
                _buildSortItem(SortType.ageYoungest, "Idade (Menor para Maior)", Icons.child_care),
                _buildSortItem(SortType.ageOldest, "Idade (Maior para Menor)", Icons.person),
              ],
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        label: const Text('Adicionar'),
        icon: const Icon(Icons.add),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          const WomanDashboard(),
          Expanded(
            child: asyncWomen.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => _buildErrorState(err),
              data: (allWomen) => _buildWomenList(allWomen, themeColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar paciente...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildWomenList(List<WomanModel> allWomen, Color themeColor) {
    final filtered = ListFilterService.filter<WomanModel>(
      items: allWomen,
      query: _query,
      selectors: (w) => [w.name],
    );

    final sorted = ListFilterService.sort<WomanModel>(
      items: filtered,
      sortType: _currentSort,
      getName: (w) => w.name,
      getAge: (w) => w.age,
      getStatusWeight: (w) => w.generalStatusWeight,
    );

    if (sorted.isEmpty) return _buildEmptyState();

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final woman = sorted[index];
        return _buildWomanCard(woman, themeColor);
      },
    );
  }

  Widget _buildWomanCard(WomanModel woman, Color themeColor) {
    final isSelected = _selectionController.isSelected(woman.id);

    return InkWell(
      onTap: () {
        if (_selectionController.isSelectionMode) {
          _selectionController.toggle(woman.id);
        } else {
          showDialog(
            context: context,
            builder: (_) => WomanDetailsDialog(woman: woman),
          );
        }
      },
      onLongPress: () => _selectionController.toggle(woman.id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? themeColor.withAlpha(20) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? themeColor : Colors.transparent, 
            width: 2
          ),
          boxShadow: isSelected ? [] : [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: _buildAvatar(woman, isSelected, themeColor),
          title: Text(
            woman.name, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
          ),
          subtitle: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${woman.age} anos",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: woman.isSus ? AppColors.infoSurface : AppColors.successSurface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: woman.isSus ? AppColors.infoBorder : AppColors.successBorder,
                  ),
                ),
                child: Text(
                  woman.isSus ? "SUS" : "Particular",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: woman.isSus ? AppColors.info : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusBadge(woman),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<SortType> _buildSortItem(SortType type, String text, IconData icon) {
    final isSelected = _currentSort == type;
    return PopupMenuItem(
      value: type,
      child: Row(
        children: [
          Icon(icon, color: isSelected ? Colors.purple : Colors.grey, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.purple : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(WomanModel woman, bool isSelected, Color themeColor) {
    return CircleAvatar(
      backgroundColor: isSelected ? themeColor : themeColor.withAlpha(30),
      child: isSelected
          ? const Icon(Icons.check, color: Colors.white)
          : Text(
              woman.name.isNotEmpty ? woman.name[0].toUpperCase() : '?',
              style: TextStyle(
                color: themeColor, 
                fontWeight: FontWeight.bold
              )
            ),
    );
  }

  Widget _buildStatusBadge(WomanModel woman) {
    if (woman.badgeStatus == null) {
      return const SizedBox.shrink();
    }

    return HealthStatusBadge(
      status: woman.badgeStatus!, 
      fontSize: 10, 
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.face_3, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _query.isEmpty 
                ? "Nenhuma paciente cadastrada." 
                : 'Nenhum resultado para "$_query"',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'Erro ao carregar dados',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => ref.invalidate(womanListControllerProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }
}