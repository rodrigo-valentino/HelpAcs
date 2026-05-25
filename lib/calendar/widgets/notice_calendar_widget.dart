import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../theme/app_colors.dart';
import '../models/notice_model.dart';
import '../providers/notice_controller.dart';

class NoticeCalendarWidget extends ConsumerWidget {
  const NoticeCalendarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuta a lista de avisos para preencher o calendário
    final notices = ref.watch(noticeListProvider);
    
    // Escuta a data selecionada atualmente
    final selectedDate = ref.watch(selectedNoticeDateProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SfCalendar(
          view: CalendarView.month,
          initialSelectedDate: selectedDate,
          initialDisplayDate: selectedDate,
          
          // Injeta os dados para os indicadores aparecerem nas datas
          dataSource: _NoticeDataSource(notices),

          // ✅ Número da semana ativado como você pediu
          showWeekNumber: true,
          weekNumberStyle: WeekNumberStyle(
            backgroundColor: Colors.grey.shade50,
            textStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),

          showNavigationArrow: true,
          headerStyle: const CalendarHeaderStyle(
            textAlign: TextAlign.center,
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          
          // Estética do calendário
          cellBorderColor: Colors.transparent,
          todayHighlightColor: AppColors.primary,
          selectionDecoration: BoxDecoration(
            color: AppColors.primary.withAlpha(20),
            border: Border.all(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          
          monthViewSettings: const MonthViewSettings(
            showAgenda: false,
            appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
            dayFormat: 'EEE', // seg, ter, qua...
            monthCellStyle: MonthCellStyle(
              textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),

          // Ao clicar, atualiza o estado global da data
          onTap: (CalendarTapDetails details) {
            if (details.targetElement == CalendarElement.calendarCell && details.date != null) {
              ref.read(selectedNoticeDateProvider.notifier).state = details.date!;
            }
          },
        ),
      ),
    );
  }
}

// ─── DataSource para o Syncfusion ler nossos modelos ───
class _NoticeDataSource extends CalendarDataSource {
  _NoticeDataSource(List<NoticeModel> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) => appointments![index].date;

  @override
  DateTime getEndTime(int index) => appointments![index].date;

  @override
  String getSubject(int index) => appointments![index].title;

  @override
  Color getColor(int index) => AppColors.primary;

  @override
  bool isAllDay(int index) => true;
}