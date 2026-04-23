class Estudiante {
  final String id;
  final String? nombre;
  final String? apellido;
 
  final String? curso;
  final int? grupo;
  final double promedio;
  final String? pin;
  final String? maestroId;
  final int xpTotal;
  final int xpHoy;
  final int rachaDias;
  final DateTime? ultimaActividad;
  final int leccionesCompletadasTotal;
  final int escaneosExitosos;
  final List<String> leccionesDesbloqueadas;
  final List<String> logrosDesbloqueados;

  Estudiante({
    required this.id,
   
    this.nombre,
    this.apellido,
    this.curso,
    this.grupo,
    this.promedio = 0,
    this.pin,
    this.maestroId,
    this.xpTotal = 0,
    this.xpHoy = 0,
    this.rachaDias = 0,
    this.ultimaActividad,
    this.leccionesCompletadasTotal = 0,
    this.escaneosExitosos = 0,
    this.leccionesDesbloqueadas = const ['leccion_1'],
    this.logrosDesbloqueados = const [],
  });

  // Convertir desde JSON (por ejemplo desde Supabase)
  factory Estudiante.fromJson(Map<String, dynamic> json) {
  return Estudiante(
    id: json['id'],
    

    // 👇 VIENEN DEL JOIN
    nombre: json['usuario']?['nombre'],
    apellido: json['usuario']?['apellido'],

    curso: json['curso'],
    grupo: json['grupo'],
    promedio: (json['promedio'] ?? 0).toDouble(),
    pin: json['pin'],
    maestroId: json['maestro_id'],
    xpTotal: json['xp_total'] ?? 0,
    xpHoy: json['xp_hoy'] ?? 0,
    rachaDias: json['racha_dias'] ?? 0,
    ultimaActividad: json['ultima_actividad'] != null
        ? DateTime.parse(json['ultima_actividad'])
        : null,
    leccionesCompletadasTotal:
        json['lecciones_completadas_total'] ?? 0,
    escaneosExitosos: json['escaneos_exitosos'] ?? 0,
    leccionesDesbloqueadas:
        List<String>.from(json['lecciones_desbloqueadas'] ?? []),
    logrosDesbloqueados:
        List<String>.from(json['logros_desbloqueados'] ?? []),
  );
}

  // Convertir a JSON (para insertar/actualizar)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
    
      'curso': curso,
      'grupo': grupo,
      'promedio': promedio,
      'pin': pin,
      'maestro_id': maestroId,
      'xp_total': xpTotal,
      'xp_hoy': xpHoy,
      'racha_dias': rachaDias,
      'ultima_actividad': ultimaActividad?.toIso8601String(),
      'lecciones_completadas_total': leccionesCompletadasTotal,
      'escaneos_exitosos': escaneosExitosos,
      'lecciones_desbloqueadas': leccionesDesbloqueadas,
      'logros_desbloqueados': logrosDesbloqueados,
    };
  }
}