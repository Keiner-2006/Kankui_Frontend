class GrupoModel {
  final String id;
  String nombre;
  String? grado;
  String? institucionId;
  String? maestroId;
  String? anioAcademico;
  int cantidadEstudiantes;
  bool activo;
  DateTime createdAt;

  GrupoModel({
    required this.id,
    required this.nombre,
    this.grado,
    this.institucionId,
    this.maestroId,
    this.anioAcademico,
    this.cantidadEstudiantes = 0,
    this.activo = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'grado': grado,
        'institucion_id': institucionId,
        'maestro_id': maestroId,
        'anio_academico': anioAcademico,
        'cantidad_estudiantes': cantidadEstudiantes,
        'activo': activo,
        'created_at': createdAt.toIso8601String(),
      };

  factory GrupoModel.fromJson(Map<String, dynamic> json) => GrupoModel(
        id: json['id'],
        nombre: json['nombre'],
        grado: json['grado'],
        institucionId: json['institucion_id'],
        maestroId: json['maestro_id'],
        anioAcademico: json['anio_academico'],
        cantidadEstudiantes: json['cantidad_estudiantes'] ?? 0,
        activo: json['activo'] ?? true,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : DateTime.now(),
      );

  GrupoModel copyWith({
    String? nombre,
    String? grado,
    String? institucionId,
    String? maestroId,
    String? anioAcademico,
    int? cantidadEstudiantes,
    bool? activo,
    DateTime? createdAt,
  }) {
    return GrupoModel(
      id: id,
      nombre: nombre ?? this.nombre,
      grado: grado ?? this.grado,
      institucionId: institucionId ?? this.institucionId,
      maestroId: maestroId ?? this.maestroId,
      anioAcademico: anioAcademico ?? this.anioAcademico,
      cantidadEstudiantes:
          cantidadEstudiantes ?? this.cantidadEstudiantes,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
