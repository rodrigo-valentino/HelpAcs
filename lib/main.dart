import 'package:helpacs/home/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Importação dos seus modelos e dos ficheiros gerados pelo build_runner
import './vaccines/models/child_model.dart';
import './vaccines/models/vaccine_record_model.dart'; // 🆕 Importação da Vacina
import './profile/models/profile_model.dart';

void main() async {
  // 1. Garante que a ponte entre o Flutter e o código nativo está inicializada
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa o Hive especificamente para o Flutter (prepara o diretório local)
  await Hive.initFlutter();

  // 3. Regista os Adapters (Gerados pelo build_runner)
  Hive.registerAdapter(ChildHealthStatusAdapter()); // TypeId: 0
  Hive.registerAdapter(ChildModelAdapter());        // TypeId: 1
  Hive.registerAdapter(ProfileModelAdapter());      // TypeId: 2
  Hive.registerAdapter(VaccineRecordAdapter());     // 🆕 TypeId: 3 (Faltava este!)

  // 4. Inicia a aplicação. 
  // O ProviderScope é obrigatório para que os Providers do Riverpod funcionem.
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Serviço e Acompanhamento',
      debugShowCheckedModeBanner: false, 
      
      // Definição do Tema Global (Material Design 3)
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          surface: const Color(0xFFF5F7FA), // O fundo cinza claro
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      home: const HomePage(),
    );
  }
}