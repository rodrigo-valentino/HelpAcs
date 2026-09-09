// lib/utils/date_formatter.dart

class DateFormatter {
  DateFormatter._();
  
  /// Formata data no padrão brasileiro: DD/MM/YYYY
  static String format(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }
  
  /// Formata data com hora: DD/MM/YYYY HH:mm
  static String formatWithTime(DateTime date) {
    return '${format(date)} '
           '${date.hour.toString().padLeft(2, '0')}:'
           '${date.minute.toString().padLeft(2, '0')}';
  }
  
  /// Formata data relativa: "Hoje", "Ontem", "DD/MM/YYYY"
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    final difference = today.difference(dateOnly).inDays;
    
    if (difference == 0) return 'Hoje';
    if (difference == 1) return 'Ontem';
    if (difference == -1) return 'Amanhã';
    
    return format(date);
  }
  
  /// Calcula idade em anos
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
  
  /// Remove horário (zera para 00:00:00)
  static DateTime toDateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

/// Extension para uso fluente
extension DateTimeFormatting on DateTime {
  String get formatted => DateFormatter.format(this);
  String get formattedWithTime => DateFormatter.formatWithTime(this);
  String get relativeFormatted => DateFormatter.formatRelative(this);
  DateTime get dateOnly => DateFormatter.toDateOnly(this);
}
