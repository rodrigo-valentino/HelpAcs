import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../models/notice_model.dart';
import '../enums/notice_enums.dart';

class NoticeCard extends StatelessWidget {
  final NoticeModel notice;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoticeCard({
    super.key,
    required this.notice,
    required this.onEdit,
    required this.onDelete,
  });

  // ─── Helpers Visuais baseados no Enum ────────────────────────────

  Color _getTypeColor(NoticeType type) {
    switch (type) {
      case NoticeType.campaign:
        return const Color(0xFF9C27B0); // Roxo
      case NoticeType.meeting:
        return const Color(0xFF2196F3); // Azul
      case NoticeType.training:
        return const Color(0xFFFF9800); // Laranja
      case NoticeType.event:
        return const Color(0xFF4CAF50); // Verde
    }
  }

  IconData _getTypeIcon(NoticeType type) {
    switch (type) {
      case NoticeType.campaign:
        return Icons.vaccines;
      case NoticeType.meeting:
        return Icons.groups;
      case NoticeType.training:
        return Icons.school;
      case NoticeType.event:
        return Icons.notifications_active;
    }
  }

  // ─── Helper de Tempo (A Pill Amarela) ────────────────────────────

  Widget _buildTimeRemainingPill() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(notice.date.year, notice.date.month, notice.date.day);
    
    final difference = eventDate.difference(today).inDays;

    String text;
    Color bgColor = const Color(0xFFFFB300); // Amarelo
    Color textColor = Colors.white;

    if (difference == 0) {
      text = "Hoje";
      bgColor = AppColors.success; 
    } else if (difference == 1) {
      text = "Amanhã";
    } else if (difference > 1) {
      text = "Em $difference dias";
    } else {
      text = "Há ${difference.abs()} dias";
      bgColor = Colors.grey.shade300; 
      textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ─── Helper de Data Formatada ────────────────────────────────────
  
  String _formatDate(DateTime date) {
    final diasSemana = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
    
    final diaSemana = diasSemana[date.weekday - 1];
    final dia = date.day.toString().padLeft(2, '0');
    final mes = date.month.toString().padLeft(2, '0');
    
    return "$diaSemana, $dia/$mes/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(notice.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12), 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: typeColor.withAlpha(80), width: 1.5), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ÍCONE LATERAL
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: typeColor.withAlpha(25), 
                shape: BoxShape.circle,
              ),
              child: Icon(_getTypeIcon(notice.type), color: typeColor, size: 20),
            ),
            const SizedBox(width: 12),
            
            // CONTEÚDO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notice.title,
                          style: const TextStyle(
                            fontSize: 15, // Reduzido
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2, 
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Badge do Tipo 
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          notice.type.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.edit_outlined, size: 18, color: Colors.grey.shade600),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onSelected: (value) {
                            if (value == 'edit') onEdit();
                            if (value == 'delete') onDelete();
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
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 6),

                  if (notice.description != null && notice.description!.trim().isNotEmpty) ...[
                    Text(
                      notice.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Data e Pill de Tempo Restante (Usando Wrap contra overflow horizontal)
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        _formatDate(notice.date),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      _buildTimeRemainingPill(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}