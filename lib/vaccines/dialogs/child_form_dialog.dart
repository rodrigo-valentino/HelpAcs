import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/child_model.dart';
import '../providers/child_list_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_input_decoration.dart';
import '../../utils/date_formatter.dart';
import '../../utils/cupertino_date_picker.dart';
import '../../utils/feedback_helper.dart';
import '../../widgets/base_dialog.dart';

class ChildFormDialog extends ConsumerStatefulWidget {
  final ChildModel? childToEdit;

  const ChildFormDialog({super.key, this.childToEdit});

  @override
  ConsumerState<ChildFormDialog> createState() => _ChildFormDialogState();
}

class _ChildFormDialogState extends ConsumerState<ChildFormDialog> {
  final _nameCtrl = TextEditingController();
  final _guardianCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  
  DateTime? _birthDate;
  String? _dateError; 

  @override
  void initState() {
    super.initState();
    if (widget.childToEdit != null) {
      final c = widget.childToEdit!;
      _nameCtrl.text = c.name;
      _guardianCtrl.text = c.guardianName ?? '';
      _notesCtrl.text = c.notes ?? '';
      _cpfCtrl.text = c.cpf ?? ''; // Preenche com o que estiver no banco
      _birthDate = c.birthDate;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _guardianCtrl.dispose();
    _notesCtrl.dispose();
    _cpfCtrl.dispose();
    super.dispose();
  }

  String _getAgeLabel() {
    if (_birthDate == null) return '';
    final years = DateFormatter.calculateAge(_birthDate!);
    if (years > 0) return 'Idade: $years anos';
    final now = DateTime.now();
    final difference = now.difference(_birthDate!).inDays;
    final months = (difference / 30).floor();
    return 'Idade: $months meses';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.childToEdit != null;

    return BaseFormDialog(
      title: isEditing ? 'Editar Paciente' : 'Cadastrar Paciente',
      icon: Icons.child_care,
      iconColor: AppColors.primary,
      saveButtonText: isEditing ? 'Atualizar' : 'Salvar',
      saveButtonColor: AppColors.primary,
      
      onSubmit: () async {
        if (_birthDate == null) {
          setState(() => _dateError = 'A data de nascimento é obrigatória');
          return false; // Apenas para a execução aqui. O BaseFormDialog não fechará.
        }
        
        bool dateChanged = false;
        if (isEditing) {
            final oldDate = DateFormatter.toDateOnly(widget.childToEdit!.birthDate);
            final newDate = DateFormatter.toDateOnly(_birthDate!);
            dateChanged = !oldDate.isAtSameMomentAs(newDate);
        }

        if (dateChanged) {
          final confirm = await FeedbackHelper.showConfirmation(
            context,
            title: 'Alterar Data de Nascimento?',
            message: 'Ao mudar a data, o cronograma de vacinas será REINICIADO.\n\n'
                     'Qualquer vacina já marcada como "Aplicada" será perdida.',
            confirmText: 'Confirmar e Reiniciar',
            cancelText: 'Cancelar',
            confirmColor: AppColors.error, 
          );
          if (!confirm) return false; 
        }

        final notifier = ref.read(childListControllerProvider.notifier);
        
        // Pegando o CPF sem máscara
        final rawCpf = _cpfCtrl.text.trim();
        final finalCpf = rawCpf.isEmpty ? null : rawCpf;

        if (isEditing) {
          await notifier.updateChild(
            key: widget.childToEdit!.key, // Usando a 'key' do Hive
            name: _nameCtrl.text.trim(),
            birthDate: _birthDate!,
            guardian: _guardianCtrl.text.trim(),
            notes: _notesCtrl.text.trim(),
            cpf: finalCpf,
          );
        } else {
          await notifier.addChild(
            ChildModel(
              name: _nameCtrl.text.trim(),
              birthDate: _birthDate!,
              guardianName: _guardianCtrl.text.trim(),
              notes: _notesCtrl.text.trim(),
              cpf: finalCpf,
            ),
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
              _buildLabel('Nome do Paciente'),
              TextFormField(
                controller: _nameCtrl,
                decoration: AppInputDecoration.outlined(hint: 'Ex: João Silva', prefixIcon: Icons.person_outline),
                textCapitalization: TextCapitalization.words,
                validator: (value) => (value == null || value.trim().isEmpty) ? 'O nome é obrigatório' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Data de nascimento'),
              InkWell(
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  final date = await showCupertinoDatePickerModal(
                    context: context,
                    initialDate: _birthDate ?? DateTime.now(), 
                    firstDate: DateTime(2000), 
                    lastDate: DateTime.now(), 
                    title: "Data de Nascimento",
                  );

                  if (date != null) {
                    setState(() {
                      _birthDate = date;
                      _dateError = null;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _dateError != null ? AppColors.error : Colors.grey.shade400,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, 
                           color: _birthDate == null ? Colors.grey : AppColors.primary),
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
                    _getAgeLabel(),
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                
              if (isEditing && _birthDate != null && 
                  !_birthDate!.dateOnly.isAtSameMomentAs(widget.childToEdit!.birthDate.dateOnly))
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.warning),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.warning),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "Alterar a data recalculará as vacinas futuras.",
                            style: TextStyle(fontSize: 11, color: AppColors.warning),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),

              _buildLabel('CPF (opcional)'),
              TextFormField(
                controller: _cpfCtrl,
                keyboardType: TextInputType.number, // Aciona o teclado numérico
                decoration: AppInputDecoration.outlined(
                  hint: 'Apenas números',
                  prefixIcon: Icons.badge_outlined,
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel('Responsável (opcional)'),
              TextFormField(
                controller: _guardianCtrl,
                decoration: AppInputDecoration.outlined(
                  hint: 'Mãe, Pai, Avó...',
                  prefixIcon: Icons.people_outline,
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              _buildLabel('Observações (opcional)'),
              TextFormField(
                controller: _notesCtrl,
                decoration: AppInputDecoration.outlined(
                  hint: 'Alergias, condições especiais, etc.',
                  prefixIcon: Icons.notes,
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
        style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500, fontSize: 14),
      ),
    );
  }
}