import 'package:helpacs/imports/import_preview_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_input_decoration.dart';
import '../../utils/feedback_helper.dart';
import '../../utils/list_filter_service.dart';
import '../providers/child_list_controller.dart';
import '../dialogs/child_form_dialog.dart';
import '../models/child_model.dart';
import 'vaccination_page.dart';
import '../../imports/import_button.dart';
import '../../services/health_status_badge.dart';
import '../../enums/health_status.dart';

class ChildListPage extends ConsumerStatefulWidget {
  const ChildListPage({super.key});

  @override
  ConsumerState<ChildListPage> createState() => _ChildListPageState();
}

class _ChildListPageState extends ConsumerState<ChildListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  final SelectionController<int> _selectionController = SelectionController<int>();
  SortType _currentSort = SortType.nameAZ;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text);
    });
    
    _selectionController.addListener(() {
      setState(() {}); 
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _selectionController.dispose();
    super.dispose();
  }

  void _showAddChildDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ChildFormDialog(),
    );
  }

  Future<void> _deleteSelected() async {
    final confirm = await FeedbackHelper.showDeleteConfirmation(
      context, 
      title: 'Excluir Crianças', 
      itemName: '${_selectionController.count} selecionadas',
      warningMessage: 'Isso apagará todo o histórico de vacinas delas.'
    );

    if (confirm) {
      // ✅ Chamada adaptada para o Controller do Hive
      await ref.read(childListControllerProvider.notifier)
          .deleteChildren(_selectionController.selectedIds.toList());
      
      _selectionController.clear();
      if(mounted) FeedbackHelper.showSuccess(context, "Crianças removidas com sucesso");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Escuta o provider que agora busca os dados do Hive
    final filteredList = ref.watch(filteredChildrenProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: _selectionController.isSelectionMode
            ? Text('${_selectionController.count} selecionado(s)')
            : const Text('Pacientes Infantis'),
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
              onPressed: _deleteSelected,
            )
          else ...[
            ImportButton(
              type: ImportPatientType.child,
              onImportRow: (row) async {
                // Usa importChild (em vez de addChild) para garantir que
                // registros duplicados sejam detectados e rejeitados antes
                // de serem inseridos no banco — o ImportPreviewDialog captura
                // a exceção e exibe o motivo na lista de falhas.
                await ref.read(childListControllerProvider.notifier).importChild(
                  ChildModel(
                    name: row.name,
                    birthDate: row.birthDate,
                    cpf: row.cpf, 
                  )
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
                _buildSortItem(SortType.ageYoungest, "Idade (Menores)", Icons.child_care),
                _buildSortItem(SortType.ageOldest, "Idade (Maiores)", Icons.person),
                _buildSortItem(SortType.statusWorstFirst, "Vacinação (Atrasados)", Icons.priority_high),
              ],
            ),
          ],
        ],
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddChildDialog(context),
        label: const Text('Adicionar'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          _buildSearchBar(ref),

          Expanded(
            child: filteredList.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma criança encontrada',
                    ),
                  )
                : _buildChildrenList(filteredList),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref) {
    final query = ref.watch(childSearchQueryProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,

        onChanged: (value) {
          ref
              .read(childSearchQueryProvider.notifier)
              .state = value;
        },

        decoration: AppInputDecoration.outlined(
          hint: 'Buscar por nome ou responsável...',
          prefixIcon: Icons.search,

          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();

                    ref
                        .read(
                          childSearchQueryProvider.notifier,
                        )
                        .state = '';
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildChildrenList(List<ChildModel> children) { 

    final sortedList = ListFilterService.sort<ChildModel>(
      items: children,
      sortType: _currentSort,
      getName: (child) => child.name,
      getAge: (child) => child.ageInDays, 
      getStatusWeight: (child) {
        switch (child.status) {
          case HealthStatus.overdue: return 3; // 🚨 Atrasados sempre no topo (Prioridade 1)
          case HealthStatus.warning: return 2; // ⚠️ Atenção (Prioridade 2)
          case HealthStatus.pending: return 1; // ⏳ Pendente / Novo cadastro (Prioridade 3)
          case HealthStatus.upToDate: return 0; }
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Text(
            'Total: ${children.length} pacientes cadastrados',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: sortedList.isEmpty 
            ? _buildEmptyState()
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: sortedList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final child = sortedList[index];
                  // O HiveObject possui uma propriedade 'key' que serve como ID único
                  final isSelected = _selectionController.isSelected(child.key); 
                  return _buildChildCard(child, isSelected);
                },
              ),
        ),
      ],
    );
  }

  PopupMenuItem<SortType> _buildSortItem(SortType type, String text, IconData icon) {
    final isSelected = _currentSort == type;
    return PopupMenuItem(
      value: type,
      child: Row(
        children: [
          Icon(icon, color: isSelected ? AppColors.primary : Colors.grey, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: isSelected ? AppColors.primary : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildCard(ChildModel child, bool isSelected) {
    return InkWell(
      onTap: () {
        if (_selectionController.isSelectionMode) {
          _selectionController.toggle(child.key);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VaccinationPage(child: child),
            ),
          );
        }
      },
      onLongPress: () => _selectionController.toggle(child.key),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(20) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected ? [] : [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: isSelected ? AppColors.primary : AppColors.primary.withAlpha(30),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white)
                    : Text(
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            child.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        HealthStatusBadge(
                          status: child.status, 
                          fontSize: 10, 
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${child.ageLabel} • Resp: ${child.guardianName ?? "-"}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              
              // 🆕 BOTÃO DE EDIÇÃO ADICIONADO AQUI
              if (!isSelected) // Só mostra o lápis se não estiver no modo de apagar
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                  tooltip: 'Editar Paciente',
                  onPressed: () {
                    // Chama o dialog que você já tem, passando a criança atual!
                    showDialog(
                      context: context,
                      builder: (context) => ChildFormDialog(childToEdit: child),
                    );
                  },
                ),
                
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _query.isEmpty 
                ? 'Nenhuma criança cadastrada.\nAdicione a primeira!' 
                : 'Nenhum resultado para "$_query"',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}