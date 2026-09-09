// lib/debug/seed_test_data.dart
import 'package:hive_flutter/hive_flutter.dart';

import '../woman/models/woman_model.dart';
import '../pregnant/models/pregnant_woman_model.dart';
import '../pregnant/enums/pregnancy_enums.dart';
import '../vaccines/models/child_model.dart';
import '../vaccines/models/vaccine_record_model.dart';
import '../vaccines/models/calendar_models.dart';
import '../enums/health_status.dart';
import '../utils/hive_keys.dart';

class SeedTestData {
  SeedTestData._();

  static Future<void> run() async {
    final now = DateTime.now();

    // ═══════════════════════════════════════════
    // 1) SAÚDE DA MULHER
    // ═══════════════════════════════════════════
    final womanBox = Hive.box<WomanModel>(HiveKeys.womanBox);

    // 🟢 Em dia — preventivo feito recentemente
    await womanBox.add(WomanModel()
      ..name = 'Teste Mulher - Em Dia'
      ..birthDate = DateTime(now.year - 35, now.month, now.day)
      ..lastPreventivoDate = now.subtract(const Duration(days: 60))
      ..nextPreventivoDate = now.add(const Duration(days: 305))
      ..isSus = true);

    // 🟡 Atenção — vence em 15 dias (janela de aviso é 30 dias)
    await womanBox.add(WomanModel()
      ..name = 'Teste Mulher - Atenção'
      ..birthDate = DateTime(now.year - 35, now.month, now.day)
      ..lastPreventivoDate = now.subtract(const Duration(days: 350))
      ..nextPreventivoDate = now.add(const Duration(days: 15))
      ..isSus = true);

    // 🔴 Atrasada — venceu há 40 dias
    await womanBox.add(WomanModel()
      ..name = 'Teste Mulher - Atrasada'
      ..birthDate = DateTime(now.year - 35, now.month, now.day)
      ..lastPreventivoDate = now.subtract(const Duration(days: 400))
      ..nextPreventivoDate = now.subtract(const Duration(days: 40))
      ..isSus = true);

    // ⚪ Pendente — nunca fez o exame
    await womanBox.add(WomanModel()
      ..name = 'Teste Mulher - Pendente'
      ..birthDate = DateTime(now.year - 35, now.month, now.day)
      ..isSus = false);

    // Bônus: paciente na faixa de mamografia (65+), mamografia atrasada
    await womanBox.add(WomanModel()
      ..name = 'Teste Mulher - Mamografia Atrasada'
      ..birthDate = DateTime(now.year - 68, now.month, now.day)
      ..lastMammographyDate = now.subtract(const Duration(days: 800))
      ..nextMammographyDate = now.subtract(const Duration(days: 70))
      ..isSus = true);

    // ═══════════════════════════════════════════
    // 2) GESTANTES (risco + progresso, não os 4 status)
    // ═══════════════════════════════════════════
    final pregnantBox = Hive.box<PregnantWomanModel>(HiveKeys.pregnantBox);

    await pregnantBox.add(PregnantWomanModel.create(
      name: 'Teste Gestante - Risco Habitual',
      birthDate: DateTime(now.year - 27, now.month, now.day),
      dum: now.subtract(const Duration(days: 90)), // ~13 semanas
      riskLevel: PregnancyRisk.habitual,
    ));

    await pregnantBox.add(PregnantWomanModel.create(
      name: 'Teste Gestante - Alto Risco',
      birthDate: DateTime(now.year - 32, now.month, now.day),
      dum: now.subtract(const Duration(days: 210)), // ~30 semanas
      riskLevel: PregnancyRisk.highRisk,
      notes: 'Hipertensão gestacional',
    ));

    await pregnantBox.add(PregnantWomanModel.create(
      name: 'Teste Gestante - Início da Gestação',
      birthDate: DateTime(now.year - 22, now.month, now.day),
      dum: now.subtract(const Duration(days: 30)), // ~4 semanas
      riskLevel: PregnancyRisk.habitual,
    ));

    // ═══════════════════════════════════════════
    // 3) VACINAS (CRIANÇAS)
    // ═══════════════════════════════════════════
    final childBox = Hive.box<ChildModel>(HiveKeys.childrenBox);
    final groupBox = Hive.box<VaccineGroupModel>(HiveKeys.calendarGroupsBox);
    final vaccineBox = Hive.box<VaccineDefinitionModel>(HiveKeys.calendarVaccinesBox);

    final activeGroups = groupBox.values.where((g) => g.active).toList();
    final firstGroup = activeGroups.isNotEmpty ? activeGroups.first : null;

    VaccineDefinitionModel? firstVaccine;
    if (firstGroup != null) {
      final vaccinesInGroup = vaccineBox.values
          .where((v) => v.active && v.groupKey == firstGroup.key)
          .toList();
      if (vaccinesInGroup.isNotEmpty) firstVaccine = vaccinesInGroup.first;
    }

    // 🟢 Em dia — primeira dose do primeiro grupo aplicada
    final childOk = ChildModel(
      name: 'Crianca - Em Dia',
      birthDate: now.subtract(const Duration(days: 120)),
      status: HealthStatus.upToDate,
    );
    if (firstGroup != null && firstVaccine != null) {
      childOk.vaccines.add(VaccineRecord(
        name: firstVaccine.name,
        doseNumber: 1,
        applied: true,
        group: firstGroup.label,
        vaccineDefinitionKey: firstVaccine.key as int,
        groupKey: firstGroup.key as int,
      ));
    }
    await childBox.add(childOk);

    // 🟡 Atenção — recém-nascida, dose do grupo "Ao nascer" vencendo agora
    await childBox.add(ChildModel(
      name: 'Criança - Atenção',
      birthDate: now,
      status: HealthStatus.warning,
    ));

    // 🔴 Atrasada — nasceu há tempo suficiente pra ter vacina vencida sem aplicar
    await childBox.add(ChildModel(
      name: 'Criança - Atrasada',
      birthDate: now.subtract(const Duration(days: 400)),
      status: HealthStatus.overdue,
    ));

    // ⚪ Pendente — cadastro novo, nenhuma avaliação registrada
    await childBox.add(ChildModel(
      name: 'Criança - Pendente',
      birthDate: now.subtract(const Duration(days: 10)),
      status: HealthStatus.pending,
    ));
  }
}