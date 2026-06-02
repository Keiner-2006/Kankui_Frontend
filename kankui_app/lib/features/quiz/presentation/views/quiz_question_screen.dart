import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kankui_app/features/quiz/presentation/controllers/quiz_question_controller.dart';
import 'package:kankui_app/shared/ui/theme/app_theme.dart';
import 'package:kankui_app/features/quiz/domain/models/pregunta_quiz_model.dart';
import 'package:kankui_app/shared/ui/widgets/opcion_respuesta_widget.dart';

class QuizQuestionScreen extends StatefulWidget {
  const QuizQuestionScreen({super.key});

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  late final QuizQuestionController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<QuizQuestionController>();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pregunta = controller.preguntas[controller.preguntaIndex.value];
      return Scaffold(
        backgroundColor: AppColors.crema,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: controller.confirmExit,
          ),
          title: Text(
            controller.categoriaNombre ?? 'Quiz',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.terracota,
                  fontWeight: FontWeight.bold,
                ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.verdeSelva.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${controller.preguntaIndex.value + 1}/${controller.preguntas.length}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.verdeSelva,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildBarraTiempo(),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LinearProgressIndicator(
                  value: (controller.preguntaIndex.value + 1) /
                      controller.preguntas.length,
                  backgroundColor: AppColors.cremaOscuro,
                  color: AppColors.terracota,
                  minHeight: 4,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEnunciado(context, pregunta),
                      const SizedBox(height: 24),
                      _buildOpcionesRespuesta(pregunta),
                      if (pregunta.pista != null &&
                          !controller.respondida.value)
                        _buildPista(context, pregunta.pista!),
                      if (controller.mostrandoResultado.value)
                        _buildResultadoPregunta(context, pregunta),
                    ],
                  ),
                ),
              ),
              if (controller.respondida.value) _buildBotonSiguiente(context),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBarraTiempo() {
    return AnimatedBuilder(
      animation: controller.timerAnimation,
      builder: (context, child) {
        return Container(
          height: 6,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.terracota, AppColors.terracotaLight],
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          width: MediaQuery.of(context).size.width *
              controller.timerAnimation.value,
        );
      },
    );
  }

  Widget _buildEnunciado(BuildContext context, PreguntaQuizModel pregunta) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: pregunta.tipo == TipoPreguntaQuiz.kankuamaASignificado
                  ? AppColors.verdeSelva.withValues(alpha: 0.2)
                  : AppColors.terracota.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              pregunta.tipo == TipoPreguntaQuiz.kankuamaASignificado
                  ? 'Palabra Kankuama → Significado'
                  : 'Significado → Palabra Kankuama',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: pregunta.tipo == TipoPreguntaQuiz.kankuamaASignificado
                        ? AppColors.verdeSelva
                        : AppColors.terracota,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.terracota.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.help_rounded,
                  color: AppColors.terracota,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  pregunta.enunciado,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textoOscuro,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOpcionesRespuesta(PreguntaQuizModel pregunta) {
    return Column(
      children: pregunta.opciones.asMap().entries.map((entry) {
        final index = entry.key;
        final opcion = entry.value;
        final esCorrecta = index == pregunta.respuestaCorrectaIndex;
        final esSeleccionada = controller.selectedOptionIndex.value == index;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OpcionRespuestaWidget(
            opcion: opcion,
            index: index,
            esSeleccionada: esSeleccionada,
            esCorrecta: controller.mostrandoResultado.value && esCorrecta,
            esIncorrecta: controller.mostrandoResultado.value &&
                esSeleccionada &&
                !esCorrecta,
            bloqueada: controller.respondida.value,
            onTap: controller.respondida.value ||
                    controller.mostrandoResultado.value
                ? null
                : () => controller.selectAnswer(index),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPista(BuildContext context, String pista) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.doradoSol.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: AppColors.doradoSol),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              pista,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textoMedio,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultadoPregunta(BuildContext context, PreguntaQuizModel pregunta) {
    final acierto =
        controller.selectedOptionIndex.value == pregunta.respuestaCorrectaIndex;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: acierto
            ? AppColors.verdeSelva.withValues(alpha: 0.15)
            : AppColors.terracota.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            acierto ? Icons.check_circle_rounded : Icons.error_rounded,
            color: acierto ? AppColors.verdeSelva : AppColors.terracota,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  acierto ? '¡Correcto!' : 'Incorrecto',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: acierto
                            ? AppColors.verdeSelva
                            : AppColors.terracota,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (!acierto)
                  Text(
                    'La respuesta correcta es: ${pregunta.respuestaCorrecta}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textoMedio,
                        ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonSiguiente(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton.icon(
        onPressed: controller.nextQuestion,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: AppColors.terracota,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        icon: Icon(
          controller.preguntaIndex.value < controller.preguntas.length - 1
              ? Icons.arrow_forward_rounded
              : Icons.check_rounded,
        ),
        label: Text(
          controller.preguntaIndex.value < controller.preguntas.length - 1
              ? 'Siguiente'
              : 'Finalizar',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
