import 'package:kankui_app/data/local/analytics_local_db.dart';
import 'package:kankui_app/models/dashboard_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository que combina datos remotos (Supabase) con cache local (SQLite)
class AnalyticsRepository {
  final SupabaseClient supabase;
  final AnalyticsLocalDB localDb;

  AnalyticsRepository(this.supabase, this.localDb);

  /// Obtiene datos del dashboard (sin filtro - último estado)
  Future<DashboardData> getDashboardData(String userId) async {
    return await _getDashboardDataInternal(userId);
  }

  /// Obtiene datos del dashboard para un rango de fechas específico
  Future<DashboardData> getDashboardDataForRange(
    String userId,
    DateTime desde,
    DateTime hasta,
  ) async {
    return await _getDashboardDataInternal(userId, desde: desde, hasta: hasta);
  }

  /// Método interno que maneja la obtención de datos (con o sin filtro)
  Future<DashboardData> _getDashboardDataInternal(
    String userId, {
    DateTime? desde,
    DateTime? hasta,
  }) async {
    try {
      final remote = await _getRemoteData(userId, desde: desde, hasta: hasta);
      await localDb.saveDashboard(remote, userId, desde: desde, hasta: hasta);
      return remote;
    } catch (e) {
      // Fallback offline: obtener desde cache local (el más reciente)
      try {
        final cached = await localDb.getLatestDashboard(userId);
        if (cached != null) {
          return cached;
        }
        return _getEmptyDashboard();
      } catch (cacheError) {
        return _getEmptyDashboard();
      }
    }
  }

  /// Refresca forzadamente desde remoto (sin filtro)
  Future<DashboardData> refreshDashboard(String userId) async {
    final remote = await _getRemoteData(userId);
    await localDb.saveDashboard(remote, userId);
    return remote;
  }

  Future<DashboardData> _getRemoteData(
    String userId, {
    DateTime? desde,
    DateTime? hasta,
  }) async {
    print('🔍 [GET REMOTE DATA] userId: $userId');

    // Determinar si el usuario es maestro o estudiante verificando su perfil
    final perfilEstudiante = await supabase
        .from('estudiante')
        .select('id')
        .eq('usuario_id', userId)
        .maybeSingle();

    print('   Perfil estudiante encontrado: ${perfilEstudiante != null}');

    if (perfilEstudiante != null) {
      print('   ✅ MODO ESTUDIANTE');
      return await _getDashboardDataEstudiante(userId, desde: desde, hasta: hasta);
    } else {
      print('   ✅ MODO DOCENTE');
      return await _getDashboardDataDocente(userId, desde: desde, hasta: hasta);
    }
  }

  /// Obtiene datos individuales de un estudiante
  Future<DashboardData> _getDashboardDataEstudiante(
    String userId, {
    DateTime? desde,
    DateTime? hasta,
  }) async {
    print('   [ESTUDIANTE DASHBOARD] userId: $userId');

    final estudiante = await supabase
        .from('estudiante')
        .select('id, usuario_id, xp_total, xp_hoy, racha_dias, lecciones_completadas_total, escaneos_exitosos, vocablos_aprendidos, tiempo_estudio, tiempo_total_estudio')
        .eq('usuario_id', userId)
        .single();

    print('   Estudiante data: $estudiante');

    // XP basado en campos xp_hoy y xp_total (sin xp_records)
    final xpPorDia = _getDailyXpFromEstudiante(estudiante);
    final actividadPorCategoria = await _getActivityByCategory(userId);
    final progresoSemanal = await _getWeeklyProgress(userId);
    final progresoNivel =
        _calculateLevelProgress((estudiante['xp_total'] as int?) ?? 0);

    final totalXp = (estudiante['xp_total'] as int?) ?? 0;
    final racha = (estudiante['racha_dias'] as int?) ?? 0;
    final lecciones = (estudiante['lecciones_completadas_total'] as int?) ?? 0;
    final escaneos = (estudiante['escaneos_exitosos'] as int?) ?? 0;
    final vocablos = (estudiante['vocablos_aprendidos'] as int?) ?? 0;
    // Intentar con ambos nombres de campo por si hay inconsistencia
    final tiempo = (estudiante['tiempo_estudio'] as int?) ??
                   (estudiante['tiempo_total_estudio'] as int?) ??
                   0;

    print('   Valores finales - XP: $totalXp, Racha: $racha, Lecciones: $lecciones, Tiempo: $tiempo');

    return DashboardData(
      totalXp: totalXp,
      racha: racha,
      lecciones: lecciones,
      escaneos: escaneos,
      xpPorDia: xpPorDia,
      actividadPorCategoria: actividadPorCategoria,
      progresoSemanal: progresoSemanal,
      progresoNivel: progresoNivel,
      vocablosAprendidos: vocablos,
      tiempoTotalEstudio: tiempo,
    );
  }

  /// Obtiene datos agregados de todos los estudiantes de un docente
  Future<DashboardData> _getDashboardDataDocente(
    String maestroUsuarioId, {
    DateTime? desde,
    DateTime? hasta,
  }) async {
    print('🔍 [DOCENTE DASHBOARD] MaestroUsuarioId: $maestroUsuarioId');

    // 1. Obtener el registro de maestro correspondiente al usuario_id
    final maestro = await supabase
        .from('maestro')
        .select('id')
        .eq('usuario_id', maestroUsuarioId)
        .maybeSingle();

    print('   Maestro encontrado: $maestro');

    if (maestro == null) {
      print('   ⚠️ No se encontró registro en tabla maestro');
      return DashboardData.empty();
    }

    final maestroId = maestro['id'] as String;
    print('   Maestro ID: $maestroId');

    // 2. Obtener TODOS los estudiantes asignados a este maestro
    final estudiantes = await supabase
        .from('estudiante')
        .select('id, usuario_id, xp_total, xp_hoy, racha_dias, lecciones_completadas_total, escaneos_exitosos, vocablos_aprendidos, tiempo_estudio, tiempo_total_estudio')
        .eq('maestro_id', maestroId);

    print('   Estudiantes crudos: ${estudiantes.length}');
    print('   Datos estudiantes: $estudiantes');

    if (estudiantes.isEmpty) {
      print('   ⚠️ No hay estudiantes asignados');
      return DashboardData.empty();
    }

    final List<Map<String, dynamic>> estudiantesList =
        List<Map<String, dynamic>>.from(estudiantes);

    // 3. Obtener usuario_ids de los estudiantes (para consultas de actividad)
    final usuarioIds = estudiantesList
        .map((e) => e['usuario_id'] as String?)
        .where((id) => id != null && id!.isNotEmpty)
        .cast<String>()
        .toList();

    print('   Usuario IDs válidos: $usuarioIds');

    // 4. Agregar métricas totals desde la tabla estudiante
    int totalXp = 0;
    int totalRacha = 0;
    int totalLecciones = 0;
    int totalEscaneos = 0;
    int totalVocablos = 0;
    int totalTiempo = 0;

    for (final est in estudiantesList) {
      final xpTotal = (est['xp_total'] as int?) ?? 0;
      final racha = (est['racha_dias'] as int?) ?? 0;
      final lecciones = (est['lecciones_completadas_total'] as int?) ?? 0;
      final escaneos = (est['escaneos_exitosos'] as int?) ?? 0;
      final vocablos = (est['vocablos_aprendidos'] as int?) ?? 0;
      final tiempo = (est['tiempo_estudio'] as int?) ?? 0;

      totalXp += xpTotal;
      totalRacha += racha;
      totalLecciones += lecciones;
      totalEscaneos += escaneos;
      totalVocablos += vocablos;
      totalTiempo += tiempo;

      print('   Estudiante ${est['id']}: XP=$xpTotal, Racha=$racha, Lecciones=$lecciones, Escaneos=$escaneos');
    }

    print('   TOTALS - XP: $totalXp, Racha: $totalRacha, Lecciones: $totalLecciones, Escaneos: $totalEscaneos');

    // 5. Obtener datos de gráficos (sin xp_records)
    final xpPorDia = _getDailyXpFromEstudiantes(estudiantesList);
    print('   XP por día generado: $xpPorDia');

    final actividadPorCategoria = await _getActivityByCategoryAggregate(usuarioIds);
    print('   Actividad por categoría: $actividadPorCategoria');

    final progresoSemanal = await _getWeeklyProgressAggregate(usuarioIds);
    print('   Progreso semanal: $progresoSemanal');

    final progresoNivel = _calculateLevelProgress(totalXp);
    print('   Progreso de nivel: $progresoNivel');

    return DashboardData(
      totalXp: totalXp,
      racha: totalRacha,
      lecciones: totalLecciones,
      escaneos: totalEscaneos,
      xpPorDia: xpPorDia,
      actividadPorCategoria: actividadPorCategoria,
      progresoSemanal: progresoSemanal,
      progresoNivel: progresoNivel,
      vocablosAprendidos: totalVocablos,
      tiempoTotalEstudio: totalTiempo,
    );
  }

  /// Genera datos de XP a partir de un solo estudiante (xp_hoy vs xp_total)
  List<ChartData> _getDailyXpFromEstudiante(Map<String, dynamic> estudiante) {
    final xpTotal = (estudiante['xp_total'] ?? 0).toDouble();
    final xpHoy = (estudiante['xp_hoy'] ?? 0).toDouble();
    final now = DateTime.now();

    return [
      ChartData(label: 'Hoy', valor: xpHoy, fecha: now),
      ChartData(label: 'Total', valor: xpTotal, fecha: now),
    ];
  }

  /// Genera datos de XP agregados a partir de una lista de estudiantes
  List<ChartData> _getDailyXpFromEstudiantes(
    List<Map<String, dynamic>> estudiantes,
  ) {
    double totalXpHoy = 0;
    double totalXp = 0;

    print('📊 [XP FROM ESTUDIANTES] Procesando ${estudiantes.length} estudiantes');

    for (final est in estudiantes) {
      final xpHoy = (est['xp_hoy'] ?? 0);
      final xpTotal = (est['xp_total'] ?? 0);
      print('   Estudiante ID: ${est['id']} - XP Hoy: $xpHoy, XP Total: $xpTotal');
      totalXpHoy += xpHoy.toDouble();
      totalXp += xpTotal.toDouble();
    }

    print('   TOTAL - Hoy: $totalXpHoy, Total: $totalXp');

    final now = DateTime.now();
    return [
      ChartData(label: 'XP Hoy (Todos)', valor: totalXpHoy, fecha: now),
      ChartData(label: 'XP Total (Todos)', valor: totalXp, fecha: now),
    ];
  }

  Future<List<ChartData>> _getActivityByCategory(String userId) async {
    try {
      final result = await supabase
          .from('actividad_categoria')
          .select('categoria, total_actividades')
          .eq('usuario_id', userId);

      return result
          .map((row) => ChartData(
                label: row['categoria'] as String,
                valor: (row['total_actividades'] as int).toDouble(),
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Agrega actividad por categoría de múltiples estudiantes
  Future<List<ChartData>> _getActivityByCategoryAggregate(
    List<String> usuarioIds) async {
    try {
      if (usuarioIds.isEmpty) {
        print('   ⚠️ No hay usuarioIds para actividad por categoría');
        return [];
      }

      print('   📊 Consultando actividad_categoria para usuarios: $usuarioIds');
      final result = await supabase
          .from('actividad_categoria')
          .select('categoria, total_actividades')
          .inFilter('usuario_id', usuarioIds);

      print('   Resultado actividad_categoria: $result');

      // Agrupar por categoría y sumar actividades
      final Map<String, double> actividadesPorCategoria = {};

      for (final row in result) {
        final categoria = row['categoria'] as String;
        final actividades = (row['total_actividades'] as int).toDouble();
        actividadesPorCategoria[categoria] =
            (actividadesPorCategoria[categoria] ?? 0) + actividades;
      }

      final lista = actividadesPorCategoria.entries
          .map((entry) => ChartData(
                label: entry.key,
                valor: entry.value,
              ))
          .toList();

      print('   Actividad agregada: $lista');
      return lista;
    } catch (e) {
      print('   ❌ Error en _getActivityByCategoryAggregate: $e');
      return [];
    }
  }

  Future<List<ChartData>> _getWeeklyProgress(String userId) async {
    try {
      final result = await supabase
          .from('progreso_semanal')
          .select('semana, lecciones_completadas')
          .eq('usuario_id', userId)
          .limit(4)
          .order('semana', ascending: false);

      return result
          .map((row) => ChartData(
                label: 'Semana ${row['semana']}',
                valor: (row['lecciones_completadas'] as int).toDouble(),
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Agrega progreso semanal de múltiples estudiantes
  Future<List<ChartData>> _getWeeklyProgressAggregate(
    List<String> usuarioIds) async {
    try {
      if (usuarioIds.isEmpty) {
        print('   ⚠️ No hay usuarioIds para progreso semanal');
        return [];
      }

      print('   📊 Consultando progreso_semanal para usuarios: $usuarioIds');
      final result = await supabase
          .from('progreso_semanal')
          .select('semana, lecciones_completadas')
          .inFilter('usuario_id', usuarioIds)
          .order('semana', ascending: false);

      print('   Resultado progreso_semanal: $result');

      // Agrupar por semana y sumar lecciones
      final Map<int, double> progresoPorSemana = {};

      for (final row in result) {
        final semana = row['semana'] as int;
        final lecciones = (row['lecciones_completadas'] as int).toDouble();
        progresoPorSemana[semana] = (progresoPorSemana[semana] ?? 0) + lecciones;
      }

      // Convertir a lista y ordenar descendente (semana más reciente primero)
      final lista = progresoPorSemana.entries
          .map((entry) => ChartData(
                label: 'Semana ${entry.key}',
                valor: entry.value,
              ))
          .toList()
        ..sort((a, b) {
          final aNum = int.tryParse(a.label.replaceAll('Semana ', '')) ?? 0;
          final bNum = int.tryParse(b.label.replaceAll('Semana ', '')) ?? 0;
          return bNum.compareTo(aNum); // DESC
        });

      final resultado = lista.take(4).toList();
      print('   Progreso semanal agregado: $resultado');
      return resultado;
    } catch (e) {
      print('   ❌ Error en _getWeeklyProgressAggregate: $e');
      return [];
    }
  }

  List<ChartData> _calculateLevelProgress(int totalXp) {
    const xpPerLevel = 1000;
    final currentLevel = (totalXp / xpPerLevel).floor();
    final xpForCurrentLevel = totalXp % xpPerLevel;
    final xpNeededForNextLevel = xpPerLevel - xpForCurrentLevel;

    return [
      ChartData(label: 'XP Actual', valor: xpForCurrentLevel.toDouble()),
      ChartData(
          label: 'XP Necesario', valor: xpNeededForNextLevel.toDouble()),
      ChartData(label: 'Nivel', valor: currentLevel.toDouble()),
    ];
  }

  DashboardData _getEmptyDashboard() {
    return DashboardData(
      totalXp: 0,
      racha: 0,
      lecciones: 0,
      escaneos: 0,
      xpPorDia: [],
      actividadPorCategoria: [],
      progresoSemanal: [],
      progresoNivel: [],
    );
  }

  // ========================================
  // HISTORIAL Y EVENTOS
  // ========================================

  Future<List<DashboardData>> getDashboardHistory(
    String userId,
    DateTime desde,
    DateTime hasta,
  ) async {
    return await localDb.getDashboardHistory(userId, desde, hasta);
  }

  Future<void> saveEvento(
    String userId,
    String tipoEvento,
    int valor, {
    String? categoria,
    Map<String, dynamic>? metadata,
  }) async {
    await localDb.saveEvento(userId, tipoEvento, valor,
        categoria: categoria, metadata: metadata);
  }

  Future<List<Map<String, dynamic>>> getEventos(
    String userId,
    DateTime desde,
    DateTime hasta,
  ) async {
    return await localDb.getEventos(userId, desde, hasta);
  }
}
