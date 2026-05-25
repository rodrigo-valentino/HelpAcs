import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../utils/feedback_helper.dart';
import '../models/task_model.dart';
import '../providers/task_controller.dart';

class TaskFormWidget extends ConsumerStatefulWidget {
  final TaskModel? taskToEdit;

  const TaskFormWidget({super.key, this.taskToEdit});

  @override
  ConsumerState<TaskFormWidget> createState() => _TaskFormWidgetState();
}

class _TaskFormWidgetState extends ConsumerState<TaskFormWidget> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _errorMsg;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initForm();
  }

  @override
  void didUpdateWidget(covariant TaskFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.taskToEdit != widget.taskToEdit) {
      _initForm();
    }
  }

  void _initForm() {
    if (widget.taskToEdit != null) {
      _titleCtrl.text = widget.taskToEdit!.title;
      _descCtrl.text = widget.taskToEdit!.description ?? '';
    } else {
      _titleCtrl.clear();
      _descCtrl.clear();
    }
    _errorMsg = null;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ── Normaliza description: string vazia → null ────────────────────────
  String? _normalizedDescription() {
    final desc = _descCtrl.text.trim();
    return desc.isEmpty ? null : desc;
  }

  Future<void> _saveTask() async {
    final title = _titleCtrl.text.trim();

    if (title.isEmpty) {
      setState(() => _errorMsg = 'O título da tarefa é obrigatório.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMsg = null;
    });

    try {
      if (widget.taskToEdit != null) {
        // ── Edição: mutação acontece no controller, não aqui ──────────
        await ref.read(taskListProvider.notifier).updateTask(
          widget.taskToEdit!,
          title: title,
          description: _normalizedDescription(),
        );
      } else {
        // ── Criação ───────────────────────────────────────────────────
        final newTask = TaskModel.create(
          title: title,
          description: _normalizedDescription(),
        );
        await ref.read(taskListProvider.notifier).addTask(newTask);
      }

      if (!mounted) return;

      // Feedback de sucesso
      FeedbackHelper.showSuccess(
        context,
        widget.taskToEdit != null
            ? 'Tarefa atualizada com sucesso.'
            : 'Tarefa adicionada com sucesso.',
      );

      // Limpa e fecha o formulário
      ref.read(taskEditingProvider.notifier).state = null;
      ref.read(taskFormExpandedProvider.notifier).state = false;
    } catch (e) {
      if (!mounted) return;
      FeedbackHelper.showError(context, 'Erro ao salvar tarefa: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskToEdit != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? 'Editar Tarefa' : 'Nova Tarefa',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildLabel('Título da Tarefa'),
          TextField(
            controller: _titleCtrl,
            decoration: _inputDeco('Ex: Entregar requisição...'),
          ),
          const SizedBox(height: 16),

          _buildLabel('Descrição (Opcional)'),
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            decoration: _inputDeco('Detalhes da tarefa...'),
          ),

          if (_errorMsg != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _errorMsg!,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                disabledBackgroundColor: Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isEditing ? 'Atualizar Tarefa' : 'Adicionar Tarefa',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}