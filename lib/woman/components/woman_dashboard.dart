import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../providers/woman_stats_provider.dart';

class WomanDashboard extends ConsumerWidget {
  const WomanDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(womanStatsProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _StatCard(
            label: "Atrasados",
            count: stats.overdue,
            color: AppColors.error,
            icon: Icons.warning_amber_rounded,
          ),
          const SizedBox(width: 12),
          _StatCard(
            label: "Atenção",
            count: stats.warning,
            color: AppColors.warning,
            icon: Icons.access_time_rounded,
          ),
          const SizedBox(width: 12),
          _StatCard(
            label: "Pendentes",
            count: stats.pending,
            color: AppColors.textSecondary,
            icon: Icons.help_outline_rounded,
          ),
          const SizedBox(width: 12),
          _StatCard(
            label: "Total",
            count: stats.total,
            color: Colors.purple,
            icon: Icons.people_outline_rounded,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }
}