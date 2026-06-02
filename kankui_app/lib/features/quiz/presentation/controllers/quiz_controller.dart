import 'package:get/get.dart';
import 'package:kankui_app/features/learning/domain/models/categoria_model.dart';
import 'package:kankui_app/features/quiz/domain/models/reto_model.dart';
import 'package:kankui_app/shared/data/seed/vocablos_data.dart';
import 'package:kankui_app/features/quiz/data/repositories/quiz_repository.dart';

class QuizController extends GetxController {
  final QuizRepository _quizRepository = Get.find();

  CategoriaModel? categoria;
  String? leccionId;
  int? cantidadPreguntas;
  bool desdeLeccion = false;
  List<Vocablo>? vocablosLeccion;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      initialize(
        categoria: args['categoria'] as CategoriaModel?,
        leccionId: args['leccionId'] as String?,
        cantidadPreguntas: args['cantidadPreguntas'] as int?,
        desdeLeccion: args['desdeLeccion'] as bool? ?? false,
        vocablosLeccion: args['vocablosLeccion'] as List<Vocablo>?,
      );
    }
  }

  void initialize({
    CategoriaModel? categoria,
    String? leccionId,
    int? cantidadPreguntas,
    bool desdeLeccion = false,
    List<Vocablo>? vocablosLeccion,
  }) {
    this.categoria = categoria;
    this.leccionId = leccionId;
    this.cantidadPreguntas = cantidadPreguntas;
    this.desdeLeccion = desdeLeccion;
    this.vocablosLeccion = vocablosLeccion;
  }

  Future<void> startQuiz() async {
    final cat = categoria;
    final cantidad = cantidadPreguntas ?? 10;

    if (cat == null) {
      startGeneralQuiz();
      return;
    }

    if (desdeLeccion &&
        vocablosLeccion != null &&
        vocablosLeccion!.isNotEmpty) {
      final preguntas = _quizRepository.generarPreguntasDeLeccion(
        vocablos: vocablosLeccion!,
      );

      final reto = RetoQuizModel(
        id: 'reto_${cat.id}_${DateTime.now().millisecondsSinceEpoch}',
        nombre: 'Quiz: ${cat.nombre}',
        preguntasQuiz: preguntas,
        leccionId: leccionId,
      );

      Get.toNamed('/quiz-question', arguments: {
        'reto': reto,
        'categoriaNombre': cat.nombre,
      });
      return;
    }

    final preguntas = _quizRepository.generarPreguntas(
      cantidad: cantidad,
      categoria: cat.id,
      dificultadMin: 1,
      dificultadMax: 3,
    );

    final reto = RetoQuizModel(
      id: 'reto_${cat.id}_${DateTime.now().millisecondsSinceEpoch}',
      nombre: 'Quiz: ${cat.nombre}',
      preguntasQuiz: preguntas,
      leccionId: leccionId,
    );

    Get.toNamed('/quiz-question', arguments: {
      'reto': reto,
      'categoriaNombre': cat.nombre,
    });
  }

  void startGeneralQuiz() {
    final reto = _quizRepository.crearReto(
      id: 'reto_general_${DateTime.now().millisecondsSinceEpoch}',
      cantidadPreguntas: 10,
      aleatorio: true,
    );

    Get.toNamed('/quiz-question', arguments: {
      'reto': reto,
      'categoriaNombre': 'General',
    });
  }

  void startRecuperacionQuiz() {
    final reto = _quizRepository.crearReto(
      id: 'reto_recup${DateTime.now().millisecondsSinceEpoch}',
      categoria: null,
      cantidadPreguntas: 8,
      aleatorio: true,
    );

    Get.toNamed('/quiz-question', arguments: {
      'reto': reto,
      'categoriaNombre': 'Recuperación',
    });
  }
}
