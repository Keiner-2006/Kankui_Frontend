import 'dart:convert';

// ============================================
// MODELOS DE CONTENIDO
// ============================================

class CategoriaLocal {
  final String id;
  final String nombre;
  final String? icono;
  final int totalPalabras;
  final int orden;

  CategoriaLocal({
    required this.id,
    required this.nombre,
    this.icono,
    this.totalPalabras = 0,
    this.orden = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'icono': icono,
    'total_palabras': totalPalabras,
    'orden': orden,
  };

  factory CategoriaLocal.fromMap(Map<String, dynamic> map) => CategoriaLocal(
    id: map['id'],
    nombre: map['nombre'],
    icono: map['icono'],
    totalPalabras: map['total_palabras'] ?? 0,
    orden: map['orden'] ?? 0,
  );

  factory CategoriaLocal.fromSupabase(Map<String, dynamic> map) => CategoriaLocal(
    id: map['id'],
    nombre: map['nombre'],
    icono: map['icono'],
    totalPalabras: map['total_palabras'] ?? 0,
    orden: map['orden'] ?? 0,
  );
}

class PalabraLocal {
  final String id;
  final String termino;
  final String? pronunciacion;
  final String? traduccion;
  final String? audioUrl;
  final String? categoriaId;

  PalabraLocal({
    required this.id,
    required this.termino,
    this.pronunciacion,
    this.traduccion,
    this.audioUrl,
    this.categoriaId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'termino': termino,
    'pronunciacion': pronunciacion,
    'traduccion': traduccion,
    'audio_url': audioUrl,
    'categoria_id': categoriaId,
  };

  factory PalabraLocal.fromMap(Map<String, dynamic> map) => PalabraLocal(
    id: map['id'],
    termino: map['termino'],
    pronunciacion: map['pronunciacion'],
    traduccion: map['traduccion'],
    audioUrl: map['audio_url'],
    categoriaId: map['categoria_id'],
  );

  factory PalabraLocal.fromSupabase(Map<String, dynamic> map) => PalabraLocal(
    id: map['id'],
    termino: map['termino'],
    pronunciacion: map['pronunciacion'],
    traduccion: map['traduccion'],
    audioUrl: map['audio_url'],
    categoriaId: map['categoria_id'],
  );
}

class LeccionLocal {
  final String id;
  final String titulo;
  final String? categoria;
  final List<String> palabras;
  final int orden;

  LeccionLocal({
    required this.id,
    required this.titulo,
    this.categoria,
    this.palabras = const [],
    this.orden = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'titulo': titulo,
    'categoria': categoria,
    'palabras': jsonEncode(palabras),
    'orden': orden,
  };

  factory LeccionLocal.fromMap(Map<String, dynamic> map) => LeccionLocal(
    id: map['id'],
    titulo: map['titulo'],
    categoria: map['categoria'],
    palabras: map['palabras'] != null 
        ? List<String>.from(jsonDecode(map['palabras']))
        : [],
    orden: map['orden'] ?? 0,
  );

  factory LeccionLocal.fromSupabase(Map<String, dynamic> map) => LeccionLocal(
    id: map['id'],
    titulo: map['titulo'],
    categoria: map['categoria'],
    palabras: map['palabras'] != null 
        ? List<String>.from(map['palabras'])
        : [],
    orden: map['orden'] ?? 0,
  );
}

class PreguntaLocal {
  final String id;
  final String enunciado;
  final List<String> opciones;
  final int respuestaCorrecta;
  final String? palabraId;

  PreguntaLocal({
    required this.id,
    required this.enunciado,
    this.opciones = const [],
    required this.respuestaCorrecta,
    this.palabraId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'enunciado': enunciado,
    'opciones': jsonEncode(opciones),
    'respuesta_correcta': respuestaCorrecta,
    'palabra_id': palabraId,
  };

  factory PreguntaLocal.fromMap(Map<String, dynamic> map) => PreguntaLocal(
    id: map['id'],
    enunciado: map['enunciado'],
    opciones: map['opciones'] != null 
        ? List<String>.from(jsonDecode(map['opciones']))
        : [],
    respuestaCorrecta: map['respuesta_correcta'],
    palabraId: map['palabra_id'],
  );

  factory PreguntaLocal.fromSupabase(Map<String, dynamic> map) => PreguntaLocal(
    id: map['id'],
    enunciado: map['enunciado'],
    opciones: map['opciones'] != null 
        ? List<String>.from(map['opciones'])
        : [],
    respuestaCorrecta: map['respuesta_correcta'],
    palabraId: map['palabra_id'],
  );
}

class RetoLocal {
  final String id;
  final String nombre;
  final List<String> preguntas;
  final int puntosMaximos;
  final int orden;
  final String? leccionId;

  RetoLocal({
    required this.id,
    required this.nombre,
    this.preguntas = const [],
    this.puntosMaximos = 100,
    this.orden = 0,
    this.leccionId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'preguntas': jsonEncode(preguntas),
    'puntos_maximos': puntosMaximos,
    'orden': orden,
    'leccion_id': leccionId,
  };

  factory RetoLocal.fromMap(Map<String, dynamic> map) => RetoLocal(
    id: map['id'],
    nombre: map['nombre'],
    preguntas: map['preguntas'] != null 
        ? List<String>.from(jsonDecode(map['preguntas']))
        : [],
    puntosMaximos: map['puntos_maximos'] ?? 100,
    orden: map['orden'] ?? 0,
    leccionId: map['leccion_id'],
  );

  factory RetoLocal.fromSupabase(Map<String, dynamic> map) => RetoLocal(
    id: map['id'],
    nombre: map['nombre'],
    preguntas: map['preguntas'] != null 
        ? List<String>.from(map['preguntas'])
        : [],
    puntosMaximos: map['puntos_maximos'] ?? 100,
    orden: map['orden'] ?? 0,
    leccionId: map['leccion_id'],
  );
}

// ============================================
// MODELOS DE USUARIO
// ============================================

class UsuarioLocal {
  final String id;
  final String nombre;
  final int identificacion;
  final String rol;
  final String? fechaRegistro;
  final String? institucionId;

  UsuarioLocal({
    required this.id,
    required this.nombre,
    required this.identificacion,
    this.rol = 'estudiante',
    this.fechaRegistro,
    this.institucionId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'identificacion': identificacion,
    'rol': rol,
    'fecha_registro': fechaRegistro,
    'institucion_id': institucionId,
  };

  factory UsuarioLocal.fromMap(Map<String, dynamic> map) => UsuarioLocal(
    id: map['id'],
    nombre: map['nombre'],
    identificacion: map['identificacion'],
    rol: map['rol'] ?? 'estudiante',
    fechaRegistro: map['fecha_registro'],
    institucionId: map['institucion_id'],
  );

  factory UsuarioLocal.fromSupabase(Map<String, dynamic> map) => UsuarioLocal(
    id: map['id'],
    nombre: map['nombre'],
    identificacion: map['identificacion'],
    rol: map['rol'] ?? 'estudiante',
    fechaRegistro: map['fecha_registro'],
    institucionId: map['institucion_id'],
  );
}

class EstudianteLocal {
  final String id;
  final String usuarioId;
  final String? curso;
  final int? grupo;
  final double promedio;
  final String? pin;
  final String? maestroId;
  final int xpTotal;
  final int xpHoy;
  final int rachaDias;
  final String? ultimaActividad;
  final int leccionesCompletadasTotal;
  final int escaneosExitosos;
  final List<String> leccionesDesbloqueadas;
  final List<String> logrosDesbloqueados;

  EstudianteLocal({
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
    this.leccionesCompletadasTotal = 0,
    this.escaneosExitosos = 0,
    this.leccionesDesbloqueadas = const ['leccion_1'],
    this.logrosDesbloqueados = const [],
  });

  Map<String, dynamic> toMap() => {
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
    'ultima_actividad': ultimaActividad,
    'lecciones_completadas_total': leccionesCompletadasTotal,
    'escaneos_exitosos': escaneosExitosos,
    'lecciones_desbloqueadas': jsonEncode(leccionesDesbloqueadas),
    'logros_desbloqueados': jsonEncode(logrosDesbloqueados),
  };

  factory EstudianteLocal.fromMap(Map<String, dynamic> map) => EstudianteLocal(
    id: map['id'],
    usuarioId: map['usuario_id'],
    curso: map['curso'],
    grupo: map['grupo'],
    promedio: (map['promedio'] ?? 0).toDouble(),
    pin: map['pin'],
    maestroId: map['maestro_id'],
    xpTotal: map['xp_total'] ?? 0,
    xpHoy: map['xp_hoy'] ?? 0,
    rachaDias: map['racha_dias'] ?? 0,
    ultimaActividad: map['ultima_actividad'],
    leccionesCompletadasTotal: map['lecciones_completadas_total'] ?? 0,
    escaneosExitosos: map['escaneos_exitosos'] ?? 0,
    leccionesDesbloqueadas: map['lecciones_desbloqueadas'] != null
        ? List<String>.from(jsonDecode(map['lecciones_desbloqueadas']))
        : ['leccion_1'],
    logrosDesbloqueados: map['logros_desbloqueados'] != null
        ? List<String>.from(jsonDecode(map['logros_desbloqueados']))
        : [],
  );

  factory EstudianteLocal.fromSupabase(Map<String, dynamic> map) => EstudianteLocal(
    id: map['id'],
    usuarioId: map['usuario_id'],
    curso: map['curso'],
    grupo: map['grupo'],
    promedio: (map['promedio'] ?? 0).toDouble(),
    pin: map['pin'],
    maestroId: map['maestro_id'],
    xpTotal: map['xp_total'] ?? 0,
    xpHoy: map['xp_hoy'] ?? 0,
    rachaDias: map['racha_dias'] ?? 0,
    ultimaActividad: map['ultima_actividad'],
    leccionesCompletadasTotal: map['lecciones_completadas_total'] ?? 0,
    escaneosExitosos: map['escaneos_exitosos'] ?? 0,
    leccionesDesbloqueadas: map['lecciones_desbloqueadas'] != null
        ? List<String>.from(map['lecciones_desbloqueadas'])
        : ['leccion_1'],
    logrosDesbloqueados: map['logros_desbloqueados'] != null
        ? List<String>.from(map['logros_desbloqueados'])
        : [],
  );

  /// Crear copia con cambios
  EstudianteLocal copyWith({
    int? xpTotal,
    int? xpHoy,
    int? rachaDias,
    String? ultimaActividad,
    int? leccionesCompletadasTotal,
    int? escaneosExitosos,
    List<String>? leccionesDesbloqueadas,
    List<String>? logrosDesbloqueados,
  }) {
    return EstudianteLocal(
      id: id,
      usuarioId: usuarioId,
      curso: curso,
      grupo: grupo,
      promedio: promedio,
      pin: pin,
      maestroId: maestroId,
      xpTotal: xpTotal ?? this.xpTotal,
      xpHoy: xpHoy ?? this.xpHoy,
      rachaDias: rachaDias ?? this.rachaDias,
      ultimaActividad: ultimaActividad ?? this.ultimaActividad,
      leccionesCompletadasTotal: leccionesCompletadasTotal ?? this.leccionesCompletadasTotal,
      escaneosExitosos: escaneosExitosos ?? this.escaneosExitosos,
      leccionesDesbloqueadas: leccionesDesbloqueadas ?? this.leccionesDesbloqueadas,
      logrosDesbloqueados: logrosDesbloqueados ?? this.logrosDesbloqueados,
    );
  }
}

// ============================================
// MODELOS DE PROGRESO
// ============================================

class ProgresoCategoriaLocal {
  final String id;
  final String usuarioId;
  final String categoriaId;
  final int leccionesCompletadas;
  final int totalLecciones;
  final String? ultimaActividad;
  final bool synced;

  ProgresoCategoriaLocal({
    required this.id,
    required this.usuarioId,
    required this.categoriaId,
    this.leccionesCompletadas = 0,
    this.totalLecciones = 0,
    this.ultimaActividad,
    this.synced = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'usuario_id': usuarioId,
    'categoria_id': categoriaId,
    'lecciones_completadas': leccionesCompletadas,
    'total_lecciones': totalLecciones,
    'ultima_actividad': ultimaActividad,
    'synced': synced ? 1 : 0,
  };

  /// Para enviar a Supabase (sin campo synced)
  Map<String, dynamic> toSupabase() => {
    'id': id,
    'usuario_id': usuarioId,
    'categoria_id': categoriaId,
    'lecciones_completadas': leccionesCompletadas,
    'total_lecciones': totalLecciones,
    'ultima_actividad': ultimaActividad,
  };

  factory ProgresoCategoriaLocal.fromMap(Map<String, dynamic> map) => ProgresoCategoriaLocal(
    id: map['id'],
    usuarioId: map['usuario_id'],
    categoriaId: map['categoria_id'],
    leccionesCompletadas: map['lecciones_completadas'] ?? 0,
    totalLecciones: map['total_lecciones'] ?? 0,
    ultimaActividad: map['ultima_actividad'],
    synced: map['synced'] == 1,
  );

  factory ProgresoCategoriaLocal.fromSupabase(Map<String, dynamic> map) => ProgresoCategoriaLocal(
    id: map['id'],
    usuarioId: map['usuario_id'],
    categoriaId: map['categoria_id'],
    leccionesCompletadas: map['lecciones_completadas'] ?? 0,
    totalLecciones: map['total_lecciones'] ?? 0,
    ultimaActividad: map['ultima_actividad'],
    synced: true, // Si viene de Supabase, ya esta sincronizado
  );
}

class ProgresoRetoLocal {
  final String id;
  final String usuarioId;
  final String retoId;
  final bool completado;
  final int puntosObtenidos;
  final String? fechaCompletado;
  final bool synced;

  ProgresoRetoLocal({
    required this.id,
    required this.usuarioId,
    required this.retoId,
    this.completado = false,
    this.puntosObtenidos = 0,
    this.fechaCompletado,
    this.synced = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'usuario_id': usuarioId,
    'reto_id': retoId,
    'completado': completado ? 1 : 0,
    'puntos_obtenidos': puntosObtenidos,
    'fecha_completado': fechaCompletado,
    'synced': synced ? 1 : 0,
  };

  Map<String, dynamic> toSupabase() => {
    'id': id,
    'usuario_id': usuarioId,
    'reto_id': retoId,
    'completado': completado,
    'puntos_obtenidos': puntosObtenidos,
    'fecha_completado': fechaCompletado,
  };

  factory ProgresoRetoLocal.fromMap(Map<String, dynamic> map) => ProgresoRetoLocal(
    id: map['id'],
    usuarioId: map['usuario_id'],
    retoId: map['reto_id'],
    completado: map['completado'] == 1,
    puntosObtenidos: map['puntos_obtenidos'] ?? 0,
    fechaCompletado: map['fecha_completado'],
    synced: map['synced'] == 1,
  );

  factory ProgresoRetoLocal.fromSupabase(Map<String, dynamic> map) => ProgresoRetoLocal(
    id: map['id'],
    usuarioId: map['usuario_id'],
    retoId: map['reto_id'],
    completado: map['completado'] ?? false,
    puntosObtenidos: map['puntos_obtenidos'] ?? 0,
    fechaCompletado: map['fecha_completado'],
    synced: true,
  );
}

class ResultadoQuizLocal {
  final String id;
  final String usuarioId;
  final String retoId;
  final List<int> respuestas;
  final int puntaje;
  final String? fecha;
  final bool synced;

  ResultadoQuizLocal({
    required this.id,
    required this.usuarioId,
    required this.retoId,
    this.respuestas = const [],
    this.puntaje = 0,
    this.fecha,
    this.synced = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'usuario_id': usuarioId,
    'reto_id': retoId,
    'respuestas': jsonEncode(respuestas),
    'puntaje': puntaje,
    'fecha': fecha,
    'synced': synced ? 1 : 0,
  };

  Map<String, dynamic> toSupabase() => {
    'id': id,
    'usuario_id': usuarioId,
    'reto_id': retoId,
    'respuestas': respuestas,
    'puntaje': puntaje,
    'fecha': fecha,
  };

  factory ResultadoQuizLocal.fromMap(Map<String, dynamic> map) => ResultadoQuizLocal(
    id: map['id'],
    usuarioId: map['usuario_id'],
    retoId: map['reto_id'],
    respuestas: map['respuestas'] != null
        ? List<int>.from(jsonDecode(map['respuestas']))
        : [],
    puntaje: map['puntaje'] ?? 0,
    fecha: map['fecha'],
    synced: map['synced'] == 1,
  );

  factory ResultadoQuizLocal.fromSupabase(Map<String, dynamic> map) => ResultadoQuizLocal(
    id: map['id'],
    usuarioId: map['usuario_id'],
    retoId: map['reto_id'],
    respuestas: map['respuestas'] != null
        ? List<int>.from(map['respuestas'])
        : [],
    puntaje: map['puntaje'] ?? 0,
    fecha: map['fecha'],
    synced: true,
  );
}

// ============================================
// METADATOS DE SYNC
// ============================================

class SyncMetadata {
  final String tabla;
  final String? ultimaSync;
  final int version;

  SyncMetadata({
    required this.tabla,
    this.ultimaSync,
    this.version = 0,
  });

  Map<String, dynamic> toMap() => {
    'tabla': tabla,
    'ultima_sync': ultimaSync,
    'version': version,
  };

  factory SyncMetadata.fromMap(Map<String, dynamic> map) => SyncMetadata(
    tabla: map['tabla'],
    ultimaSync: map['ultima_sync'],
    version: map['version'] ?? 0,
  );
}