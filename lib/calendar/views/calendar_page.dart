import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/feedback_helper.dart';
import '../models/notice_model.dart';
import '../providers/notice_controller.dart';
import '../widgets/notice_card.dart';
import '../widgets/notice_calendar_widget.dart';
import '../widgets/notice_form_widget.dart';

class MuralPage extends ConsumerWidget {
  const MuralPage({super.key});

  // ── Handlers ─────────────────────────────────────────────

  /// Exibe confirmação antes de excluir.
  ///
  /// Recebe context e ref como parâmetros porque este é um
  /// ConsumerWidget (sem estado): não há this.context nem this.ref
  /// fora do build(). O context capturado aqui é o do build(),
  /// válido durante toda a exibição do diálogo.
  ///
  /// Não precisamos de mounted check: após o await, usamos apenas
  /// ref.read (sem setState nem context) — operação segura mesmo
  /// que o widget tenha sido removido da árvore entre a abertura
  /// e o fechamento do diálogo.
  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    NoticeModel notice,
  ) async {
    final confirmed = await FeedbackHelper.showDeleteConfirmation(
      context,
      title: 'Excluir Aviso',
      itemName: notice.title,
    );
    if (confirmed) {
      ref.read(noticeListProvider.notifier).deleteNotice(notice.id);
    }
  }

  // ── Build ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFormOpen    = ref.watch(noticeFormExpandedProvider);
    final editingNotice = ref.watch(noticeEditingProvider);

    // groupedNoticesProvider é derivado de noticeListProvider:
    // recomputa automaticamente ao mudar a lista, sem custo
    // extra no build() desta página.
    final groupedNotices = ref.watch(groupedNoticesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Calendário de Avisos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cabeçalho ─────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mural de Avisos',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Eventos e avisos sincronizados com calendário',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    if (isFormOpen) {
                      ref.read(noticeEditingProvider.notifier).state = null;
                    }
                    ref.read(noticeFormExpandedProvider.notifier).state =
                        !isFormOpen;
                  },
                  icon: Icon(
                    isFormOpen ? Icons.close : Icons.add,
                    color: Colors.white,
                    size: 16,
                  ),
                  label: Text(
                    isFormOpen ? 'Cancelar' : 'Novo Aviso',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Formulário retrátil (Criação / Edição) ────
            if (isFormOpen) NoticeFormWidget(noticeToEdit: editingNotice),

            // ── Calendário ────────────────────────────────
            const NoticeCalendarWidget(),
            const SizedBox(height: 24),

            // ── Lista agrupada por mês ────────────────────
            _buildNoticesList(context, ref, groupedNotices),
          ],
        ),
      ),
    );
  }

  // ── Lista agrupada ───────────────────────────────────────

  Widget _buildNoticesList(
    BuildContext context,
    WidgetRef ref,
    Map<String, List<NoticeModel>> groupedNotices,
  ) {
    if (groupedNotices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'Nenhum evento cadastrado.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedNotices.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho do grupo (ex: "Maio 2026")
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 4),
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            // Cards do grupo
            ...entry.value.map((notice) {
              return NoticeCard(
                notice: notice,
                onEdit: () {
                  ref.read(noticeEditingProvider.notifier).state = notice;
                  ref.read(noticeFormExpandedProvider.notifier).state = true;
                },
                onDelete: () => _handleDelete(context, ref, notice),
              );
            }),

            const SizedBox(height: 12),
          ],
        );
      }).toList(),
    );
  }
}