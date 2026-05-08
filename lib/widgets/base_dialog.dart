// lib/widgets/base_dialog.dart

import 'package:flutter/material.dart';

/// 🎯 SOLUÇÃO DRY: Template base para todos os diálogos
/// Elimina duplicação de código de estrutura de diálogo
class BaseDialog extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final Widget child;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final String saveButtonText;
  final String cancelButtonText;
  final Color? saveButtonColor;
  final bool isEditMode;
  final List<Widget>? additionalActions;
  final double? maxWidth;
  final bool dismissible;

  const BaseDialog({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.iconColor,
    this.onSave,
    this.onCancel,
    this.saveButtonText = 'Salvar',
    this.cancelButtonText = 'Cancelar',
    this.saveButtonColor,
    this.isEditMode = false,
    this.additionalActions,
    this.maxWidth,
    this.dismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: maxWidth,
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              child,
              const SizedBox(height: 24),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (iconColor ?? Theme.of(context).colorScheme.primary)
                  .withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor ?? Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (additionalActions != null) ...additionalActions!,
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    // ✅ Alterado: Cancelar na Esquerda, Salvar na Direita
    return Row(
      children: [
        // 1. Botão Cancelar (Esquerda)
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel ?? () => Navigator.of(context).pop(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(cancelButtonText),
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // 2. Botão Salvar (Direita) - Só aparece se tiver ação de save
        if (onSave != null) ...[
          Expanded(
            child: FilledButton(
              onPressed: onSave,
              style: saveButtonColor != null
                  ? FilledButton.styleFrom(
                      backgroundColor: saveButtonColor,
                    )
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  isEditMode && saveButtonText == 'Salvar'
                      ? 'Atualizar'
                      : saveButtonText,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
/// Formulário base com estado
class BaseFormDialog extends StatefulWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final Widget Function(GlobalKey<FormState> formKey) builder;
  final Future<void> Function() onSubmit;
  final String saveButtonText;
  final Color? saveButtonColor;
  final bool isEditMode;
  final VoidCallback? onDelete;

  const BaseFormDialog({
    super.key,
    required this.title,
    required this.builder,
    required this.onSubmit,
    this.icon,
    this.iconColor,
    this.saveButtonText = 'Salvar',
    this.saveButtonColor,
    this.isEditMode = false,
    this.onDelete,
  });

  @override
  State<BaseFormDialog> createState() => _BaseFormDialogState();
}

class _BaseFormDialogState extends State<BaseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      
      try {
        await widget.onSubmit();
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: widget.title,
      icon: widget.icon,
      iconColor: widget.iconColor,
      isEditMode: widget.isEditMode,
      saveButtonText: widget.saveButtonText,
      saveButtonColor: widget.saveButtonColor,
      onSave: _isLoading ? null : _handleSubmit,
      additionalActions: widget.onDelete != null
          ? [
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, 
                               color: Colors.red),
                onPressed: widget.onDelete,
                tooltip: 'Excluir',
              ),
            ]
          : null,
      child: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          : widget.builder(_formKey),
    );
  }
}