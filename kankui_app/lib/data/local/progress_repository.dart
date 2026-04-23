import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'database_service.dart';
import 'models_local.dart';

/// Repositorio para progreso del usuario (lectura/escritura local + sync)
class ProgressRepository {
  final DatabaseService _db = DatabaseService();
  final Uuid _uuid = const Uuid();

  // ============================================
  // PROGRESO CATEGORIA
  // ============================================

  /// Obtener todo el progreso de categorias del usuario
  Future<List<ProgresoCategoriaLocal>> getProgresoCategoriasUsuario(String usuarioId) async {
    final db = await _db.database;
    final maps = await db.query(
      'progreso_categoria',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
    );
    return maps.map((m) => ProgresoCategoriaLocal.fromMap(m)).toList();
  }

  /// Obtener progreso de una categoria especifica
  Future<ProgresoCategoriaLocal?> getProgresoCategoria(String usuarioId, String categoriaId) async {
    final db = await _db.database;
    final maps = await db.query(
      'progreso_categoria',
      where: 'usuario_id = ? AND categoria_id = ?',
      whereArgs: [usuarioId, categoriaId],
    );
    if (maps.isEmpty) return null;
    return ProgresoCategoriaLocal.fromMap(maps.first);
  }

  /// Actualizar progreso de categoria (incrementar lecciones completadas)
  Future<ProgresoCategoriaLocal> updateProgresoCategoria({
    required String usuarioId,
    required String categoriaId,
    required int leccionesCompletadas,
    required int totalLecciones,
  }) async {
    final db = await _db.database;
    final existing = await getProgresoCategoria(usuarioId, categoriaId);
    
    final progreso = ProgresoCategoriaLocal(
      id: existing?.id ?? _uuid.v4(),
      usuarioId: usuarioId,
      categoriaId: categoriaId,
      leccionesCompletadas: leccionesCompletadas,
      totalLecciones: totalLecciones,
      ultimaActividad: DateTime.now().toIso8601String(),
      synced: false, // Marcar para sync
    );

    await db.insert(
      'progreso_categoria',
      progreso.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return progreso;
  }

  /// Guardar progreso desde Supabase
  Future<void> saveProgresoCategoriasFromSupabase(List<ProgresoCategoriaLocal> progresos) async {
    final db = await _db.database;
    final batch = db.batch();
    
    for (var progreso in progresos) {
      batch.insert(
        'progreso_categoria',
        progreso.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  // ============================================
  // PROGRESO RETO
  // ============================================

  /// Obtener todo el progreso de retos del usuario
  Future<List<ProgresoRetoLocal>> getProgresoRetosUsuario(String usuarioId) async {
    final db = await _db.database;
    final maps = await db.query(
      'progreso_reto',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
    );
    return maps.map((m) => ProgresoRetoLocal.fromMap(m)).toList();
  }

  /// Obtener progreso de un reto especifico
  Future<ProgresoRetoLocal?> getProgresoReto(String usuarioId, String retoId) async {
    final db = await _db.database;
    final maps = await db.query(
      'progreso_reto',
      where: 'usuario_id = ? AND reto_id = ?',
      whereArgs: [usuarioId, retoId],
    );
    if (maps.isEmpty) return null;
    return ProgresoRetoLocal.fromMap(maps.first);
  }

  /// Completar un reto
  Future<ProgresoRetoLocal> completarReto({
    required String usuarioId,
    required String retoId,
    required int puntosObtenidos,
  }) async {
    final db = await _db.database;
    final existing = await getProgresoReto(usuarioId, retoId);
    
    // Solo actualizar si es mejor puntaje o no existe
    if (existing != null && existing.puntosObtenidos >= puntosObtenidos) {
      return existing;
    }

    final progreso = ProgresoRetoLocal(
      id: existing?.id ?? _uuid.v4(),
      usuarioId: usuarioId,
      retoId: retoId,
      completado: true,
      puntosObtenidos: puntosObtenidos,
      fechaCompletado: DateTime.now().toIso8601String(),
      synced: false,
    );

    await db.insert(
      'progreso_reto',
      progreso.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return progreso;
  }

  /// Verificar si un reto esta completado
  Future<bool> isRetoCompletado(String usuarioId, String retoId) async {
    final progreso = await getProgresoReto(usuarioId, retoId);
    return progreso?.completado ?? false;
  }

  /// Guardar progreso de retos desde Supabase
  Future<void> saveProgresoRetosFromSupabase(List<ProgresoRetoLocal> progresos) async {
    final db = await _db.database;
    final batch = db.batch();
    
    for (var progreso in progresos) {
      batch.insert(
        'progreso_reto',
        progreso.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  // ============================================
  // RESULTADOS QUIZ
  // ============================================

  /// Guardar resultado de quiz
  Future<ResultadoQuizLocal> saveResultadoQuiz({
    required String usuarioId,
    required String retoId,
    required List<int> respuestas,
    required int puntaje,
  }) async {
    final db = await _db.database;
    
    final resultado = ResultadoQuizLocal(
      id: _uuid.v4(),
      usuarioId: usuarioId,
      retoId: retoId,
      respuestas: respuestas,
      puntaje: puntaje,
      fecha: DateTime.now().toIso8601String(),
      synced: false,
    );

    await db.insert('resultado_quiz', resultado.toMap());
    return resultado;
  }

  /// Obtener historial de resultados de un usuario
  Future<List<ResultadoQuizLocal>> getResultadosUsuario(String usuarioId) async {
    final db = await _db.database;
    final maps = await db.query(
      'resultado_quiz',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'fecha DESC',
    );
    return maps.map((m) => ResultadoQuizLocal.fromMap(m)).toList();
  }

  /// Obtener resultados de un reto especifico
  Future<List<ResultadoQuizLocal>> getResultadosByReto(String usuarioId, String retoId) async {
    final db = await _db.database;
    final maps = await db.query(
      'resultado_quiz',
      where: 'usuario_id = ? AND reto_id = ?',
      whereArgs: [usuarioId, retoId],
      orderBy: 'fecha DESC',
    );
    return maps.map((m) => ResultadoQuizLocal.fromMap(m)).toList();
  }

  /// Obtener mejor resultado de un reto
  Future<ResultadoQuizLocal?> getMejorResultado(String usuarioId, String retoId) async {
    final db = await _db.database;
    final maps = await db.query(
      'resultado_quiz',
      where: 'usuario_id = ? AND reto_id = ?',
      whereArgs: [usuarioId, retoId],
      orderBy: 'puntaje DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ResultadoQuizLocal.fromMap(maps.first);
  }

  /// Guardar resultados desde Supabase
  Future<void> saveResultadosFromSupabase(List<ResultadoQuizLocal> resultados) async {
    final db = await _db.database;
    final batch = db.batch();
    
    for (var resultado in resultados) {
      batch.insert(
        'resultado_quiz',
        resultado.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  // ============================================
  // SYNC - Obtener datos no sincronizados
  // ============================================

  /// Obtener progreso de categorias no sincronizado
  Future<List<ProgresoCategoriaLocal>> getUnsyncedProgresoCategoria() async {
    final db = await _db.database;
    final maps = await db.query(
      'progreso_categoria',
      where: 'synced = 0',
    );
    return maps.map((m) => ProgresoCategoriaLocal.fromMap(m)).toList();
  }

  /// Obtener progreso de retos no sincronizado
  Future<List<ProgresoRetoLocal>> getUnsyncedProgresoReto() async {
    final db = await _db.database;
    final maps = await db.query(
      'progreso_reto',
      where: 'synced = 0',
    );
    return maps.map((m) => ProgresoRetoLocal.fromMap(m)).toList();
  }

  /// Obtener resultados de quiz no sincronizados
  Future<List<ResultadoQuizLocal>> getUnsyncedResultados() async {
    final db = await _db.database;
    final maps = await db.query(
      'resultado_quiz',
      where: 'synced = 0',
    );
    return maps.map((m) => ResultadoQuizLocal.fromMap(m)).toList();
  }

  // ============================================
  // SYNC - Marcar como sincronizado
  // ============================================

  /// Marcar progreso de categoria como sincronizado
  Future<void> markProgresoCategoriaAsSynced(String id) async {
    final db = await _db.database;
    await db.update(
      'progreso_categoria',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Marcar progreso de reto como sincronizado
  Future<void> markProgresoRetoAsSynced(String id) async {
    final db = await _db.database;
    await db.update(
      'progreso_reto',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Marcar resultado como sincronizado
  Future<void> markResultadoAsSynced(String id) async {
    final db = await _db.database;
    await db.update(
      'resultado_quiz',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Marcar multiples como sincronizados
  Future<void> markAllAsSynced(List<String> ids, String tabla) async {
    if (ids.isEmpty) return;
    final db = await _db.database;
    final placeholders = ids.map((_) => '?').join(',');
    await db.rawUpdate(
      'UPDATE $tabla SET synced = 1 WHERE id IN ($placeholders)',
      ids,
    );
  }

  // ============================================
  // ESTADISTICAS
  // ============================================

  /// Obtener estadisticas generales del usuario
  Future<Map<String, dynamic>> getEstadisticasUsuario(String usuarioId) async {
    final db = await _db.database;
    
    // Total retos completados
    final retosCompletados = await db.rawQuery('''
      SELECT COUNT(*) as count FROM progreso_reto 
      WHERE usuario_id = ? AND completado = 1
    ''', [usuarioId]);
    
    // Promedio de puntaje
    final promedioPuntaje = await db.rawQuery('''
      SELECT AVG(puntaje) as promedio FROM resultado_quiz 
      WHERE usuario_id = ?
    ''', [usuarioId]);
    
    // Total quizzes realizados
    final totalQuizzes = await db.rawQuery('''
      SELECT COUNT(*) as count FROM resultado_quiz 
      WHERE usuario_id = ?
    ''', [usuarioId]);
    
    // Categorias con progreso
    final categoriasProgreso = await db.rawQuery('''
      SELECT COUNT(*) as count FROM progreso_categoria 
      WHERE usuario_id = ? AND lecciones_completadas > 0
    ''', [usuarioId]);

    return {
      'retos_completados': retosCompletados.first['count'] ?? 0,
      'promedio_puntaje': promedioPuntaje.first['promedio'] ?? 0.0,
      'total_quizzes': totalQuizzes.first['count'] ?? 0,
      'categorias_con_progreso': categoriasProgreso.first['count'] ?? 0,
    };
  }
}