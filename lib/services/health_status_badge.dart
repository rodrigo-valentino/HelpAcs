import 'package:flutter/material.dart';
import '../theme/app_colors.dart'; 
import '../core/enums/health_status.dart'; // 🆕 Import do Enum Global

class HealthStatusBadge extends StatelessWidget {
  final HealthStatus status; // 🆕 Agora recebe o HealthStatus global
  final double fontSize;

  const HealthStatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color bgColor;
    String label;
    IconData icon;

    // A mágica centralizada!
    switch (status) {
      case ChildHealthStatus.upToDate:
        textColor = AppColors.success; // Verde
        bgColor = AppColors.success.withAlpha(25);
        label = 'Em Dia';
        icon = Icons.check_circle_outline;
        break;
      case ChildHealthStatus.warning:
        textColor = AppColors.warning; // Laranja/Amarelo
        bgColor = AppColors.warning.withAlpha(25);
        label = 'Atenção';
        icon = Icons.access_time;
        break;
      case ChildHealthStatus.overdue:
        textColor = AppColors.error; // Vermelho
        bgColor = AppColors.error.withAlpha(25);
        label = 'Atrasado';
        icon = Icons.error_outline;
        break;
      case ChildHealthStatus.pending:
      default:
        textColor = Colors.grey.shade700;
        bgColor = Colors.grey.shade200;
        label = 'Pendente';
        icon = Icons.help_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Ocupa apenas o tamanho necessário
        children: [
          Icon(icon, size: fontSize + 4, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}