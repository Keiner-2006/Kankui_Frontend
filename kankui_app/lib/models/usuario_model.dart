
 class UsuarioModel {
  final String id;
  String nombre;
  String identificacion;
  String rol;
  DateTime fechaRegistro;
  String? institucionId;

  // 🔥 NUEVOS CAMPOS DE PROGRESO
  int xpTotal;
  int xpHoy;
  int rachaDias;
  int leccionesCompletadas;
  int escaneosExitosos;
  List<String> logros;

  UsuarioModel({
    required this.id,
    required this.nombre,
    required this.identificacion,
    this.rol = 'estudiante',
    DateTime? fechaRegistro,
    this.institucionId,

    // progreso
    this.xpTotal = 0,
    this.xpHoy = 0,
    this.rachaDias = 0,
    this.leccionesCompletadas = 0,
    this.escaneosExitosos = 0,
    this.logros = const [],
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

      // progreso
      xpTotal: json['xp_total'] ?? 0,
      xpHoy: json['xp_hoy'] ?? 0,
      rachaDias: json['racha_dias'] ?? 0,
      leccionesCompletadas: json['lecciones_completadas'] ?? 0,
      escaneosExitosos: json['escaneos_exitosos'] ?? 0,
      logros: List<String>.from(json['logros'] ?? []),
    );

  // copyWith
  UsuarioModel copyWith({
    String? nombre,
    String? identificacion,
    String? rol,
    DateTime? fechaRegistro,
    String? institucionId,
    int? xpTotal,
    int? xpHoy,
    int? rachaDias,
    int? leccionesCompletadas,
    int? escaneosExitosos,
    List<String>? logros,
  }) {
    return UsuarioModel(
      id: id,
      nombre: nombre ?? this.nombre,
      identificacion: identificacion ?? this.identificacion,
      rol: rol ?? this.rol,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      institucionId: institucionId ?? this.institucionId,
      xpTotal: xpTotal ?? this.xpTotal,
      xpHoy: xpHoy ?? this.xpHoy,
      rachaDias: rachaDias ?? this.rachaDias,
      leccionesCompletadas: leccionesCompletadas ?? this.leccionesCompletadas,
      escaneosExitosos: escaneosExitosos ?? this.escaneosExitosos,
      logros: logros ?? this.logros,
    );
  }

  // 🔥 PRO: validaciones útiles
  bool get esEstudiante => rol == 'estudiante';
  bool get esMaestro => rol == 'maestro';
}