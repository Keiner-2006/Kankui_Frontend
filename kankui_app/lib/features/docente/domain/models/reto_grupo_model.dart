class RetoGrupoModel {
  final String id;
  final String retoId;
  final String grupoId;
  String? nombreReto;
  int? puntajeMaximo;
  DateTime fechaAsignacion;
  DateTime? fechaLimite;
  bool activo;
  int orden;

  RetoGrupoModel({
    required this.id,
    required this.retoId,
    required this.grupoId,
    this.nombreReto,
    this.puntajeMaximo,
    DateTime? fechaAsignacion,
    this.fechaLimite,
    this.activo = true,
    this.orden = 0,
  }) : fechaAsignacion = fechaAsignacion ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'reto_id': retoId,
        'grupo_id': grupoId,
        'nombre_reto': nombreReto,
        'puntaje_maximo': puntajeMaximo,
        'fecha_asignacion': fechaAsignacion.toIso8601String(),
        'fecha_limite': fechaLimite?.toIso8601String(),
        'activo': activo,
        'orden': orden,
      };

  factory RetoGrupoModel.fromJson(Map<String, dynamic> json) =>
      RetoGrupoModel(
        id: json['id'],
        retoId: json['reto_id'],
        grupoId: json['grupo_id'],
        nombreReto: json['nombre_reto'],
        puntajeMaximo: json['puntaje_maximo'],
        fechaAsignacion: json['fecha_asignacion'] != null
            ? DateTime.parse(json['fecha_asignacion'])
            : DateTime.now(),
        fechaLimite: json['fecha_limite'] != null
            ? DateTime.parse(json['fecha_limite'])
            : null,
        activo: json['activo'] ?? true,
        orden: json['orden'] ?? 0,
      );

  RetoGrupoModel copyWith({
    String? retoId,
    String? grupoId,
    String? nombreReto,
    int? puntajeMaximo,
    DateTime? fechaAsignacion,
    DateTime? fechaLimite,
    bool? activo,
    int? orden,
  }) {
    return RetoGrupoModel(
      id: id,
      retoId: retoId ?? this.retoId,
      grupoId: grupoId ?? this.grupoId,
      nombreReto: nombreReto ?? this.nombreReto,
      puntajeMaximo: puntajeMaximo ?? this.puntajeMaximo,
      fechaAsignacion: fechaAsignacion ?? this.fechaAsignacion,
      fechaLimite: fechaLimite ?? this.fechaLimite,
      activo: activo ?? this.activo,
      orden: orden ?? this.orden,
    );
  }
}
