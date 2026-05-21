import 'package:flutter/material.dart';
import '../../widgets/base_dialog.dart';
import '../../theme/app_input_decoration.dart';
import '../../utils/date_formatter.dart';

class ManageItemDialog extends StatefulWidget {
  final String title;
  final String itemLabel; // Ex: "Nome do Exame" ou "Nome da Vacina"
  final String? initialName;
  final DateTime? initialDate;
  final String? initialNotes;
  
  /// Retorna os dados para a Tab que chamou este diálogo salvar no Hive
  final Future<void> Function(String name, DateTime? date, String? notes) onSave;

  const ManageItemDialog({
    super.key,
    required this.title,
    required this.itemLabel,
    required this.onSave,
    this.initialName,
    this.initialDate,
    this.initialNotes,
  });

  @override
  State<ManageItemDialog> createState() => _ManageItemDialogState();
}

class _ManageItemDialogState extends State<ManageItemDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _notesController = TextEditingController(text: widget.initialNotes);
    _selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 300)), // Permite datas retroativas recentes
      lastDate: DateTime.now().add(const Duration(days: 300)),       // Permite agendamentos futuros
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialName != null;

    return BaseFormDialog(
      title: widget.title,
      icon: isEdit ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
      isEditMode: isEdit,
      onSubmit: () async {
        // Envia os dados coletados de volta para a Tab que acionou o diálogo
        await widget.onSave(
          _nameController.text.trim(),
          _selectedDate,
          _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
        return true; // Retorna true para o BaseFormDialog fechar automaticamente
      },
      builder: (formKey) {
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: AppInputDecoration.outlined(
                  label: widget.itemLabel, 
                  prefixIcon: Icons.medical_information_outlined,
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Insira um nome válido' : null,
              ),
              const SizedBox(height: 16),
              
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: AppInputDecoration.outlined(
                    label: 'Data (Opcional)', 
                    prefixIcon: Icons.calendar_month,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_selectedDate == null ? 'Selecionar data' : _selectedDate!.formatted),
                      if (_selectedDate != null)
                        GestureDetector(
                          onTap: () => setState(() => _selectedDate = null),
                          child: const Icon(Icons.close, size: 20, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: AppInputDecoration.outlined(
                  label: 'Observação (Opcional)', 
                  prefixIcon: Icons.notes,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}