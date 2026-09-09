import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Imports de Utils e Theme
import '../../theme/app_colors.dart';
import '../../utils/date_formatter.dart';
import '../../utils/cupertino_date_picker.dart';
import '../../widgets/base_dialog.dart';
import '../models/woman_model.dart';

// Controller
import '../providers/woman_controller.dart';

class WomanFormDialog extends ConsumerStatefulWidget {
  final WomanModel? woman;

  const WomanFormDialog({super.key, this.woman});

  @override
  ConsumerState<WomanFormDialog> createState() => _WomanFormDialogState();
}

class _WomanFormDialogState extends ConsumerState<WomanFormDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _notesCtrl;
  DateTime? _birthDate;
  bool _isSus = true;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.woman?.name);
    _notesCtrl = TextEditingController(text: widget.woman?.notes);
    _birthDate = widget.woman?.birthDate;
    _isSus = widget.woman?.isSus ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // Helper de Data
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showCupertinoDatePickerModal(
      context: context,
      initialDate: _birthDate ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: now, 
      title: "Data de Nascimento",
    );
    
    if (date != null) {
      setState(() {
        _birthDate = date;
        _dateError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.woman != null;
    const themeColor = Colors.purple;

    return BaseFormDialog(
      title: isEditing ? 'Editar Paciente' : 'Cadastrar Paciente',
      isEditMode: isEditing,
      icon: isEditing ? Icons.edit_note : Icons.face_3, 
      iconColor: themeColor,
      saveButtonText: isEditing ? 'Atualizar' : 'Salvar',
      saveButtonColor: themeColor,
      
      onSubmit: () async {
        if (_birthDate == null) {
          setState(() => _dateError = 'Data de nascimento é obrigatória');
          return false;
        }

        if (isEditing) {
          // ✅ Lógica de Atualização
          await ref.read(womanListControllerProvider.notifier).updateWomanInfo(
            widget.woman!.id,
            name: _nameCtrl.text.trim(),
            birthDate: _birthDate!,
            notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
            isSus: _isSus,
          );
        } else {
          // Lógica de Cadastro
          await ref.read(womanListControllerProvider.notifier).addWoman(
            _nameCtrl.text.trim(),
            _birthDate!,
            notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
            isSus: _isSus,
          );
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
                  value == null || value.trim().isEmpty ? 'O nome é obrigatório' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Data de Nascimento'),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(
                      color: _dateError != null ? AppColors.error : Colors.grey.shade400,
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
                            color: _birthDate == null ? Colors.grey.shade600 : Colors.black87,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              if (_dateError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 12),
                  child: Text(_dateError!, 
                      style: TextStyle(color: AppColors.error, fontSize: 12)),
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

              _buildLabel('Tipo de Atendimento'),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: SwitchListTile(
                  title: Text(
                    _isSus ? 'Paciente SUS' : 'Paciente Particular',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _isSus ? AppColors.info : AppColors.success,
                    ),
                  ),
                  value: _isSus,
                  activeThumbColor: AppColors.info, // Cor para SUS
                  inactiveThumbColor: AppColors.success, // Cor para Particular
                  inactiveTrackColor: AppColors.successSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onChanged: (val) => setState(() => _isSus = val),
                ),
              ),

              const SizedBox(height: 16),

              _buildLabel('Observações (opcional)'),
              TextFormField(
                controller: _notesCtrl,
                decoration: _inputDecoration(
                  hint: 'Histórico, condições prévias, etc.',
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

  // --- Helpers UI ---

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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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