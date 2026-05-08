import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';
import '../utils/date_formatter.dart';
import '../imports/import_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ENUM: Tipo de paciente sendo importado
// ─────────────────────────────────────────────────────────────────────────────

enum ImportPatientType { woman, child }

// ─────────────────────────────────────────────────────────────────────────────
// PROVIDER DE ESTADO DO IMPORT (Isolado por instância do Dialog)
// ─────────────────────────────────────────────────────────────────────────────

/// Estado interno do processo de importação em lote
class _BulkImportState {
  final int total;
  final int done;
  final int errors;
  final bool isRunning;
  final bool isFinished;
  final String? currentName;

  const _BulkImportState({
    this.total = 0,
    this.done = 0,
    this.errors = 0,
    this.isRunning = false,
    this.isFinished = false,
    this.currentName,
  });

  double get progress => total == 0 ? 0 : done / total;

  _BulkImportState copyWith({
    int? total,
    int? done,
    int? errors,
    bool? isRunning,
    bool? isFinished,
    String? currentName,
  }) {
    return _BulkImportState(
      total: total ?? this.total,
      done: done ?? this.done,
      errors: errors ?? this.errors,
      isRunning: isRunning ?? this.isRunning,
      isFinished: isFinished ?? this.isFinished,
      currentName: currentName ?? this.currentName,
    );
  }
}

Future<void> showImportPreviewDialog({
  required BuildContext context,
  required WidgetRef ref,
  required ImportResult result,
  required ImportPatientType type,
  required Future<void> Function(ImportedPatientRow row) onImportRow,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ImportPreviewDialog(
      result: result,
      type: type,
      onImportRow: onImportRow,
    ),
  );
}

class _ImportPreviewDialog extends StatefulWidget {
  final ImportResult result;
  final ImportPatientType type;
  final Future<void> Function(ImportedPatientRow row) onImportRow;

  const _ImportPreviewDialog({
    required this.result,
    required this.type,
    required this.onImportRow,
  });

  @override
  State<_ImportPreviewDialog> createState() => _ImportPreviewDialogState();
}

class _ImportPreviewDialogState extends State<_ImportPreviewDialog> {
  _BulkImportState _importState = const _BulkImportState();
  final List<String> _importErrors = [];

  Color get _themeColor =>
      widget.type == ImportPatientType.woman ? Colors.purple : AppColors.primary;

  IconData get _themeIcon =>
      widget.type == ImportPatientType.woman ? Icons.face_3 : Icons.child_care;

  String get _patientLabel =>
      widget.type == ImportPatientType.woman ? 'pacientes' : 'crianças';

  // ── LÓGICA DE IMPORTAÇÃO ──────────────────────────────────────────────────

  Future<void> _startImport() async {
    final rows = widget.result.rows;

    setState(() {
      _importState = _BulkImportState(
        total: rows.length,
        isRunning: true,
      );
      _importErrors.clear();
    });

    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];

      setState(() {
        _importState = _importState.copyWith(currentName: row.name);
      });

      try {
        await widget.onImportRow(row);
        setState(() {
          _importState = _importState.copyWith(done: _importState.done + 1);
        });
      } catch (e) {
        final errorMsg = _parseError(e, row.name);
        setState(() {
          _importState = _importState.copyWith(
            done: _importState.done + 1,
            errors: _importState.errors + 1,
          );
        });
        _importErrors.add(errorMsg);
        debugPrint('⚠️ Erro ao importar ${row.name}: $e');
      }

      // Pequena pausa para não travar a UI
      await Future.delayed(const Duration(milliseconds: 30));
    }

    setState(() {
      _importState = _importState.copyWith(
        isRunning: false,
        isFinished: true,
        currentName: null,
      );
    });
  }

  String _parseError(Object e, String name) {
    final msg = e.toString();
    if (msg.contains('já existe') || msg.contains('nome')) {
      return '$name: já cadastrado(a).';
    }
    return '$name: erro inesperado.';
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: _importState.isRunning || _importState.isFinished
                  ? _buildProgressBody()
                  : _buildPreviewBody(),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ── CABEÇALHO ─────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: _themeColor.withAlpha(15),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          bottom: BorderSide(color: _themeColor.withAlpha(30)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _themeColor.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(_themeIcon, color: _themeColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _importState.isFinished ? 'Importação Concluída' : 'Pré-visualização',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _themeColor,
                  ),
                ),
                Text(
                  widget.result.fileName,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── CORPO: PRÉ-VISUALIZAÇÃO ───────────────────────────────────────────────

  Widget _buildPreviewBody() {
    final result = widget.result;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Resumo
          _buildSummaryCards(result),
          const SizedBox(height: 16),

          // Aviso de linhas ignoradas
          if (result.skippedCount > 0) ...[
            _buildSkippedWarning(result),
            const SizedBox(height: 16),
          ],

          // Tabela de prévia
          Text(
            'Dados que serão importados (${result.validCount} $_patientLabel):',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          _buildPreviewTable(result),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(ImportResult result) {
    return Row(
      children: [
        _SummaryCard(
          count: result.validCount,
          label: 'Prontas',
          color: AppColors.success,
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(width: 12),
        _SummaryCard(
          count: result.skippedCount,
          label: 'Ignoradas',
          color: result.skippedCount > 0 ? Colors.orange : Colors.grey,
          icon: Icons.warning_amber_outlined,
        ),
      ],
    );
  }

  Widget _buildSkippedWarning(ImportResult result) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 12),
      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      leading: const Icon(Icons.info_outline, color: Colors.orange, size: 20),
      title: Text(
        '${result.skippedCount} linha(s) serão ignoradas',
        style: const TextStyle(
          fontSize: 13,
          color: Colors.orange,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Colors.orange.shade50,
      collapsedBackgroundColor: Colors.orange.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.orange.shade200),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.orange.shade200),
      ),
      children: result.skippedReasons
          .map(
            (reason) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.remove, size: 14, color: Colors.orange),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(reason,
                        style: const TextStyle(fontSize: 12, color: Colors.orange)),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPreviewTable(ImportResult result) {
    final rows = result.rows;
    final previewRows = rows.take(50).toList(); // Mostra até 50 na prévia

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header da tabela
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _themeColor.withAlpha(20),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Nome',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: _themeColor)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Data de Nasc.',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: _themeColor)),
                ),
              ],
            ),
          ),
          // Linhas de dados
          ...previewRows.asMap().entries.map((entry) {
            final i = entry.key;
            final row = entry.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: i.isEven ? Colors.white : Colors.grey.shade50,
                border: Border(
                    top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      row.name,
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      DateFormatter.format(row.birthDate),
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            );
          }),
          // Aviso se mostrando parcial
          if (rows.length > 50)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(8)),
                border: Border(
                    top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Center(
                child: Text(
                  '... e mais ${rows.length - 50} registros',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── CORPO: PROGRESSO ──────────────────────────────────────────────────────

  Widget _buildProgressBody() {
    final state = _importState;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (state.isRunning) ...[
            // Animação de progresso
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: state.progress,
                    strokeWidth: 6,
                    color: _themeColor,
                    backgroundColor: _themeColor.withAlpha(20),
                  ),
                  Text(
                    '${(state.progress * 100).toInt()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _themeColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Importando ${state.done + 1} de ${state.total}...',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (state.currentName != null) ...[
              const SizedBox(height: 6),
              Text(
                state.currentName!,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ] else if (state.isFinished) ...[
            // Resultado final
            Icon(
              state.errors == 0 ? Icons.check_circle : Icons.check_circle_outline,
              color: state.errors == 0 ? AppColors.success : Colors.orange,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              '${state.total - state.errors} de ${state.total} importados!',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),

            if (state.errors > 0) ...[
              Text(
                '${state.errors} já existiam ou tiveram erro.',
                style: TextStyle(color: Colors.orange.shade700, fontSize: 13),
              ),
              const SizedBox(height: 12),
              // Erros detalhados
              Container(
                constraints: const BoxConstraints(maxHeight: 140),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _importErrors
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text('• $e',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.orange)),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ── RODAPÉ ────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    final state = _importState;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!state.isRunning && !state.isFinished) ...[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: widget.result.isEmpty ? null : _startImport,
              icon: const Icon(Icons.upload_rounded, size: 18),
              label: Text('Importar ${widget.result.validCount}'),
              style: FilledButton.styleFrom(backgroundColor: _themeColor),
            ),
          ] else if (state.isFinished) ...[
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(backgroundColor: _themeColor),
              child: const Text('Concluir'),
            ),
          ] else ...[
            // Rodapé durante o import (sem botões)
            Text(
              'Por favor, aguarde...',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET AUXILIAR: Card de resumo
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.count,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(label,
                    style: TextStyle(fontSize: 11, color: color)),
              ],
            )
          ],
        ),
      ),
    );
  }
}