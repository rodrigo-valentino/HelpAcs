import 'package:flutter/material.dart';

class PregnantItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final String? notes;
  final bool isCustom; // Define se pode ser excluído/editado
  final VoidCallback onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PregnantItemCard({
    super.key,
    required this.title,
    required this.subtitle,
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
        title: const Text('Observação'),
        content: Text(notes ?? ''),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED), // Cor de fundo similar à imagem (laranja bem claro)
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withAlpha(77)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : Colors.grey.shade600,
              borderRadius: BorderRadius.circular(8), // Checkbox arredondado da imagem
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone de observação (Azul) - Só aparece se houver texto
            if (notes != null && notes!.trim().isNotEmpty)
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.blue),
                onPressed: () => _showNotesDialog(context),
                tooltip: 'Ver observação',
              ),
            
            // Menu de opções (Editar / Excluir) - Só para itens extras
            if (isCustom)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (value) {
                  if (value == 'edit' && onEdit != null) onEdit!();
                  if (value == 'delete' && onDelete != null) onDelete!();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Editar'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Excluir', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}