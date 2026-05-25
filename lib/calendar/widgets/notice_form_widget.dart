import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../utils/cupertino_date_picker.dart';
import '../../utils/date_formatter.dart';
import '../enums/notice_enums.dart';
import '../models/notice_model.dart';
import '../providers/notice_controller.dart';

class NoticeFormWidget extends ConsumerStatefulWidget {
  final NoticeModel? noticeToEdit;

  const NoticeFormWidget({super.key, this.noticeToEdit});

  @override
  ConsumerState<NoticeFormWidget> createState() => _NoticeFormWidgetState();
}

class _NoticeFormWidgetState extends ConsumerState<NoticeFormWidget> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  NoticeType _selectedType = NoticeType.event;
  DateTime? _selectedDate;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _initForm();
  }

  @override
  void didUpdateWidget(covariant NoticeFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.noticeToEdit != widget.noticeToEdit) {
      _initForm();
    }
  }

  void _initForm() {
    if (widget.noticeToEdit != null) {
      _titleCtrl.text = widget.noticeToEdit!.title;
      _descCtrl.text  = widget.noticeToEdit!.description ?? '';
      _selectedType   = widget.noticeToEdit!.type;
      _selectedDate   = widget.noticeToEdit!.date;
    } else {
      _titleCtrl.clear();
      _descCtrl.clear();
      _selectedType = NoticeType.event;
      _selectedDate = null;
    }
    _errorMsg = null;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ── Salvar ───────────────────────────────────────────────

  void _saveNotice() {
    final title = _titleCtrl.text.trim();

    if (title.isEmpty || _selectedDate == null) {
      setState(() => _errorMsg = 'Título e Data são obrigatórios.');
      return;
    }


    final desc = _descCtrl.text.trim().isEmpty
        ? null
        : _descCtrl.text.trim();

    if (widget.noticeToEdit != null) {

      final updated = widget.noticeToEdit!.copyWith(
        title: title,
        description: desc,
        type: _selectedType,
        date: _selectedDate!,
      );
      ref.read(noticeListProvider.notifier).updateNotice(updated);
    } else {
      final newNotice = NoticeModel.create(
        title: title,
        description: desc,
        type: _selectedType,
        date: _selectedDate!,
      );
      ref.read(noticeListProvider.notifier).addNotice(newNotice);
    }

    // Fecha e limpa o formulário
    ref.read(noticeEditingProvider.notifier).state = null;
    ref.read(noticeFormExpandedProvider.notifier).state = false;
  }

  // ── Seleção de data ──────────────────────────────────────

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showCupertinoDatePickerModal(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 1825)),
      title: 'Data do Evento',
    );

    if (date != null && mounted) {
      setState(() {
        _selectedDate = date;
        _errorMsg = null;
      });
    }
  }

  // ── Build ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.noticeToEdit != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? 'Editar Aviso/Evento' : 'Novo Aviso/Evento',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildLabel('Título do Evento'),
          TextField(
            controller: _titleCtrl,
            decoration: _inputDeco('Ex: Dia D de Vacinação'),
          ),
          const SizedBox(height: 16),

          _buildLabel('Descrição'),
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            decoration: _inputDeco('Detalhes do evento...'),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              // ── Tipo ──────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Tipo'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<NoticeType>(
                          value: _selectedType,
                          isExpanded: true,
                          items: NoticeType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.label),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedType = val!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // ── Data ──────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Data do Evento'),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedDate == null
                                    ? 'Selecionar data'
                                    : DateFormatter.format(_selectedDate!),
                                style: TextStyle(
                                  color: _selectedDate == null
                                      ? Colors.grey
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Mensagem de erro ─────────────────────────────
          if (_errorMsg != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _errorMsg!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                ),
              ),
            ),

          const SizedBox(height: 20),

          // ── Botão de salvar ──────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveNotice,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isEditing ? 'Atualizar Evento' : 'Adicionar ao Calendário',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers de UI ────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}