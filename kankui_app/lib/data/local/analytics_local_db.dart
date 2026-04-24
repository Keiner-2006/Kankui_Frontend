import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '/models/dashboard_data.dart';

/// Clase para manejar el almacenamiento local de analytics usando SQLite
class AnalyticsLocalDB {
  static final AnalyticsLocalDB _instance = AnalyticsLocalDB._internal();
  factory AnalyticsLocalDB() => _instance;
  AnalyticsLocalDB._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'analytics_cache.db');

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    await db.execute('PRAGMA foreign_keys = ON');
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla para cache de DashboardData por usuario
    await db.execute('''
      CREATE TABLE dashboard_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id TEXT NOT NULL,
        total_xp INTEGER DEFAULT 0,
        racha_dias INTEGER DEFAULT 0,
        lecciones_completadas_total INTEGER DEFAULT 0,
        escaneos_exitosos INTEGER DEFAULT 0,
        vocablos_aprendidos INTEGER DEFAULT 0,
        tiempo_total_estudio INTEGER DEFAULT 0,
        fecha_guardado TEXT NOT NULL,
        fecha_desde TEXT,
        fecha_hasta TEXT,
        sync_status TEXT DEFAULT 'synced'
      )
    ''');

    // Tabla para XP por día (serie temporal)
    await db.execute('''
      CREATE TABLE xp_diario (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id TEXT NOT NULL,
        fecha TEXT NOT NULL,
        xp_amount INTEGER DEFAULT 0,
        dashboard_cache_id INTEGER,
        FOREIGN KEY (dashboard_cache_id) REFERENCES dashboard_cache(id)
      )
    ''');

    // Tabla para actividad por categoría
    await db.execute('''
      CREATE TABLE actividad_categoria (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id TEXT NOT NULL,
        categoria TEXT NOT NULL,
        total_actividades INTEGER DEFAULT 0,
        dashboard_cache_id INTEGER,
        FOREIGN KEY (dashboard_cache_id) REFERENCES dashboard_cache(id)
      )
    ''');

    // Tabla para progreso semanal
    await db.execute('''
      CREATE TABLE progreso_semanal (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id TEXT NOT NULL,
        semana INTEGER DEFAULT 0,
        lecciones_completadas INTEGER DEFAULT 0,
        dashboard_cache_id INTEGER,
        FOREIGN KEY (dashboard_cache_id) REFERENCES dashboard_cache(id)
      )
    ''');

    // Tabla para progreso de nivel
    await db.execute('''
      CREATE TABLE progreso_nivel (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id TEXT NOT NULL,
        label TEXT NOT NULL,
        valor REAL DEFAULT 0,
        dashboard_cache_id INTEGER,
        FOREIGN KEY (dashboard_cache_id) REFERENCES dashboard_cache(id)
      )
    ''');

    // Tabla para historial de eventos analytics
    await db.execute('''
      CREATE TABLE analytics_eventos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id TEXT NOT NULL,
        tipo_evento TEXT NOT NULL,
        valor INTEGER DEFAULT 0,
        categoria TEXT,
        metadata TEXT,
        fecha TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Índices para mejor performance
    await db.execute(
        'CREATE INDEX idx_dashboard_usuario ON dashboard_cache(usuario_id)');
    await db.execute(
        'CREATE INDEX idx_xp_diario_usuario ON xp_diario(usuario_id, fecha)');
    await db.execute(
        'CREATE INDEX idx_actividad_usuario ON actividad_categoria(usuario_id)');
    await db.execute(
        'CREATE INDEX idx_progreso_sem_usuario ON progreso_semanal(usuario_id)');
    await db.execute(
        'CREATE INDEX idx_progreso_nivel_usuario ON progreso_nivel(usuario_id)');
    await db.execute(
        'CREATE INDEX idx_eventos_usuario ON analytics_eventos(usuario_id, fecha)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migraciones futuras aquí
  }

  // ========================================
  // DASHBOARD CACHE
  // ========================================

  /// Guarda un dashboard completo en cache local
  Future<void> saveDashboard(
    DashboardData data,
    String usuarioId, {
    DateTime? desde,
    DateTime? hasta,
  }) async {
    final db = await database;

    await db.transaction((txn) async {
      // 1. Insertar registro principal
      final dashboardId = await txn.insert('dashboard_cache', {
        'usuario_id': usuarioId,
        'total_xp': data.totalXp,
        'racha_dias': data.racha,
        'lecciones_completadas_total': data.lecciones,
        'escaneos_exitosos': data.escaneos,
        'vocablos_aprendidos': data.vocablosAprendidos,
        'tiempo_total_estudio': data.tiempoTotalEstudio,
        'fecha_guardado': DateTime.now().toIso8601String(),
        'fecha_desde': desde?.toIso8601String(),
        'fecha_hasta': hasta?.toIso8601String(),
        'sync_status': 'synced',
      });

      // 2. Guardar XP diario
      for (final item in data.xpPorDia) {
        await txn.insert('xp_diario', {
          'usuario_id': usuarioId,
          'fecha': item.fecha?.toIso8601String() ??
              DateTime.now().toIso8601String(),
          'xp_amount': item.valor.toInt(),
          'dashboard_cache_id': dashboardId,
        });
      }

      // 3. Guardar actividad por categoría
      for (final item in data.actividadPorCategoria) {
        await txn.insert('actividad_categoria', {
          'usuario_id': usuarioId,
          'categoria': item.label,
          'total_actividades': item.valor.toInt(),
          'dashboard_cache_id': dashboardId,
        });
      }

      // 4. Guardar progreso semanal
      for (final item in data.progresoSemanal) {
        await txn.insert('progreso_semanal', {
          'usuario_id': usuarioId,
          'semana':
              int.tryParse(item.label.replaceAll('Semana ', '')) ?? 0,
          'lecciones_completadas': item.valor.toInt(),
          'dashboard_cache_id': dashboardId,
        });
      }

      // 5. Guardar progreso de nivel
      for (final item in data.progresoNivel) {
        await txn.insert('progreso_nivel', {
          'usuario_id': usuarioId,
          'label': item.label,
          'valor': item.valor,
          'dashboard_cache_id': dashboardId,
        });
      }
    });
  }

  /// Obtiene el dashboard más reciente para un usuario
  Future<DashboardData?> getLatestDashboard(String usuarioId) async {
    final db = await database;

    final dashboardMap = await db.query(
      'dashboard_cache',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'fecha_guardado DESC',
      limit: 1,
    );

    if (dashboardMap.isEmpty) return null;

    final dashboardId = dashboardMap.first['id'] as int;

    // Cargar datos relacionados
    final xpDiario = await db.query(
      'xp_diario',
      where: 'dashboard_cache_id = ?',
      whereArgs: [dashboardId],
    );

    final actividadCategoria = await db.query(
      'actividad_categoria',
      where: 'dashboard_cache_id = ?',
      whereArgs: [dashboardId],
    );

    final progresoSemanal = await db.query(
      'progreso_semanal',
      where: 'dashboard_cache_id = ?',
      whereArgs: [dashboardId],
    );

    final progresoNivel = await db.query(
      'progreso_nivel',
      where: 'dashboard_cache_id = ?',
      whereArgs: [dashboardId],
    );

    final dash = dashboardMap.first;

    return DashboardData(
      totalXp: dash['total_xp'] as int,
      racha: dash['racha_dias'] as int,
      lecciones: dash['lecciones_completadas_total'] as int,
      escaneos: dash['escaneos_exitosos'] as int,
      vocablosAprendidos: dash['vocablos_aprendidos'] as int? ?? 0,
      tiempoTotalEstudio: dash['tiempo_total_estudio'] as int? ?? 0,
      xpPorDia: xpDiario
          .map((e) => ChartData(
                label: _formatFecha(DateTime.parse(e['fecha'] as String)),
                valor: (e['xp_amount'] as int).toDouble(),
                fecha: DateTime.parse(e['fecha'] as String),
              ))
          .toList(),
      actividadPorCategoria: actividadCategoria
          .map((e) => ChartData(
                label: e['categoria'] as String,
                valor: (e['total_actividades'] as int).toDouble(),
              ))
          .toList(),
      progresoSemanal: progresoSemanal
          .map((e) => ChartData(
                label: 'Semana ${e['semana']}',
                valor: (e['lecciones_completadas'] as int).toDouble(),
              ))
          .toList(),
      progresoNivel: progresoNivel
          .map((e) => ChartData(
                label: e['label'] as String,
                valor: e['valor'] as double,
              ))
          .toList(),
    );
  }

  /// Obtiene historial de dashboards para un rango de fechas
  Future<List<DashboardData>> getDashboardHistory(
    String usuarioId,
    DateTime desde,
    DateTime hasta,
  ) async {
    final db = await database;

    final dashboards = await db.query(
      'dashboard_cache',
      where: 'usuario_id = ? AND fecha_guardado BETWEEN ? AND ?',
      whereArgs: [
        usuarioId,
        desde.toIso8601String(),
        hasta.toIso8601String(),
      ],
      orderBy: 'fecha_guardado ASC',
    );

    List<DashboardData> result = [];

    for (final dash in dashboards) {
      final dashboardId = dash['id'] as int;

      final xpDiario = await db.query(
        'xp_diario',
        where: 'dashboard_cache_id = ?',
        whereArgs: [dashboardId],
      );

      final actividadCategoria = await db.query(
        'actividad_categoria',
        where: 'dashboard_cache_id = ?',
        whereArgs: [dashboardId],
      );

      final progresoSemanal = await db.query(
        'progreso_semanal',
        where: 'dashboard_cache_id = ?',
        whereArgs: [dashboardId],
      );

      final progresoNivel = await db.query(
        'progreso_nivel',
        where: 'dashboard_cache_id = ?',
        whereArgs: [dashboardId],
      );

      result.add(DashboardData(
        totalXp: dash['total_xp'] as int,
        racha: dash['racha_dias'] as int,
        lecciones: dash['lecciones_completadas_total'] as int,
        escaneos: dash['escaneos_exitosos'] as int,
        vocablosAprendidos: dash['vocablos_aprendidos'] as int? ?? 0,
        tiempoTotalEstudio: dash['tiempo_total_estudio'] as int? ?? 0,
        xpPorDia: xpDiario
            .map((e) => ChartData(
                  label: _formatFecha(DateTime.parse(e['fecha'] as String)),
                  valor: (e['xp_amount'] as int).toDouble(),
                  fecha: DateTime.parse(e['fecha'] as String),
                ))
            .toList(),
        actividadPorCategoria: actividadCategoria
            .map((e) => ChartData(
                  label: e['categoria'] as String,
                  valor: (e['total_actividades'] as int).toDouble(),
                ))
            .toList(),
        progresoSemanal: progresoSemanal
            .map((e) => ChartData(
                  label: 'Semana ${e['semana']}',
                  valor: (e['lecciones_completadas'] as int).toDouble(),
                ))
            .toList(),
        progresoNivel: progresoNivel
            .map((e) => ChartData(
                  label: e['label'] as String,
                  valor: e['valor'] as double,
                ))
            .toList(),
      ));
    }

    return result;
  }

  // ========================================
  // EVENTOS ANALYTICS
  // ========================================

  /// Guarda un evento de analytics
  Future<void> saveEvento(
    String usuarioId,
    String tipoEvento,
    int valor, {
    String? categoria,
    Map<String, dynamic>? metadata,
  }) async {
    final db = await database;

    await db.insert('analytics_eventos', {
      'usuario_id': usuarioId,
      'tipo_evento': tipoEvento,
      'valor': valor,
      'categoria': categoria,
      'metadata': metadata != null ? metadata.toString() : null,
      'fecha': DateTime.now().toIso8601String(),
      'synced': 0, // pendiente de sincronizar
    });
  }

  /// Obtiene eventos para un rango de fechas
  Future<List<Map<String, dynamic>>> getEventos(
    String usuarioId,
    DateTime desde,
    DateTime hasta,
  ) async {
    final db = await database;

    return await db.query(
      'analytics_eventos',
      where: 'usuario_id = ? AND fecha BETWEEN ? AND ?',
      whereArgs: [
        usuarioId,
        desde.toIso8601String(),
        hasta.toIso8601String(),
      ],
      orderBy: 'fecha DESC',
    );
  }

  // ========================================
  // UTILIDADES
  // ========================================

  String _formatFecha(DateTime date) {
    return '${date.day}/${date.month}';
  }

  /// Limpia todo el cache de analytics (logout/reset)
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('xp_diario');
    await db.delete('actividad_categoria');
    await db.delete('progreso_semanal');
    await db.delete('progreso_nivel');
    await db.delete('dashboard_cache');
    await db.delete('analytics_eventos');
  }

  /// Elimina dashboards antiguos (ej: más de 30 días)
  Future<void> cleanupOldData({int keepDays = 30}) async {
    final db = await database;
    final cutoff = DateTime.now().subtract(Duration(days: keepDays));

    await db.delete(
      'dashboard_cache',
      where: 'fecha_guardado < ?',
      whereArgs: [cutoff.toIso8601String()],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}