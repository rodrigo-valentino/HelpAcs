import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../utils/feedback_helper.dart';
import '../providers/task_controller.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form_widget.dart';

class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFormOpen = ref.watch(taskFormExpandedProvider);
    final editingTask = ref.watch(taskEditingProvider);

    // Listas já filtradas pelos derived providers
    final pendingTasks = ref.watch(pendingTasksProvider);
    final completedTasks = ref.watch(completedTasksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Anotações'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CABEÇALHO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gestão de Pendências',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'To-Do List inteligente e anotações rápidas',
                        style:
                            TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    if (isFormOpen) {
                      ref.read(taskEditingProvider.notifier).state = null;
                    }
                    ref.read(taskFormExpandedProvider.notifier).state =
                        !isFormOpen;
                  },
                  icon: Icon(
                    isFormOpen ? Icons.close : Icons.add,
                    color: Colors.white,
                    size: 16,
                  ),
                  label: Text(
                    isFormOpen ? 'Cancelar' : 'Nova Tarefa',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // FORMULÁRIO RETRÁTIL
            if (isFormOpen) TaskFormWidget(taskToEdit: editingTask),

            // SEÇÃO: PENDENTES
            _buildSectionHeader(
              Icons.schedule,
              'Pendentes',
              pendingTasks.length,
              Colors.black87,
            ),
            const SizedBox(height: 12),

            if (pendingTasks.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 12),
                child: Text(
                  'Nenhuma tarefa pendente 🎉',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              )
            else
              ...pendingTasks.map(
                (task) => TaskCardWidget(
                  task: task,
                  onToggle: () => ref
                      .read(taskListProvider.notifier)
                      .toggleTaskCompletion(task.id),
                  onEdit: () {
                    ref.read(taskEditingProvider.notifier).state = task;
                    ref.read(taskFormExpandedProvider.notifier).state = true;
                  },
                  // ── Confirmação antes de excluir ─────────────────────
                  onDelete: () async {
                    final confirmed =
                        await FeedbackHelper.showDeleteConfirmation(
                      context,
                      title: 'Excluir Tarefa',
                      itemName: task.title,
                    );
                    if (confirmed) {
                      ref
                          .read(taskListProvider.notifier)
                          .deleteTask(task.id);
                    }
                  },
                ),
              ),

            const SizedBox(height: 16),

            // SEÇÃO: CONCLUÍDAS
            if (completedTasks.isNotEmpty) ...[
              _buildSectionHeader(
                Icons.check_circle_outline,
                'Concluídas',
                completedTasks.length,
                AppColors.success,
              ),
              const SizedBox(height: 12),
              ...completedTasks.map(
                (task) => TaskCardWidget(
                  task: task,
                  onToggle: () => ref
                      .read(taskListProvider.notifier)
                      .toggleTaskCompletion(task.id),
                  onEdit: () {
                    ref.read(taskEditingProvider.notifier).state = task;
                    ref.read(taskFormExpandedProvider.notifier).state = true;
                  },
                  onDelete: () async {
                    final confirmed =
                        await FeedbackHelper.showDeleteConfirmation(
                      context,
                      title: 'Excluir Tarefa',
                      itemName: task.title,
                    );
                    if (confirmed) {
                      ref
                          .read(taskListProvider.notifier)
                          .deleteTask(task.id);
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    IconData icon,
    String title,
    int count,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          '$title ($count)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}