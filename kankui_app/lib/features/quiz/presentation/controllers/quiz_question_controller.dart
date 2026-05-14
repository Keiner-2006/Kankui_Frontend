import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/features/quiz/domain/models/reto_model.dart';
import 'package:kankui_app/features/quiz/domain/models/pregunta_quiz_model.dart';
import 'package:kankui_app/features/quiz/data/repositories/quiz_repository.dart';
import 'package:kankui_app/features/docente/data/repositories/estudiante_repository.dart';
import 'package:kankui_app/shared/data/local/user_repository.dart';
import 'package:kankui_app/shared/services/audio_service.dart';

class QuizQuestionController extends GetxController
    with SingleGetTickerProviderMixin {
  final QuizRepository _quizRepository = Get.find();
  final UserRepository _userRepo = Get.find();
  final AudioService _audioService = Get.find();

  late List<PreguntaQuizModel> preguntas;
  late List<int?> respuestasUsuario;
  late int preguntaIndex;
  late AnimationController timerController;
  late Animation<double> timerAnimation;

  final selectedOptionIndex = Rxn<int>();
  final mostrandoResultado = false.obs;
  final respondida = false.obs;

  late RetoQuizModel reto;
  late String? categoriaNombre;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    reto = args['reto'] as RetoQuizModel;
    categoriaNombre = args['categoriaNombre'] as String?;

    preguntas = reto.preguntasQuiz;
    respuestasUsuario = List<int?>.filled(preguntas.length, null);
    preguntaIndex = 0;

    timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    timerAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: timerController, curve: Curves.easeInOut),
    );

    timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !respondida.value) {
        nextQuestion();
      }
    });

    timerController.forward();
  }

  @override
  void onClose() {
    timerController.dispose();
    _audioService.stop();
    super.onClose();
  }

  void selectAnswer(int index) {
    selectedOptionIndex.value = index;
    respondida.value = true;
    timerController.stop();
    respuestasUsuario[preguntaIndex] = index;

    Future.delayed(const Duration(seconds: 1), () {
      mostrandoResultado.value = true;
    });
  }

  void nextQuestion() {
    if (preguntaIndex < preguntas.length - 1) {
      preguntaIndex++;
      mostrandoResultado.value = false;
      respondida.value = false;
      selectedOptionIndex.value = null;
      timerController.reset();
      timerController.forward();
    } else {
      finishQuiz();
    }
  }

  void finishQuiz() {
    timerController.stop();

    final respuestasValidas = respuestasUsuario.where((r) => r != null).length;
    final correctas = _quizRepository.calcularRespuestasCorrectas(
      preguntas,
      respuestasUsuario.where((r) => r != null).cast<int>().toList(),
    );

    final resultado = {
      'total': preguntas.length,
      'respondidas': respuestasValidas,
      'correctas': correctas,
      'puntos': correctas * 10,
      'porcentaje': (correctas / preguntas.length * 100).round(),
    };

    _guardarProgreso(resultado);
    Get.offNamed('/quiz-resumen', arguments: {
      'reto': reto,
      'resultado': resultado,
      'preguntas': preguntas,
      'respuestasUsuario': respuestasUsuario,
      'categoriaNombre': categoriaNombre,
    });
  }

  Future<void> _guardarProgreso(Map<String, dynamic> resultado) async {
    final resultadoId = await _userRepo.guardarResultadoQuiz(
      reto.id,
      resultado,
    );

    final correctas = resultado['correctas'] as int;
    final xpGanado = correctas * 10;

    await _userRepo.addXP(xpGanado);
    await _userRepo.incrementarEscaneos();

    if (reto.leccionId != null) {
      try {
        await _userRepo.completarLeccion(reto.leccionId!);
      } catch (_) {}
    }

    await _userRepo.updateRacha();

    final usuario = await _userRepo.getCurrentUser();
    if (usuario != null) {
      try {
        final repo = EstudianteRepository(Supabase.instance.client);
        await repo.actualizarGamificacion(
          usuarioId: usuario.id,
          xpSumar: xpGanado,
          incrementarRacha: true,
          leccionesSumar: reto.leccionId != null ? 1 : 0,
        );
      } catch (_) {}
    }
  }

  void confirmExit() {
    Get.dialog(
      AlertDialog(
        title: const Text('¿Salir del quiz?'),
        content: const Text('Tu progreso actual no se guardará.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}
