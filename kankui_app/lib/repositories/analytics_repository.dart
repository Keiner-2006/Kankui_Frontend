import 'package:kankui_app/data/local/analytics_local_db.dart';
import 'package:kankui_app/models/dashboard_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsRepository {
  final SupabaseClient supabase;
  final AnalyticsLocalDB localDb;

  AnalyticsRepository(this.supabase, this.localDb);

  Future<DashboardData> getDashboardData(String userId) async {
    return await _getDashboardDataInternal(userId);
  }

  Future<DashboardData> getDashboardDataForRange(
    String userId,
    DateTime desde,
    DateTime hasta,
  ) async {
    return await _getDashboardDataInternal(userId);
  }

  Future<DashboardData> _getDashboardDataInternal(
    String userId,
  ) async {
    try {
      final remote = await _getRemoteData(userId);
      await localDb.saveDashboard(remote, userId);
      return remote;
    } catch (e) {
      final cached = await localDb.getLatestDashboard(userId);
      return cached ?? _getEmptyDashboard();
    }
  }

  Future<DashboardData> _getRemoteData(String userId) async {
  print('🚀 INICIANDO FETCH DE ESTUDIANTES');

  final estudiantes = await supabase
      .from('estudiante')
      .select();

  print('📊 TOTAL ESTUDIANTES: ${estudiantes.length}');
  print('📦 DATA CRUDA: $estudiantes');

  if (estudiantes.isEmpty) {
    print('❌ NO HAY ESTUDIANTES');
    return _getEmptyDashboard();
  }

  int totalXp = 0;
  double totalXpHoy = 0;

  for (final est in estudiantes) {
    print('-----------------------------');
    print('👤 Estudiante completo: $est');

    final xpRaw = est['xp_total'];
    final xpHoyRaw = est['xp_hoy'];

    print('➡️ xp_total RAW: $xpRaw (${xpRaw.runtimeType})');
    print('➡️ xp_hoy RAW: $xpHoyRaw (${xpHoyRaw.runtimeType})');

    final xp = (xpRaw ?? 0);
    final xpHoy = (xpHoyRaw ?? 0);

    print('✅ xp_total procesado: $xp');
    print('✅ xp_hoy procesado: $xpHoy');

    totalXp += (xp as num).toInt();
    totalXpHoy += (xpHoy as num).toDouble();
  }

  print('=============================');
  print('🔥 TOTAL XP FINAL: $totalXp');
  print('🔥 TOTAL XP HOY FINAL: $totalXpHoy');

  return DashboardData(
    totalXp: totalXp,
    racha: 0,
    lecciones: 0,
    escaneos: 0,
    xpPorDia: [
      ChartData(label: 'Hoy', valor: totalXpHoy),
      ChartData(label: 'Total', valor: totalXp.toDouble()),
    ],
    actividadPorCategoria: [],
    progresoSemanal: [],
    progresoNivel: _calculateLevelProgress(totalXp),
    vocablosAprendidos: 0,
    tiempoTotalEstudio: 0,
  );
}

  // ============================
  // 👤 ESTUDIANTE
  // ============================

  Future<DashboardData> _getDashboardDataEstudiante(
    String userId,
  ) async {
    final est = await supabase
        .from('estudiante')
        .select()
        .eq('usuario_id', userId)
        .single();

    final xpTotal = (est['xp_total'] ?? 0) as int;
    final xpHoy = (est['xp_hoy'] ?? 0) as int;

    return DashboardData(
      totalXp: xpTotal,
      racha: (est['racha_dias'] ?? 0),
      lecciones: (est['lecciones_completadas_total'] ?? 0),
      escaneos: (est['escaneos_exitosos'] ?? 0),
      xpPorDia: [
        ChartData(label: 'Hoy', valor: xpHoy.toDouble()),
        ChartData(label: 'Total', valor: xpTotal.toDouble()),
      ],
      actividadPorCategoria: [],
      progresoSemanal: [],
      progresoNivel: _calculateLevelProgress(xpTotal),
      vocablosAprendidos: (est['vocablos_aprendidos'] ?? 0),
      tiempoTotalEstudio:
          (est['tiempo_estudio'] ?? est['tiempo_total_estudio'] ?? 0),
    );
  }

  // ============================
  // 👨‍🏫 DOCENTE
  // ============================

  Future<DashboardData> _getDashboardDataDocente(
    String maestroUsuarioId,
  ) async {
    // 1. Obtener maestro
    final maestro = await supabase
        .from('maestro')
        .select('id')
        .eq('usuario_id', maestroUsuarioId)
        .maybeSingle();

    if (maestro == null) {
      return _getEmptyDashboard();
    }

    final maestroId = maestro['id'];

    // 2. Obtener estudiantes
    final estudiantes = await supabase
        .from('estudiante')
        .select()
        .eq('maestro_id', maestroId);

    if (estudiantes.isEmpty) {
      return _getEmptyDashboard();
    }

    int totalXp = 0;
    int totalRacha = 0;
    int totalLecciones = 0;
    int totalEscaneos = 0;
    int totalVocablos = 0;
    int totalTiempo = 0;
    double totalXpHoy = 0;

    for (final est in estudiantes) {
      totalXp += (est['xp_total'] ?? 0) as int;
      totalRacha += (est['racha_dias'] ?? 0) as int;
      totalLecciones += (est['lecciones_completadas_total'] ?? 0) as int;
      totalEscaneos += (est['escaneos_exitosos'] ?? 0) as int;
      totalVocablos += (est['vocablos_aprendidos'] ?? 0) as int;
      totalTiempo += (est['tiempo_estudio'] ?? 0) as int;
      totalXpHoy += (est['xp_hoy'] ?? 0).toDouble();
    }

    return DashboardData(
      totalXp: totalXp,
      racha: totalRacha,
      lecciones: totalLecciones,
      escaneos: totalEscaneos,
      xpPorDia: [
        ChartData(label: 'Hoy', valor: totalXpHoy),
        ChartData(label: 'Total', valor: totalXp.toDouble()),
      ],
      actividadPorCategoria: [],
      progresoSemanal: [],
      progresoNivel: _calculateLevelProgress(totalXp),
      vocablosAprendidos: totalVocablos,
      tiempoTotalEstudio: totalTiempo,
    );
  }

  // ============================
  // 📊 NIVEL
  // ============================

  List<ChartData> _calculateLevelProgress(int totalXp) {
    const xpPerLevel = 1000;
    final currentLevel = (totalXp / xpPerLevel).floor();
    final xpForCurrentLevel = totalXp % xpPerLevel;
    final xpNeeded = xpPerLevel - xpForCurrentLevel;

    return [
      ChartData(label: 'XP Actual', valor: xpForCurrentLevel.toDouble()),
      ChartData(label: 'XP Restante', valor: xpNeeded.toDouble()),
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
}