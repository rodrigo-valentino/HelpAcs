import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../utils/date_formatter.dart';
import '../../utils/cupertino_date_picker.dart';
import '../../widgets/base_dialog.dart';

import '../models/pregnant_woman_model.dart';
import '../enums/pregnancy_enums.dart';
import '../providers/pregnant_list_controller.dart';

class PregnantFormDialog extends ConsumerStatefulWidget {
  final PregnantWomanModel? woman;

  const PregnantFormDialog({super.key, this.woman});

  @override
  ConsumerState<PregnantFormDialog> createState() => _PregnantFormDialogState();
}

class _PregnantFormDialogState extends ConsumerState<PregnantFormDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _notesCtrl;

  DateTime? _birthDate;
  DateTime? _selectedPregnancyDate;

  bool _useDum = true;
  PregnancyRisk _riskLevel = PregnancyRisk.habitual;
  String? _birthDateError;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.woman?.name);
    _notesCtrl = TextEditingController(text: widget.woman?.notes);
    _birthDate = widget.woman?.birthDate;

    if (widget.woman != null) {
      _riskLevel = widget.woman!.riskLevel;
      if (widget.woman!.dum != null) {
        _useDum = true;
        _selectedPregnancyDate = widget.woman!.dum;
      } else if (widget.woman!.dpp != null) {
        _useDum = false;
        _selectedPregnancyDate = widget.woman!.dpp;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isBirthDate}) async {
    final now = DateTime.now();

    final initialDate = isBirthDate
        ? (_birthDate ?? DateTime(1995))
        : (_selectedPregnancyDate ?? now);

    final firstDate = isBirthDate
        ? DateTime(1900)
        : now.subtract(const Duration(days: 300));

    final lastDate = isBirthDate
        ? now
        : now.add(const Duration(days: 300));

    final title = isBirthDate
        ? 'Data de Nascimento'
        : (_useDum ? 'Data da Última Menstruação (DUM)' : 'Data Provável do Parto (DPP)');

    final date = await showCupertinoDatePickerModal(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      title: title,
    );

    if (date != null) {
      setState(() {
        if (isBirthDate) {
          _birthDate = date;
          _birthDateError = null;
        } else {
          _selectedPregnancyDate = date;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.woman != null;
    const themeColor = AppColors.primary;

    return BaseFormDialog(
      title: isEditing ? 'Editar Gestante' : 'Cadastrar Gestante',
      isEditMode: isEditing,
      icon: isEditing ? Icons.edit_note : Icons.pregnant_woman,
      iconColor: themeColor,
      saveButtonText: isEditing ? 'Atualizar' : 'Salvar',
      saveButtonColor: themeColor,
      onSubmit: () async {
        if (_birthDate == null) {
          setState(() => _birthDateError = 'Data de nascimento é obrigatória');
          return false;
        }

        if (isEditing) {
          widget.woman!.name = _nameCtrl.text.trim();
          widget.woman!.birthDate = _birthDate!;
          widget.woman!.notes =
              _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();
          widget.woman!.riskLevel = _riskLevel;
          widget.woman!.dum = _useDum ? _selectedPregnancyDate : null;
          widget.woman!.dpp = !_useDum ? _selectedPregnancyDate : null;

          await ref
              .read(pregnantListProvider.notifier)
              .updatePregnant(widget.woman!);
        } else {
          final newPregnant = PregnantWomanModel.create(
            name: _nameCtrl.text.trim(),
            birthDate: _birthDate!,
            notes:
                _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
            riskLevel: _riskLevel,
            dum: _useDum ? _selectedPregnancyDate : null,
            dpp: !_useDum ? _selectedPregnancyDate : null,
          );

          await ref.read(pregnantListProvider.notifier).addPregnant(newPregnant);
        }
        return true;
      },
      builder: (formKey) {
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLabel('Nome Completo'),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration(
                  hint: 'Ex: Maria Silva',
                  icon: Icons.person_outline,
                  activeColor: themeColor,
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'O nome é obrigatório'
                        : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Data de Nascimento'),
              InkWell(
                onTap: () => _pickDate(isBirthDate: true),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(
                      color: _birthDateError != null
                          ? AppColors.error
                          : Colors.grey.shade400,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          color: _birthDate == null ? Colors.grey : themeColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _birthDate == null
                              ? 'Selecione a data'
                              : DateFormatter.format(_birthDate!),
                          style: TextStyle(
                            fontSize: 16,
                            color: _birthDate == null
                                ? Colors.grey.shade600
                                : Colors.black87,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              if (_birthDateError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 12),
                  child: Text(_birthDateError!,
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 12)),
                )
              else if (_birthDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 12),
                  child: Text(
                    'Idade: ${DateFormatter.calculateAge(_birthDate!)} anos',
                    style: const TextStyle(
                      color: themeColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              _buildLabel('Classificação de Risco da Gestação'),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: SwitchListTile(
                  title: Text(
                    _riskLevel == PregnancyRisk.habitual
                        ? 'Risco Habitual'
                        : 'Alto Risco',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _riskLevel == PregnancyRisk.habitual
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                  value: _riskLevel == PregnancyRisk.highRisk,
                  activeThumbColor: AppColors.error,
                  activeTrackColor: AppColors.errorSurface,
                  inactiveThumbColor: AppColors.success,
                  inactiveTrackColor: AppColors.successSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _riskLevel =
                          val ? PregnancyRisk.highRisk : PregnancyRisk.habitual;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel('Cálculo Gestacional (Opcional)'),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Usar DUM',
                          style: TextStyle(fontSize: 14)),
                      value: true,
                      // ignore: deprecated_member_use
                      groupValue: _useDum,
                      contentPadding: EdgeInsets.zero,
                      activeColor: themeColor,
                      // ignore: deprecated_member_use
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _useDum = v;
                            _selectedPregnancyDate = null;
                          });
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Usar DPP',
                          style: TextStyle(fontSize: 14)),
                      value: false,
                      // ignore: deprecated_member_use
                      groupValue: _useDum,
                      contentPadding: EdgeInsets.zero,
                      activeColor: themeColor,
                      // ignore: deprecated_member_use
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _useDum = v;
                            _selectedPregnancyDate = null;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              InkWell(
                onTap: () => _pickDate(isBirthDate: false),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.baby_changing_station,
                          color: _selectedPregnancyDate == null
                              ? Colors.grey
                              : themeColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedPregnancyDate == null
                              ? 'Selecione a data (${_useDum ? 'DUM' : 'DPP'})'
                              : DateFormatter.format(_selectedPregnancyDate!),
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedPregnancyDate == null
                                ? Colors.grey.shade600
                                : Colors.black87,
                          ),
                        ),
                      ),
                      if (_selectedPregnancyDate != null)
                        GestureDetector(
                          onTap: () =>
                              setState(() => _selectedPregnancyDate = null),
                          child: const Icon(Icons.close,
                              color: Colors.grey, size: 20),
                        )
                      else
                        const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              _buildLabel('Observações Gerais (Opcional)'),
              TextFormField(
                controller: _notesCtrl,
                decoration: _inputDecoration(
                  hint: 'Alergias, histórico médico, etc.',
                  icon: Icons.notes,
                  activeColor: themeColor,
                ).copyWith(alignLabelWithHint: true),
                maxLines: 3,
                maxLength: 500,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required Color activeColor,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: activeColor),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: activeColor, width: 2),
      ),
    );
  }
}