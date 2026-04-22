class ProgresoCategoriaModel {
  final String id;
  final String usuarioId;
  final String categoriaId;
  int leccionesCompletadas;
  int totalLecciones;
  DateTime ultimaActividad;

  ProgresoCategoriaModel({
    required this.id,
    required this.usuarioId,
    required this.categoriaId,
    this.leccionesCompletadas = 0,
    this.totalLecciones = 0,
    DateTime? ultimaActividad,
  }) : ultimaActividad = ultimaActividad ?? DateTime.now();

  // Convertir a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'usuario_id': usuarioId,
        'categoria_id': categoriaId,
        'lecciones_completadas': leccionesCompletadas,
        'total_lecciones': totalLecciones,
        'ultima_actividad': ultimaActividad.toIso8601String(),
      };

  // Factory desde JSON
  factory ProgresoCategoriaModel.fromJson(Map<String, dynamic> json) =>
      ProgresoCategoriaModel(
        id: json['id'],
        usuarioId: json['usuario_id'],
        categoriaId: json['categoria_id'],
        leccionesCompletadas: json['lecciones_completadas'] ?? 0,
        totalLecciones: json['total_lecciones'] ?? 0,
        ultimaActividad: json['ultima_actividad'] != null
            ? DateTime.parse(json['ultima_actividad'])
            : DateTime.now(),
      );

  // copyWith
  ProgresoCategoriaModel copyWith({
    int? leccionesCompletadas,
    int? totalLecciones,
    DateTime? ultimaActividad,
  }) {
    return ProgresoCategoriaModel(
      id: id,
      usuarioId: usuarioId,
      categoriaId: categoriaId,
      leccionesCompletadas:
          leccionesCompletadas ?? this.leccionesCompletadas,
      totalLecciones: totalLecciones ?? this.totalLecciones,
      ultimaActividad: ultimaActividad ?? this.ultimaActividad,
    );
  }

  // 🔥 PRO: porcentaje de progreso
  double get porcentajeProgreso {
    if (totalLecciones == 0) return 0;
    return (leccionesCompletadas / totalLecciones) * 100;
  }
}