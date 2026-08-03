import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/calendar_models.dart';
import '../providers/calendar_controller.dart';
import '../../widgets/base_dialog.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_input_decoration.dart';

class VaccineFormDialog extends ConsumerStatefulWidget {
  /// Grupo sob o qual a vacina será criada (ignorado se estiver editando
  /// e o usuário trocar o grupo pelo dropdown).
  final int groupKey;

  /// Se informado, o diálogo abre em modo de edição.
  final VaccineDefinitionModel? vaccineToEdit;

  const VaccineFormDialog({
    super.key,
    required this.groupKey,
    this.vaccineToEdit,
  });

  @override
  ConsumerState<VaccineFormDialog> createState() => _VaccineFormDialogState();
}

class _VaccineFormDialogState extends ConsumerState<VaccineFormDialog> {
  final _nameCtrl = TextEditingController();
  final _totalDosesCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  late int _selectedGroupKey;

  @override
  void initState() {
    super.initState();
    final v = widget.vaccineToEdit;
    _selectedGroupKey = v?.groupKey ?? widget.groupKey;
    if (v != null) {
      _nameCtrl.text = v.name;
      _totalDosesCtrl.text = v.totalDoses.toString();
      _notesCtrl.text = v.notes ?? '';
    } else {
      _totalDosesCtrl.text = '1';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _totalDosesCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.vaccineToEdit != null;
    final groups = ref.watch(calendarGroupsProvider).valueOrNull ?? [];

    return BaseFormDialog(
      title: isEditing ? 'Editar Vacina' : 'Nova Vacina',
      icon: Icons.vaccines_outlined,
      iconColor: AppColors.primary,
      saveButtonText: isEditing ? 'Atualizar' : 'Criar',
      saveButtonColor: AppColors.primary,
      onSubmit: () async {
        final name = _nameCtrl.text.trim();
        final totalDoses = int.tryParse(_totalDosesCtrl.text.trim()) ?? 1;

        if (name.isEmpty) throw Exception('O nome da vacina é obrigatório');
        if (totalDoses < 1) throw Exception('A vacina precisa ter ao menos 1 dose');

        final notifier = ref.read(calendarVaccinesProvider.notifier);
        if (isEditing) {
          await notifier.updateVaccine(
            vaccineKey: widget.vaccineToEdit!.key as int,
            name: name,
            totalDoses: totalDoses,
            notes: _notesCtrl.text.trim(),
            groupKey: _selectedGroupKey,
          );
        } else {
          await notifier.addVaccine(
            groupKey: _selectedGroupKey,
            name: name,
            totalDoses: totalDoses,
            notes: _notesCtrl.text.trim(),
          );
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
                child: Text('Nome da vacina *', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: AppInputDecoration.outlined(
                  hint: 'Ex: Penta, VIP, Pneumocócica 10v',
                  prefixIcon: Icons.vaccines,
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),

              if (isEditing) ...[
                const Padding(
                  padding: EdgeInsets.only(bottom: 6, left: 4),
                  child: Text('Grupo', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                DropdownButtonFormField<int>(
                  initialValue: _selectedGroupKey,
                  decoration: AppInputDecoration.outlined(prefixIcon: Icons.folder_special_outlined),
                  items: groups
                      .map((g) => DropdownMenuItem(value: g.key as int, child: Text(g.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedGroupKey = v!),
                ),
                const SizedBox(height: 16),
              ],

              const Padding(
                padding: EdgeInsets.only(bottom: 6, left: 4),
                child: Text('Número de doses *', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              TextFormField(
                controller: _totalDosesCtrl,
                keyboardType: TextInputType.number,
                decoration: AppInputDecoration.outlined(hint: '1', prefixIcon: Icons.filter_9_plus),
                validator: (v) {
                  final n = int.tryParse(v?.trim() ?? '');
                  if (n == null || n < 1) return 'Mínimo 1 dose';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              const Padding(
                padding: EdgeInsets.only(bottom: 6, left: 4),
                child: Text('Observações (opcional)', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: AppInputDecoration.outlined(
                  hint: 'Ex: orientação sobre reforços, bula, etc.',
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