import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/notice_model.dart';
import '../../utils/hive_keys.dart';

// ─────────────────────────────────────────────────────────
// 1. PROVIDERS DE ESTADO DA INTERFACE (UI)
// ─────────────────────────────────────────────────────────

/// Controla a data selecionada no calendário.
/// Usado como initialSelectedDate / initialDisplayDate no SfCalendar.
/// A lista do mural exibe todos os avisos (comportamento de quadro de avisos),
/// portanto não filtra por esta data — isso é intencional.
final selectedNoticeDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// Controla se o painel de formulário está aberto.
///
/// autoDispose: quando nenhum widget da MuralPage mais assiste
/// este provider (ou seja, a página saiu da árvore), o Riverpod
/// descarta e reseta automaticamente para false. Elimina a
/// necessidade de resetar manualmente em dispose(), que causava
/// StateError ao acessar ref fora do ciclo de vida seguro.
final noticeFormExpandedProvider =
    StateProvider.autoDispose<bool>((ref) => false);

/// Controla qual aviso está sendo editado no momento.
/// null = modo de criação.
///
/// autoDispose pelo mesmo motivo que noticeFormExpandedProvider:
/// ao sair da página, o provider é descartado e reseta para null,
/// evitando que noticeEditingProvider aponte para um objeto
/// já deletado ao retornar à tela.
final noticeEditingProvider =
    StateProvider.autoDispose<NoticeModel?>((ref) => null);

// ─────────────────────────────────────────────────────────
// 2. PROVIDER DE DADOS (HIVE CRUD)
// ─────────────────────────────────────────────────────────

final noticeListProvider =
    NotifierProvider<NoticeListNotifier, List<NoticeModel>>(
  NoticeListNotifier.new,
);

// ─────────────────────────────────────────────────────────
// 3. PROVIDER DERIVADO — Agrupamento por mês/ano
//
// Calculado fora do build() dos widgets para evitar
// reprocessamento a cada rebuild. Atualiza automaticamente
// sempre que noticeListProvider mudar.
// A ordem dos grupos reflete a ordem da lista já ordenada
// pelo NoticeListNotifier (futuros no topo, passados no fim).
// ─────────────────────────────────────────────────────────

final groupedNoticesProvider =
    Provider<Map<String, List<NoticeModel>>>((ref) {
  final notices = ref.watch(noticeListProvider);

  const meses = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril',
    'Maio',    'Junho',     'Julho', 'Agosto',
    'Setembro','Outubro',   'Novembro','Dezembro',
  ];

  // LinkedHashMap implícito do Dart preserva ordem de inserção,
  // que aqui reflete a ordenação já aplicada pelo notifier.
  final Map<String, List<NoticeModel>> grouped = {};
  for (final notice in notices) {
    final key = '${meses[notice.date.month - 1]} ${notice.date.year}';
    grouped.putIfAbsent(key, () => []).add(notice);
  }
  return grouped;
});

// ─────────────────────────────────────────────────────────
// 4. NOTIFIER
// ─────────────────────────────────────────────────────────

class NoticeListNotifier extends Notifier<List<NoticeModel>> {
  // Getter protegido: lança AssertionError em debug se a box
  // não estiver aberta, evitando HiveError genérico em produção.
  Box<NoticeModel> get _box {
    assert(
      Hive.isBoxOpen(HiveKeys.noticeBox),
      'NoticeBox não está aberta. '
      'Verifique se Hive.openBox foi chamado em main.dart antes de runApp().',
    );
    return Hive.box<NoticeModel>(HiveKeys.noticeBox);
  }

  @override
  List<NoticeModel> build() => _getSortedNotices();

  // ── Ordenação ────────────────────────────────────────────
  // Futuros/hoje no topo (mais próximo primeiro).
  // Passados no fim (mais recente primeiro).
  List<NoticeModel> _getSortedNotices() {
    final notices = _box.values.toList();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    notices.sort((a, b) {
      final dateA = DateTime(a.date.year, a.date.month, a.date.day);
      final dateB = DateTime(b.date.year, b.date.month, b.date.day);

      final isPastA = dateA.isBefore(today);
      final isPastB = dateB.isBefore(today);

      if (!isPastA && isPastB) return -1;
      if (isPastA && !isPastB) return 1;

      if (!isPastA && !isPastB) {
        return a.date.compareTo(b.date);
      } else {
        return b.date.compareTo(a.date);
      }
    });

    return notices;
  }

  void refresh() => state = _getSortedNotices();

  // ── CRUD ─────────────────────────────────────────────────

  Future<void> addNotice(NoticeModel notice) async {
    try {
      await _box.put(notice.id, notice);
      refresh();
    } catch (e) {
      rethrow;
    }
  }

  /// Recebe um objeto criado via [NoticeModel.copyWith] e usa
  /// [Box.put] para substituir a referência no cache interno do Hive.
  ///
  /// Por que put e não save?
  /// O Hive mantém um cache de objetos por chave. Quando [save] é
  /// chamado após mutação direta, o cache continua apontando para
  /// o mesmo objeto (mesma identidade). O Riverpod compara por
  /// identidade de lista e pode não detectar mudança, causando UI
  /// desatualizada (bug silencioso). Com [put] de um objeto novo
  /// (via copyWith), a referência no cache é substituída,
  /// garantindo que [_box.values] retorne o objeto atualizado.
  Future<void> updateNotice(NoticeModel updatedNotice) async {
    try {
      await _box.put(updatedNotice.id, updatedNotice);
      refresh();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNotice(String id) async {
    try {
      await _box.delete(id);
      refresh();
    } catch (e) {
      rethrow;
    }
  }
}