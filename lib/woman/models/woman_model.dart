import 'package:hive/hive.dart';
import '../../utils/date_formatter.dart';
import '../../enums/health_status.dart';

part 'woman_model.g.dart';

@HiveType(typeId: 5)
class WomanModel extends HiveObject {
  int get id => key as int? ?? -1;

  @HiveField(0)
  late String name;

  @HiveField(1)
  late DateTime birthDate;
  
  // --- DATAS DO PREVENTIVO ---
  @HiveField(2)
  DateTime? lastPreventivoDate;

  @HiveField(3)
  DateTime? nextPreventivoDate; 

  // --- DATAS DA MAMOGRAFIA ---
  @HiveField(4)
  DateTime? lastMammographyDate;

  @HiveField(5)
  DateTime? nextMammographyDate; 
  
  @HiveField(6)
  String? notes;

  @HiveField(7)
  bool isSus = true; // true = SUS, false = Particular

  // --- LÓGICA DE NEGÓCIO ---

  int get age => DateFormatter.calculateAge(birthDate);

  /// 🚦 Helper para Ordenação: Retorna o "peso" do status geral da paciente
  /// 3 = Crítico (Overdue) - Aparece no topo
  /// 2 = Atenção (Warning)
  /// 1 = Em dia (UpToDate)
  /// 0 = Outros (Pending, null)
  int get generalStatusWeight {
    final statuses = [preventivoStatus, mammographyStatus].whereType<HealthStatus>().toList();
    
    if (statuses.isEmpty) return 0;
    if (statuses.contains(HealthStatus.overdue)) return 3;
    if (statuses.contains(HealthStatus.warning)) return 2;
    if (statuses.contains(HealthStatus.upToDate)) return 1;
    
    return 0; // Para pendentes
  }
  
  /// Preventivo (25 a 64 anos)
  HealthStatus? get preventivoStatus {
    if (age < 25 || age > 64) return null; // Não aplicável
    if (lastPreventivoDate == null) return HealthStatus.pending; // Nunca feito
    
    final targetDate = nextPreventivoDate ?? lastPreventivoDate!.add(const Duration(days: 365));
    return _calculateStatus(targetDate);
  }

  /// Mamografia (50 a 74 anos)
  HealthStatus? get mammographyStatus {
    if (age < 50 || age > 74) return null; // Não aplicável
    if (lastMammographyDate == null) return HealthStatus.pending; // Nunca feito

    final targetDate = nextMammographyDate ?? lastMammographyDate!.add(const Duration(days: 730));
    return _calculateStatus(targetDate);
  }

  HealthStatus _calculateStatus(DateTime nextDue) {
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final dueNorm = DateTime(nextDue.year, nextDue.month, nextDue.day);

    if (todayNorm.isAfter(dueNorm)) return HealthStatus.overdue;
    
    final diff = dueNorm.difference(todayNorm).inDays;
    if (diff <= 30) return HealthStatus.warning;

    return HealthStatus.upToDate;
  }

  /// 🎯 LÓGICA DO BADGE GLOBAL
  /// 
  /// Retorna o status mais crítico entre os exames aplicáveis, ou null se nenhum se aplica.
  HealthStatus? get badgeStatus {
    final applicableStatuses = [preventivoStatus, mammographyStatus].whereType<HealthStatus>().toList();

    if (applicableStatuses.isEmpty) {
      return null;
    }

    if (applicableStatuses.contains(HealthStatus.overdue)) {
      return HealthStatus.overdue;
    }

    if (applicableStatuses.contains(HealthStatus.pending)) {
      return HealthStatus.pending;
    }

    if (applicableStatuses.contains(HealthStatus.warning)) {
      return HealthStatus.warning;
    }

    return HealthStatus.upToDate;
  }
}