class UsuarioModel {
  final String id;
  String nombre;
  int identificacion;
  String rol;
  DateTime fechaRegistro;
  String? institucionId;

  UsuarioModel({
    required this.id,
    required this.nombre,
    required this.identificacion,
    this.rol = 'estudiante',
    DateTime? fechaRegistro,
    this.institucionId,
  }) : fechaRegistro = fechaRegistro ?? DateTime.now();

  // Convertir a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'identificacion': identificacion,
        'rol': rol,
        'fecha_registro': fechaRegistro.toIso8601String(),
        'institucion_id': institucionId,
      };

  // Factory desde JSON
  factory UsuarioModel.fromJson(Map<String, dynamic> json) =>
      UsuarioModel(
        id: json['id'],
        nombre: json['nombre'],
        identificacion: json['identificacion'],
        rol: json['rol'] ?? 'estudiante',
        fechaRegistro: json['fecha_registro'] != null
            ? DateTime.parse(json['fecha_registro'])
            : DateTime.now(),
        institucionId: json['institucion_id'],
      );

  // copyWith
  UsuarioModel copyWith({
    String? nombre,
    int? identificacion,
    String? rol,
    DateTime? fechaRegistro,
    String? institucionId,
  }) {
    return UsuarioModel(
      id: id,
      nombre: nombre ?? this.nombre,
      identificacion: identificacion ?? this.identificacion,
      rol: rol ?? this.rol,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      institucionId: institucionId ?? this.institucionId,
    );
  }

  // 🔥 PRO: validaciones útiles
  bool get esEstudiante => rol == 'estudiante';
  bool get esMaestro => rol == 'maestro';
}