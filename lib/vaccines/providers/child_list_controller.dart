import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/child_model.dart';
import '../../services/health_status_service.dart';

final childListControllerProvider = AsyncNotifierProvider<ChildListController, List<ChildModel>>(() {
  return ChildListController();
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

  // Método para deletar pacientes selecionados
  Future<void> deleteChildren(List<dynamic> keys) async {
    final box = Hive.box<ChildModel>(HiveKeys.childrenBox);
    await box.deleteAll(keys); 
    
    // Atualiza a tela após a exclusão
    state = AsyncValue.data(box.values.toList());
  }
  
  Future<void> updateChild({
    required dynamic key, // O Hive usa 'key' em vez de 'id'
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