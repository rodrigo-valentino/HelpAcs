import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/pregnant_woman_model.dart';
import '../models/prenatal_consultation_model.dart';
import '../models/ultrasound_exam_model.dart';
import '../models/lab_exam_model.dart';
import '../models/prenatal_vaccine_model.dart';
import '../../utils/hive_keys.dart';
import 'pregnant_list_controller.dart';

final pregnantDetailsProvider =
    NotifierProvider.family<PregnantDetailsNotifier, PregnantWomanModel?, int>(
        () {
  return PregnantDetailsNotifier();
});

class PregnantDetailsNotifier extends FamilyNotifier<PregnantWomanModel?, int> {
  
  // ✅ CORREÇÃO: Transformado em getter. 
  // Evita o erro de inicialização e busca a box instantaneamente na memória do Hive.
  Box<PregnantWomanModel> get _box => Hive.box<PregnantWomanModel>(HiveKeys.pregnantBox);

  @override
  PregnantWomanModel? build(int arg) {
    return _box.get(arg);
  }

  @override
  bool updateShouldNotify(PregnantWomanModel? previous, PregnantWomanModel? next) {
    return true; 
  }

  void _refresh() {
    state = _box.get(arg);
    ref.read(pregnantListProvider.notifier).refresh();
  }

  // ─── CONSULTAS ──────────────────────────────────────────────

  void toggleConsultation(String itemId) {
    if (state == null) return;
    final index = state!.consultations.indexWhere((c) => c.id == itemId);
    if (index != -1) {
      state!.consultations[index].completed =
          !state!.consultations[index].completed;
      state!.save();
      _refresh();
    }
  }

  void updateConsultation(
    String itemId, {
    required String? customName,
    required DateTime? date,
    required String? notes,
  }) {
    if (state == null) return;
    final index = state!.consultations.indexWhere((c) => c.id == itemId);
    if (index != -1) {
      state!.consultations[index].customName = customName;
      state!.consultations[index].date = date;
      state!.consultations[index].notes = notes;
      state!.save();
      _refresh();
    }
  }

  void addConsultation(PrenatalConsultationModel consultation) {
    if (state == null) return;
    state!.consultations.add(consultation);
    state!.save();
    _refresh();
  }

  void deleteConsultation(String itemId) {
    if (state == null) return;
    state!.consultations.removeWhere((c) => c.id == itemId);
    state!.save();
    _refresh();
  }

  // ─── ULTRASSONS ─────────────────────────────────────────────

  void toggleUltrasound(String itemId) {
    if (state == null) return;
    final index = state!.ultrasounds.indexWhere((u) => u.id == itemId);
    if (index != -1) {
      state!.ultrasounds[index].completed =
          !state!.ultrasounds[index].completed;
      state!.save();
      _refresh();
    }
  }

  void updateUltrasound(
    String itemId, {
    required String? customName,
    required DateTime? date,
    required String? result,
  }) {
    if (state == null) return;
    final index = state!.ultrasounds.indexWhere((u) => u.id == itemId);
    if (index != -1) {
      state!.ultrasounds[index].customName = customName;
      state!.ultrasounds[index].date = date;
      state!.ultrasounds[index].result = result;
      state!.save();
      _refresh();
    }
  }

  void addUltrasound(UltrasoundExamModel ultrasound) {
    if (state == null) return;
    state!.ultrasounds.add(ultrasound);
    state!.save();
    _refresh();
  }

  void deleteUltrasound(String itemId) {
    if (state == null) return;
    state!.ultrasounds.removeWhere((u) => u.id == itemId);
    state!.save();
    _refresh();
  }

  // ─── EXAMES ─────────────────────────────────────────────────

  void toggleExam(String itemId) {
    if (state == null) return;
    final index = state!.labExams.indexWhere((e) => e.id == itemId);
    if (index != -1) {
      state!.labExams[index].completed = !state!.labExams[index].completed;
      state!.save();
      _refresh();
    }
  }

  void updateExam(
    String itemId, {
    required String? customName,
    required DateTime? date,
    required String? result,
  }) {
    if (state == null) return;
    final index = state!.labExams.indexWhere((e) => e.id == itemId);
    if (index != -1) {
      state!.labExams[index].customName = customName;
      state!.labExams[index].date = date;
      state!.labExams[index].result = result;
      state!.save();
      _refresh();
    }
  }

  void addExam(LabExamModel exam) {
    if (state == null) return;
    state!.labExams.add(exam);
    state!.save();
    _refresh();
  }

  void deleteExam(String itemId) {
    if (state == null) return;
    state!.labExams.removeWhere((e) => e.id == itemId);
    state!.save();
    _refresh();
  }

  // ─── VACINAS ────────────────────────────────────────────────

  void toggleVaccine(String itemId) {
    if (state == null) return;
    final index = state!.vaccines.indexWhere((v) => v.id == itemId);
    if (index != -1) {
      state!.vaccines[index].administered =
          !state!.vaccines[index].administered;
      state!.save();
      _refresh();
    }
  }

  void updateVaccine(
    String itemId, {
    required String? customName,
    required DateTime? date,
    required String? notes,
  }) {
    if (state == null) return;
    final index = state!.vaccines.indexWhere((v) => v.id == itemId);
    if (index != -1) {
      state!.vaccines[index].customName = customName;
      state!.vaccines[index].date = date;
      state!.vaccines[index].notes = notes;
      state!.save();
      _refresh();
    }
  }

  void addVaccine(PrenatalVaccineModel vaccine) {
    if (state == null) return;
    state!.vaccines.add(vaccine);
    state!.save();
    _refresh();
  }

  void deleteVaccine(String itemId) {
    if (state == null) return;
    state!.vaccines.removeWhere((v) => v.id == itemId);
    state!.save();
    _refresh();
  }

  // ─── GALERIA ───────────────────────────────────────────────

  Future<void> addGalleryImage(String path) async {
    if (state == null) return;
    state!.photoPaths.add(path);
    await state!.save();
    _refresh();
  }

  Future<void> removeGalleryImage(int index) async {
    if (state == null) return;
    if (index < 0 || index >= state!.photoPaths.length) {
      return;
    }
    state!.photoPaths.removeAt(index);
    await state!.save();
    _refresh();
  }
}