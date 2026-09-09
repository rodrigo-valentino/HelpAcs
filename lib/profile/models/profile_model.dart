import 'package:hive/hive.dart';

part 'profile_model.g.dart'; // Lembre-se de rodar o build_runner!

@HiveType(typeId: 2) 
class ProfileModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String email;

  @HiveField(2)
  bool notificationsEnabled;

  @HiveField(3)
  int reminderDaysBefore;

  ProfileModel({
    this.name = 'Usuário',
    this.email = '',
    this.notificationsEnabled = false,
    this.reminderDaysBefore = 3,
  });
}