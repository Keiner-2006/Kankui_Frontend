class QuizModel {
  final String id;
  String? usuarioId;
  String? maestroId;
  String? retoId;
  List<String> preguntas;
  DateTime fecha;

  QuizModel({
    required this.id,
    this.usuarioId,
    this.maestroId,
    this.retoId,
    List<String>? preguntas,
    DateTime? fecha,
  })  : preguntas = preguntas ?? [],
        fecha = fecha ?? DateTime.now();

  // Convertir a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'usuario_id': usuarioId,
        'maestro_id': maestroId,
        'reto_id': retoId,
        'preguntas': preguntas,
        'fecha': fecha.toIso8601String(),
      };

  // Factory desde JSON
  factory QuizModel.fromJson(Map<String, dynamic> json) =>
      QuizModel(
        id: json['id'],
        usuarioId: json['usuario_id'],
        maestroId: json['maestro_id'],
        retoId: json['reto_id'],
        preguntas: json['preguntas'] != null
            ? List<String>.from(json['preguntas'])
            : [],
        fecha: json['fecha'] != null
            ? DateTime.parse(json['fecha'])
            : DateTime.now(),
      );

  // copyWith
  QuizModel copyWith({
    String? usuarioId,
    String? maestroId,
    String? retoId,
    List<String>? preguntas,
    DateTime? fecha,
  }) {
    return QuizModel(
      id: id,
      usuarioId: usuarioId ?? this.usuarioId,
      maestroId: maestroId ?? this.maestroId,
      retoId: retoId ?? this.retoId,
      preguntas: preguntas ?? this.preguntas,
      fecha: fecha ?? this.fecha,
    );
  }
}