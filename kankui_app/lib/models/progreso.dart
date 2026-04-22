class Progreso {
  final String id;
  final String usuarioId;
  final String categoriaId;
  final int leccionesCompletadas;
  final int totalLecciones;
  final String ultimaActividad;
  final int sincronizado;

  Progreso({
    required this.id,
    required this.usuarioId,
    required this.categoriaId,
    required this.leccionesCompletadas,
    required this.totalLecciones,
    required this.ultimaActividad,
    required this.sincronizado,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'categoria_id': categoriaId,
      'lecciones_completadas': leccionesCompletadas,
      'total_lecciones': totalLecciones,
      'ultima_actividad': ultimaActividad,
      'sincronizado': sincronizado,
    };
  }

  factory Progreso.fromMap(Map<String, dynamic> map) {
    return Progreso(
      id: map['id'],
      usuarioId: map['usuario_id'],
      categoriaId: map['categoria_id'],
      leccionesCompletadas: map['lecciones_completadas'],
      totalLecciones: map['total_lecciones'],
      ultimaActividad: map['ultima_actividad'],
      sincronizado: map['sincronizado'],
    );
  }
}