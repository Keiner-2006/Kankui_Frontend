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

  // Campos adicionales de Keiner
  final String? usuarioId;
  final int leccionesCompletadas;
  final int escaneoExitosos;
  final int vocablosAprendidos;

  // Identificación del usuario (join con tabla usuario)
  final int identificacion;

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
    // Inicialización de campos de Keiner
    this.usuarioId,
    this.leccionesCompletadas = 0,
    this.escaneoExitosos = 0,
    this.vocablosAprendidos = 0,
    this.identificacion = 0,
  });

  // Factory unificado
  factory Estudiante.fromJson(Map<String, dynamic> json) {
    final usuario = json['usuario'];
    return Estudiante(
      id: json['id'],
      usuarioId: json['usuario_id'],
      nombre: usuario != null ? usuario['nombre'] : json['nombre'],
      apellido: usuario != null ? usuario['apellido'] : json['apellido'],
      curso: json['curso'],
      grupo: json['grupo'],
      promedio: (json['promedio'] ?? 0).toDouble(),
      pin: json['pin'],
      maestroId: json['maestro_id'],
      xpTotal: json['xp_total'] ?? 0,
      xpHoy: json['xp_hoy'] ?? 0,
      rachaDias: json['racha_dias'] ?? 0,
      ultimaActividad: json['ultima_actividad'] != null
          ? DateTime.tryParse(json['ultima_actividad'])
          : null,
      leccionesCompletadasTotal: json['lecciones_completadas_total'] ?? 0,
      leccionesCompletadas: json['lecciones_completadas_total'] ?? 0,
      escaneosExitosos: json['escaneos_exitosos'] ?? 0,
      escaneoExitosos: json['escaneos_exitosos'] ?? 0,
      vocablosAprendidos: json['vocablosAprendidos'] ?? 0,
      leccionesDesbloqueadas:
          List<String>.from(json['lecciones_desbloqueadas'] ?? ['leccion_1']),
      logrosDesbloqueados:
          List<String>.from(json['logros_desbloqueados'] ?? []),
      // Extraer identificación del join con usuario
      identificacion:
          usuario != null ? (usuario['identificacion'] ?? 0) as int : 0,
    );
  }

  // ToJson unificado
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
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
      'vocablosAprendidos': vocablosAprendidos,
    };
  }
}

// Alias para mantener compatibilidad con el código de Keiner
typedef EstudianteModel = Estudiante;
