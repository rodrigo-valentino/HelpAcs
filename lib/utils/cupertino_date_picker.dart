import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoDatePickerWidget extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String title;
  final Function(DateTime) onDateSelected;

  const CupertinoDatePickerWidget({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.title,
    required this.onDateSelected,
  });

  @override
  State<CupertinoDatePickerWidget> createState() => _CupertinoDatePickerWidgetState();
}

class _CupertinoDatePickerWidgetState extends State<CupertinoDatePickerWidget> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    // Garante que a data inicial esteja dentro do intervalo permitido
    if (widget.initialDate.isBefore(widget.firstDate)) {
      _selectedDate = widget.firstDate;
    } else if (widget.initialDate.isAfter(widget.lastDate)) {
      _selectedDate = widget.lastDate;
    } else {
      _selectedDate = widget.initialDate;
    }
  }

  void _confirm() {
    widget.onDateSelected(_selectedDate);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 16),
                  ),
                ),
                
                Expanded(
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center, // Centraliza
                    overflow: TextOverflow.ellipsis, // Corta com "..." se for muito grande
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                TextButton(
                  onPressed: _confirm,
                  child: Text(
                    'Confirmar',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Date Picker
          Expanded(
            child: CupertinoTheme(
              data: CupertinoThemeData(
                brightness: Theme.of(context).brightness,
                primaryColor: Theme.of(context).colorScheme.primary,
              ),
              child: Localizations.override(
                context: context,
                locale: const Locale('pt', 'BR'),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedDate,
                  minimumDate: widget.firstDate,
                  maximumDate: widget.lastDate,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      _selectedDate = newDate;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<DateTime?> showCupertinoDatePickerModal({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  String title = 'Selecione a data',
}) async {
  DateTime? selectedDate;

  // Função interna para remover horas (Zerar o relógio)
  DateTime toDateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Normaliza todas as datas para 00:00:00
  final DateTime safeFirst = toDateOnly(firstDate ?? DateTime(1900));
  final DateTime safeLast = toDateOnly(lastDate ?? DateTime.now().add(const Duration(days: 365 * 2)));
  DateTime safeInitial = toDateOnly(initialDate);

  // Proteção extra: Garante que o initial está dentro do intervalo
  if (safeInitial.isBefore(safeFirst)) safeInitial = safeFirst;
  if (safeInitial.isAfter(safeLast)) safeInitial = safeLast;

  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => CupertinoDatePickerWidget(
      initialDate: safeInitial,
      firstDate: safeFirst,
      lastDate: safeLast,
      title: title,
      onDateSelected: (date) {
        selectedDate = date;
      },
    ),
  );

  return selectedDate;
}