import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/profile_model.dart';

final profileControllerProvider = AsyncNotifierProvider<ProfileController, ProfileModel>(() {
  return ProfileController();
});

class ProfileController extends AsyncNotifier<ProfileModel> {
  @override
  Future<ProfileModel> build() async {
    final box = await Hive.openBox<ProfileModel>('profileBox');
    // Retorna o perfil existente ou cria um padrão se for o primeiro acesso
    return box.get('adminProfile') ?? ProfileModel();
  }

  // Atualiza Nome e Email (Chamado no Dialog)
  Future<void> updateUserInfo(String name, String email) async {
    final box = Hive.box<ProfileModel>('profileBox');
    final profile = box.get('adminProfile') ?? ProfileModel();
    
    profile.name = name;
    profile.email = email;
    
    await box.put('adminProfile', profile);
    state = AsyncValue.data(profile); // Atualiza a tela
  }

  // Liga/Desliga Notificações (Chamado no Switch)
  Future<void> toggleNotifications(bool value) async {
    final box = Hive.box<ProfileModel>('profileBox');
    final profile = box.get('adminProfile') ?? ProfileModel();
    
    profile.notificationsEnabled = value;
    
    await box.put('adminProfile', profile);
    state = AsyncValue.data(profile);
  }

  // Altera os dias de lembrete (Chamado nas bolinhas 3, 7, 14)
  Future<void> setReminderDays(int days) async {
    final box = Hive.box<ProfileModel>('profileBox');
    final profile = box.get('adminProfile') ?? ProfileModel();
    
    profile.reminderDaysBefore = days;
    
    await box.put('adminProfile', profile);
    state = AsyncValue.data(profile);
  }
}