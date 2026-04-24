// Si usas fl_chart para gráficos

class DashboardData {
  final int totalXp;
  final int racha;
  final int lecciones;
  final int escaneos;
  final List<ChartData> xpPorDia;
  final List<ChartData> actividadPorCategoria;
  final List<ChartData> progresoSemanal;
  final List<ChartData> progresoNivel;
  final int vocablosAprendidos;
  final int tiempoTotalEstudio;

  DashboardData({
    required this.totalXp,
    required this.racha,
    required this.lecciones,
    required this.escaneos,
    required this.xpPorDia,
    required this.actividadPorCategoria,
    required this.progresoSemanal,
    required this.progresoNivel,
    this.vocablosAprendidos = 0,
    this.tiempoTotalEstudio = 0,
  });

  // Factory constructor para crear desde datos de Supabase
  factory DashboardData.fromSupabase(Map<String, dynamic> data) {
    return DashboardData(
      totalXp: data['total_xp'] ?? 0,
      racha: data['racha'] ?? 0,
      lecciones: data['lecciones_completadas'] ?? 0,
      escaneos: data['escaneos_exitosos'] ?? 0,
      xpPorDia: (data['xp_por_dia'] as List? ?? [])
          .map((e) => ChartData.fromJson(e))
          .toList(),
      actividadPorCategoria: (data['actividad_por_categoria'] as List? ?? [])
          .map((e) => ChartData.fromJson(e))
          .toList(),
      progresoSemanal: (data['progreso_semanal'] as List? ?? [])
          .map((e) => ChartData.fromJson(e))
          .toList(),
      progresoNivel: (data['progreso_nivel'] as List? ?? [])
          .map((e) => ChartData.fromJson(e))
          .toList(),
      vocablosAprendidos: data['vocablos_aprendidos'] ?? 0,
      tiempoTotalEstudio: data['tiempo_total_estudio'] ?? 0,
    );
  }

  // Dashboard vacío para cuando no hay datos
  factory DashboardData.empty() {
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

  // Copia con modificaciones
  DashboardData copyWith({
    int? totalXp,
    int? racha,
    int? lecciones,
    int? escaneos,
    List<ChartData>? xpPorDia,
    List<ChartData>? actividadPorCategoria,
    List<ChartData>? progresoSemanal,
    List<ChartData>? progresoNivel,
    int? vocablosAprendidos,
    int? tiempoTotalEstudio,
  }) {
    return DashboardData(
      totalXp: totalXp ?? this.totalXp,
      racha: racha ?? this.racha,
      lecciones: lecciones ?? this.lecciones,
      escaneos: escaneos ?? this.escaneos,
      xpPorDia: xpPorDia ?? this.xpPorDia,
      actividadPorCategoria:
          actividadPorCategoria ?? this.actividadPorCategoria,
      progresoSemanal: progresoSemanal ?? this.progresoSemanal,
      progresoNivel: progresoNivel ?? this.progresoNivel,
      vocablosAprendidos: vocablosAprendidos ?? this.vocablosAprendidos,
      tiempoTotalEstudio: tiempoTotalEstudio ?? this.tiempoTotalEstudio,
    );
  }
}

class ChartData {
  final String label;
  final double valor;
  final DateTime? fecha;

  ChartData({
    required this.label,
    required this.valor,
    this.fecha,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      label: json['label'] ?? '',
      valor: (json['valor'] ?? 0).toDouble(),
      fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'valor': valor,
        'fecha': fecha?.toIso8601String(),
      };
}
