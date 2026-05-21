import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/woman_controller.dart';
import '../../enums/health_status.dart';

class WomanStats {
  final int total;
  final int overdue;
  final int warning;
  final int pending;

  WomanStats({
    required this.total,
    required this.overdue,
    required this.warning,
    required this.pending,
  });

  factory WomanStats.empty() => WomanStats(total: 0, overdue: 0, warning: 0, pending: 0);
}

final womanStatsProvider = Provider<WomanStats>((ref) {
  final womenAsync = ref.watch(womanListControllerProvider);

  return womenAsync.maybeWhen(
    data: (list) {
      int overdue = 0;
      int warning = 0;
      int pending = 0;

      for (final woman in list) {
        final status = woman.badgeStatus;
        if (status == HealthStatus.overdue) {
          overdue++;
        } else if (status == HealthStatus.warning) {
          warning++;
        } else if (status == HealthStatus.pending) {
          pending++;
        }
      }

      return WomanStats(
        total: list.length,
        overdue: overdue,
        warning: warning,
        pending: pending,
      );
    },
    orElse: () => WomanStats.empty(),
  );
});