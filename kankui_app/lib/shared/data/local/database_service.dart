import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Servicio singleton para manejar la base de datos SQLite local
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /* Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'kankui_local.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

  }
*/

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'kankui_local.db');

    final db = await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    await db.execute('PRAGMA foreign_keys = ON');

    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    // ========================================
    // CONTENIDO (sync desde Supabase - solo lectura local)
    // ========================================

    await db.execute('''
      CREATE TABLE categoria (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        icono TEXT,
        total_palabras INTEGER DEFAULT 0,
        orden INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
       CREATE TABLE palabra (
         id TEXT PRIMARY KEY,
         termino TEXT NOT NULL,
         pronunciacion TEXT,
         traduccion TEXT,
         sync_status TEXT DEFAULT 'pending',
         audio_url TEXT,
         image_url TEXT,
         categoria_id TEXT,
         FOREIGN KEY (categoria_id) REFERENCES categoria(id)
       )
    ''');

    await db.execute('''
      CREATE TABLE leccion (
        id TEXT PRIMARY KEY,
        titulo TEXT NOT NULL,
        categoria TEXT,
        palabras TEXT DEFAULT '[]',
        orden INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE pregunta (
        id TEXT PRIMARY KEY,
        enunciado TEXT NOT NULL,
        opciones TEXT DEFAULT '[]',
        respuesta_correcta INTEGER NOT NULL,
        palabra_id TEXT,
        FOREIGN KEY (palabra_id) REFERENCES palabra(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE reto (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        preguntas TEXT DEFAULT '[]',
        puntos_maximos INTEGER DEFAULT 100,
        orden INTEGER DEFAULT 0,
        leccion_id TEXT,
        FOREIGN KEY (leccion_id) REFERENCES leccion(id)
      )
    ''');

    // ========================================
    // USUARIO ACTUAL (cache del usuario logueado)
    // ========================================

    await db.execute('''
      CREATE TABLE usuario (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        identificacion TEXT NOT NULL,
        rol TEXT NOT NULL DEFAULT 'estudiante',
        fecha_registro TEXT,
        institucion_id TEXT
      )
    ''');

    await db.execute('''
    CREATE TABLE maestro (
      id TEXT PRIMARY KEY,
      usuario_id TEXT NOT NULL,
      FOREIGN KEY (usuario_id) REFERENCES usuario(id)
  )
''');

    await db.execute('''
      CREATE TABLE estudiante (
        id TEXT PRIMARY KEY,
        usuario_id TEXT NOT NULL UNIQUE,
        curso TEXT,
        grupo INTEGER,
        promedio REAL DEFAULT 0,
        pin TEXT,
        maestro_id TEXT,
        xp_total INTEGER DEFAULT 0,
        xp_hoy INTEGER DEFAULT 0,
        racha_dias INTEGER DEFAULT 0,
        ultima_actividad TEXT,
        lecciones_completadas_total INTEGER DEFAULT 0,
        escaneos_exitosos INTEGER DEFAULT 0,
        lecciones_desbloqueadas TEXT DEFAULT '["leccion_1"]',
        logros_desbloqueados TEXT DEFAULT '[]',
        FOREIGN KEY (usuario_id) REFERENCES usuario(id)
      )
    ''');

    // ========================================
    // PROGRESO (lectura/escritura local + sync a Supabase)
    // ========================================

    await db.execute('''
      CREATE TABLE progreso_categoria (
        id TEXT PRIMARY KEY,
        usuario_id TEXT NOT NULL,
        categoria_id TEXT NOT NULL,
        lecciones_completadas INTEGER DEFAULT 0,
        total_lecciones INTEGER DEFAULT 0,
        ultima_actividad TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (usuario_id) REFERENCES usuario(id),
        FOREIGN KEY (categoria_id) REFERENCES categoria(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE progreso_reto (
        id TEXT PRIMARY KEY,
        usuario_id TEXT NOT NULL,
        reto_id TEXT NOT NULL,
        completado INTEGER DEFAULT 0,
        puntos_obtenidos INTEGER DEFAULT 0,
        fecha_completado TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (usuario_id) REFERENCES usuario(id),
        FOREIGN KEY (reto_id) REFERENCES reto(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE resultado_quiz (
        id TEXT PRIMARY KEY,
        usuario_id TEXT NOT NULL,
        reto_id TEXT NOT NULL,
        respuestas TEXT DEFAULT '[]',
        puntaje INTEGER DEFAULT 0,
        fecha TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (usuario_id) REFERENCES usuario(id),
        FOREIGN KEY (reto_id) REFERENCES reto(id)
      )
    ''');

    // ========================================
    // METADATOS DE SINCRONIZACION
    // ========================================

    await db.execute('''
      CREATE TABLE sync_metadata (
        tabla TEXT PRIMARY KEY,
        ultima_sync TEXT,
        version INTEGER DEFAULT 0
      )
    ''');

    // Indices para mejorar performance
    await db
        .execute('CREATE INDEX idx_palabra_categoria ON palabra(categoria_id)');
    await db
        .execute('CREATE INDEX idx_pregunta_palabra ON pregunta(palabra_id)');
    await db.execute('CREATE INDEX idx_reto_leccion ON reto(leccion_id)');
    await db.execute(
        'CREATE INDEX idx_progreso_cat_usuario ON progreso_categoria(usuario_id)');
    await db.execute(
        'CREATE INDEX idx_progreso_reto_usuario ON progreso_reto(usuario_id)');
    await db.execute(
        'CREATE INDEX idx_resultado_usuario ON resultado_quiz(usuario_id)');
    await db.execute(
        'CREATE INDEX idx_estudiante_usuario ON estudiante(usuario_id)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Manejar migraciones futuras aqui
    if (oldVersion < 2) {
      // Version 2: Añadir columna image_url a la tabla palabra
      await db.execute('ALTER TABLE palabra ADD COLUMN image_url TEXT');
    }
  }

  /// Limpiar toda la base de datos (para logout o reset)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('resultado_quiz');
    await db.delete('progreso_reto');
    await db.delete('progreso_categoria');
    await db.delete('estudiante');
    await db.delete('usuario');
    await db.delete('sync_metadata');
  }

  /// Limpiar solo el contenido (para re-sync)
  Future<void> clearContent() async {
    final db = await database;
    await db.delete('reto');
    await db.delete('pregunta');
    await db.delete('leccion');
    await db.delete('palabra');
    await db.delete('categoria');
  }

  /// Cerrar la base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
