import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import 'models_local.dart';

/// Repositorio para contenido de solo lectura (sync desde Supabase)
class ContentRepository {
  final DatabaseService _db = DatabaseService();

  // ============================================
  // CATEGORIAS
  // ============================================

  Future<List<CategoriaLocal>> getCategorias() async {
    final db = await _db.database;
    final maps = await db.query('categoria', orderBy: 'orden ASC');
    return maps.map((m) => CategoriaLocal.fromMap(m)).toList();
  }

  Future<CategoriaLocal?> getCategoriaById(String id) async {
    final db = await _db.database;
    final maps = await db.query('categoria', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return CategoriaLocal.fromMap(maps.first);
  }

  Future<void> saveCategorias(List<CategoriaLocal> categorias) async {
    final db = await _db.database;
    final batch = db.batch();
    
    for (var cat in categorias) {
      batch.insert(
        'categoria',
        cat.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  // ============================================
  // PALABRAS
  // ============================================

  Future<List<PalabraLocal>> getPalabras() async {
    final db = await _db.database;
    final maps = await db.query('palabra');
    return maps.map((m) => PalabraLocal.fromMap(m)).toList();
  }

  Future<List<PalabraLocal>> getPalabrasByCategoria(String categoriaId) async {
    final db = await _db.database;
    final maps = await db.query(
      'palabra',
      where: 'categoria_id = ?',
      whereArgs: [categoriaId],
    );
    return maps.map((m) => PalabraLocal.fromMap(m)).toList();
  }

  Future<PalabraLocal?> getPalabraById(String id) async {
    final db = await _db.database;
    final maps = await db.query('palabra', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return PalabraLocal.fromMap(maps.first);
  }

  Future<List<PalabraLocal>> getPalabrasByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final db = await _db.database;
    final placeholders = ids.map((_) => '?').join(',');
    final maps = await db.rawQuery(
      'SELECT * FROM palabra WHERE id IN ($placeholders)',
      ids,
    );
    return maps.map((m) => PalabraLocal.fromMap(m)).toList();
  }

  Future<void> savePalabras(List<PalabraLocal> palabras) async {
    final db = await _db.database;
    final batch = db.batch();
    
    for (var palabra in palabras) {
      batch.insert(
        'palabra',
        palabra.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  // ============================================
  // LECCIONES
  // ============================================

  Future<List<LeccionLocal>> getLecciones() async {
    final db = await _db.database;
    final maps = await db.query('leccion', orderBy: 'orden ASC');
    return maps.map((m) => LeccionLocal.fromMap(m)).toList();
  }

  Future<List<LeccionLocal>> getLeccionesByCategoria(String categoria) async {
    final db = await _db.database;
    final maps = await db.query(
      'leccion',
      where: 'categoria = ?',
      whereArgs: [categoria],
      orderBy: 'orden ASC',
    );
    return maps.map((m) => LeccionLocal.fromMap(m)).toList();
  }

  Future<LeccionLocal?> getLeccionById(String id) async {
    final db = await _db.database;
    final maps = await db.query('leccion', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return LeccionLocal.fromMap(maps.first);
  }

  Future<void> saveLecciones(List<LeccionLocal> lecciones) async {
    final db = await _db.database;
    final batch = db.batch();
    
    for (var leccion in lecciones) {
      batch.insert(
        'leccion',
        leccion.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  // ============================================
  // PREGUNTAS
  // ============================================

  Future<List<PreguntaLocal>> getPreguntas() async {
    final db = await _db.database;
    final maps = await db.query('pregunta');
    return maps.map((m) => PreguntaLocal.fromMap(m)).toList();
  }

  Future<List<PreguntaLocal>> getPreguntasByPalabra(String palabraId) async {
    final db = await _db.database;
    final maps = await db.query(
      'pregunta',
      where: 'palabra_id = ?',
      whereArgs: [palabraId],
    );
    return maps.map((m) => PreguntaLocal.fromMap(m)).toList();
  }

  Future<PreguntaLocal?> getPreguntaById(String id) async {
    final db = await _db.database;
    final maps = await db.query('pregunta', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return PreguntaLocal.fromMap(maps.first);
  }

  Future<List<PreguntaLocal>> getPreguntasByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final db = await _db.database;
    final placeholders = ids.map((_) => '?').join(',');
    final maps = await db.rawQuery(
      'SELECT * FROM pregunta WHERE id IN ($placeholders)',
      ids,
    );
    return maps.map((m) => PreguntaLocal.fromMap(m)).toList();
  }

  Future<void> savePreguntas(List<PreguntaLocal> preguntas) async {
    final db = await _db.database;
    final batch = db.batch();
    
    for (var pregunta in preguntas) {
      batch.insert(
        'pregunta',
        pregunta.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  // ============================================
  // RETOS
  // ============================================

  Future<List<RetoLocal>> getRetos() async {
    final db = await _db.database;
    final maps = await db.query('reto', orderBy: 'orden ASC');
    return maps.map((m) => RetoLocal.fromMap(m)).toList();
  }

  Future<List<RetoLocal>> getRetosByLeccion(String leccionId) async {
    final db = await _db.database;
    final maps = await db.query(
      'reto',
      where: 'leccion_id = ?',
      whereArgs: [leccionId],
      orderBy: 'orden ASC',
    );
    return maps.map((m) => RetoLocal.fromMap(m)).toList();
  }

  Future<RetoLocal?> getRetoById(String id) async {
    final db = await _db.database;
    final maps = await db.query('reto', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return RetoLocal.fromMap(maps.first);
  }

  Future<void> saveRetos(List<RetoLocal> retos) async {
    final db = await _db.database;
    final batch = db.batch();
    
    for (var reto in retos) {
      batch.insert(
        'reto',
        reto.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  // ============================================
  // SYNC METADATA
  // ============================================

  Future<SyncMetadata?> getSyncMetadata(String tabla) async {
    final db = await _db.database;
    final maps = await db.query(
      'sync_metadata',
      where: 'tabla = ?',
      whereArgs: [tabla],
    );
    if (maps.isEmpty) return null;
    return SyncMetadata.fromMap(maps.first);
  }

  Future<void> updateSyncMetadata(String tabla) async {
    final db = await _db.database;
    final existing = await getSyncMetadata(tabla);
    
    await db.insert(
      'sync_metadata',
      {
        'tabla': tabla,
        'ultima_sync': DateTime.now().toIso8601String(),
        'version': (existing?.version ?? 0) + 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Verificar si necesita sync (mas de X horas desde la ultima)
  Future<bool> needsSync(String tabla, {int hoursThreshold = 24}) async {
    final metadata = await getSyncMetadata(tabla);
    if (metadata == null || metadata.ultimaSync == null) return true;
    
    final lastSync = DateTime.parse(metadata.ultimaSync!);
    final now = DateTime.now();
    return now.difference(lastSync).inHours >= hoursThreshold;
  }

  /// Verificar si hay contenido local
  Future<bool> hasLocalContent() async {
    final db = await _db.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM categoria');
    return (result.first['count'] as int) > 0;
  }
}