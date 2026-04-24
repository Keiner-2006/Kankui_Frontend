import 'pregunta_quiz_model.dart';

class RetoModel {
  final String id;
  String nombre;
  List<String> preguntas;
  int puntosMaximos;
  int orden;
  String? leccionId;

  RetoModel({
    required this.id,
    required this.nombre,
    List<String>? preguntas,
    this.puntosMaximos = 100,
    this.orden = 0,
    this.leccionId,
  }) : preguntas = preguntas ?? [];

  // Convertir a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'preguntas': preguntas,
        'puntos_maximos': puntosMaximos,
        'orden': orden,
        'leccion_id': leccionId,
      };

  // Factory desde JSON
  factory RetoModel.fromJson(Map<String, dynamic> json) => RetoModel(
        id: json['id'],
        nombre: json['nombre'],
        preguntas: json['preguntas'] != null
            ? List<String>.from(json['preguntas'])
            : [],
        puntosMaximos: json['puntos_maximos'] ?? 100,
        orden: json['orden'] ?? 0,
        leccionId: json['leccion_id'],
      );

  // copyWith
  RetoModel copyWith({
    String? nombre,
    List<String>? preguntas,
    int? puntosMaximos,
    int? orden,
    String? leccionId,
  }) {
    return RetoModel(
      id: id,
      nombre: nombre ?? this.nombre,
      preguntas: preguntas ?? this.preguntas,
      puntosMaximos: puntosMaximos ?? this.puntosMaximos,
      orden: orden ?? this.orden,
      leccionId: leccionId ?? this.leccionId,
    );
  }

  // 🔥 PRO: calcular porcentaje de puntaje
  double calcularPorcentaje(int puntajeObtenido) {
    if (puntosMaximos == 0) return 0;
    return (puntajeObtenido / puntosMaximos) * 100;
  }
}

/// Modelo para un Reto de tipo Quiz (preguntas de opción múltiple)
/// Extiende RetoModel para mantener compatibilidad, pero usa preguntas tipo PreguntaQuizModel
class RetoQuizModel extends RetoModel {
  final List<PreguntaQuizModel> preguntasQuiz;
  final int? tiempoLimiteMinutos;
  final bool aleatorio;

  RetoQuizModel({
    required String id,
    String? nombre,
    required this.preguntasQuiz,
    this.tiempoLimiteMinutos,
    this.aleatorio = false,
    int? puntosMaximos,
    int orden = 0,
    String? leccionId,
  }) : super(
          id: id,
          nombre: nombre ?? 'Reto Quiz (${preguntasQuiz.length} preguntas)',
          preguntas: const [],
          puntosMaximos: puntosMaximos ?? (preguntasQuiz.length * 10),
          orden: orden,
          leccionId: leccionId,
        );

  @override
  int get puntosMaximos => super.puntosMaximos > 0
      ? super.puntosMaximos
      : (preguntasQuiz.length * 10);

  int calcularPuntaje(List<int> respuestasUsuario) {
    int correctas = 0;
    for (int i = 0;
        i < respuestasUsuario.length && i < preguntasQuiz.length;
        i++) {
      if (preguntasQuiz[i].esCorrecta(respuestasUsuario[i])) {
        correctas++;
      }
    }
    return correctas * 10;
  }

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      'preguntas_quiz': preguntasQuiz.map((p) => p.toJson()).toList(),
      'tiempo_limite_minutos': tiempoLimiteMinutos,
      'aleatorio': aleatorio,
    });

  factory RetoQuizModel.fromJson(Map<String, dynamic> json) {
    return RetoQuizModel(
      id: json['id'],
      nombre: json['nombre'],
      preguntasQuiz: (json['preguntas_quiz'] as List<dynamic>? ?? [])
          .map((p) => PreguntaQuizModel.fromJson(p))
          .toList(),
      tiempoLimiteMinutos: json['tiempo_limite_minutos'],
      aleatorio: json['aleatorio'] ?? false,
      puntosMaximos: json['puntos_maximos'],
      orden: json['orden'] ?? 0,
      leccionId: json['leccion_id'],
    );
  }

  @override
  RetoModel copyWith({
    String? nombre,
    List<String>? preguntas,
    int? puntosMaximos,
    int? orden,
    String? leccionId,
  }) {
    return RetoQuizModel(
      id: id,
      nombre: nombre ?? this.nombre,
      preguntasQuiz: preguntasQuiz,
      tiempoLimiteMinutos: tiempoLimiteMinutos,
      aleatorio: aleatorio,
      puntosMaximos: puntosMaximos ?? this.puntosMaximos,
      orden: orden ?? this.orden,
      leccionId: leccionId ?? this.leccionId,
    );
  }

  RetoQuizModel copyWithQuiz({
    String? nombre,
    List<PreguntaQuizModel>? preguntasQuiz,
    int? tiempoLimiteMinutos,
    bool? aleatorio,
    int? puntosMaximos,
    int? orden,
    String? leccionId,
  }) {
    return RetoQuizModel(
      id: id,
      nombre: nombre ?? this.nombre,
      preguntasQuiz: preguntasQuiz ?? this.preguntasQuiz,
      tiempoLimiteMinutos: tiempoLimiteMinutos ?? this.tiempoLimiteMinutos,
      aleatorio: aleatorio ?? this.aleatorio,
      puntosMaximos: puntosMaximos ?? this.puntosMaximos,
      orden: orden ?? this.orden,
      leccionId: leccionId ?? this.leccionId,
    );
  }
}
