import 'package:flutter/material.dart';

abstract class AppColors {
  // 🎨 COR OFICIAL DO APP (Vou deixar Azul, que é padrão para apps de saúde, mas pode mudar para Colors.teal se preferir)
  static const Color primary = Colors.blue; 

  // 🚥 Cores Semânticas (Status)
  static const Color success = Color(0xFF4CAF50); // Verde
  static const Color warning = Colors.orange;     // Laranja
  static const Color error = Colors.red;          // Vermelho
  static const Color info = Colors.blueGrey;

  // ⚪ Cores de Fundo e Superfícies
  static const Color background = Color(0xFFF5F7FA);
  
  // Cores de Texto
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.grey;
}