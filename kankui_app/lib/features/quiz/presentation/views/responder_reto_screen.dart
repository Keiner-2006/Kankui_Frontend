import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kankui_app/features/docente/domain/models/reto_model.dart';
import 'package:kankui_app/features/quiz/presentation/controllers/retos_estudiante_controller.dart';
import 'package:kankui_app/shared/ui/theme/app_theme.dart';

class ResponderRetoScreen extends StatefulWidget {
  final RetoModel reto;

  const ResponderRetoScreen({super.key, required this.reto});

  @override
  State<ResponderRetoScreen> createState() => _ResponderRetoScreenState();
}

class _ResponderRetoScreenState extends State<ResponderRetoScreen> {
  final _respuestaController = TextEditingController();
  final _controller = Get.find<RetosEstudianteController>();
  var _enviando = false;

  @override
  void dispose() {
    _respuestaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.crema,
      appBar: AppBar(
        title: Text(widget.reto.nombre),
        backgroundColor: AppColors.terracota,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.reto.preguntas != null && widget.reto.preguntas!.isNotEmpty) ...[
              const Text(
                'Preguntas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textoOscuro,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(widget.reto.preguntas!.length, (i) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cremaOscuro,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${i + 1}. ${widget.reto.preguntas![i]}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textoMedio,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],
            const Text(
              'Tu respuesta',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textoOscuro,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _respuestaController,
              maxLines: 8,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Escribe aquí tu respuesta...',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.terracota,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    _enviando ? null : () => _enviarRespuesta(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terracota,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _enviando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Enviar respuesta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _enviarRespuesta(BuildContext context) async {
    final respuesta = _respuestaController.text.trim();
    if (respuesta.isEmpty) {
      Get.snackbar(
        'Respuesta vacía',
        'Escribe una respuesta antes de enviar.',
        backgroundColor: AppColors.advertencia,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _enviando = true);
    try {
      await _controller.enviarRespuesta(widget.reto.id, respuesta);
      _respuestaController.clear();
      Get.snackbar(
        'Enviado',
        'Tu respuesta ha sido registrada.',
        backgroundColor: AppColors.verdeSelva,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo enviar la respuesta: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }
}
