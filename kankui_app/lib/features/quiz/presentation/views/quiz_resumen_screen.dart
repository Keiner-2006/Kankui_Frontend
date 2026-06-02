import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kankui_app/shared/ui/theme/app_theme.dart';
import 'package:kankui_app/features/quiz/domain/models/reto_model.dart';
import 'package:kankui_app/features/quiz/domain/models/pregunta_quiz_model.dart';
import 'package:kankui_app/features/learning/presentation/controllers/home_controller.dart';
import 'package:kankui_app/features/learning/presentation/controllers/lessons_controller.dart';

class QuizResumenScreen extends StatelessWidget {
  const QuizResumenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final resultado = args['resultado'] as Map<String, dynamic>;
    final preguntas = args['preguntas'] as List<PreguntaQuizModel>;
    final respuestasUsuario = args['respuestasUsuario'] as List<int?>;

    final correctas = resultado['correctas'] as int;
    final total = resultado['total'] as int;
    final porcentaje = resultado['porcentaje'] as int;
    final puntos = resultado['puntos'] as int;

    return Scaffold(
      backgroundColor: AppColors.crema,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const SizedBox(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: correctas >= total * 0.7
                      ? AppColors.verdeSelva.withValues(alpha: 0.15)
                      : AppColors.terracota.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  correctas >= total * 0.7
                      ? Icons.celebration_rounded
                      : Icons.school_rounded,
                  color: correctas >= total * 0.7
                      ? AppColors.verdeSelva
                      : AppColors.terracota,
                  size: 80,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '¡Reto Completado!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.textoOscuro,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Has demostrado tu conocimiento en kankuama',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textoMedio,
                    ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  _buildMetricCard(
                    context,
                    label: 'Correctas',
                    value: '$correctas/$total',
                    color: AppColors.verdeSelva,
                  ),
                  const SizedBox(width: 12),
                  _buildMetricCard(
                    context,
                    label: 'Puntos',
                    value: '$puntos',
                    color: AppColors.doradoSol,
                  ),
                  const SizedBox(width: 12),
                  _buildMetricCard(
                    context,
                    label: 'Precisión',
                    value: '$porcentaje%',
                    color: AppColors.terracota,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revisión de Respuestas',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textoOscuro,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(preguntas.length, (index) {
                      final pregunta = preguntas[index];
                      final respuestaUsuario = respuestasUsuario[index];
                      final respondida = respuestaUsuario != null;
                      final correcta = respondida &&
                          respuestaUsuario == pregunta.respuestaCorrectaIndex;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: correcta
                                    ? AppColors.verdeSelva.withValues(alpha: 0.2)
                                    : AppColors.terracota.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                correcta ? Icons.check : Icons.close,
                                color: correcta
                                    ? AppColors.verdeSelva
                                    : AppColors.terracota,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pregunta ${index + 1}: ${pregunta.enunciado}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.textoOscuro,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tu respuesta: ${respondida ? pregunta.opciones[respuestaUsuario] : "No respondida"}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: respondida
                                              ? (correcta
                                                  ? AppColors.verdeSelva
                                                  : AppColors.terracota)
                                              : AppColors.textoClaro,
                                        ),
                                  ),
                                  if (!correcta && respondida)
                                    Text(
                                      'Correcta: ${pregunta.respuestaCorrecta}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.verdeSelva,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Get.offAllNamed('/home');
                  try {
                    Get.find<HomeController>().fetchData();
                  } catch (_) {}
                  try {
                    Get.find<LessonsController>().fetchCategorias();
                  } catch (_) {}
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: AppColors.terracota,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Volver al Inicio'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textoClaro,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
