import 'package:flutter/material.dart';

final class AppColors {
  // ========================================
  // 🎨 CORES PRINCIPAIS
  // ========================================

  static const Color primary = Colors.blue;

  // ========================================
  // 🎨 STATUS
  // ========================================

  // ✅ Sucesso
  static const Color success = Color(0xFF4CAF50);
  static final Color successSurface = success.withAlpha(20);
  static final Color successContainer = success.withAlpha(35);
  static final Color successBorder = success.withAlpha(60);

  // ⚠️ Atenção
  static const Color warning = Colors.orange;
  static final Color warningSurface = warning.withAlpha(20);
  static final Color warningContainer = warning.withAlpha(35);
  static final Color warningBorder = warning.withAlpha(60);

  // ❌ Erro
  static const Color error = Colors.red;
  static final Color errorSurface = error.withAlpha(20);
  static final Color errorContainer = error.withAlpha(35);
  static final Color errorBorder = error.withAlpha(60);

  // ℹ️ Informação
  static const Color info = Colors.blueGrey;
  static final Color infoSurface = info.withAlpha(20);
  static final Color infoContainer = info.withAlpha(35);
  static final Color infoBorder = info.withAlpha(60);

  // ========================================
  // 🎨 BACKGROUNDS
  // ========================================

  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color inputFill = Color(0xFFF9FAFB);

  // ========================================
  // 🎨 TEXTOS
  // ========================================

  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.grey;
  static const Color hint = Color(0xFF9E9E9E);

  // ========================================
  // 🎨 BORDAS
  // ========================================

  static const Color border = Color(0xFFE0E0E0);
}