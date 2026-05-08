import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppInputDecoration {
  static const _radius = BorderRadius.all(Radius.circular(12));

  static InputDecoration outlined({
    String? hint,
    String? label,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      hintStyle: const TextStyle(
        color: AppColors.hint,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppColors.primary)
          : null,
      filled: true,
      fillColor: AppColors.inputFill,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),

      border: _border(),
      enabledBorder: _border(),
      focusedBorder: _border(
        color: AppColors.primary,
        width: 2,
      ),
      errorBorder: _border(
        color: AppColors.error,
        width: 1.5,
      ),
      focusedErrorBorder: _border(
        color: AppColors.error,
        width: 2,
      ),
    );
  }

  static OutlineInputBorder _border({
    Color color = AppColors.border,
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: _radius,
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }
}