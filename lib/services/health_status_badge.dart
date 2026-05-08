import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../enums/health_status.dart';

class HealthStatusBadge extends StatelessWidget {
  final HealthStatus status;
  final double fontSize;

  const HealthStatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    late final Color textColor;
    late final Color backgroundColor;
    late final Color borderColor;
    late final String label;
    late final IconData icon;

    switch (status) {
      case HealthStatus.upToDate:
        textColor = AppColors.success;
        backgroundColor = AppColors.successSurface;
        borderColor = AppColors.successBorder;
        label = 'Em Dia';
        icon = Icons.check_circle_outline;
        break;

      case HealthStatus.warning:
        textColor = AppColors.warning;
        backgroundColor = AppColors.warningSurface;
        borderColor = AppColors.warningBorder;
        label = 'Atenção';
        icon = Icons.access_time;
        break;

      case HealthStatus.overdue:
        textColor = AppColors.error;
        backgroundColor = AppColors.errorSurface;
        borderColor = AppColors.errorBorder;
        label = 'Atrasado';
        icon = Icons.error_outline;
        break;

      case HealthStatus.pending:
        textColor = AppColors.textSecondary;
        backgroundColor = AppColors.surface;
        borderColor = AppColors.border;
        label = 'Pendente';
        icon = Icons.help_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: fontSize + 4,
            color: textColor,
          ),

          const SizedBox(width: 6),

          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}