import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kankui_app/features/learning/presentation/controllers/home_controller.dart';
import 'package:kankui_app/shared/ui/theme/app_theme.dart';
import 'package:kankui_app/shared/ui/theme/kankui_icons.dart';
import 'package:kankui_app/shared/ui/widgets/sierra_path.dart';
import 'package:kankui_app/shared/ui/widgets/custom_bottom_nav.dart';
import 'package:kankui_app/shared/ui/widgets/user_stats_card.dart';
import 'package:kankui_app/shared/services/sesionmanager.dart';
import 'package:kankui_app/shared/data/user_progress.dart';
import 'package:kankui_app/features/learning/presentation/views/lessons_screen.dart'
    as legacy;
import 'package:kankui_app/features/qr_scanner/presentation/views/qr_scanner_screen.dart'
    as legacy;
import 'package:kankui_app/features/docente/presentation/views/ranking_screen.dart'
    as legacy;
import 'package:kankui_app/features/learning/presentation/views/profile_screen.dart'
    as legacy;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final progress = controller.userProgress.value ?? const UserProgress();
      final progresoCategorias =
          Map<String, double>.from(controller.progresoCategorias);

      return Scaffold(
        body: controller.loadingCategorias.value
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.terracota))
            : IndexedStack(
                index: controller.currentNavIndex.value,
                children: [
                  _HomeContent(progresoCategorias: progresoCategorias),
                  const legacy.LessonsScreen(),
                  const legacy.QrScannerScreen(),
                  legacy.RankingScreen(userProgress: progress),
                  legacy.ProfileScreen(userProgress: progress),
                ],
              ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: controller.currentNavIndex.value,
          onTap: (index) => controller.changeNavIndex(index),
        ),
      );
    });
  }
}

class _HomeContent extends StatelessWidget {
  final Map<String, double> progresoCategorias;

  const _HomeContent({required this.progresoCategorias});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final progress = controller.userProgress.value ?? const UserProgress();
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: UserStatsCard(userProgress: progress),
          )),
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Row(children: [
              KankuiIcons.sierra(size: 28, color: AppColors.terracota),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('El Camino de la Sierra',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: AppColors.textoOscuro)),
                Text('Tu viaje por el conocimiento Kankuamo',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textoClaro)),
              ]),
            ]),
          )),
          SliverToBoxAdapter(
              child: SierraPath(
            categorias: controller.categorias,
            progresoCategorias: progresoCategorias,
          )),
          SliverToBoxAdapter(child: _buildPalabraDelDia(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final usuario = Get.find<SessionManager>().usuario;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(usuario?.nombre ?? 'Viajero',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.terracota, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.terracota.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(_obtenerSaludo(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.terracota,
                          fontStyle: FontStyle.italic))),
            ]),
            const SizedBox(height: 4),
            Text('Bienvenido al camino del saber',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppColors.textoMedio)),
          ]),
          GestureDetector(
            onTap: () {},
            child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    color: AppColors.terracota.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.terracota.withValues(alpha: 0.3),
                        width: 2)),
                child: Center(
                    child: KankuiIcons.mochila(
                        size: 28, color: AppColors.terracota))),
          ),
        ],
      ),
    );
  }

  String _obtenerSaludo() {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Buenos días';
    if (hora < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  Widget _buildPalabraDelDia(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppColors.terracota, AppColors.terracotaLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: AppColors.terracota.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12)),
              child: KankuiIcons.espiral(size: 24, color: Colors.white)),
          const SizedBox(width: 12),
          Text('Palabra del día',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white.withValues(alpha: 0.9))),
        ]),
        const SizedBox(height: 16),
        Text('Kunsamunu',
            style: Theme.of(context)
                .textTheme
                .displayMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('/kun-sa-mu-nu/',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontStyle: FontStyle.italic)),
        const SizedBox(height: 12),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12)),
            child: Text('Sierra Nevada - El corazón del mundo',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white))),
        const SizedBox(height: 16),
        Row(children: [
          _buildActionButton(context,
              icon: Icons.volume_up_rounded, label: 'Escuchar', onTap: () {}),
          const SizedBox(width: 12),
          _buildActionButton(context,
              icon: Icons.bookmark_outline_rounded,
              label: 'Guardar',
              onTap: () {}),
        ]),
      ]),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 20, color: AppColors.terracota),
            const SizedBox(width: 8),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: AppColors.terracota)),
          ])),
    );
  }
}
