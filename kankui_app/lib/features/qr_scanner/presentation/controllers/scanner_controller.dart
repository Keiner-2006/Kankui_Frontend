import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/features/learning/data/repositories/categoria_repository.dart';
import 'package:kankui_app/shared/data/seed/vocablos_data.dart';

class ScannerController extends GetxController {
  final CategoriaRepository _categoriaRepo = Get.find();

  late MobileScannerController cameraController;
  final isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    cameraController = MobileScannerController();
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }

  Future<void> onDetect(BarcodeCapture capture) async {
    if (isProcessing.value) return;
    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final code = barcodes.first.rawValue;
      if (code != null) {
        await HapticFeedback.lightImpact();
        isProcessing.value = true;
        await cameraController.stop();

        if (code.startsWith('KANKUI_LESSON:')) {
          final categoriaId = code.split(':').last;
          await navigateToLesson(categoriaId);
        } else if (code.startsWith('KANKUI_ITEM:')) {
          final vocabloId = code.split(':').last;
          await navigateToItem(vocabloId);
        } else {
          await navigateToInfo(code);
        }

        if (Get.isOverlaysOpen == false) {
          isProcessing.value = false;
          await cameraController.start();
        }
      }
    }
  }

  Future<void> navigateToLesson(String categoriaId) async {
    try {
      final categoria = await _categoriaRepo.getCategoriaById(categoriaId);
      if (categoria != null) {
        final nombreBuscado = categoria.nombre.toLowerCase();
        String idEstatico = nombreBuscado.replaceAll(' ', '_');

        if (nombreBuscado.contains('saludo')) {
          idEstatico = 'saludos';
        } else if (nombreBuscado.contains('familia')) idEstatico = 'familia';
        else if (nombreBuscado.contains('naturaleza')) idEstatico = 'naturaleza';
        else if (nombreBuscado.contains('objeto') || nombreBuscado.contains('sagrado')) idEstatico = 'objetos_sagrados';
        else if (nombreBuscado.contains('numero') || nombreBuscado.contains('número')) idEstatico = 'numeros';
        else if (nombreBuscado.contains('color')) idEstatico = 'colores';
        else if (nombreBuscado.contains('animal')) idEstatico = 'animales';
        else if (nombreBuscado.contains('planta')) idEstatico = 'plantas';

        final vocablos = VocablosData.vocablos.where((v) => v.categoria == idEstatico).toList();

        Get.toNamed('/lesson-detail', arguments: {
          'categoria': categoria,
          'vocablos': vocablos,
        });
      } else {
        _showError('No se encontró la lección para: $categoriaId');
      }
    } catch (e) {
      _showError('Error al cargar la lección: $e');
    }
  }

  Future<void> navigateToItem(String vocabloId) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('palabra')
          .select()
          .eq('id', vocabloId)
          .maybeSingle();

      if (response == null) {
        _showError('No se encontró la palabra en la base de datos.');
        return;
      }

      final termino = response['termino'] ?? 'Palabra';
      final traduccion = response['traduccion'] ?? 'Sin traducción';
      final pronunciacion = response['pronunciacion'] ?? '';

      Get.dialog(AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: const Color(0xFFFFF8F0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFD4730A), shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            Text(termino, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF5C2E00))),
            if (pronunciacion.isNotEmpty)
              Text('[ $pronunciacion ]', style: const TextStyle(fontSize: 14, color: Color(0xFF8A6E5C), fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            Text('"$traduccion"', style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Color(0xFF8A6E5C))),
            const SizedBox(height: 16),
            const Divider(),
            const Text('¡Has descubierto una palabra de la lengua Kankuama! Recuérdala bien.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF2C1A0E))),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('¡Entendido!'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C2E00), foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ));
    } catch (e) {
      _showError('Error al cargar el objeto: $e');
    }
  }

  Future<void> navigateToInfo(String code) async {
    await Get.toNamed('/kankuama-info', arguments: {'qrCodeId': code});
  }

  void _showError(String message) {
    Get.snackbar('Error', message,
        backgroundColor: Colors.redAccent, colorText: Colors.white);
  }
}
