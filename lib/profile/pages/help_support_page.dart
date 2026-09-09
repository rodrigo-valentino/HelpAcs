import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../utils/feedback_helper.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  static const String _supportEmail = 'rodrigovalentino.rv@gmail.com';

  void _copyEmail(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: _supportEmail));
    FeedbackHelper.showSuccess(context, 'E-mail copiado para a área de transferência');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ajuda e Suporte'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.primary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Está com alguma dúvida ou encontrou algum problema no HelpACS?',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade800, height: 1.4),
          ),
          const SizedBox(height: 8),
          Text(
            'Envie um e-mail para o endereço abaixo que retornaremos assim que possível.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
          ),
          const SizedBox(height: 20),

          // ── Card de contato ─────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.email_outlined, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _supportEmail,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
                IconButton(
                  onPressed: () => _copyEmail(context),
                  icon: const Icon(Icons.copy_rounded, size: 20),
                  color: AppColors.primary,
                  tooltip: 'Copiar e-mail',
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Como solicitar suporte ──────────────────────
          const Text(
            'Como solicitar suporte',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Ao entrar em contato, informe, sempre que possível:',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
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
              children: const [
                _BulletItem('Qual funcionalidade você estava utilizando'),
                _BulletItem('O que aconteceu ou qual erro foi apresentado'),
                _BulletItem('Os passos realizados antes do problema'),
                _BulletItem('Uma captura de tela, caso seja necessário', isLast: true),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Aviso importante ─────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warningSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warningBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 18, color: AppColors.warning),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.4),
                      children: const [
                        TextSpan(text: 'Importante: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(
                          text: 'não envie informações desnecessárias ou dados pessoais de pacientes ao solicitar suporte.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  final bool isLast;

  const _BulletItem(this.text, {this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Icon(Icons.circle, size: 6, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}