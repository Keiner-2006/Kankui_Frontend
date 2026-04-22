class ResultadoQuizModel {
  final String id;
  String? usuarioId;
  String? retoId;
  List<int> respuestas;
  int puntaje;
  DateTime fecha;

  ResultadoQuizModel({
    required this.id,
    this.usuarioId,
    this.retoId,
    List<int>? respuestas,
    this.puntaje = 0,
    DateTime? fecha,
  })  : respuestas = respuestas ?? [],
        fecha = fecha ?? DateTime.now();

  // Convertir a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'usuario_id': usuarioId,
        'reto_id': retoId,
        'respuestas': respuestas,
        'puntaje': puntaje,
        'fecha': fecha.toIso8601String(),
      };

  // Factory desde JSON
  factory ResultadoQuizModel.fromJson(Map<String, dynamic> json) =>
      ResultadoQuizModel(
        id: json['id'],
        usuarioId: json['usuario_id'],
        retoId: json['reto_id'],
        respuestas: json['respuestas'] != null
            ? List<int>.from(json['respuestas'])
            : [],
        puntaje: json['puntaje'] ?? 0,
        fecha: json['fecha'] != null
            ? DateTime.parse(json['fecha'])
            : DateTime.now(),
      );

  // copyWith
  ResultadoQuizModel copyWith({
    String? usuarioId,
    String? retoId,
    List<int>? respuestas,
    int? puntaje,
    DateTime? fecha,
  }) {
    return ResultadoQuizModel(
      id: id,
      usuarioId: usuarioId ?? this.usuarioId,
      retoId: retoId ?? this.retoId,
      respuestas: respuestas ?? this.respuestas,
      puntaje: puntaje ?? this.puntaje,
      fecha: fecha ?? this.fecha,
    );
  }

  // 🔥 PRO: calcular puntaje automáticamente
  void calcularPuntaje(List<int> respuestasCorrectas) {
    int score = 0;

    for (int i = 0; i < respuestas.length; i++) {
      if (i < respuestasCorrectas.length &&
          respuestas[i] == respuestasCorrectas[i]) {
        score++;
      }
    }

    puntaje = score;
  }
}