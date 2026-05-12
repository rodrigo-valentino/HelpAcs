import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/base_dialog.dart';

import '../models/woman_model.dart';
import '../providers/woman_controller.dart';
import 'update_exam_dialog.dart';
import 'woman_form_dialog.dart'; // ✅ Import necessário para o botão de editar

// Imports do novo padrão de Badge e Status
import '../../enums/health_status.dart';
import '../../services/health_status_badge.dart';

class WomanDetailsDialog extends ConsumerWidget {
  final WomanModel woman;

  const WomanDetailsDialog({super.key, required this.woman});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuta o provider para garantir que a UI atualize após a edição
    final asyncWomen = ref.watch(womanListControllerProvider);
    final currentWoman = asyncWomen.value?.lookup(woman.id) ?? woman;

    return BaseDialog(
      title: currentWoman.name,
      icon: Icons.face_3,
      iconColor: Colors.purple,
      cancelButtonText: 'Fechar', 
      onCancel: () => Navigator.pop(context),
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ✅ Cabeçalho principal com botão de editar
          _buildMainHeader(context, currentWoman),
          
          const SizedBox(height: 24),

          _ExamCard(
            title: "Preventivo",
            subtitle: "Periodicidade: Anual (25-64 anos)",
            status: currentWoman.preventivoStatus,
            lastDate: currentWoman.lastPreventivoDate,
            nextDate: currentWoman.nextPreventivoDate,
            onUpdate: () => _showExamUpdateDialog(
              context, 
              ref,
              currentWoman, 
              isPreventivo: true
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          _ExamCard(
            title: "Mamografia",
            subtitle: "Periodicidade: Bienal (50-74 anos)",
            status: currentWoman.mammographyStatus,
            lastDate: currentWoman.lastMammographyDate,
            nextDate: currentWoman.nextMammographyDate,
            onUpdate: () => _showExamUpdateDialog(
              context,
              ref,
              currentWoman, 
              isPreventivo: false
            ),
          ),
        ],
      ),
    );
  }

  // --- 🛠️ CABEÇALHO PRINCIPAL ARRUMADO ---
  Widget _buildMainHeader(BuildContext context, WomanModel woman) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            // 1. Idade
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${woman.age} anos",
                style: const TextStyle(
                  fontSize: 14, 
                  color: Colors.purple, 
                  fontWeight: FontWeight.w700
                ),
              ),
            ),
            const SizedBox(width: 8),
            
            // 2. Tag SUS / Particular
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: woman.isSus ? AppColors.infoSurface : AppColors.successSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: woman.isSus ? AppColors.infoBorder : AppColors.successBorder,
                ),
              ),
              child: Text(
                woman.isSus ? "SUS" : "Particular",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: woman.isSus ? AppColors.info : AppColors.success,
                ),
              ),
            ),

            const Spacer(),

            // ✅ 3. BOTÃO DE EDITAR (Para Notas e isSus)
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => WomanFormDialog(woman: woman),
                );
              },
              icon: const Icon(Icons.edit_outlined, size: 22),
              color: Colors.purple,
              tooltip: "Editar dados da paciente",
              style: IconButton.styleFrom(
                backgroundColor: Colors.purple.withAlpha(15),
              ),
            ),
          ],
        ),

        // 4. Observações em baixo
        if (woman.notes != null && woman.notes!.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.notes, size: 16, color: Colors.grey.shade700),
                    const SizedBox(width: 6),
                    Text(
                      "Observações",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  woman.notes!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          )
        ],
      ],
    );
  }

  void _showExamUpdateDialog(
    BuildContext context,
    WidgetRef ref,
    WomanModel woman, {
    required bool isPreventivo,
  }) {
    showDialog(
      context: context,
      builder: (_) => WomanExamUpdateDialog(
        woman: woman,
        isPreventivo: isPreventivo,
      ),
    );
  }
}

// --- 📋 CARD DE EXAME ---
class _ExamCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final HealthStatus? status; 
  final DateTime? lastDate;
  final DateTime? nextDate;
  final VoidCallback onUpdate;

  const _ExamCard({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.lastDate,
    required this.nextDate,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = _getBackgroundColor();
    final Color borderColor = _getBorderColor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExamHeader(),
          const SizedBox(height: 16),
          _buildDates(),
        ],
      ),
    );
  }

  // ✅ Aqui está o widget que você enviou, integrado ao Card
  Widget _buildExamHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, 
                style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16, 
                  color: AppColors.textPrimary
                )
              ),
              const SizedBox(height: 2),
              Text(
                subtitle, 
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        status == null 
          ? _buildNotApplicableBadge()
          : HealthStatusBadge(status: status!, fontSize: 11),
      ],
    );
  }

  Widget _buildNotApplicableBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "N/A",
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDates() {
    return Row(
      children: [
        Expanded(
          child: _DateInfo(label: "Último:", date: lastDate),
        ),
        Container(
          width: 1, 
          height: 30, 
          color: Colors.grey.shade300,
          margin: const EdgeInsets.symmetric(horizontal: 12),
        ),
        Expanded(
          child: _DateInfo(label: "Próximo:", date: nextDate, isBold: true),
        ),
        IconButton(
          onPressed: onUpdate,
          icon: const Icon(Icons.edit_calendar),
          color: Colors.purple,
          tooltip: "Atualizar data",
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ],
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case HealthStatus.upToDate: return AppColors.successSurface;
      case HealthStatus.warning: return AppColors.warningSurface;
      case HealthStatus.overdue: return AppColors.errorSurface;
      case HealthStatus.pending: return AppColors.surface;
      case null: return Colors.grey.shade50;
    }
  }

  Color _getBorderColor() {
    switch (status) {
      case HealthStatus.upToDate: return AppColors.successBorder;
      case HealthStatus.warning: return AppColors.warningBorder;
      case HealthStatus.overdue: return AppColors.errorBorder;
      case HealthStatus.pending: return AppColors.border;
      case null: return Colors.grey.shade200;
    }
  }
}

// Widget reutilizável para exibição de data
class _DateInfo extends StatelessWidget {
  final String label;
  final DateTime? date;
  final bool isBold;

  const _DateInfo({required this.label, required this.date, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          date != null ? DateFormatter.format(date!) : "--/--/----", 
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: date != null ? AppColors.textPrimary : Colors.grey.shade400,
            fontSize: 14
          ),
        ),
      ],
    );
  }
}

extension ListLookup on List<WomanModel> {
  WomanModel? lookup(int id) {
    try {
      return firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}