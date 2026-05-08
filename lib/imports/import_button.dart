import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpacs/imports/import_service.dart';

import 'import_preview_dialog.dart';
import '../utils/feedback_helper.dart';

class ImportButton extends ConsumerWidget {
  final ImportPatientType type;
  final Future<void> Function(ImportedPatientRow row) onImportRow;
  final Color? color;

  const ImportButton({
    super.key,
    required this.type,
    required this.onImportRow,
    this.color,
  });

  Color get _defaultColor =>
      type == ImportPatientType.woman ? Colors.purple : Colors.teal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: 'Importar planilha',
      icon: const Icon(Icons.upload_file_rounded),
      color: color ?? _defaultColor,
      onPressed: () => _handleImport(context, ref),
    );
  }

  Future<void> _handleImport(BuildContext context, WidgetRef ref) async {
    try {
      // 1. Abre o picker e faz o parsing
      final result = await ImportService.pickAndParse();
      if (result == null) return; // Usuário cancelou

      if (result.isEmpty && result.skippedCount == 0) {
        if (context.mounted) {
          FeedbackHelper.showError(context, 'O arquivo está vazio.');
        }
        return;
      }

      if (result.isEmpty) {
        if (context.mounted) {
          FeedbackHelper.showError(
            context,
            'Nenhuma linha válida encontrada. '
            'Verifique se a planilha tem colunas de nome e data de nascimento.',
          );
        }
        return;
      }

      // 2. Exibe o dialog de prévia
      if (context.mounted) {
        await showImportPreviewDialog(
          context: context,
          ref: ref,
          result: result,
          type: type,
          onImportRow: onImportRow,
        );
      }
    } on Exception catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      if (context.mounted) {
        FeedbackHelper.showError(context, 'Erro ao ler arquivo: $msg');
      }
    }
  }
}