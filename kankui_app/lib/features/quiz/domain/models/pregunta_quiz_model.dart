/// Tipo de pregunta del quiz
enum TipoPreguntaQuiz {
  kankuamaASignificado,  // Muestra palabra en Kankuama, opciones son significados en español
  significadoAKankuama,  // Muestra significado en español, opciones son palabras en Kankuama
}

/// Modelo para una pregunta de tipo Quiz
/// Contiene el enunciado, opciones de respuesta y la respuesta correcta
class PreguntaQuizModel {
  final String id;
  final String enunciado; // ej: 'Esta palabra es "buenos días" en kankuama:'
  final List<String> opciones; // listado de opciones a elegir
  final int respuestaCorrectaIndex; // índice de la opción correcta (0-based)
  final String? palabraId; // id de la palabra vocablos_data relacionada
  final String? pista; // pista opcional
  final TipoPreguntaQuiz tipo; // tipo de pregunta

  const PreguntaQuizModel({
    required this.id,
    required this.enunciado,
    required this.opciones,
    required this.respuestaCorrectaIndex,
    this.palabraId,
    this.pista,
    required this.tipo,
  })  : assert(opciones.length >= 2, 'Debe haber al menos 2 opciones'),
        assert(
          respuestaCorrectaIndex >= 0 && respuestaCorrectaIndex < opciones.length,
          'El índice de respuesta correcta debe ser válido',
        );

  /// Retorna la opción (palabra kankuama o significado) que es correcta
  String get respuestaCorrecta => opciones[respuestaCorrectaIndex];

  /// Verifica si una opción seleccionada es correcta
  bool esCorrecta(int index) => index == respuestaCorrectaIndex;

  /// Convertir a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'enunciado': enunciado,
        'opciones': opciones,
        'respuesta_correcta_index': respuestaCorrectaIndex,
        'palabra_id': palabraId,
        'pista': pista,
        'tipo': tipo.index,
      };

  /// Factory desde JSON
  factory PreguntaQuizModel.fromJson(Map<String, dynamic> json) =>
      PreguntaQuizModel(
        id: json['id'],
        enunciado: json['enunciado'],
        opciones: List<String>.from(json['opciones'] ?? []),
        respuestaCorrectaIndex: json['respuesta_correcta_index'] ?? 0,
        palabraId: json['palabra_id'],
        pista: json['pista'],
        tipo: TipoPreguntaQuiz.values[json['tipo'] ?? 0],
      );

  /// copyWith para inmutabilidad
  PreguntaQuizModel copyWith({
    String? id,
    String? enunciado,
    List<String>? opciones,
    int? respuestaCorrectaIndex,
    String? palabraId,
    String? pista,
    TipoPreguntaQuiz? tipo,
  }) {
    return PreguntaQuizModel(
      id: id ?? this.id,
      enunciado: enunciado ?? this.enunciado,
      opciones: opciones ?? this.opciones,
      respuestaCorrectaIndex: respuestaCorrectaIndex ?? this.respuestaCorrectaIndex,
      palabraId: palabraId ?? this.palabraId,
      pista: pista ?? this.pista,
      tipo: tipo ?? this.tipo,
    );
  }
}
