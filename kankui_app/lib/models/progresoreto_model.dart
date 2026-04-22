class ProgresoRetoModel {
  final String id;
  final String usuarioId;
  final String retoId;
  bool completado;
  int puntosObtenidos;
  DateTime? fechaCompletado;

  ProgresoRetoModel({
    required this.id,
    required this.usuarioId,
    required this.retoId,
    this.completado = false,
    this.puntosObtenidos = 0,
    this.fechaCompletado,
  });

  // Convertir a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'usuario_id': usuarioId,
        'reto_id': retoId,
        'completado': completado,
        'puntos_obtenidos': puntosObtenidos,
        'fecha_completado': fechaCompletado?.toIso8601String(),
      };

  // Factory desde JSON
  factory ProgresoRetoModel.fromJson(Map<String, dynamic> json) =>
      ProgresoRetoModel(
        id: json['id'],
        usuarioId: json['usuario_id'],
        retoId: json['reto_id'],
        completado: json['completado'] ?? false,
        puntosObtenidos: json['puntos_obtenidos'] ?? 0,
        fechaCompletado: json['fecha_completado'] != null
            ? DateTime.parse(json['fecha_completado'])
            : null,
      );

  // copyWith
  ProgresoRetoModel copyWith({
    bool? completado,
    int? puntosObtenidos,
    DateTime? fechaCompletado,
  }) {
    return ProgresoRetoModel(
      id: id,
      usuarioId: usuarioId,
      retoId: retoId,
      completado: completado ?? this.completado,
      puntosObtenidos: puntosObtenidos ?? this.puntosObtenidos,
      fechaCompletado: fechaCompletado ?? this.fechaCompletado,
    );
  }

  // 🔥 PRO: marcar como completado automáticamente
  void completar({int puntos = 0}) {
    completado = true;
    puntosObtenidos = puntos;
    fechaCompletado = DateTime.now();
  }
}