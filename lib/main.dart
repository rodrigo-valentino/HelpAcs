import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:helpacs/home/pages/home_page.dart';

// Módulos Anteriores
import './vaccines/models/child_model.dart';
import './vaccines/models/vaccine_record_model.dart';
import './vaccines/models/campaign_vaccine_model.dart';
import './profile/models/profile_model.dart';
import './theme/app_colors.dart';
import './enums/health_status.dart';
import './nutrition/models/nutrition_record_model.dart';
import './woman/models/woman_model.dart';
import '../../utils/hive_keys.dart';

// ✅ NOVOS IMPORTS: Módulo Gestantes
import './pregnant/models/pregnant_woman_model.dart';
import './pregnant/models/prenatal_consultation_model.dart';
import './pregnant/models/ultrasound_exam_model.dart';
import './pregnant/models/lab_exam_model.dart';
import './pregnant/models/prenatal_vaccine_model.dart';
import './pregnant/enums/pregnancy_enums.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // ─── ADAPTADORES EXISTENTES ──────────────────────────────────────────
  Hive.registerAdapter(HealthStatusAdapter());          // TypeId: 0
  Hive.registerAdapter(ChildModelAdapter());            // TypeId: 1
  Hive.registerAdapter(ProfileModelAdapter());          // TypeId: 2
  Hive.registerAdapter(VaccineRecordAdapter());         // TypeId: 3
  Hive.registerAdapter(CampaignVaccineModelAdapter());  // TypeId: 4
  Hive.registerAdapter(WomanModelAdapter());            // TypeId: 5
  // TypeIds 6 estão livres 
  Hive.registerAdapter(FoodConsistencyAdapter());       // TypeId: 7
  // TypeIds 8, 9 estão livres
  Hive.registerAdapter(NutritionAnswerAdapter());       // TypeId: 10
  Hive.registerAdapter(FoodFrequencyAdapter());         // TypeId: 11
  // TypeId 12 está livre
  Hive.registerAdapter(AgeCategoryAdapter());           // TypeId: 13
  Hive.registerAdapter(NutritionRecordModelAdapter());  // TypeId: 14

  // ─── ✅ NOVOS ADAPTADORES (Módulo Gestantes) ───────────────────────
  Hive.registerAdapter(PregnantWomanModelAdapter());        // TypeId: 15
  Hive.registerAdapter(PrenatalConsultationModelAdapter()); // TypeId: 16
  Hive.registerAdapter(UltrasoundExamModelAdapter());       // TypeId: 17
  Hive.registerAdapter(LabExamModelAdapter());              // TypeId: 18
  Hive.registerAdapter(PrenatalVaccineModelAdapter());      // TypeId: 19
  Hive.registerAdapter(PregnancyRiskAdapter());             // TypeId: 20
  Hive.registerAdapter(ConsultationTypeAdapter());          // TypeId: 21
  Hive.registerAdapter(UltrasoundTypeAdapter());            // TypeId: 22
  Hive.registerAdapter(LabExamTypeAdapter());               // TypeId: 23
  Hive.registerAdapter(PrenatalVaccineTypeAdapter());       // TypeId: 24

  // Abrir as boxes principais para evitar atrasos na UI
  await Future.wait([
    Hive.openBox<WomanModel>(HiveKeys.womanBox),
    Hive.openBox<ChildModel>(HiveKeys.childrenBox),
    Hive.openBox<ProfileModel>(HiveKeys.profileBox),
    Hive.openBox<NutritionRecordModel>(HiveKeys.nutritionBox),
    Hive.openBox<PregnantWomanModel>(HiveKeys.pregnantBox),
  ]);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Serviço e Acompanhamento',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.background,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}