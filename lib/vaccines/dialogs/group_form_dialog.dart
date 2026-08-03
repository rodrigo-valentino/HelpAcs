import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/calendar_models.dart';
import '../providers/calendar_controller.dart';
import '../../widgets/base_dialog.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_input_decoration.dart';

class GroupFormDialog extends ConsumerStatefulWidget {
  /// Se informado, o diálogo abre em modo de edição.
  final VaccineGroupModel? groupToEdit;

  const GroupFormDialog({super.key, this.groupToEdit});

  @override
  ConsumerState<GroupFormDialog> createState() => _GroupFormDialogState();
}

class _GroupFormDialogState extends ConsumerState<GroupFormDialog> {
  final _labelCtrl = TextEditingController();
  final _ageValueCtrl = TextEditingController();
  AgeUnit _ageUnit = AgeUnit.months;

  @override
  void initState() {
    super.initState();
    final g = widget.groupToEdit;
    if (g != null) {
      _labelCtrl.text = g.label;
      _ageValueCtrl.text = g.ageValue.toString();
      _ageUnit = g.ageUnit;
    } else {
      _ageValueCtrl.text = '0';
    }
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _ageValueCtrl.dispose();
    super.dispose();
  }

  String _unitLabel(AgeUnit unit) {
    switch (unit) {
      case AgeUnit.days:
        return 'Dias';
      case AgeUnit.months:
        return 'Meses';
      case AgeUnit.years:
        return 'Anos';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.groupToEdit != null;

    return BaseFormDialog(
      title: isEditing ? 'Editar Grupo' : 'Novo Grupo do Calendário',
      icon: Icons.folder_special_outlined,
      iconColor: AppColors.primary,
      saveButtonText: isEditing ? 'Atualizar' : 'Criar',
      saveButtonColor: AppColors.primary,
      onSubmit: () async {
        final label = _labelCtrl.text.trim();
        final ageValue = int.tryParse(_ageValueCtrl.text.trim()) ?? 0;

        if (label.isEmpty) {
          throw Exception('O nome do grupo é obrigatório');
        }

        final notifier = ref.read(calendarGroupsProvider.notifier);
        if (isEditing) {
          await notifier.updateGroup(
            groupKey: widget.groupToEdit!.key as int,
            label: label,
            ageValue: ageValue,
            ageUnit: _ageUnit,
          );
        } else {
          await notifier.addGroup(label: label, ageValue: ageValue, ageUnit: _ageUnit);
        }
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
                child: Text('Nome do grupo *', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              TextFormField(
                controller: _labelCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: AppInputDecoration.outlined(
                  hint: 'Ex: 2 meses, Ao nascer, Reforço Escolar',
                  prefixIcon: Icons.label_outline,
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.only(bottom: 6, left: 4),
                child: Text(
                  'Quando vence, a partir do nascimento *',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _ageValueCtrl,
                      keyboardType: TextInputType.number,
                      decoration: AppInputDecoration.outlined(hint: '0', prefixIcon: Icons.numbers),
                      validator: (v) {
                        final n = int.tryParse(v?.trim() ?? '');
                        if (n == null || n < 0) return 'Inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<AgeUnit>(
                      initialValue: _ageUnit,
                      decoration: AppInputDecoration.outlined(hint: ''),
                      items: AgeUnit.values
                          .map((u) => DropdownMenuItem(value: u, child: Text(_unitLabel(u))))
                          .toList(),
                      onChanged: (v) => setState(() => _ageUnit = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Ex.: valor 2 + "Meses" = vence aos 2 meses de vida.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}