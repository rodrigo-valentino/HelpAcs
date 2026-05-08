import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/feedback_helper.dart';
import '../controllers/profile_controller.dart';
import '../../theme/app_colors.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProfile = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);

    // Cores fiéis ao design (Verde e Cinza)
    const activeColor = AppColors.primary;
    const backgroundColor = AppColors.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Perfil")),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.primary),
      ),
      body: asyncProfile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erro: $e')),
        data: (profile) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // 1. CABEÇALHO (Dados Reais do Controller)
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: activeColor,
                      child: Text(
                        profile.name.isNotEmpty ? profile.name[0].toUpperCase() : "U",
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profile.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 2. CARD DE NOTIFICAÇÕES (Funcional)
              _buildCard(
                title: "Configurações de Notificação",
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Ativar Notificações", style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text(
                      "Receba alertas sobre vacinas próximas",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    value: profile.notificationsEnabled,
                    activeThumbColor: activeColor,
                    onChanged: (val) => controller.toggleNotifications(val),
                  ),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Dias de Lembrete", style: TextStyle(fontWeight: FontWeight.w600)),
                            SizedBox(height: 4),
                            Text(
                              "Receba lembretes antes das vacinas",
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      // Seletores Circulares (3, 7, 14)
                      Row(
                        children: [3, 7, 14].map((day) {
                          final isSelected = profile.reminderDaysBefore == day;
                          return GestureDetector(
                            onTap: () => controller.setReminderDays(day),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 36,
                              height: 36,
                              margin: const EdgeInsets.only(left: 8),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? activeColor : Colors.white,
                                border: Border.all(
                                  color: isSelected ? activeColor : Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                "$day",
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey.shade700,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),

              const SizedBox(height: 20),

              // 3. CARD DE CONTA
              _buildCard(
                title: "Conta",
                children: [
                  _buildListTile(
                    icon: Icons.person_outline, 
                    title: "Editar Perfil", 
                    onTap: () => _showEditProfileDialog(context, controller, profile.name, profile.email)
                  ),
                  _buildListTile(icon: Icons.lock_outline, title: "Alterar Senha", onTap: () => FeedbackHelper.showInfo(context, "Funcionalidade futura")),
                  _buildListTile(icon: Icons.help_outline, title: "Ajuda e Suporte", onTap: () {}),
                  _buildListTile(icon: Icons.info_outline, title: "Sobre", onTap: () {}),
                  const Divider(),
                  _buildListTile(
                    icon: Icons.delete_outline,
                    title: "Excluir Conta",
                    color: Colors.red,
                    onTap: () async {
                       final confirm = await FeedbackHelper.showDeleteConfirmation(context, title: "Excluir Conta", itemName: "seus dados");
                       if(confirm) {
                         // Lógica de wipe data aqui
                       }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 4. BOTÃO SAIR
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    // Lógica de logout
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: BorderSide(color: Colors.red.withAlpha(50)),
                  ),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    "Sair",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  // --- Widgets Auxiliares ---

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    Color color = Colors.black87,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color == Colors.red ? Colors.red : const Color(0xFF4CAF50)),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      dense: true,
    );
  }

  // --- Lógica de Edição ---

  void _showEditProfileDialog(BuildContext context, ProfileController controller, String currentName, String currentEmail) {
    showDialog(
      context: context,
      builder: (ctx) => _EditProfileDialog(
        controller: controller,
        currentName: currentName,
        currentEmail: currentEmail,
      ),
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  final ProfileController controller;
  final String currentName;
  final String currentEmail;

  const _EditProfileDialog({
    required this.controller,
    required this.currentName,
    required this.currentEmail,
  });

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.currentName);
    _emailCtrl = TextEditingController(text: widget.currentEmail);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Editar Perfil"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const AppInputDecoration.outlined(labelText: "Nome", prefixIcon: Icons.person),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailCtrl,
              decoration: const AppInputDecoration.outlined(labelText: "E-mail", prefixIcon: Icons.email),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
        FilledButton(
          onPressed: () {
            widget.controller.updateUserInfo(_nameCtrl.text, _emailCtrl.text);
            Navigator.pop(context);
            FeedbackHelper.showSuccess(context, "Perfil atualizado!");
          },
          child: const Text("Salvar"),
        ),
      ],
    );
  }
}