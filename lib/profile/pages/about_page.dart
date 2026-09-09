import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const String _version = '1.0.0';

  static const List<String> _features = [
    'Cadastro e acompanhamento de usuários',
    'Registro e acompanhamento de vacinação',
    'Acompanhamento de crianças',
    'Acompanhamento de gestantes',
    'Registros relacionados à saúde da mulher',
    'Avaliação e acompanhamento nutricional',
    'Organização das informações dos pacientes',
    'Recursos de consulta e acompanhamento',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sobre'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.primary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Cabeçalho ────────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.health_and_safety_rounded,
                      color: AppColors.primary, size: 36),
                ),
                const SizedBox(height: 12),
                const Text(
                  'HelpACS',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Versão $_version',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Descrição ────────────────────────────────────
          Text(
            'O HelpACS é um aplicativo desenvolvido para auxiliar o trabalho dos '
            'Agentes Comunitários de Saúde (ACS), facilitando a organização, o '
            'registro e o acompanhamento das informações relacionadas às '
            'atividades realizadas no dia a dia.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.5),
          ),
          const SizedBox(height: 12),
          Text(
            'O aplicativo reúne recursos para tornar o trabalho mais organizado e '
            'prático, permitindo o gerenciamento de informações e o acompanhamento '
            'dos usuários de forma centralizada.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.5),
          ),

          const SizedBox(height: 24),

          // ── Principais recursos ──────────────────────────
          const Text(
            'Principais recursos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < _features.length; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: i == _features.length - 1 ? 0 : 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 18, color: AppColors.success),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _features[i],
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'O HelpACS foi pensado para facilitar a rotina do ACS, reduzir a '
            'necessidade de controles manuais e tornar o acesso às informações '
            'mais rápido e organizado.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.5),
          ),

          const SizedBox(height: 32),

          // ── Rodapé ───────────────────────────────────────
          Center(
            child: Column(
              children: [
                Text(
                  '© 2026 — HelpACS',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 4),
                Text(
                  'Desenvolvido para auxiliar profissionais da Atenção Primária à Saúde.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}