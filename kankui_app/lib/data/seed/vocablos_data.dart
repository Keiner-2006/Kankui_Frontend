/// Datos de los vocablos Kankui (Lengua Kankuamo)
/// Fuente: Mayores y Cabildo Kankuamo
///
/// Cada vocablo incluye información lingüística y cultural
library;

class Vocablo {
  final String id;
  final String palabra;
  final String fonetica;
  final String significado;
  final String categoria;
  final String? descripcionCultural;
  final String? audioPath;
  final String? imagePath;
  final bool enRecuperacion; // Palabras con "certeza baja"
  final int nivelDificultad; // 1-5

  const Vocablo({
    required this.id,
    required this.palabra,
    required this.fonetica,
    required this.significado,
    required this.categoria,
    this.descripcionCultural,
    this.audioPath,
    this.imagePath,
    this.enRecuperacion = false,
    this.nivelDificultad = 1,
  });
}

class CategoriaVocablo {
  final String id;
  final String nombre;
  final String descripcion;
  final String icono;
  final int orden;

  const CategoriaVocablo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.orden,
  });
}

/// Categorías de vocablos
class VocablosData {
  static const List<CategoriaVocablo> categorias = [
    CategoriaVocablo(
      id: 'saludos',
      nombre: 'Saludos',
      descripcion: 'Formas de saludo y cortesía en Kankui',
      icono: 'espiral',
      orden: 1,
    ),
    CategoriaVocablo(
      id: 'familia',
      nombre: 'Familia',
      descripcion: 'Términos para miembros de la familia',
      icono: 'circulo',
      orden: 2,
    ),
    CategoriaVocablo(
      id: 'naturaleza',
      nombre: 'Naturaleza',
      descripcion: 'Elementos de la Sierra Nevada',
      icono: 'sierra',
      orden: 3,
    ),
    CategoriaVocablo(
      id: 'objetos_sagrados',
      nombre: 'Objetos Sagrados',
      descripcion: 'Elementos rituales y culturales',
      icono: 'poporo',
      orden: 4,
    ),
    CategoriaVocablo(
      id: 'numeros',
      nombre: 'Números',
      descripcion: 'Sistema numérico Kankuamo',
      icono: 'tejido',
      orden: 5,
    ),
    CategoriaVocablo(
      id: 'colores',
      nombre: 'Colores',
      descripcion: 'Colores en lengua Kankui',
      icono: 'mochila',
      orden: 6,
    ),
    CategoriaVocablo(
      id: 'animales',
      nombre: 'Animales',
      descripcion: 'Fauna de la Sierra Nevada',
      icono: 'hoja',
      orden: 7,
    ),
    CategoriaVocablo(
      id: 'plantas',
      nombre: 'Plantas',
      descripcion: 'Flora y plantas medicinales',
      icono: 'hoja',
      orden: 8,
    ),
  ];

  /// Los 43 vocablos iniciales (datos de ejemplo simulados)
  static const List<Vocablo> vocablos = [
    // === SALUDOS ===
    Vocablo(
      id: 'v001',
      palabra: 'Eyuama',
      fonetica: 'e-yu-a-ma',
      significado: 'Buenos días',
      categoria: 'saludos',
      descripcionCultural:
          'Saludo tradicional usado al amanecer, cuando el sol bendice la Sierra.',
      nivelDificultad: 1,
    ),
    Vocablo(
      id: 'v002',
      palabra: 'Kankui',
      fonetica: 'kan-kui',
      significado: 'Lengua / Palabra',
      categoria: 'saludos',
      descripcionCultural: 'Nombre de la lengua ancestral del pueblo Kankuamo.',
      nivelDificultad: 1,
    ),
    Vocablo(
      id: 'v003',
      palabra: 'Sewá',
      fonetica: 'se-wá',
      significado: 'Gracias',
      categoria: 'saludos',
      descripcionCultural: 'Expresión de gratitud y reconocimiento al otro.',
      nivelDificultad: 1,
    ),
    Vocablo(
      id: 'v004',
      palabra: 'Zhigoneshi',
      fonetica: 'shi-go-ne-shi',
      significado: 'Hermano menor',
      categoria: 'saludos',
      descripcionCultural:
          'Forma respetuosa de referirse a los no indígenas, reconociéndolos como hermanos.',
      nivelDificultad: 2,
    ),

    // === FAMILIA ===
    Vocablo(
      id: 'v005',
      palabra: 'Nana',
      fonetica: 'na-na',
      significado: 'Madre',
      categoria: 'familia',
      descripcionCultural: 'La madre, fuente de vida y protección.',
      nivelDificultad: 1,
    ),
    Vocablo(
      id: 'v006',
      palabra: 'Tata',
      fonetica: 'ta-ta',
      significado: 'Padre',
      categoria: 'familia',
      descripcionCultural: 'El padre, guía y proveedor de la familia.',
      nivelDificultad: 1,
    ),
    Vocablo(
      id: 'v007',
      palabra: 'Mamu',
      fonetica: 'ma-mu',
      significado: 'Mayor / Sabio',
      categoria: 'familia',
      descripcionCultural:
          'Líder espiritual y guardián del conocimiento ancestral.',
      nivelDificultad: 1,
    ),
    Vocablo(
      id: 'v008',
      palabra: 'Saga',
      fonetica: 'sa-ga',
      significado: 'Mujer Sabia',
      categoria: 'familia',
      descripcionCultural: 'Mujer con conocimiento espiritual y medicinal.',
      nivelDificultad: 2,
    ),
    Vocablo(
      id: 'v009',
      palabra: 'Maku',
      fonetica: 'ma-ku',
      significado: 'Abuelo',
      categoria: 'familia',
      descripcionCultural: 'Ancestro masculino, fuente de sabiduría.',
      nivelDificultad: 1,
      enRecuperacion: true,
    ),

    // === NATURALEZA ===
    Vocablo(
      id: 'v010',
      palabra: 'Ñi',
      fonetica: 'ñi',
      significado: 'Agua',
      categoria: 'naturaleza',
      descripcionCultural:
          'Elemento sagrado, fuente de vida que baja de la Sierra.',
      nivelDificultad: 1,
    ),
    Vocablo(
      id: 'v011',
      palabra: 'Kunsamunu',
      fonetica: 'kun-sa-mu-nu',
      significado: 'Sierra Nevada',
      categoria: 'naturaleza',
      descripcionCultural:
          'El corazón del mundo, territorio sagrado de los cuatro pueblos.',
      nivelDificultad: 3,
    ),
    Vocablo(
      id: 'v012',
      palabra: 'Yuí',
      fonetica: 'yu-í',
      significado: 'Sol',
      categoria: 'naturaleza',
      descripcionCultural: 'Padre Sol, dador de energía y vida.',
      nivelDificultad: 1,
    ),
    Vocablo(
      id: 'v013',
      palabra: 'Ati',
      fonetica: 'a-ti',
      significado: 'Luna',
      categoria: 'naturaleza',
      descripcionCultural: 'Madre Luna, guardiana de los ciclos y las mujeres.',
      nivelDificultad: 1,
    ),
    Vocablo(
      id: 'v014',
      palabra: 'Kashí',
      fonetica: 'ka-shí',
      significado: 'Piedra',
      categoria: 'naturaleza',
      descripcionCultural:
          'Memoria de la tierra, guardiana de historias ancestrales.',
      nivelDificultad: 2,
    ),
    Vocablo(
      id: 'v015',
      palabra: 'Seykuín',
      fonetica: 'sey-ku-ín',
      significado: 'Montaña',
      categoria: 'naturaleza',
      descripcionCultural: 'Cuerpo de la Madre Tierra.',
      nivelDificultad: 2,
      enRecuperacion: true,
    ),

    // === OBJETOS SAGRADOS ===
    Vocablo(
      id: 'v016',
      palabra: 'Tutú',
      fonetica: 'tu-tú',
      significado: 'Mochila',
      categoria: 'objetos_sagrados',
      descripcionCultural:
          'Símbolo del útero de la Madre Tierra. En su tejido se guarda el pensamiento.',
      nivelDificultad: 1,
    ),
    Vocablo(
      id: 'v017',
      palabra: 'Zhátukua',
      fonetica: 'shá-tu-kua',
      significado: 'Poporo',
      categoria: 'objetos_sagrados',
      descripcionCultural:
          'Calabaza sagrada usada para el poporeo, práctica de meditación y conexión espiritual.',
      nivelDificultad: 2,
    ),
    Vocablo(
      id: 'v018',
      palabra: 'Ayo',
      fonetica: 'a-yo',
      significado: 'Hoja de coca',
      categoria: 'objetos_sagrados',
      descripcionCultural:
          'Planta sagrada usada para la comunicación con los ancestros.',
      nivelDificultad: 1,
    ),
    Vocablo(
      id: 'v019',
      palabra: 'Kankurua',
      fonetica: 'kan-ku-rua',
      significado: 'Casa ceremonial',
      categoria: 'objetos_sagrados',
      descripcionCultural:
          'Templo tradicional de forma cónica, centro de reunión y ceremonia.',
      nivelDificultad: 2,
    ),

    // === NÚMEROS ===
    Vocablo(
      id: 'v020',
      palabra: 'Ingui',
      fonetica: 'in-gui',
      significado: 'Uno',
      categoria: 'numeros',
      descripcionCultural: 'El principio, la unidad.',
      nivelDificultad: 1,
    ),
    Vocablo(
      id: 'v021',
      palabra: 'Muza',
      fonetica: 'mu-za',
      significado: 'Dos',
      categoria: 'numeros',
      descripcionCultural: 'La dualidad, complemento.',
      nivelDificultad: 1,
    ),
    Vocablo(
      id: 'v022',
      palabra: 'Mauna',
      fonetica: 'mau-na',
      significado: 'Tres',
      categoria: 'numeros',
      descripcionCultural: 'El equilibrio de los tres mundos.',
      nivelDificultad: 1,
    ),
    Vocablo(
      id: 'v023',
      palabra: 'Makui',
      fonetica: 'ma-kui',
      significado: 'Cuatro',
      categoria: 'numeros',
      descripcionCultural:
          'Los cuatro puntos cardinales, los cuatro pueblos de la Sierra.',
      nivelDificultad: 1,
    ),
    Vocablo(
      id: 'v024',
      palabra: 'Atui',
      fonetica: 'a-tui',
      significado: 'Cinco',
      categoria: 'numeros',
      descripcionCultural: 'Los cinco dedos de la mano.',
      nivelDificultad: 1,
      enRecuperacion: true,
    ),

    // === COLORES ===
    Vocablo(
      id: 'v025',
      palabra: 'Gunama',
      fonetica: 'gu-na-ma',
      significado: 'Negro',
      categoria: 'colores',
      descripcionCultural: 'Color de la noche y la tierra fértil.',
      nivelDificultad: 2,
    ),
    Vocablo(
      id: 'v026',
      palabra: 'Muna',
      fonetica: 'mu-na',
      significado: 'Blanco',
      categoria: 'colores',
      descripcionCultural: 'Color de los nevados y la pureza.',
      nivelDificultad: 2,
    ),
    Vocablo(
      id: 'v027',
      palabra: 'Suí',
      fonetica: 'su-í',
      significado: 'Rojo',
      categoria: 'colores',
      descripcionCultural: 'Color de la sangre y la vida.',
      nivelDificultad: 2,
    ),
    Vocablo(
      id: 'v028',
      palabra: 'Zhey',
      fonetica: 'shey',
      significado: 'Amarillo',
      categoria: 'colores',
      descripcionCultural: 'Color del sol y la sabiduría.',
      nivelDificultad: 2,
      enRecuperacion: true,
    ),

    // === ANIMALES ===
    Vocablo(
      id: 'v029',
      palabra: 'Nama',
      fonetica: 'na-ma',
      significado: 'Jaguar',
      categoria: 'animales',
      descripcionCultural:
          'Guardián de la selva y símbolo de poder espiritual.',
      nivelDificultad: 2,
    ),
    Vocablo(
      id: 'v030',
      palabra: 'Unguma',
      fonetica: 'un-gu-ma',
      significado: 'Cóndor',
      categoria: 'animales',
      descripcionCultural: 'Mensajero entre el mundo de arriba y la tierra.',
      nivelDificultad: 2,
    ),
    Vocablo(
      id: 'v031',
      palabra: 'Seyneyka',
      fonetica: 'sey-ney-ka',
      significado: 'Serpiente',
      categoria: 'animales',
      descripcionCultural: 'Guardiana del agua y símbolo de transformación.',
      nivelDificultad: 3,
    ),
    Vocablo(
      id: 'v032',
      palabra: 'Misi',
      fonetica: 'mi-si',
      significado: 'Colibrí',
      categoria: 'animales',
      descripcionCultural: 'Mensajero de los espíritus y polinizador sagrado.',
      nivelDificultad: 1,
    ),
    Vocablo(
      id: 'v033',
      palabra: 'Gunkanu',
      fonetica: 'gun-ka-nu',
      significado: 'Mono',
      categoria: 'animales',
      descripcionCultural: 'Guardián de los bosques de niebla.',
      nivelDificultad: 2,
      enRecuperacion: true,
    ),

    // === PLANTAS ===
    Vocablo(
      id: 'v034',
      palabra: 'Guanga',
      fonetica: 'guan-ga',
      significado: 'Frailejón',
      categoria: 'plantas',
      descripcionCultural: 'Planta sagrada del páramo, guardiana del agua.',
      nivelDificultad: 2,
    ),
    Vocablo(
      id: 'v035',
      palabra: 'Chimía',
      fonetica: 'chi-mí-a',
      significado: 'Tabaco',
      categoria: 'plantas',
      descripcionCultural: 'Planta de limpieza espiritual y ofrenda.',
      nivelDificultad: 2,
    ),
    Vocablo(
      id: 'v036',
      palabra: 'Gunsey',
      fonetica: 'gun-sey',
      significado: 'Maíz',
      categoria: 'plantas',
      descripcionCultural: 'Alimento sagrado, regalo de la Madre Tierra.',
      nivelDificultad: 2,
    ),
    Vocablo(
      id: 'v037',
      palabra: 'Zhikaka',
      fonetica: 'shi-ka-ka',
      significado: 'Cacao',
      categoria: 'plantas',
      descripcionCultural: 'Fruto sagrado usado en ceremonias.',
      nivelDificultad: 2,
      enRecuperacion: true,
    ),

    // === MÁS VOCABULARIO ===
    Vocablo(
      id: 'v038',
      palabra: 'Gunámu',
      fonetica: 'gu-ná-mu',
      significado: 'Tierra',
      categoria: 'naturaleza',
      descripcionCultural: 'La Madre Tierra, origen de todo.',
      nivelDificultad: 2,
    ),
    Vocablo(
      id: 'v039',
      palabra: 'Zhigala',
      fonetica: 'shi-ga-la',
      significado: 'Fuego',
      categoria: 'naturaleza',
      descripcionCultural: 'Elemento de purificación y transformación.',
      nivelDificultad: 2,
    ),
    Vocablo(
      id: 'v040',
      palabra: 'Bunguey',
      fonetica: 'bun-guey',
      significado: 'Viento',
      categoria: 'naturaleza',
      descripcionCultural: 'Mensajero de los espíritus entre montañas.',
      nivelDificultad: 2,
    ),
    Vocablo(
      id: 'v041',
      palabra: 'Gunzhí',
      fonetica: 'gun-shí',
      significado: 'Árbol',
      categoria: 'plantas',
      descripcionCultural: 'Los abuelos de pie, guardianes del territorio.',
      nivelDificultad: 2,
    ),
    Vocablo(
      id: 'v042',
      palabra: 'Seynuá',
      fonetica: 'sey-nu-á',
      significado: 'Camino',
      categoria: 'naturaleza',
      descripcionCultural: 'La línea negra que conecta los sitios sagrados.',
      nivelDificultad: 2,
    ),
    Vocablo(
      id: 'v043',
      palabra: 'Kanká',
      fonetica: 'kan-ká',
      significado: 'Corazón',
      categoria: 'familia',
      descripcionCultural: 'Centro del ser, donde reside el pensamiento.',
      nivelDificultad: 1,
    ),
  ];

  /// Obtener vocablos por categoría
  static List<Vocablo> obtenerPorCategoria(String categoriaId) {
    return vocablos.where((v) => v.categoria == categoriaId).toList();
  }

  /// Obtener vocablos por nivel de dificultad
  static List<Vocablo> obtenerPorNivel(int nivel) {
    return vocablos.where((v) => v.nivelDificultad == nivel).toList();
  }

  /// Obtener vocablos en recuperación
  static List<Vocablo> obtenerEnRecuperacion() {
    return vocablos.where((v) => v.enRecuperacion).toList();
  }
}
