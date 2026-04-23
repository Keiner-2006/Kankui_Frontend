class EstudianteModel {
  // Datos Académicos y Administrativos
  final String id;
  final String usuarioId;
  String? curso;
  int? grupo;
  double promedio;
  String? pin;
  String? maestroId;

  // Datos de Gamificación y Progresión
  int xpTotal;
  int xpHoy;
  int rachaDias;
  DateTime? ultimaActividad;

  // Estadísticas de Aprendizaje
  int leccionesCompletadas;
  int escaneoExitosos;
  int vocablosAprendidos;
  List<String> leccionesDesbloqueadas;
  List<String> logrosDesbloqueados;

  EstudianteModel({
    required this.id,
    required this.usuarioId,
    this.curso,
    this.grupo,
    this.promedio = 0,
    this.pin,
    this.maestroId,
    this.xpTotal = 0,
    this.xpHoy = 0,
    this.rachaDias = 0,
    this.ultimaActividad,
    this.leccionesCompletadas = 0,
    this.escaneoExitosos = 0,
    this.vocablosAprendidos = 0,
    this.leccionesDesbloqueadas = const ['leccion_1'],
    this.logrosDesbloqueados = const [],
  });

  // Convertir a JSON (para enviar a DB)
  Map<String, dynamic> toJson() => {
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
        'lecciones_completadas': leccionesCompletadas,
        'escaneo_exitosos': escaneoExitosos,
        'vocablos_aprendidos': vocablosAprendidos,
        'lecciones_desbloqueadas': leccionesDesbloqueadas,
        'logros_desbloqueados': logrosDesbloqueados,
      };

  // Factory desde JSON (desde DB o API)
  factory EstudianteModel.fromJson(Map<String, dynamic> json) =>
      EstudianteModel(
        id: json['id'],
        usuarioId: json['usuario_id'],
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
        leccionesCompletadas: json['lecciones_completadas'] ?? 0,
        escaneoExitosos: json['escaneo_exitosos'] ?? 0,
        vocablosAprendidos: json['vocablos_aprendidos'] ?? 0,
        leccionesDesbloqueadas: List<String>.from(json['lecciones_desbloqueadas'] ?? ['leccion_1']),
        logrosDesbloqueados: List<String>.from(json['logros_desbloqueados'] ?? []),
      );
}