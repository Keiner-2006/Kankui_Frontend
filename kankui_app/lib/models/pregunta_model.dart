class PreguntaModel {
  final String id;
  String enunciado;
  List<String> opciones;
  int respuestaCorrecta;
  String? palabraId;

  PreguntaModel({
    required this.id,
    required this.enunciado,
    List<String>? opciones,
    required this.respuestaCorrecta,
    this.palabraId,
  }) : opciones = opciones ?? [];

  // Convertir a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'enunciado': enunciado,
        'opciones': opciones,
        'respuesta_correcta': respuestaCorrecta,
        'palabra_id': palabraId,
      };

  // Factory desde JSON
  factory PreguntaModel.fromJson(Map<String, dynamic> json) =>
      PreguntaModel(
        id: json['id'],
        enunciado: json['enunciado'],
        opciones: json['opciones'] != null
            ? List<String>.from(json['opciones'])
            : [],
        respuestaCorrecta: json['respuesta_correcta'],
        palabraId: json['palabra_id'],
      );

  // copyWith (recomendado)
  PreguntaModel copyWith({
    String? enunciado,
    List<String>? opciones,
    int? respuestaCorrecta,
    String? palabraId,
  }) {
    return PreguntaModel(
      id: id,
      enunciado: enunciado ?? this.enunciado,
      opciones: opciones ?? this.opciones,
      respuestaCorrecta: respuestaCorrecta ?? this.respuestaCorrecta,
      palabraId: palabraId ?? this.palabraId,
    );
  }
}