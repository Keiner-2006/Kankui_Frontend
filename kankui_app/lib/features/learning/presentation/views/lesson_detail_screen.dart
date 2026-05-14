import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kankui_app/shared/ui/theme/app_theme.dart';
import 'package:kankui_app/shared/ui/theme/kankui_icons.dart';
import 'package:kankui_app/features/learning/domain/models/categoria_model.dart';
import 'package:kankui_app/shared/data/seed/vocablos_data.dart';
import 'package:kankui_app/features/learning/presentation/controllers/lesson_detail_controller.dart';

class LessonDetailScreen extends GetView<LessonDetailController> {
  const LessonDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final categoria = args['categoria'] as CategoriaModel;
    final vocablos = args['vocablos'] as List<Vocablo>;

    controller.initialize(categoria, vocablos);

    if (vocablos.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.crema,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Get.back(),
          ),
          title: Text(categoria.nombre),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 64,
                  color: AppColors.textoClaro,
                ),
                const SizedBox(height: 24),
                Text(
                  'No hay vocablos disponibles',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textoOscuro,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Pronto se añadirán nuevas palabras a esta categoría.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textoClaro,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Obx(() {
      final currentIndex = controller.currentIndex.value;
      final showSignificado = controller.showSignificado.value;
      final vocablo = vocablos[currentIndex];

      return Scaffold(
        backgroundColor: AppColors.crema,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Get.back(),
          ),
          title: Text(categoria.nombre),
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: AppColors.terracota.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${currentIndex + 1}/${vocablos.length}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.terracota),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.cremaOscuro,
                borderRadius: BorderRadius.circular(3),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: constraints.maxWidth * ((currentIndex + 1) / vocablos.length),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.terracota, AppColors.terracotaLight],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: controller.toggleSignificado,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: showSignificado
                              ? _buildSignificadoCard(context, vocablo)
                              : _buildPalabraCard(context, vocablo),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Toca la tarjeta para ver ${showSignificado ? 'la palabra' : 'el significado'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textoClaro,
                          ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.volume_up_rounded,
                              color: AppColors.terracota,
                            ),
                            iconSize: 28,
                            onPressed: vocablo.audioPath?.isNotEmpty == true
                                ? () => controller.playAudio(vocablo.audioPath)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: currentIndex > 0
                              ? Row(
                                  children: [
                                    OutlinedButton(
                                      onPressed: controller.goToPrevious,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.terracota,
                                        side: const BorderSide(color: AppColors.terracota),
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(12),
                                      ),
                                      child: const Icon(Icons.arrow_back_rounded),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: controller.goToNext,
                                        icon: Icon(
                                          currentIndex < vocablos.length - 1
                                              ? Icons.arrow_forward_rounded
                                              : Icons.check_rounded,
                                          size: 18,
                                        ),
                                        label: Text(
                                          currentIndex < vocablos.length - 1
                                              ? 'Siguiente'
                                              : 'Completar',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.terracota,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(28),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : ElevatedButton.icon(
                                  onPressed: controller.goToNext,
                                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                                  label: const Text('Siguiente', style: TextStyle(fontSize: 14)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.terracota,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPalabraCard(BuildContext context, Vocablo vocablo) {
    return Container(
      key: const ValueKey('palabra'),
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.terracota, AppColors.terracotaLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.terracota.withValues(alpha: 0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (vocablo.imagePath != null && vocablo.imagePath!.isNotEmpty)
            Container(
              width: 200,
              height: 200,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
                image: DecorationImage(
                  image: NetworkImage(vocablo.imagePath!),
                  fit: BoxFit.contain,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: KankuiIcons.tejido(size: 48, color: Colors.white),
            ),
          const SizedBox(height: 16),
          Text(
            vocablo.palabra,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 42,
                  letterSpacing: 2,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '/${vocablo.fonetica}/',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
          const Spacer(),
          if (vocablo.enRecuperacion) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.doradoSol.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Palabra en recuperación',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSignificadoCard(BuildContext context, Vocablo vocablo) {
    return Container(
      key: const ValueKey('significado'),
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.verdeSelva.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: KankuiIcons.hoja(size: 40, color: AppColors.verdeSelva),
          ),
          const SizedBox(height: 32),
          Text(
            vocablo.significado,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.textoOscuro,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (vocablo.descripcionCultural != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.crema,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.terracota, size: 20),
                      const SizedBox(width: 8),
                      Text('Conocimiento de los Mayores', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.terracota)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vocablo.descripcionCultural!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textoMedio, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          Text(vocablo.palabra, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.terracota, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}