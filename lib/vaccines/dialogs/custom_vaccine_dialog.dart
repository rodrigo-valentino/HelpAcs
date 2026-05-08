import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vaccination_controller.dart';
import '../../widgets/base_dialog.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_input_decoration.dart';

class CustomVaccineDialog extends ConsumerStatefulWidget {
  final int childKey; 
  final String groupName;

  const CustomVaccineDialog({
    super.key,
    required this.childKey,
    required this.groupName,
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

      // O BaseFormDialog gerencia a submissão
      onSubmit: () async {
        if (_nameCtrl.text.trim().isEmpty) {
          throw Exception('O nome da vacina é obrigatório');
        }

        await ref
            .read(
              vaccinationControllerProvider(widget.childKey).notifier,
            )
            .addCustomVaccine(
              groupName: widget.groupName,
              vaccineName: _nameCtrl.text.trim(),
              observation: _obsCtrl.text.trim().isEmpty
                  ? null
                  : _obsCtrl.text.trim(),
            );
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
                child: Text(
                  'Nome da Vacina *',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: AppInputDecoration.outlined(
                  hint: 'Ex: Influenza, COVID-19',
                  prefixIcon: Icons.vaccines,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Obrigatório';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              const Padding(
                padding: EdgeInsets.only(bottom: 6, left: 4),
                child: Text(
                  'Observação (opcional)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
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