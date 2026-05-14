import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/features/learning/domain/models/categoria_model.dart';
import 'package:kankui_app/shared/data/seed/vocablos_data.dart';
import 'package:kankui_app/shared/services/audio_service.dart';
import 'package:kankui_app/shared/ui/theme/app_theme.dart';
import 'package:kankui_app/shared/data/local/user_repository.dart';
import 'package:kankui_app/shared/data/local/progress_repository.dart';
import 'package:kankui_app/features/docente/data/repositories/estudiante_repository.dart';

class LessonDetailController extends GetxController {
  final AudioService _audioService = Get.find();
  final UserRepository _userRepo = Get.find();
  final ProgressRepository _progressRepo = Get.find();

  final currentIndex = 0.obs;
  final showSignificado = false.obs;

  late CategoriaModel categoria;
  late List<Vocablo> vocablos;

  void initialize(CategoriaModel cat, List<Vocablo> vocs) {
    categoria = cat;
    vocablos = vocs;
  }

  void toggleSignificado() {
    showSignificado.toggle();
  }

  void goToPrevious() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      showSignificado.value = false;
    }
  }

  void goToNext() {
    if (currentIndex.value < vocablos.length - 1) {
      currentIndex.value++;
      showSignificado.value = false;
    } else {
      showCompletionDialog();
    }
  }

  Future<void> _guardarProgreso() async {
    try {
      final usuario = await _userRepo.getCurrentUser();
      if (usuario == null) return;

      final xpGanado = vocablos.length * 10;

      await _userRepo.addXP(xpGanado);
      await _userRepo.updateRacha();
      await _userRepo.completarLeccion(categoria.id);

      final estudiante = await _userRepo.getCurrentEstudiante();
      final totalCompletadas = estudiante?.leccionesCompletadasTotal ?? 1;

      await _progressRepo.updateProgresoCategoria(
        usuarioId: usuario.id,
        categoriaId: categoria.id,
        leccionesCompletadas: totalCompletadas,
        totalLecciones: 1,
      );

      try {
        final repo = EstudianteRepository(Supabase.instance.client);
        await repo.actualizarGamificacion(
          usuarioId: usuario.id,
          xpSumar: xpGanado,
          incrementarRacha: true,
          leccionesSumar: 1,
        );
      } catch (_) {}
    } catch (e) {
      debugPrint('Error guardando progreso de lección: $e');
    }
  }

  void showCompletionDialog() {
    Get.dialog(_buildCompletionDialog());
  }

  Widget _buildCompletionDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.verdeSelva.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration_rounded,
                color: AppColors.verdeSelva,
                size: 56,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¡Sewá!',
              style: Get.textTheme.headlineLarge?.copyWith(
                color: AppColors.verdeSelva,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '(¡Gracias!)',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.textoClaro,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Has completado la lección de ${categoria.nombre}',
              style: Get.textTheme.bodyLarge?.copyWith(color: AppColors.textoMedio),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.doradoSol.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.doradoSol,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+${vocablos.length * 10} XP',
                    style: Get.textTheme.headlineMedium?.copyWith(
                      color: AppColors.doradoSol,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                Get.back();
                await _guardarProgreso();
                _mostrarOpcionesPostLeccion();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarOpcionesPostLeccion() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Qué deseas hacer ahora?',
              style: Get.textTheme.titleLarge?.copyWith(
                color: AppColors.textoOscuro,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Get.back();
                Get.toNamed('/quiz', arguments: {
                  'categoria': categoria,
                  'leccionId': categoria.id,
                  'cantidadPreguntas': vocablos.length,
                  'desdeLeccion': true,
                  'vocablosLeccion': vocablos,
                });
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: AppColors.terracota,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.quiz_rounded),
              label: const Text('Hacer Quiz'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Get.back();
                currentIndex.value = 0;
                showSignificado.value = false;
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                side: const BorderSide(color: AppColors.terracota),
              ),
              icon: const Icon(Icons.replay_rounded, color: AppColors.terracota),
              label: Text('Repetir Lección', style: TextStyle(color: AppColors.terracota)),
            ),
            TextButton(onPressed: () => Get.back(), child: const Text('Volver al Inicio')),
          ],
        ),
      ),
    );
  }

  Future<void> playAudio(String? audioPath) async {
    if (audioPath != null && audioPath.isNotEmpty) {
      await _audioService.play(audioPath);
    }
  }

  @override
  void onClose() {
    _audioService.stop();
    super.onClose();
  }
}
