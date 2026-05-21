import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../utils/date_formatter.dart';
import '../models/pregnant_woman_model.dart';
import '../providers/pregnant_details_controller.dart';
import '../enums/pregnancy_enums.dart';
import '../../widgets/document_gallery_widget.dart';
import '../dialogs/pregnant_form_dialog.dart';

import '../tabs/consultations_tab.dart';
import '../tabs/ultrasounds_tab.dart';
import '../tabs/exams_tab.dart';
import '../tabs/vaccines_tab.dart';

class PregnantDetailsPage extends ConsumerWidget {
  final int womanKey;

  const PregnantDetailsPage({
    super.key,
    required this.womanKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final woman = ref.watch(pregnantDetailsProvider(womanKey));

    if (woman == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes da Gestante')),
        body: const Center(child: Text('Gestante não encontrada.')),
      );
    }

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Acompanhamento', style: TextStyle(fontSize: 18)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
          actions: [
            // ✅ Passo 7: Editar gestante
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => PregnantFormDialog(woman: woman),
                );
                // Invalida o provider ao fechar
                ref.invalidate(pregnantDetailsProvider(womanKey));
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            _buildHeader(woman),
            _buildDashboard(woman),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                children: [
                  ConsultationsTab(womanKey: womanKey),
                  UltrasoundsTab(womanKey: womanKey),
                  ExamsTab(womanKey: womanKey),
                  VaccinesTab(womanKey: womanKey),
                  _buildGalleryTab(context, ref, woman),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(PregnantWomanModel woman) {
    final isHighRisk = woman.riskLevel == PregnancyRisk.highRisk;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Passo 2: Badge ao lado do nome
          Row(
            children: [
              Expanded(
                child: Text(
                  woman.name,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isHighRisk ? AppColors.errorSurface : AppColors.successSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isHighRisk ? AppColors.errorBorder : AppColors.successBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 14,
                      color: isHighRisk ? AppColors.error : AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      woman.riskLevel.label,
                      style: TextStyle(
                        color: isHighRisk ? AppColors.error : AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${woman.ageLabel}  •  ${woman.trimesterLabel}',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // ✅ Passo 6: Card Idade Gestacional + DPP 
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF26A69A), // Teal/Verde do mockup
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Idade Gestacional',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        woman.gestationalAgeLabel,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'DPP: ${woman.effectiveDpp?.formatted ?? "Não informada"}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.child_friendly,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),

          if (woman.notes != null && woman.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.infoSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.infoBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 18, color: AppColors.info),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      woman.notes!,
                      style: const TextStyle(
                          color: AppColors.info,
                          fontSize: 13,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildDashboard(PregnantWomanModel woman) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progresso do Pré-Natal',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                woman.progressLabel,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: woman.overallProgress,
              minHeight: 8,
              backgroundColor: AppColors.border.withAlpha(100),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              woman.progressSummaryLabel,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return const Material(
      color: AppColors.surface,
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        tabs: [
          Tab(text: 'Consultas'),
          Tab(text: 'Ultrassons'),
          Tab(text: 'Exames'),
          Tab(text: 'Vacinas'),
          Tab(text: 'Galeria'),
        ],
      ),
    );
  }

  Widget _buildGalleryTab(
    BuildContext context,
    WidgetRef ref,
    PregnantWomanModel woman,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DocumentGalleryWidget(
        title: 'Galeria da Gestante',
        imagePaths: woman.photoPaths,
        maxImages: 10,
        onAddImage: (path) async {
          await ref.read(pregnantDetailsProvider(womanKey).notifier).addGalleryImage(path);
        },
        onRemoveImage: (index) async {
          await ref.read(pregnantDetailsProvider(womanKey).notifier).removeGalleryImage(index);
        },
      ),
    );
  }
}