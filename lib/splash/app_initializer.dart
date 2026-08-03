// lib/splash/app_initializer.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ─── Módulos anteriores ──────────────────────────────────────────────────────
import '../vaccines/models/child_model.dart';
import '../vaccines/models/vaccine_record_model.dart';
import '../vaccines/models/campaign_vaccine_model.dart';
import '../profile/models/profile_model.dart';
import '../enums/health_status.dart';
import '../nutrition/models/nutrition_record_model.dart';
import '../woman/models/woman_model.dart';
import '../utils/hive_keys.dart';

// ─── Módulo Gestantes ─────────────────────────────────────────────────────────
import '../pregnant/models/pregnant_woman_model.dart';
import '../pregnant/models/prenatal_consultation_model.dart';
import '../pregnant/models/ultrasound_exam_model.dart';
import '../pregnant/models/lab_exam_model.dart';
import '../pregnant/models/prenatal_vaccine_model.dart';
import '../pregnant/enums/pregnancy_enums.dart';

// ─── Calendário e Notas ───────────────────────────────────────────────────────
import '../calendar/models/notice_model.dart';
import '../calendar/enums/notice_enums.dart';
import '../notes/models/task_model.dart';

// ─── 🆕 Catálogo de Calendário Vacinal (editável) ─────────────────────────────
import '../vaccines/models/calendar_models.dart';
import '../vaccines/utils/calendar_seed.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ESTADO DA INICIALIZAÇÃO
// ─────────────────────────────────────────────────────────────────────────────

enum InitStatus { idle, running, complete, error }

class InitializationState {
  final InitStatus status;
  final String message;
  final double progress; // 0.0 → 1.0
  final String? errorMessage;

  const InitializationState({
    this.status = InitStatus.idle,
    this.message = 'Iniciando...',
    this.progress = 0.0,
    this.errorMessage,
  });

  bool get isComplete  => status == InitStatus.complete;
  bool get hasError    => status == InitStatus.error;
  bool get isRunning   => status == InitStatus.running;

  InitializationState copyWith({
    InitStatus? status,
    String? message,
    double? progress,
    String? errorMessage,
  }) {
    return InitializationState(
      status:       status       ?? this.status,
      message:      message      ?? this.message,
      progress:     progress     ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROVIDER
// ─────────────────────────────────────────────────────────────────────────────

final appInitializerProvider =
    StateNotifierProvider<AppInitializer, InitializationState>((ref) {
  return AppInitializer();
});

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFIER — orquestra cada passo com progresso granular
// ─────────────────────────────────────────────────────────────────────────────

class AppInitializer extends StateNotifier<InitializationState> {
  AppInitializer() : super(const InitializationState());

  /// Executa a sequência completa de inicialização.
  ///
  /// Usa [Future.timeout] do dart:async — sem conflito de nomes.
  /// Timeout de 30s previne travamento infinito caso algo falhe silenciosamente.
  Future<void> initialize() async {
    if (state.isRunning || state.isComplete) return;

    try {
      await _runInitSequence().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          // Chamado pelo dart:async quando o tempo limite é atingido
          if (!state.hasError) {
            state = state.copyWith(
              status: InitStatus.error,
              message: 'Tempo esgotado',
              errorMessage:
                  'A inicialização demorou mais de 30 segundos.\n'
                  'Tente fechar e reabrir o aplicativo.',
            );
          }
        },
      );
    } catch (e) {
      // Somente sobrescreve se ainda não foi marcado como erro (ex: pelo onTimeout)
      if (!state.hasError) {
        state = state.copyWith(
          status: InitStatus.error,
          message: 'Erro ao inicializar',
          errorMessage: e.toString(),
        );
      }
    }
  }

  Future<void> _runInitSequence() async {
    // ── Passo 1: Hive.initFlutter ──────────────────────────────────────────
    _step('Inicializando banco de dados...', 0.05);
    await Hive.initFlutter();

    // ── Passo 2: Registro de adaptadores ──────────────────────────────────
    _step('Registrando adaptadores de dados...', 0.20);
    await Future.delayed(const Duration(milliseconds: 80));
    _registerAdapters();

    // ── Passo 3: Abertura das boxes ────────────────────────────────────────
    _step('Carregando dados locais...', 0.45);
    await _openBoxes();

    // ── Passo 4: 🆕 Calendário vacinal (catálogo editável) ──────────────────
    _step('Configurando calendário vacinal...', 0.65);
    await CalendarSeed.runIfNeeded();

    // ── Passo 5: Configuração ───────────────────────────────────────────────
    _step('Configurando ambiente...', 0.80);
    await Future.delayed(const Duration(milliseconds: 200));

    // ── Passo 6: Finalização ────────────────────────────────────────────────
    _step('Quase pronto...', 0.92);
    await Future.delayed(const Duration(milliseconds: 350));

    state = state.copyWith(
      status:   InitStatus.complete,
      message:  'Pronto!',
      progress: 1.0,
    );
  }

  void _step(String message, double progress) {
    state = state.copyWith(
      status:   InitStatus.running,
      message:  message,
      progress: progress,
    );
  }

  // ── Registro de todos os adaptadores Hive ─────────────────────────────────

  void _registerAdapters() {
    // Módulos existentes
    Hive.registerAdapter(HealthStatusAdapter());          // TypeId: 0
    Hive.registerAdapter(ChildModelAdapter());            // TypeId: 1
    Hive.registerAdapter(ProfileModelAdapter());          // TypeId: 2
    Hive.registerAdapter(VaccineRecordAdapter());         // TypeId: 3
    Hive.registerAdapter(CampaignVaccineModelAdapter());  // TypeId: 4
    Hive.registerAdapter(WomanModelAdapter());            // TypeId: 5
    // TypeIds 6, 8, 9, 12 estão livres
    Hive.registerAdapter(FoodConsistencyAdapter());       // TypeId: 7
    Hive.registerAdapter(NutritionAnswerAdapter());       // TypeId: 10
    Hive.registerAdapter(FoodFrequencyAdapter());         // TypeId: 11
    Hive.registerAdapter(AgeCategoryAdapter());           // TypeId: 13
    Hive.registerAdapter(NutritionRecordModelAdapter());  // TypeId: 14

    // Módulo Gestantes
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

    // Calendário e Notas
    Hive.registerAdapter(NoticeTypeAdapter());                // TypeId: 25
    Hive.registerAdapter(NoticeModelAdapter());                // TypeId: 26
    Hive.registerAdapter(TaskModelAdapter());                  // TypeId: 27

    // 🆕 Catálogo de Calendário Vacinal (editável pelo usuário)
    Hive.registerAdapter(AgeUnitAdapter());                    // TypeId: 28
    Hive.registerAdapter(VaccineGroupModelAdapter());           // TypeId: 29
    Hive.registerAdapter(VaccineDefinitionModelAdapter());      // TypeId: 30
  }

  // ── Abertura paralela das boxes ───────────────────────────────────────────

  Future<void> _openBoxes() async {
    await Future.wait([
      Hive.openBox<WomanModel>(HiveKeys.womanBox),
      Hive.openBox<ChildModel>(HiveKeys.childrenBox),
      Hive.openBox<ProfileModel>(HiveKeys.profileBox),
      Hive.openBox<NutritionRecordModel>(HiveKeys.nutritionBox),
      Hive.openBox<PregnantWomanModel>(HiveKeys.pregnantBox),
      Hive.openBox<NoticeModel>(HiveKeys.noticeBox),
      Hive.openBox<TaskModel>(HiveKeys.taskBox),
      // 🆕 Catálogo de Calendário Vacinal
      Hive.openBox<VaccineGroupModel>(HiveKeys.calendarGroupsBox),
      Hive.openBox<VaccineDefinitionModel>(HiveKeys.calendarVaccinesBox),
      Hive.openBox(HiveKeys.calendarMetaBox),
    ]);
  }
}