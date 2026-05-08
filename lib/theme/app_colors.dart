// lib/theme/app_colors.dart
import 'package:flutter/material.dart';
/// Sistema de cores padronizado do app
/// Baseado em Material You 3 com Colors.teal como seed
class AppColors {
  AppColors._(); // Construtor privado para classe utilitária
  
  static const Color primary = Colors.teal;
  static const Color secondary = Colors.tealAccent;
  
  // ========================================
  // 🔲 SUPERFÍCIES E CONTAINERS (Teal)
  // ========================================
  
  /// Para fundos muito claros (AppBar, Cards leves)
  /// Equivalente a 5% de opacidade
  static final Color tealSurface = primary.withAlpha(12);
  
  /// Para fundos de containers secundários
  /// Equivalente a 10% de opacidade
  static final Color tealContainer = primary.withAlpha(30);
  
  /// Para bordas e divisores
  /// Equivalente a 25% de opacidade
  static final Color tealBorder = primary.withAlpha(60);
  
  /// Para destaques e hover states
  /// Equivalente a 40% de opacidade
  static final Color tealHighlight = primary.withAlpha(100);

  // ========================================
  // 🎨 CORES DE STATUS
  // ========================================
  
  // Verde (Sucesso)
  static const Color success = Colors.green;
  static final Color successSurface = success.withAlpha(12);
  static final Color successContainer = success.withAlpha(30);
  static final Color successBorder = success.withAlpha(60);
  
  // Laranja (Atenção/Alerta)
  static const Color warning = Colors.orange;
  static final Color warningSurface = warning.withAlpha(12);
  static final Color warningContainer = warning.withAlpha(30);
  static final Color warningBorder = warning.withAlpha(60);
  
  // Vermelho (Erro/Crítico)
  static const Color error = Colors.red;
  static final Color errorSurface = error.withAlpha(12);
  static final Color errorContainer = error.withAlpha(30);
  static final Color errorBorder = error.withAlpha(60);
  
  // Azul (Info)
  static const Color info = Colors.blue;
  static final Color infoSurface = info.withAlpha(12);
  static final Color infoContainer = info.withAlpha(30);
  static final Color infoBorder = info.withAlpha(60);
  
  // Rosa (Gestantes)
  static const Color pink = Colors.pink;
  static final Color pinkSurface = pink.withAlpha(12);
  static final Color pinkContainer = pink.withAlpha(30);
  static final Color pinkBorder = pink.withAlpha(60);
  
  // Roxo (Especial)
  static const Color purple = Colors.purple;
  static final Color purpleSurface = purple.withAlpha(12);
  static final Color purpleContainer = purple.withAlpha(30);
  static final Color purpleBorder = purple.withAlpha(60);

  // ========================================
  // 🩺 CORES ESPECÍFICAS DO DOMÍNIO
  // ========================================
  
  /// Cores para tipos de eventos clínicos
  static const Color vaccine = Colors.blue;
  static const Color consultation = Colors.green;
  static const Color exam = Colors.orange;
  static const Color ultrasound = Colors.purple;
  static const Color dental = Colors.teal;
  static const Color nutritional = Colors.lightGreen;
  
  // ========================================
  // 🔘 SURFACES PARA EVENTOS
  // ========================================
  
  static final Color vaccineSurface = vaccine.withAlpha(30);
  static final Color consultationSurface = consultation.withAlpha(30);
  static final Color examSurface = exam.withAlpha(30);
  static final Color ultrasoundSurface = ultrasound.withAlpha(30);
  static final Color dentalSurface = dental.withAlpha(30);
  static final Color nutritionalSurface = nutritional.withAlpha(30);

  // ========================================
  // 🎯 HELPERS DE COR POR TIPO
  // ========================================
  
  /// Retorna a cor principal baseada no status de vacinação
  static Color getVaccineStatusColor(VaccineStatusType status) {
    switch (status) {
      case VaccineStatusType.completed:
        return success;
      case VaccineStatusType.partial:
        return warning;
      case VaccineStatusType.overdue:
        return error;
      case VaccineStatusType.pending:
        return info;
    }
  }
  
  /// Retorna a cor de superfície baseada no status de vacinação
  static Color getVaccineStatusSurface(VaccineStatusType status) {
    switch (status) {
      case VaccineStatusType.completed:
        return successContainer;
      case VaccineStatusType.partial:
        return warningContainer;
      case VaccineStatusType.overdue:
        return errorContainer;
      case VaccineStatusType.pending:
        return infoContainer;
    }
  }
  
  /// Retorna a cor baseada no status de exame preventivo/mamografia
  static Color getExamStatusColor(ExamStatusType status) {
    switch (status) {
      case ExamStatusType.upToDate:
        return success;
      case ExamStatusType.alert:
        return warning;
      case ExamStatusType.overdue:
        return error;
      case ExamStatusType.neverExamined:
        return Colors.grey;
    }
  }
  
  /// Retorna a cor de superfície baseada no status de exame
  static Color getExamStatusSurface(ExamStatusType status) {
    switch (status) {
      case ExamStatusType.upToDate:
        return successContainer;
      case ExamStatusType.alert:
        return warningContainer;
      case ExamStatusType.overdue:
        return errorContainer;
      case ExamStatusType.neverExamined:
        return Colors.grey.withAlpha(30);
    }
  }
  
  /// Retorna a cor baseada no progresso (0.0 a 1.0)
  static Color getProgressColor(double progress) {
    if (progress >= 0.8) return success;
    if (progress >= 0.5) return warning;
    return error;
  }
}


// ========================================
// 📋 ENUMS DE SUPORTE
// ========================================

enum VaccineStatusType {
  completed,
  partial,
  overdue,
  pending,
}

enum ExamStatusType {
  upToDate,
  alert,
  overdue,
  neverExamined,
}