import 'package:hive/hive.dart';

part 'health_status.g.dart';

@HiveType(typeId: 0) //
enum HealthStatus {
  @HiveField(0)
  upToDate,   // Em dia

  @HiveField(1)
  warning,    // Atenção (vence em breve)

  @HiveField(2)
  overdue,    // Atrasado

  @HiveField(3)
  pending,    // Pendente (sem dados)
}