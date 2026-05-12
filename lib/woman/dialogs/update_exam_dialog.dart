// lib/woman/dialogs/update_exam_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../utils/date_formatter.dart';
import '../../utils/cupertino_date_picker.dart';
import '../../utils/feedback_helper.dart';
import '../../widgets/base_dialog.dart';

import '../models/woman_model.dart';
import '../providers/woman_controller.dart';

class WomanExamUpdateDialog extends ConsumerStatefulWidget {
  final WomanModel woman;
  final bool isPreventivo;

  const WomanExamUpdateDialog({
    super.key,
    required this.woman,
    required this.isPreventivo,
  });

  @override
  ConsumerState<WomanExamUpdateDialog> createState() =>
      _WomanExamUpdateDialogState();
}

class _WomanExamUpdateDialogState
    extends ConsumerState<WomanExamUpdateDialog> {
  late DateTime _lastDate;
  late DateTime _nextDate;

  @override
  void initState() {
    super.initState();
    _initializeDates();
  }

  void _initializeDates() {
    final now = DateTime.now();
    final periodDays = widget.isPreventivo ? 365 : 730;

    if (widget.isPreventivo) {
      _lastDate = widget.woman.lastPreventivoDate ?? now;
      _nextDate = widget.woman.nextPreventivoDate ??
          _lastDate.add(Duration(days: periodDays));
    } else {
      _lastDate = widget.woman.lastMammographyDate ?? now;
      _nextDate = widget.woman.nextMammographyDate ??
          _lastDate.add(Duration(days: periodDays));
    }
  }

  Future<void> _pickLastDate() async {
    final picked = await showCupertinoDatePickerModal(
      context: context,
      initialDate: _lastDate,
      lastDate: DateTime.now(),
      title: 'Data Realizada',
    );

    if (picked != null) {
      setState(() {
        _lastDate = picked;
        // Recalcula o próximo vencimento automaticamente ao alterar a data realizada.
        final periodDays = widget.isPreventivo ? 365 : 730;
        _nextDate = picked.add(Duration(days: periodDays));
      });
    }
  }

  Future<void> _pickNextDate() async {
    final picked = await showCupertinoDatePickerModal(
      context: context,
      initialDate: _nextDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      title: 'Próximo Exame',
    );

    if (picked != null) {
      setState(() => _nextDate = picked);
    }
  }

  Future<bool> _handleSubmit() async {
    try {
      await ref.read(womanListControllerProvider.notifier).updateExamDate(
        widget.woman.id,
        lastDate: _lastDate,
        nextDate: _nextDate,
        isPreventivo: widget.isPreventivo,
      );
      return true;
    } catch (e) {
      // Antes: o erro era silenciado com "return false" e o dialog apenas
      // ficava aberto sem nenhuma mensagem — o agente não sabia o que ocorreu.
      if (mounted) {
        FeedbackHelper.showError(
          context,
          'Erro ao salvar: ${e.toString().replaceAll('Exception:', '').trim()}',
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final examName = widget.isPreventivo ? 'Preventivo' : 'Mamografia';
    final periodText = widget.isPreventivo ? '1 ano' : '2 anos';

    return BaseFormDialog(
      title: 'Atualizar $examName',
      icon: Icons.edit_calendar,
      iconColor: Colors.purple,
      saveButtonText: 'Salvar',
      saveButtonColor: Colors.purple,
      onSubmit: _handleSubmit,
      builder: (formKey) {
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDateField(
                label: 'Data Realizada',
                date: _lastDate,
                onTap: _pickLastDate,
                icon: Icons.event_available,
                isHighlight: false,
              ),
              const SizedBox(height: 20),
              _buildDateField(
                label: 'Próximo Vencimento',
                date: _nextDate,
                onTap: _pickNextDate,
                icon: Icons.event_note,
                isHighlight: true,
              ),
              const SizedBox(height: 12),
              _buildHelpText(periodText),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
    required IconData icon,
    required bool isHighlight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isHighlight ? Colors.purple : Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isHighlight
                  ? Colors.purple.withAlpha(10)
                  : Colors.grey.shade50,
              border: Border.all(
                color:
                    isHighlight ? Colors.purple : Colors.grey.shade400,
                width: isHighlight ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: isHighlight
                          ? Colors.purple
                          : Colors.grey.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DateFormatter.format(date),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isHighlight
                            ? Colors.purple
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.edit,
                  size: 16,
                  color: isHighlight ? Colors.purple : Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpText(String periodText) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.infoSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.infoBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: AppColors.info),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'O sistema calculou automaticamente $periodText, '
              'mas você pode alterar o próximo vencimento acima.',
              style: TextStyle(fontSize: 11, color: AppColors.info),
            ),
          ),
        ],
      ),
    );
  }
}