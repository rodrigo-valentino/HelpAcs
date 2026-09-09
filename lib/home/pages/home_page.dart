import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../profile/pages/profile_page.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../woman/providers/woman_controller.dart';
import '../../pregnant/providers/pregnant_list_controller.dart';
import '../../vaccines/providers/child_list_controller.dart';
import '../../vaccines/views/child_list_page.dart';
import '../../nutrition/views/nutrition_children_list_page.dart';
import '../../woman/views/woman_list_page.dart';
import '../../pregnant/views/pregnant_list_page.dart';
import '../../calendar/views/calendar_page.dart'; 
import '../../notes/views/task_page.dart';

import 'package:flutter/foundation.dart'; //para kDebugMode
import '../../debug/seed_test_data.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProfile = ref.watch(profileControllerProvider);

    final hour = DateTime.now().hour;
    String greeting = 'Bom dia';
    if (hour >= 12) greeting = 'Boa tarde';
    if (hour >= 18) greeting = 'Boa noite';

    return Scaffold(
      floatingActionButton: kDebugMode
      ? FloatingActionButton.extended(
          heroTag: 'seed_debug_fab',
          backgroundColor: Colors.black87,
          icon: const Icon(Icons.bug_report, color: Colors.white),
          label: const Text(
            'Seed Teste',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () async {
            await SeedTestData.run();

            // Força os providers a relerem as boxes do zero
            ref.invalidate(childListControllerProvider);
            ref.invalidate(womanListControllerProvider);
            ref.invalidate(pregnantListProvider);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dados de teste criados com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        )
      : null,
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. CABEÇALHO (Header)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      asyncProfile.when(
                        data: (profile) => Text(
                          profile.name, 
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        loading: () => const SizedBox(
                          width: 100, 
                          height: 20, 
                          child: LinearProgressIndicator()
                        ),
                        error: (_, __) => const Text(
                          "Olá", 
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 2. MÓDULOS PRINCIPAIS
              const Text(
                "Acessar Módulo",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1, 
                children: [
                  _HomeModuleCard(
                    title: "Acompanhamento Vacinal",
                    subtitle: "Crianças e adultos",
                    icon: Icons.child_care_rounded,
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChildListPage()),
                      );
                    },
                  ),
                  _HomeModuleCard(
                    title: "Gestantes",
                    subtitle: "Pré-natal",
                    icon: Icons.pregnant_woman_rounded,
                    color: Colors.pink,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PregnantListPage()),
                      );
                    },
                  ),
                  _HomeModuleCard(
                    title: "Saúde da Mulher",
                    subtitle: "Preventivo e Mamografia",
                    icon: Icons.face_3_rounded,
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WomanListPage()),
                      );
                    },
                  ),
                  _HomeModuleCard(
                    title: "Acompanhamento Nutricional",
                    subtitle: "Consumo Alimentar",
                    icon: Icons.restaurant_menu_rounded,
                    color: Colors.orange,
                    onTap: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NutritionChildrenListPage()),
                      );
                    },
                  ),
                  _HomeModuleCard(
                    title: "Anotações",
                    subtitle: "Notas e Avisos",
                    icon: Icons.edit_note_rounded,
                    color: Colors.teal,
                    onTap: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TasksPage()),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 3. ATALHO RÁPIDO / CARD DE DESTAQUE
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MuralPage()),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withAlpha(200),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(50),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(50),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Calendário Nacional",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Acessar visualização mensal",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HomeModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2, 
      shadowColor: Colors.black.withAlpha(25),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}