/// Sistema de Progresión - Círculo de Sabiduría
/// Maneja el progreso del usuario: XP, niveles, rachas y logros
library;

class NivelSabiduria {
  final int nivel;
  final String nombre;
  final String descripcion;
  final int xpRequerido;
  final String icono;

  const NivelSabiduria({
    required this.nivel,
    required this.nombre,
    required this.descripcion,
    required this.xpRequerido,
    required this.icono,
  });
}

class Logro {
  final String id;
  final String nombre;
  final String descripcion;
  final String icono;
  final int xpRecompensa;
  final bool desbloqueado;

  const Logro({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.xpRecompensa,
    this.desbloqueado = false,
  });

  Logro copyWith({bool? desbloqueado}) {
    return Logro(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      icono: icono,
      xpRecompensa: xpRecompensa,
      desbloqueado: desbloqueado ?? this.desbloqueado,
    );
  }
}

class UserProgress {
  final int xpTotal;
  final int xpHoy;
  final int rachaDias;
  final int leccionesCompletadas;
  final int escaneoExitosos;
  final List<String> leccionesDesbloqueadas;
  final List<String> logrosDesbloqueados;
  final DateTime? ultimaActividad;

  const UserProgress({
    this.xpTotal = 0,
    this.xpHoy = 0,
    this.rachaDias = 0,
    this.leccionesCompletadas = 0,
    this.escaneoExitosos = 0,
    this.leccionesDesbloqueadas = const ['leccion_1'],
    this.logrosDesbloqueados = const [],
    this.ultimaActividad,
  });

  /// Obtener el nivel actual basado en XP
  NivelSabiduria get nivelActual {
    for (int i = nivelesSabiduria.length - 1; i >= 0; i--) {
      if (xpTotal >= nivelesSabiduria[i].xpRequerido) {
        return nivelesSabiduria[i];
      }
    }
    return nivelesSabiduria[0];
  }

  /// XP necesario para el siguiente nivel
  int get xpParaSiguienteNivel {
    final nivelIndex = nivelesSabiduria.indexOf(nivelActual);
    if (nivelIndex < nivelesSabiduria.length - 1) {
      return nivelesSabiduria[nivelIndex + 1].xpRequerido - xpTotal;
    }
    return 0;
  }

  /// Progreso hacia el siguiente nivel (0.0 - 1.0)
  double get progresoNivel {
    final nivelIndex = nivelesSabiduria.indexOf(nivelActual);
    if (nivelIndex >= nivelesSabiduria.length - 1) return 1.0;

    final xpNivelActual = nivelActual.xpRequerido;
    final xpSiguienteNivel = nivelesSabiduria[nivelIndex + 1].xpRequerido;
    final xpEnNivel = xpTotal - xpNivelActual;
    final xpNecesario = xpSiguienteNivel - xpNivelActual;

    return xpEnNivel / xpNecesario;
  }

  UserProgress copyWith({
    int? xpTotal,
    int? xpHoy,
    int? rachaDias,
    int? leccionesCompletadas,
    int? escaneoExitosos,
    List<String>? leccionesDesbloqueadas,
    List<String>? logrosDesbloqueados,
    DateTime? ultimaActividad,
  }) {
    return UserProgress(
      xpTotal: xpTotal ?? this.xpTotal,
      xpHoy: xpHoy ?? this.xpHoy,
      rachaDias: rachaDias ?? this.rachaDias,
      leccionesCompletadas: leccionesCompletadas ?? this.leccionesCompletadas,
      escaneoExitosos: escaneoExitosos ?? this.escaneoExitosos,
      leccionesDesbloqueadas:
          leccionesDesbloqueadas ?? this.leccionesDesbloqueadas,
      logrosDesbloqueados: logrosDesbloqueados ?? this.logrosDesbloqueados,
      ultimaActividad: ultimaActividad ?? this.ultimaActividad,
    );
  }
}

/// Los niveles de sabiduría (evolución del usuario)
const List<NivelSabiduria> nivelesSabiduria = [
  NivelSabiduria(
    nivel: 1,
    nombre: 'Semilla',
    descripcion:
        'El inicio del camino, todo conocimiento comienza con una semilla.',
    xpRequerido: 0,
    icono: 'semilla',
  ),
  NivelSabiduria(
    nivel: 2,
    nombre: 'Brote',
    descripcion: 'La semilla ha germinado, el conocimiento empieza a crecer.',
    xpRequerido: 100,
    icono: 'brote',
  ),
  NivelSabiduria(
    nivel: 3,
    nombre: 'Raíz',
    descripcion: 'Las raíces se fortalecen, el aprendizaje se profundiza.',
    xpRequerido: 300,
    icono: 'raiz',
  ),
  NivelSabiduria(
    nivel: 4,
    nombre: 'Tallo',
    descripcion: 'El tallo emerge firme, el conocimiento se eleva.',
    xpRequerido: 600,
    icono: 'tallo',
  ),
  NivelSabiduria(
    nivel: 5,
    nombre: 'Hoja',
    descripcion: 'Las hojas se extienden, captando la luz del saber.',
    xpRequerido: 1000,
    icono: 'hoja',
  ),
  NivelSabiduria(
    nivel: 6,
    nombre: 'Flor',
    descripcion: 'La flor se abre, el conocimiento florece.',
    xpRequerido: 1500,
    icono: 'flor',
  ),
  NivelSabiduria(
    nivel: 7,
    nombre: 'Fruto',
    descripcion: 'El fruto madura, listo para compartir su esencia.',
    xpRequerido: 2200,
    icono: 'fruto',
  ),
  NivelSabiduria(
    nivel: 8,
    nombre: 'Árbol',
    descripcion: 'Un árbol fuerte que da sombra a otros.',
    xpRequerido: 3000,
    icono: 'arbol',
  ),
  NivelSabiduria(
    nivel: 9,
    nombre: 'Guardián',
    descripcion: 'Protector del conocimiento ancestral.',
    xpRequerido: 4000,
    icono: 'guardian',
  ),
  NivelSabiduria(
    nivel: 10,
    nombre: 'Sabio',
    descripcion: 'Portador de la sabiduría de los Mayores.',
    xpRequerido: 5500,
    icono: 'sabio',
  ),
  NivelSabiduria(
    nivel: 11,
    nombre: 'Mayor',
    descripcion: 'Has alcanzado la sabiduría de un Mayor. Eres guía de otros.',
    xpRequerido: 7500,
    icono: 'mayor',
  ),
];

/// Logros disponibles
const List<Logro> logrosDisponibles = [
  Logro(
    id: 'primera_palabra',
    nombre: 'Primera Palabra',
    descripcion: 'Aprendiste tu primera palabra en Kankui',
    icono: 'estrella',
    xpRecompensa: 10,
  ),
  Logro(
    id: 'racha_3',
    nombre: 'Constancia',
    descripcion: 'Mantuviste una racha de 3 días',
    icono: 'fuego',
    xpRecompensa: 25,
  ),
  Logro(
    id: 'racha_7',
    nombre: 'Dedicación',
    descripcion: 'Mantuviste una racha de 7 días',
    icono: 'fuego',
    xpRecompensa: 50,
  ),
  Logro(
    id: 'racha_30',
    nombre: 'Guardián del Fuego',
    descripcion: 'Mantuviste una racha de 30 días',
    icono: 'fuego',
    xpRecompensa: 200,
  ),
  Logro(
    id: 'primer_escaneo',
    nombre: 'Ojo Ancestral',
    descripcion: 'Realizaste tu primer escaneo exitoso',
    icono: 'ojo',
    xpRecompensa: 20,
  ),
  Logro(
    id: 'diez_escaneos',
    nombre: 'Explorador',
    descripcion: 'Realizaste 10 escaneos exitosos',
    icono: 'ojo',
    xpRecompensa: 75,
  ),
  Logro(
    id: 'categoria_completa',
    nombre: 'Maestro de Categoría',
    descripcion: 'Completaste todos los vocablos de una categoría',
    icono: 'corona',
    xpRecompensa: 100,
  ),
  Logro(
    id: 'todas_categorias',
    nombre: 'Guardián del Kankui',
    descripcion: 'Dominaste todas las categorías',
    icono: 'sierra',
    xpRecompensa: 500,
  ),
  Logro(
    id: 'nivel_sabio',
    nombre: 'Camino del Sabio',
    descripcion: 'Alcanzaste el nivel de Sabio',
    icono: 'espiral',
    xpRecompensa: 300,
  ),
  Logro(
    id: 'nivel_mayor',
    nombre: 'Sabiduría Ancestral',
    descripcion: 'Alcanzaste el nivel de Mayor',
    icono: 'poporo',
    xpRecompensa: 500,
  ),
];
