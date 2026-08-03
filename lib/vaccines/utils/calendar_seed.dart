import 'package:hive_flutter/hive_flutter.dart';
import '../models/calendar_models.dart';
import '../../utils/hive_keys.dart';

/// Roda uma única vez (checado via calendarMetaBox) para popular o
/// catálogo editável a partir do calendário oficial atual. A partir daí,
/// o usuário assume o controle total via CalendarController — este seed
/// nunca mais roda de novo.
class CalendarSeed {
  CalendarSeed._();

  static const _seedDoneKey = 'calendarSeedDone';

  static Future<void> runIfNeeded() async {
    final metaBox = await Hive.openBox(HiveKeys.calendarMetaBox);
    if (metaBox.get(_seedDoneKey, defaultValue: false) == true) return;

    final groupsBox = await Hive.openBox<VaccineGroupModel>(HiveKeys.calendarGroupsBox);
    final vaccinesBox = await Hive.openBox<VaccineDefinitionModel>(HiveKeys.calendarVaccinesBox);

    // Só semeia se realmente estiver vazio (proteção extra contra reinstalar
    // por cima de um banco já configurado manualmente pelo usuário).
    if (groupsBox.isNotEmpty || vaccinesBox.isNotEmpty) {
      await metaBox.put(_seedDoneKey, true);
      return;
    }

    // Estrutura: (label, ageValue, ageUnit, [ (nomeVacina, totalDoses) ])
    final seed = <(String, int, AgeUnit, List<(String, int)>)>[
      ('Ao nascer', 0, AgeUnit.days, [
        ('BCG', 1),
        ('Hepatite B', 1),
      ]),
      ('2 meses', 2, AgeUnit.months, [
        ('Penta (DTP+Hib+HepB)', 1),
        ('VIP (Pólio Inativada)', 1),
        ('Pneumocócica 20v', 1),
        ('Rotavírus', 1),
      ]),
      ('3 meses', 3, AgeUnit.months, [
        ('Meningocócica C', 1),
      ]),
      ('4 meses', 4, AgeUnit.months, [
        ('Penta (DTP+Hib+HepB)', 1),
        ('VIP (Pólio Inativada)', 1),
        ('Pneumocócica 20v', 1),
        ('Rotavírus', 1),
      ]),
      ('5 meses', 5, AgeUnit.months, [
        ('Meningocócica C', 1),
      ]),
      ('6 meses', 6, AgeUnit.months, [
        ('Penta (DTP+Hib+HepB)', 1),
        ('VIP (Pólio Inativada)', 1),
      ]),
      ('9 meses', 9, AgeUnit.months, [
        ('Febre Amarela', 1),
      ]),
      ('12 meses', 12, AgeUnit.months, [
        ('Tríplice Viral (SCR)', 1),
        ('Meningocócica ACWY', 1),
        ('Pneumo 20v (1° Reforço)', 1),
      ]),
      ('15 meses', 15, AgeUnit.months, [
        ('Hepatite A', 1),
        ('Varicela', 1),
        ('Triviral SCR (1° Reforço)', 1),
        ('DTP (1° Reforço)', 1),
        ('VIP (1° Reforço)', 1),
      ]),
      ('4 anos', 4, AgeUnit.years, [
        ('Varicela', 1),
        ('Febre Amarela', 1),
        ('DTP (2° Reforço)', 1),
        ('VIP (2° Reforço)', 1),        
      ]),
      ('9 a 14 anos', 9, AgeUnit.years, [
        ('HPV', 1),
      ]),
      ('11 anos', 11, AgeUnit.years, [
        ('Meningocócica ACWY', 1),
      ]),
      ('14 anos', 14, AgeUnit.years, [ 
        ('dT (Dupla Adulto)', 1), 
      ]),
    ];

    for (var i = 0; i < seed.length; i++) {
      final (label, ageValue, ageUnit, vaccines) = seed[i];

      final group = VaccineGroupModel(
        label: label,
        ageValue: ageValue,
        ageUnit: ageUnit,
        order: i,
      );
      final groupKey = await groupsBox.add(group);

      for (var j = 0; j < vaccines.length; j++) {
        final (name, totalDoses) = vaccines[j];
        await vaccinesBox.add(
          VaccineDefinitionModel(
            groupKey: groupKey,
            name: name,
            totalDoses: totalDoses,
            order: j,
          ),
        );
      }
    }

    await metaBox.put(_seedDoneKey, true);
  }
}