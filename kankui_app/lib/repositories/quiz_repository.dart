import 'dart:math';

import '../models/pregunta_quiz_model.dart';
import '../models/reto_model.dart';
import '../data/seed/vocablos_data.dart';

/// Repositorio para gestionar la generación y obtención de preguntas de Quiz
/// A partir del vocabulario Kankui, crea preguntas tipo opción múltiple
class QuizRepository {
  final Random _random = Random();

  /// Genera preguntas de quiz a partir de una lista de vocablos (original)
  /// [cantidad] - número de preguntas a generar
  /// [categoria] - filtro opcional por categoría
  /// [dificultadMin] - nivel mínimo de dificultad
  /// [dificultadMax] - nivel máximo de dificultad
  List<PreguntaQuizModel> generarPreguntas({
    int cantidad = 10,
    String? categoria,
    int dificultadMin = 1,
    int dificultadMax = 5,
  }) {
    // Filtrar vocablos según criterios
    var vocablosFiltrados = VocablosData.vocablos.where((v) {
      if (categoria != null && v.categoria != categoria) return false;
      if (v.nivelDificultad < dificultadMin) return false;
      if (v.nivelDificultad > dificultadMax) return false;
      return true;
    }).toList();

    if (vocablosFiltrados.isEmpty) {
      vocablosFiltrados = VocablosData.vocablos.toList();
    }

    cantidad = cantidad.clamp(1, vocablosFiltrados.length);
    vocablosFiltrados.shuffle(_random);
    final vocablosSeleccionados = vocablosFiltrados.take(cantidad).toList();

    return vocablosSeleccionados
        .map((vocablo) => _generarPreguntaDesdeVocablo(vocablo))
        .toList();
  }

  /// Genera preguntas de quiz para palabras específicas de una lección
  /// Asegura que haya exactamente una pregunta por cada vocablo
  /// Alterna aleatoriamente entre los dos tipos de pregunta:
  ///   - kankuamaASignificado: palabra en Kankuama → elegir significado en español
  ///   - significadoAKankuama: significado en español → elegir palabra en Kankuama
  List<PreguntaQuizModel> generarPreguntasDeLeccion({
    required List<Vocablo> vocablos,
    int? cantidad,
  }) {
    if (vocablos.isEmpty) return [];

    final numPreguntas = cantidad ?? vocablos.length;
    final vocablosSeleccionados = (vocablos.toList()..shuffle(_random)).take(numPreguntas).toList();

    return vocablosSeleccionados.map((vocablo) {
      final tipo = _random.nextBool()
          ? TipoPreguntaQuiz.kankuamaASignificado
          : TipoPreguntaQuiz.significadoAKankuama;

      if (tipo == TipoPreguntaQuiz.kankuamaASignificado) {
        return _generarPreguntaKankuamaASignificado(vocablo);
      } else {
        return _generarPreguntaSignificadoAKankuama(vocablo);
      }
    }).toList();
  }

  /// Tipo 1: Palabra en Kankuama → Seleccionar significado correcto en español
  PreguntaQuizModel _generarPreguntaKankuamaASignificado(Vocablo vocabloCorrecto) {
    final distractores = VocablosData.vocablos
        .where((v) =>
            v.id != vocabloCorrecto.id &&
            v.categoria == vocabloCorrecto.categoria &&
            v.significado != vocabloCorrecto.significado)
        .map((v) => v.significado)
        .toList()
      ..shuffle(_random);

    final opcionesDistractoras = distractores.take(3).toList();
    while (opcionesDistractoras.length < 3) {
      opcionesDistractoras.add('Sin significado');
    }

    final todasOpciones = [vocabloCorrecto.significado, ...opcionesDistractoras]..shuffle(_random);
    final respuestaCorrectaIndex = todasOpciones.indexOf(vocabloCorrecto.significado);

    return PreguntaQuizModel(
      id: 'quiz_kank_${vocabloCorrecto.id}',
      enunciado: '"${vocabloCorrecto.palabra}" significa:',
      opciones: todasOpciones,
      respuestaCorrectaIndex: respuestaCorrectaIndex,
      palabraId: vocabloCorrecto.id,
      tipo: TipoPreguntaQuiz.kankuamaASignificado,
    );
  }

  /// Tipo 2: Significado en español → Seleccionar palabra correcta en Kankuama
  PreguntaQuizModel _generarPreguntaSignificadoAKankuama(Vocablo vocabloCorrecto) {
    final distractores = VocablosData.vocablos
        .where((v) =>
            v.id != vocabloCorrecto.id &&
            v.categoria == vocabloCorrecto.categoria &&
            v.palabra != vocabloCorrecto.palabra)
        .map((v) => v.palabra)
        .toList()
      ..shuffle(_random);

    final opcionesDistractoras = distractores.take(3).toList();
    while (opcionesDistractoras.length < 3) {
      opcionesDistractoras.add('--');
    }

    final todasOpciones = [vocabloCorrecto.palabra, ...opcionesDistractoras]..shuffle(_random);
    final respuestaCorrectaIndex = todasOpciones.indexOf(vocabloCorrecto.palabra);

    final enunciados = [
      '¿Cómo se dice "${vocabloCorrecto.significado}" en kankuama?',
      'Selecciona la palabra kankuama para "${vocabloCorrecto.significado}":',
      'La palabra que significa "${vocabloCorrecto.significado}" es:',
    ];
    final enunciado = (enunciados..shuffle(_random)).first;

    return PreguntaQuizModel(
      id: 'quiz_esp_${vocabloCorrecto.id}',
      enunciado: enunciado,
      opciones: todasOpciones,
      respuestaCorrectaIndex: respuestaCorrectaIndex,
      palabraId: vocabloCorrecto.id,
      tipo: TipoPreguntaQuiz.significadoAKankuama,
    );
  }

  /// Genera preguntas de quiz por categoría (modo general)
  List<PreguntaQuizModel> generarPreguntasPorCategoria(
    String categoriaId, {
    int cantidad = 10,
  }) {
    return generarPreguntas(
      cantidad: cantidad,
      categoria: categoriaId,
    );
  }

  /// Genera preguntas de quiz para palabras en recuperación
  List<PreguntaQuizModel> generarPreguntasRecuperacion({
    int cantidad = 10,
  }) {
    final vocablosRecuperacion = VocablosData.obtenerEnRecuperacion();
    if (vocablosRecuperacion.isEmpty) {
      return generarPreguntas(cantidad: cantidad);
    }

    final cantidadReal = cantidad.clamp(1, vocablosRecuperacion.length);
    final seleccionados = (vocablosRecuperacion..shuffle(_random)).take(cantidadReal).toList();

    return seleccionados
        .map((vocablo) => _generarPreguntaDesdeVocablo(vocablo))
        .toList();
  }

  /// Crea un RetoQuizModel completo
  RetoQuizModel crearReto({
    required String id,
    String? nombre,
    int cantidadPreguntas = 10,
    String? categoria,
    int? tiempoLimiteMinutos,
    bool aleatorio = true,
    int? puntosMaximos,
    int orden = 0,
    String? leccionId,
  }) {
    final preguntas = generarPreguntas(
      cantidad: cantidadPreguntas,
      categoria: categoria,
    );

    return RetoQuizModel(
      id: id,
      nombre: nombre ?? 'Reto de ${preguntas.length} preguntas',
      preguntasQuiz: preguntas,
      tiempoLimiteMinutos: tiempoLimiteMinutos,
      aleatorio: aleatorio,
      puntosMaximos: puntosMaximos,
      orden: orden,
      leccionId: leccionId,
    );
  }

  /// Crea un RetoQuiz para una lección/categoría específica
  RetoQuizModel crearRetoPorCategoria({
    required String categoriaId,
    required String leccionId,
    int cantidadPreguntas = 10,
    bool aleatorio = true,
  }) {
    final preguntas = generarPreguntasPorCategoria(
      categoriaId,
      cantidad: cantidadPreguntas,
    );

    return RetoQuizModel(
      id: 'reto_${leccionId}_${DateTime.now().millisecondsSinceEpoch}',
      nombre: 'Reto de ${preguntas.length} preguntas',
      preguntasQuiz: preguntas,
      tiempoLimiteMinutos: null,
      aleatorio: aleatorio,
      leccionId: leccionId,
    );
  }

  /// Calcula cuántas respuestas son correctas
  int calcularRespuestasCorrectas(List<PreguntaQuizModel> preguntas, List<int?> respuestasUsuario) {
    int correctas = 0;
    for (int i = 0; i < preguntas.length; i++) {
      if (i < respuestasUsuario.length && respuestasUsuario[i] != null) {
        if (preguntas[i].respuestaCorrectaIndex == respuestasUsuario[i]) {
          correctas++;
        }
      }
    }
    return correctas;
  }

  /// Modo ORIGINAL: Pregunta en español, opciones en Kankuama
  PreguntaQuizModel _generarPreguntaDesdeVocablo(Vocablo vocabloCorrecto) {
    // 50% de probabilidad de preguntar en Español o en Kankuamo
    final preguntaEnEspanol = _random.nextBool();

    // Sacar distractores de TODA la base de datos para que haya opciones válidas,
    // pero la respuesta correcta SIEMPRE es de la lección actual.
    final distractoresGlobales = VocablosData.vocablos
        .where((v) => v.id != vocabloCorrecto.id)
        .toList()
      ..shuffle(_random);

    List<String> opcionesDistractoras;
    String respuestaCorrectaTexto;
    List<String> enunciados;

    if (preguntaEnEspanol) {
      // Pregunta: Kankuamo -> Español. (Opciones en Español)
      respuestaCorrectaTexto = vocabloCorrecto.significado;
      opcionesDistractoras = distractoresGlobales.take(3).map((v) => v.significado).toList();

      enunciados = [
        '¿Qué significa "${vocabloCorrecto.palabra}" en español?',
        'Selecciona el significado de "${vocabloCorrecto.palabra}":',
      ];
    } else {
      // Pregunta: Español -> Kankuamo. (Opciones en Kankuamo)
      respuestaCorrectaTexto = vocabloCorrecto.palabra;
      opcionesDistractoras = distractoresGlobales.take(3).map((v) => v.palabra).toList();

      enunciados = [
        '¿Cómo se dice "${vocabloCorrecto.significado}" en lengua kankuama?',
        'Selecciona la traducción para "${vocabloCorrecto.significado}":',
      ];
    }

    final todasOpciones = [respuestaCorrectaTexto, ...opcionesDistractoras]..shuffle(_random);
    final respuestaCorrectaIndex = todasOpciones.indexOf(respuestaCorrectaTexto);
    final enunciado = (enunciados..shuffle(_random)).first;

    return PreguntaQuizModel(
      id: 'quiz_${vocabloCorrecto.id}_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}',
      enunciado: enunciado,
      opciones: todasOpciones,
      respuestaCorrectaIndex: respuestaCorrectaIndex,
      palabraId: vocabloCorrecto.id,
      pista: 'Recuerda la lección estudiada',
      tipo: preguntaEnEspanol ? TipoPreguntaQuiz.kankuamaASignificado : TipoPreguntaQuiz.significadoAKankuama,
    );
  }
}
