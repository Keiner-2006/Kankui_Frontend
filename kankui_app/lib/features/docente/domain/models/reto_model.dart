class RetoModel {
  final String id;
  String nombre;
  List<String>? preguntas;
  int? puntosMaximos;
  int orden;
  String? leccionId;
  String? grado;

  RetoModel({
    required this.id,
    required this.nombre,
    this.preguntas,
    this.puntosMaximos,
    this.orden = 0,
    this.leccionId,
    this.grado,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'preguntas': preguntas,
        'puntos_maximos': puntosMaximos,
        'orden': orden,
        'leccion_id': leccionId,
        'grado': grado,
      };

  factory RetoModel.fromJson(Map<String, dynamic> json) => RetoModel(
        id: json['id'],
        nombre: json['nombre'],
        preguntas: (json['preguntas'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
        puntosMaximos: json['puntos_maximos'],
        orden: json['orden'] ?? 0,
        leccionId: json['leccion_id'],
        grado: json['grado'],
      );

  RetoModel copyWith({
    String? nombre,
    List<String>? preguntas,
    int? puntosMaximos,
    int? orden,
    String? leccionId,
    String? grado,
  }) {
    return RetoModel(
      id: id,
      nombre: nombre ?? this.nombre,
      preguntas: preguntas ?? this.preguntas,
      puntosMaximos: puntosMaximos ?? this.puntosMaximos,
      orden: orden ?? this.orden,
      leccionId: leccionId ?? this.leccionId,
      grado: grado ?? this.grado,
    );
  }
}
