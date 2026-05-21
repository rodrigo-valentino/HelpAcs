import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../utils/list_filter_service.dart';
import '../../utils/feedback_helper.dart';
import '../providers/pregnant_list_controller.dart';
import '../models/pregnant_woman_model.dart';
import '../enums/pregnancy_enums.dart';
import '../dialogs/pregnant_form_dialog.dart';
import 'pregnant_details_page.dart';

class PregnantListPage extends ConsumerStatefulWidget {
  const PregnantListPage({super.key});

  @override
  ConsumerState<PregnantListPage> createState() => _PregnantListPageState();
}

class _PregnantListPageState extends ConsumerState<PregnantListPage> {
  final TextEditingController _searchController = TextEditingController();
  final SelectionController<dynamic> _selectionController =
      SelectionController<dynamic>();

  SortType _currentSort = SortType.nameAZ;
  String _query = '';
  static const Color _themeColor = Colors.purple;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
        () => setState(() => _query = _searchController.text));
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
      barrierDismissible: false,
      builder: (_) => const PregnantFormDialog(),
    );
  }

  Future<void> _deleteSelected(List<PregnantWomanModel> currentList) async {
    final selectedIds = _selectionController.selectedIds;
    final confirm = await FeedbackHelper.showDeleteConfirmation(
      context,
      title: 'Excluir Gestantes',
      itemName: '${_selectionController.count} selecionada(s)',
      warningMessage:
          'Isso apagará permanentemente todo o histórico do pré-natal delas.',
    );

    if (confirm) {
      final notifier = ref.read(pregnantListProvider.notifier);

      for (final id in selectedIds) {
        final target = currentList.firstWhere((w) => w.key == id);
        await notifier.deletePregnant(target);
      }

      _selectionController.clear();
      if (mounted) {
        FeedbackHelper.showSuccess(context, 'Cadastros removidos com sucesso');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pregnantList = ref.watch(pregnantListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: _selectionController.isSelectionMode
            ? Text('${_selectionController.count} selecionada(s)')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pré-Natal / Gestantes'),
                  Text(
                    _query.isEmpty
                        ? '${pregnantList.length} gestantes cadastradas'
                        : '${ListFilterService.filter<PregnantWomanModel>(items: pregnantList, query: _query, selectors: (w) => [w.name]).length} resultados encontrados',
                    style: const TextStyle(
                      fontSize: 13,
                      color: _themeColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
        leading: _selectionController.isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _selectionController.clear,
              )
            : null,
        actions: [
          if (_selectionController.isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _deleteSelected(pregnantList),
              tooltip: 'Excluir selecionadas',
            )
          else ...[
            PopupMenuButton<SortType>(
              icon: const Icon(Icons.sort_rounded),
              tooltip: 'Ordenar lista',
              initialValue: _currentSort,
              onSelected: (SortType newValue) {
                setState(() => _currentSort = newValue);
              },
              itemBuilder: (context) => [
                _buildSortItem(SortType.nameAZ, 'Nome (A-Z)', Icons.sort_by_alpha),
                _buildSortItem(
                    SortType.ageYoungest, 'Idade (Menor para Maior)', Icons.child_care),
                _buildSortItem(
                    SortType.ageOldest, 'Idade (Maior para Menor)', Icons.person),
              ],
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        label: const Text('Adicionar',
            style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
        backgroundColor: _themeColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildWomenList(pregnantList),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar gestante...',
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

  Widget _buildWomenList(List<PregnantWomanModel> allWomen) {
    final filtered = ListFilterService.filter<PregnantWomanModel>(
      items: allWomen,
      query: _query,
      selectors: (w) => [w.name],
    );

    final sorted = ListFilterService.sort<PregnantWomanModel>(
      items: filtered,
      sortType: _currentSort,
      getName: (w) => w.name,
      getAge: (w) => w.age,
      getStatusWeight: (w) =>
          w.riskLevel == PregnancyRisk.highRisk ? 1 : 0,
    );

    if (sorted.isEmpty) return _buildEmptyState();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final woman = sorted[index];
        return _buildWomanCard(woman);
      },
    );
  }

  Widget _buildWomanCard(PregnantWomanModel woman) {
    final isSelected = _selectionController.isSelected(woman.key);
    final isHighRisk = woman.riskLevel == PregnancyRisk.highRisk;
    final riskColor = isHighRisk ? AppColors.error : AppColors.success;

    return InkWell(
      onTap: () {
        if (_selectionController.isSelectionMode) {
          _selectionController.toggle(woman.key);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PregnantDetailsPage(womanKey: woman.key as int),
            ),
          );
        }
      },
      onLongPress: () => _selectionController.toggle(woman.key),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? _themeColor.withAlpha(20) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _themeColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildAvatar(woman, isSelected),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          woman.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${woman.ageLabel}  •  ${woman.gestationalAgeLabel}',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isHighRisk
                          ? AppColors.errorSurface
                          : AppColors.successSurface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isHighRisk
                            ? AppColors.errorBorder
                            : AppColors.successBorder,
                      ),
                    ),
                    child: Text(
                      woman.riskLevel.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: riskColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      woman.progressSummaryLabel,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    woman.progressLabel,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _themeColor),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: woman.overallProgress,
                backgroundColor: AppColors.border.withAlpha(100),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(_themeColor),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(PregnantWomanModel woman, bool isSelected) {
    return CircleAvatar(
      backgroundColor:
          isSelected ? _themeColor : _themeColor.withAlpha(30),
      child: isSelected
          ? const Icon(Icons.check, color: Colors.white)
          : Text(
              woman.name.isNotEmpty ? woman.name[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: _themeColor, fontWeight: FontWeight.bold),
            ),
    );
  }

  PopupMenuItem<SortType> _buildSortItem(
      SortType type, String text, IconData icon) {
    final isSelected = _currentSort == type;
    return PopupMenuItem(
      value: type,
      child: Row(
        children: [
          Icon(icon,
              color: isSelected ? _themeColor : Colors.grey, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: isSelected ? _themeColor : AppColors.textPrimary,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pregnant_woman_rounded,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _query.isEmpty
                ? 'Nenhuma gestante cadastrada.'
                : 'Nenhum resultado para "$_query"',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}