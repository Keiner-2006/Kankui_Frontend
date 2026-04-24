import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import 'models_local.dart';

/// Repositorio para datos del usuario actual
class UserRepository {
  final DatabaseService _db = DatabaseService();

  // ============================================
  // USUARIO
  // ============================================

  /// Guardar usuario actual (al hacer login)
  Future<void> saveCurrentUser(UsuarioLocal usuario) async {
    final db = await _db.database;
    
    // Limpiar usuario anterior si existe (en orden correcto para evitar FOREIGN KEY)
    await db.delete('resultado_quiz');
    await db.delete('progreso_reto');
    await db.delete('progreso_categoria');
    await db.delete('estudiante');
    await db.delete('maestro');
    await db.delete('usuario');
    
    await db.insert(
      'usuario',
      usuario.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtener usuario actual
  Future<UsuarioLocal?> getCurrentUser() async {
    final db = await _db.database;
    final maps = await db.query('usuario', limit: 1);
    if (maps.isEmpty) return null;
    return UsuarioLocal.fromMap(maps.first);
  }

  /// Verificar si hay usuario logueado
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  /// Cerrar sesion (limpiar datos de usuario)
  Future<void> logout() async {
    final db = await _db.database;
    await db.delete('resultado_quiz');
    await db.delete('progreso_reto');
    await db.delete('progreso_categoria');
    await db.delete('estudiante');
    await db.delete('usuario');
  }

  // ============================================
  // ESTUDIANTE
  // ============================================

  /// Guardar datos del estudiante
  Future<void> saveEstudiante(EstudianteLocal estudiante) async {
    final db = await _db.database;
    await db.insert(
      'estudiante',
      estudiante.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtener estudiante actual
  Future<EstudianteLocal?> getCurrentEstudiante() async {
    final db = await _db.database;
    final maps = await db.query('estudiante', limit: 1);
    if (maps.isEmpty) return null;
    return EstudianteLocal.fromMap(maps.first);
  }

  /// Obtener estudiante por usuario_id
  Future<EstudianteLocal?> getEstudianteByUsuarioId(String usuarioId) async {
    final db = await _db.database;
    final maps = await db.query(
      'estudiante',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
    );
    if (maps.isEmpty) return null;
    return EstudianteLocal.fromMap(maps.first);
  }

  /// Actualizar estudiante
  Future<void> updateEstudiante(EstudianteLocal estudiante) async {
    final db = await _db.database;
    await db.update(
      'estudiante',
      estudiante.toMap(),
      where: 'id = ?',
      whereArgs: [estudiante.id],
    );
  }

  // ============================================
  // GAMIFICACION - XP
  // ============================================

  /// Agregar XP al estudiante
  Future<EstudianteLocal?> addXP(int xp) async {
    final estudiante = await getCurrentEstudiante();
    if (estudiante == null) return null;

    final updated = estudiante.copyWith(
      xpTotal: estudiante.xpTotal + xp,
      xpHoy: estudiante.xpHoy + xp,
      ultimaActividad: DateTime.now().toIso8601String(),
    );

    await updateEstudiante(updated);
    return updated;
  }

  /// Resetear XP del dia (llamar al inicio de cada dia)
  Future<void> resetDailyXP() async {
    final estudiante = await getCurrentEstudiante();
    if (estudiante == null) return;

    final updated = estudiante.copyWith(xpHoy: 0);
    await updateEstudiante(updated);
  }

  // ============================================
  // GAMIFICACION - RACHA
  // ============================================

  /// Actualizar racha de dias
  Future<EstudianteLocal?> updateRacha() async {
    final estudiante = await getCurrentEstudiante();
    if (estudiante == null) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int nuevaRacha = estudiante.rachaDias;
    
    if (estudiante.ultimaActividad != null) {
      final lastActivity = DateTime.parse(estudiante.ultimaActividad!);
      final lastDate = DateTime(lastActivity.year, lastActivity.month, lastActivity.day);
      final difference = today.difference(lastDate).inDays;
      
      if (difference == 1) {
        // Dia consecutivo
        nuevaRacha = estudiante.rachaDias + 1;
      } else if (difference > 1) {
        // Se rompio la racha
        nuevaRacha = 1;
      }
      // Si difference == 0, es el mismo dia, no cambia
    } else {
      nuevaRacha = 1;
    }

    final updated = estudiante.copyWith(
      rachaDias: nuevaRacha,
      ultimaActividad: now.toIso8601String(),
    );

    await updateEstudiante(updated);
    return updated;
  }

  // ============================================
  // GAMIFICACION - LECCIONES
  // ============================================

  /// Marcar leccion como completada
  Future<EstudianteLocal?> completarLeccion(String leccionId) async {
    final estudiante = await getCurrentEstudiante();
    if (estudiante == null) return null;

    final updated = estudiante.copyWith(
      leccionesCompletadasTotal: estudiante.leccionesCompletadasTotal + 1,
      ultimaActividad: DateTime.now().toIso8601String(),
    );

    await updateEstudiante(updated);
    return updated;
  }

  /// Desbloquear una leccion
  Future<EstudianteLocal?> desbloquearLeccion(String leccionId) async {
    final estudiante = await getCurrentEstudiante();
    if (estudiante == null) return null;

    if (estudiante.leccionesDesbloqueadas.contains(leccionId)) {
      return estudiante; // Ya desbloqueada
    }

    final nuevasDesbloqueadas = [...estudiante.leccionesDesbloqueadas, leccionId];
    final updated = estudiante.copyWith(
      leccionesDesbloqueadas: nuevasDesbloqueadas,
    );

    await updateEstudiante(updated);
    return updated;
  }

  /// Verificar si una leccion esta desbloqueada
  Future<bool> isLeccionDesbloqueada(String leccionId) async {
    final estudiante = await getCurrentEstudiante();
    if (estudiante == null) return false;
    return estudiante.leccionesDesbloqueadas.contains(leccionId);
  }

  // ============================================
  // GAMIFICACION - LOGROS
  // ============================================

  /// Desbloquear un logro
  Future<EstudianteLocal?> desbloquearLogro(String logroId) async {
    final estudiante = await getCurrentEstudiante();
    if (estudiante == null) return null;

    if (estudiante.logrosDesbloqueados.contains(logroId)) {
      return estudiante; // Ya desbloqueado
    }

    final nuevosLogros = [...estudiante.logrosDesbloqueados, logroId];
    final updated = estudiante.copyWith(
      logrosDesbloqueados: nuevosLogros,
    );

    await updateEstudiante(updated);
    return updated;
  }

  /// Verificar si tiene un logro
  Future<bool> hasLogro(String logroId) async {
    final estudiante = await getCurrentEstudiante();
    if (estudiante == null) return false;
    return estudiante.logrosDesbloqueados.contains(logroId);
  }

  // ============================================
  // GAMIFICACION - ESCANEOS QR
  // ============================================

  /// Incrementar contador de escaneos exitosos
  Future<EstudianteLocal?> incrementarEscaneos() async {
    final estudiante = await getCurrentEstudiante();
    if (estudiante == null) return null;

    final updated = estudiante.copyWith(
      escaneosExitosos: estudiante.escaneosExitosos + 1,
    );

    await updateEstudiante(updated);
    return updated;
  }
}