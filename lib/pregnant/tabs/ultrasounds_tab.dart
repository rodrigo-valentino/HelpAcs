import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpacs/pregnant/models/ultrasound_exam_model.dart';

import '../../../theme/app_colors.dart';
import '../../../utils/date_formatter.dart';
import '../providers/pregnant_details_controller.dart';
import '../enums/pregnancy_enums.dart';
import '../widgets/pregnant_item_card.dart';
import '../widgets/manage_item_dialog.dart';

class UltrasoundsTab extends ConsumerWidget {
  final int womanKey;

  const UltrasoundsTab({super.key, required this.womanKey});

  String _getTitle(UltrasoundExamModel item) {
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
        itemCount: woman.ultrasounds.length,
        itemBuilder: (context, index) {
          final item = woman.ultrasounds[index];
          final isCustom = item.customName != null;

          return PregnantItemCard(
            title: _getTitle(item),
            subtitle:
                item.date != null ? 'Data: ${item.date!.formatted}' : 'Pendente',
            isCompleted: item.completed,
            notes: item.result,
            isCustom: isCustom,
            onToggle: () => controller.toggleUltrasound(item.id),
            onDelete: () => controller.deleteUltrasound(item.id),
            onEdit: () {
              showDialog(
                context: context,
                builder: (_) => ManageItemDialog(
                  title: 'Editar Ultrassom Extra',
                  itemLabel: 'Tipo de Ultrassom',
                  initialName: item.customName,
                  initialDate: item.date,
                  initialNotes: item.result,
                  onSave: (name, date, notes) async {
                    controller.updateUltrasound(
                      item.id,
                      customName: name.isEmpty ? null : name,
                      date: date,
                      result: notes,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_ultrasound',
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Adicionar',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => ManageItemDialog(
              title: 'Adicionar Ultrassom Extra',
              itemLabel: 'Tipo de Ultrassom',
              onSave: (name, date, notes) async {
                final newUltrasound = UltrasoundExamModel(
                  type: UltrasoundType.values.last,
                  customName: name,
                  date: date,
                  result: notes,
                );
                controller.addUltrasound(newUltrasound);
              },
            ),
          );
        },
      ),
    );
  }
}