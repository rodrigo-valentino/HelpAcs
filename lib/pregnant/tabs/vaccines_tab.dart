import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_colors.dart';
import '../../../utils/date_formatter.dart';
import '../providers/pregnant_details_controller.dart';
import '../enums/pregnancy_enums.dart';
import '../widgets/pregnant_item_card.dart';
import '../widgets/manage_item_dialog.dart';
import '../models/prenatal_vaccine_model.dart';

class VaccinesTab extends ConsumerWidget {
  final int womanKey;

  const VaccinesTab({super.key, required this.womanKey});

  String _getTitle(PrenatalVaccineModel item) {
    if (item.customName != null && item.customName!.isNotEmpty) {
      return item.customName!;
    }
    return item.type.label;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final woman = ref.watch(pregnantDetailsProvider(womanKey));
    final controller = ref.read(pregnantDetailsProvider(womanKey).notifier);

    if (woman == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: woman.vaccines.length,
        itemBuilder: (context, index) {
          final item = woman.vaccines[index];
          final isCustom = item.customName != null;

          return PregnantItemCard(
            title: _getTitle(item),
            subtitle: item.date != null
                ? 'Aplicação: ${item.date!.formatted}'
                : 'Não administrada',
            isCompleted: item.administered,
            notes: item.notes,
            isCustom: isCustom,
            onToggle: () => controller.toggleVaccine(item.id),
            onDelete: () => controller.deleteVaccine(item.id),
            onEdit: () {
              showDialog(
                context: context,
                builder: (_) => ManageItemDialog(
                  title: 'Editar Vacina Extra',
                  itemLabel: 'Nome da Vacina',
                  initialName: item.customName,
                  initialDate: item.date,
                  initialNotes: item.notes,
                  onSave: (name, date, notes) async {
                    controller.updateVaccine(
                      item.id,
                      customName: name.isEmpty ? null : name,
                      date: date,
                      notes: notes,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_vaccine',
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        // ✅ Passo 4: Extra -> Adicionar
        label: const Text('Adicionar',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => ManageItemDialog(
              title: 'Adicionar Vacina Extra',
              itemLabel: 'Nome da Vacina',
              onSave: (name, date, notes) async {
                final newVaccine = PrenatalVaccineModel(
                  type: PrenatalVaccineType.values.last,
                  customName: name,
                  date: date,
                  notes: notes,
                );
                controller.addVaccine(newVaccine);
              },
            ),
          );
        },
      ),
    );
  }
}