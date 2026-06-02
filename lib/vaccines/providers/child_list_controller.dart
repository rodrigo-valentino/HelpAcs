import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/child_model.dart';
import '../../services/health_status_service.dart';
import '../../utils/hive_keys.dart';

final childListControllerProvider = AsyncNotifierProvider<ChildListController, List<ChildModel>>(() {
  return ChildListController();
});

// 1. Provider para guardar o texto da busca
final childSearchQueryProvider = StateProvider<String>((ref) => '');

// 2. O FILTRO INTELIGENTE (PERF 1)
final filteredChildrenProvider = Provider<List<ChildModel>>((ref) {
  // Escuta a lista vinda do banco
  final allChildren = ref.watch(childListControllerProvider).valueOrNull ?? [];
  // Escuta o texto da busca
  final query = ref.watch(childSearchQueryProvider).toLowerCase();

  if (query.isEmpty) return allChildren;

  // Realiza o filtro apenas quando necessário
  return allChildren.where((child) {
    return child.name.toLowerCase().contains(query) || 
           (child.guardianName?.toLowerCase().contains(query) ?? false);
  }).toList();
});

class ChildListController extends AsyncNotifier<List<ChildModel>> {
  @override
  Future<List<ChildModel>> build() async {
    final box = await Hive.openBox<ChildModel>(HiveKeys.childrenBox);
    final children = box.values.toList();

    bool needsSave = false;

    // Recálculo Automático ao abrir (RN04)
    for (final child in children) {
      final calculatedStatus = HealthStatusService.calculateOverallStatus(
        child: child,
        patientRecords: child.vaccines, // Supondo que você adicionou a lista no ChildModel
      );

      // Atualiza o banco só se o status mudou (ex: virou meia-noite e uma vacina atrasou)
      if (child.status != calculatedStatus) {
        child.status = calculatedStatus;
        await child.save();
        needsSave = true;
      }
    }

    return needsSave ? box.values.toList() : children;
  }

  // Método para adicionar um paciente
  Future<void> addChild(ChildModel child) async {
    final box = Hive.box<ChildModel>(HiveKeys.childrenBox);
    await box.add(child); // O Hive gera o ID (key) automaticamente
    
    // Atualiza a tela instantaneamente com a nova lista
    state = AsyncValue.data(box.values.toList());
  }

  Future<void> importChild(ChildModel child) async {
    final box = Hive.box<ChildModel>(HiveKeys.childrenBox);
    final existing = box.values.toList();

    // Normaliza o CPF: remove pontos, traços e espaços para comparação robusta
    final String? incomingCpf = _normalizeCpf(child.cpf);

    for (final record in existing) {
      final String? recordCpf = _normalizeCpf(record.cpf);

      // Regra 1 — CPF único: se ambos têm CPF e são iguais → duplicata certa
      if (incomingCpf != null && incomingCpf.isNotEmpty &&
          recordCpf != null && recordCpf.isNotEmpty &&
          incomingCpf == recordCpf) {
        throw Exception(
          'já existe um paciente com o CPF ${child.cpf} cadastrado.',
        );
      }

      if ((incomingCpf == null || incomingCpf.isEmpty) &&
          (recordCpf == null || recordCpf.isEmpty)) {
        final sameDate = _sameDate(child.birthDate, record.birthDate);
        final sameName = child.name.trim().toLowerCase() ==
            record.name.trim().toLowerCase();

        if (sameName && sameDate) {
          throw Exception(
            'já existe um paciente com o nome "${record.name}" '
            'e a mesma data de nascimento.',
          );
        }
      }
    }

    // Nenhuma duplicata encontrada — insere normalmente
    await box.add(child);
    state = AsyncValue.data(box.values.toList());
  }

  /// Remove formatação do CPF para comparação normalizada.
  static String? _normalizeCpf(String? cpf) {
    if (cpf == null) return null;
    return cpf.replaceAll(RegExp(r'[\s.\-/]'), '').trim();
  }

  /// Compara apenas a parte da data (dia/mês/ano), ignorando horário.
  static bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Método para deletar pacientes selecionados
  Future<void> deleteChildren(List<dynamic> keys) async {
    final box = Hive.box<ChildModel>(HiveKeys.childrenBox);
    await box.deleteAll(keys); 
    
    // Atualiza a tela após a exclusão
    state = AsyncValue.data(box.values.toList());
  }
  
  Future<void> updateChild({
    required dynamic key,
    required String name,
    required DateTime birthDate,
    String? guardian,
    String? notes,
    String? cpf,
  }) async {
    final box = Hive.box<ChildModel>(HiveKeys.childrenBox);
    
    // Busca o paciente pela chave única do Hive
    final child = box.get(key); 
    
    if (child != null) {
      child.name = name;
      child.birthDate = birthDate;
      child.guardianName = guardian;
      child.notes = notes;
      child.cpf = cpf;
      
      // O HiveObject tem esse método mágico que salva a si mesmo no banco
      await child.save(); 
      
      // Atualiza a tela
      state = AsyncValue.data(box.values.toList());
    }
  }
}