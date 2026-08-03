import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vaccination_controller.dart';
import '../../widgets/base_dialog.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_input_decoration.dart';

class CustomVaccineDialog extends ConsumerStatefulWidget {
  final int childKey;

  /// Key do VaccineGroupModel (catálogo) sob o qual esta vacina
  /// personalizada será exibida agrupada. Antes era `groupName` (String);
  /// passou a ser o ID para não depender de comparação por texto.
  final int groupKey;

  /// Label atual do grupo, só para exibição/snapshot no registro.
  final String groupLabel;

  const CustomVaccineDialog({
    super.key,
    required this.childKey,
    required this.groupKey,
    required this.groupLabel,
  });

  @override
  ConsumerState<CustomVaccineDialog> createState() => _CustomVaccineDialogState();
}

class _CustomVaccineDialogState extends ConsumerState<CustomVaccineDialog> {
  final _nameCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseFormDialog(
      title: 'Adicionar Vacina Personalizada',
      icon: Icons.vaccines,
      iconColor: AppColors.primary,
      saveButtonText: 'Adicionar',
      saveButtonColor: AppColors.primary,
      onSubmit: () async {
        if (_nameCtrl.text.trim().isEmpty) {
          throw Exception('O nome da vacina é obrigatório');
        }

        await ref
            .read(vaccinationControllerProvider(widget.childKey).notifier)
            .addCustomVaccine(
              groupKey: widget.groupKey,
              groupLabel: widget.groupLabel,
              vaccineName: _nameCtrl.text.trim(),
              observation: _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),
            );
        return true;
      },
      builder: (formKey) {
        return Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 6, left: 4),
                child: Text('Nome da Vacina *', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: AppInputDecoration.outlined(
                  hint: 'Ex: Influenza, COVID-19',
                  prefixIcon: Icons.vaccines,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Obrigatório';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.only(bottom: 6, left: 4),
                child: Text('Observação (opcional)', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              TextFormField(
                controller: _obsCtrl,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: AppInputDecoration.outlined(
                  hint: 'Informações adicionais sobre a vacina',
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