import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/task_model.dart';
import '../../utils/hive_keys.dart';

// 1. PROVIDERS DE ESTADO DA INTERFACE (UI)

/// Controla se o formulário "Nova Tarefa" está aberto
final taskFormExpandedProvider = StateProvider<bool>((ref) => false);

/// Controla qual tarefa está sendo editada
final taskEditingProvider = StateProvider<TaskModel?>((ref) => null);

// 2. PROVIDER DE DADOS (HIVE CRUD)

final taskListProvider = NotifierProvider<TaskListNotifier, List<TaskModel>>(() {
  return TaskListNotifier();
});

class TaskListNotifier extends Notifier<List<TaskModel>> {
  // ── Guard: lança erro claro se a box não estiver aberta ──────────────
  Box<TaskModel> get _box {
    if (!Hive.isBoxOpen(HiveKeys.taskBox)) {
      throw StateError(
        'taskBox não está aberta. '
        'Verifique se Hive.openBox<TaskModel>(HiveKeys.taskBox) '
        'foi chamado antes de runApp().',
      );
    }
    return Hive.box<TaskModel>(HiveKeys.taskBox);
  }

  @override
  List<TaskModel> build() {
    return _getSortedTasks();
  }

  List<TaskModel> _getSortedTasks() {
    final tasks = _box.values.toList();
    tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return tasks;
  }

  void refresh() {
    state = _getSortedTasks();
  }

  // ── CREATE ────────────────────────────────────────────────────────────

  Future<void> addTask(TaskModel task) async {
    await _box.put(task.id, task);
    refresh();
  }

  // ── UPDATE ────────────────────────────────────────────────────────────

  /// Atualiza os campos de texto de uma tarefa existente.
  ///
  /// A mutação ocorre aqui (controller), não no widget.
  /// Se a tarefa foi deletada enquanto o formulário estava aberto,
  /// a operação é ignorada silenciosamente em vez de re-inserir o objeto.
  Future<void> updateTask(
    TaskModel task, {
    required String title,
    String? description,
  }) async {
    // Verifica se o registro ainda existe antes de persistir
    final existing = _box.get(task.id);
    if (existing == null) return;

    existing.title = title;
    existing.description = description;
    await existing.save();
    refresh();
  }

  // ── DELETE ────────────────────────────────────────────────────────────

  Future<void> deleteTask(String id) async {
    await _box.delete(id);
    refresh();
  }

  // ── TOGGLE ───────────────────────────────────────────────────────────

  Future<void> toggleTaskCompletion(String id) async {
    final task = _box.get(id);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      await task.save();
      refresh();
    }
  }
}

// ─────────────────────────────────────────────────────────
// 3. PROVIDERS DERIVADOS (FILTROS)
// ─────────────────────────────────────────────────────────

/// Retorna apenas as tarefas que não foram concluídas
final pendingTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(taskListProvider);
  return tasks.where((t) => !t.isCompleted).toList();
});

/// Retorna apenas as tarefas que já foram concluídas
final completedTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(taskListProvider);
  return tasks.where((t) => t.isCompleted).toList();
});