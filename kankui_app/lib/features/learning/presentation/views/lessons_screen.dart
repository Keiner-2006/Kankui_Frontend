import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kankui_app/shared/ui/theme/app_theme.dart';
import 'package:kankui_app/shared/ui/theme/kankui_icons.dart';
import 'package:kankui_app/shared/data/seed/vocablos_data.dart';
import 'package:kankui_app/features/learning/presentation/controllers/lessons_controller.dart';
import 'package:kankui_app/shared/ui/widgets/categoria_card.dart';
import 'package:kankui_app/shared/data/local/palabra_local.dart';
import 'package:kankui_app/shared/services/media_download_service.dart';

class LessonsScreen extends GetView<LessonsController> {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() => CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildProgresoGeneral(context)),
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Text('Categorías de Aprendizaje', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.textoOscuro)),
          )),
          if (controller.loading.value)
            const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.terracota))))
          else if (controller.categorias.isEmpty)
            const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No hay categorías disponibles'))))
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) {
                final categoria = controller.categorias[index];
                final progreso = controller.calcularProgresoCategoria(categoria.id);
                return Padding(padding: const EdgeInsets.only(bottom: 16),
                  child: CategoriaCard(
                    categoria: categoria, cantidadVocablos: categoria.totalPalabras,
                    progreso: progreso,
                    onTap: () async {
                      final palabraLocal = PalabraLocal();
                      final data = await palabraLocal.obtenerPorCategoria(categoria.id);
                      if (data.isEmpty) {
                        Get.snackbar('Sin contenido', 'No hay palabras en esta categoría');
                        return;
                      }
                      final vocablos = data.map((e) => Vocablo(
                        id: e['id'], palabra: e['termino'], significado: e['traduccion'],
                        fonetica: e['pronunciacion'], categoria: e['categoria_id'],
                        audioPath: MediaDownloadService.resolveAudioSync(e['id'], e['audio_url']),
                        imagePath: MediaDownloadService.resolveImageSync(e['id'], e['image_url']),
                        descripcionCultural: null, enRecuperacion: false,
                      )).toList();
                      Get.toNamed('/lesson-detail', arguments: {'categoria': categoria, 'vocablos': vocablos});
                    },
                  ),
                );
              }, childCount: controller.categorias.length)),
            ),
          SliverToBoxAdapter(child: _buildSeccionRecuperacion(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      )),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        KankuiIcons.mochila(size: 32, color: AppColors.terracota), const SizedBox(width: 12),
        Text('Kakatukwa-Lingo', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.terracota, fontWeight: FontWeight.bold)),
      ]),
      const SizedBox(height: 8),
      Text('Aprende la lengua de los ancestros', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textoMedio)),
    ]));
  }

  Widget _buildProgresoGeneral(BuildContext context) {
    int aprendidos = 0;
    int totalVocablos = 0;
    for (var cat in controller.categorias) {
      final progreso = controller.progresoCategorias[cat.id] ?? 0.0;
      aprendidos += (progreso * cat.totalPalabras).round();
      totalVocablos += cat.totalPalabras;
    }
    if (totalVocablos == 0) {
      totalVocablos = VocablosData.vocablos.length;
    }
    final porcentaje = totalVocablos > 0 ? (aprendidos / totalVocablos).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.terracota.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 4))]),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Tu Progreso', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textoOscuro)),
            Text('$aprendidos de $totalVocablos vocablos', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textoClaro)),
          ]),
          Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: AppColors.verdeSelva.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Text('${(porcentaje * 100).toInt()}%', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.verdeSelva, fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 16),
        Container(height: 12,
          decoration: BoxDecoration(color: AppColors.cremaOscuro, borderRadius: BorderRadius.circular(10)),
          child: Stack(children: [
            FractionallySizedBox(widthFactor: porcentaje, child: Container(
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.verdeSelva, AppColors.verdeMontana]), borderRadius: BorderRadius.circular(10)))),
            Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(10), child: CustomPaint(painter: _TejidoBarraPainter()))),
          ])),
      ]),
    );
  }

  Widget _buildSeccionRecuperacion(BuildContext context) {
    final palabrasRecuperacion = VocablosData.obtenerEnRecuperacion();
    return Container(
      margin: const EdgeInsets.all(20), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.doradoSol.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.doradoSol.withValues(alpha: 0.3), width: 2)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.doradoSol.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.auto_awesome, color: AppColors.doradoSol, size: 24)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Palabras en Recuperación', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textoOscuro)),
            Text('${palabrasRecuperacion.length} palabras', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textoClaro)),
          ])),
        ]),
        const SizedBox(height: 12),
        Text('Estas palabras están siendo recuperadas por el Cabildo y los Mayores.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textoMedio, fontStyle: FontStyle.italic)),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: palabrasRecuperacion.take(5).map((vocablo) {
          return Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.doradoSol.withValues(alpha: 0.3))),
            child: Text(vocablo.palabra, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.terracota, fontWeight: FontWeight.w600)));
        }).toList()),
      ]),
    );
  }
}

class _TejidoBarraPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.15)..style = PaintingStyle.stroke..strokeWidth = 1;
    for (double i = -size.height; i < size.width + size.height; i += 8) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
