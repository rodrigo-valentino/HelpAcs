import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_colors.dart';
import '../../../utils/date_formatter.dart';
import '../providers/pregnant_details_controller.dart';
import '../enums/pregnancy_enums.dart';
import '../models/prenatal_consultation_model.dart';
import '../widgets/pregnant_item_card.dart';
import '../widgets/manage_item_dialog.dart';

class ConsultationsTab extends ConsumerWidget {
  final int womanKey;

  const ConsultationsTab({super.key, required this.womanKey});

  String _getTitle(PrenatalConsultationModel item) {
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
        itemCount: woman.consultations.length,
        itemBuilder: (context, index) {
          final item = woman.consultations[index];
          final isCustom = item.customName != null;

          return PregnantItemCard(
            title: _getTitle(item),
            subtitle: item.date != null
                ? 'Agendado: ${item.date!.formatted}'
                : 'Sem data definida',
            isCompleted: item.completed,
            notes: item.notes,
            isCustom: isCustom,
            onToggle: () => controller.toggleConsultation(item.id),
            onDelete: () => controller.deleteConsultation(item.id),
            onEdit: () {
              showDialog(
                context: context,
                builder: (_) => ManageItemDialog(
                  title: 'Editar Consulta Extra',
                  itemLabel: 'Nome do Especialista / Consulta',
                  initialName: item.customName,
                  initialDate: item.date,
                  initialNotes: item.notes,
                  onSave: (name, date, notes) async {
                    controller.updateConsultation(
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
        heroTag: 'fab_consultation',
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
              title: 'Adicionar Consulta Extra',
              itemLabel: 'Nome do Especialista / Consulta',
              onSave: (name, date, notes) async {
                final newConsultation = PrenatalConsultationModel(
                  type: ConsultationType.values.last,
                  customName: name,
                  date: date,
                  notes: notes,
                );
                controller.addConsultation(newConsultation);
              },
            ),
          );
        },
      ),
    );
  }
}