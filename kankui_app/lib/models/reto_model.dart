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
  factory RetoModel.fromJson(Map<String, dynamic> json) =>
      RetoModel(
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