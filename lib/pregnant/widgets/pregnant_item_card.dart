import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class PregnantItemCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isCompleted;
  final String? notes;
  final bool isCustom;
  final VoidCallback onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PregnantItemCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.isCompleted,
    this.notes,
    this.isCustom = false,
    required this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  void _showNotesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primary),
            SizedBox(width: 12),
            Text('Observação'),
          ],
        ),
        content: Text(notes ?? '', style: const TextStyle(fontSize: 15)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = isCompleted ? AppColors.success : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      // ✅ 1. Outer Container: Apenas Sombra
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(color: accentColor, width: 4),
              top: const BorderSide(color: AppColors.border),
              right: const BorderSide(color: AppColors.border),
              bottom: const BorderSide(color: AppColors.border),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.success : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isCompleted 
                      ? null 
                      : Border.all(color: Colors.grey.shade400, width: 2),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 15,
                color: isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
              ),
            ),
            subtitle: subtitle != null
                ? Text(
                    subtitle!,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (notes != null && notes!.trim().isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.info_outline, color: AppColors.primary),
                    onPressed: () => _showNotesDialog(context),
                    tooltip: 'Ver observação',
                  ),
                
                if (isCustom)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (value) {
                      if (value == 'edit' && onEdit != null) onEdit!();
                      if (value == 'delete' && onDelete != null) onDelete!();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 20),
                            SizedBox(width: 12),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                            SizedBox(width: 12),
                            Text('Excluir', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}