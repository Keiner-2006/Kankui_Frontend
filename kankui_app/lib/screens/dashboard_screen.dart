import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/models/dashboard_data.dart';
import 'package:kankui_app/repositories/analytics_repository.dart';
import 'package:kankui_app/services/export_service.dart';
import 'package:kankui_app/widgets/kpi_card.dart';
import 'package:kankui_app/widgets/filter_bar.dart';
import 'package:kankui_app/widgets/charts/bar_chart_widget.dart';
import 'package:kankui_app/widgets/charts/line_chart_widget.dart';
import 'package:kankui_app/widgets/charts/pie_chart_widget.dart';
import 'package:kankui_app/widgets/charts/custom_chart_widget.dart';

/// Pantalla principal de Analytics Dashboard para Docentes
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey _dashboardKey = GlobalKey();
  final AnalyticsRepository _analyticsRepo = GetIt.I<AnalyticsRepository>();
  final ExportService _exportService = ExportService();

  DateFilter _currentFilter = DateFilter.week;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  DashboardData? _dashboardData;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _currentFilter = DateFilter.week;
    _loadDashboard();
  }

  /// Carga datos aplicando el filtro actualmente seleccionado
  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      DashboardData data;

      // Determinar rango según filtro
      if (_currentFilter == DateFilter.custom &&
          _customStartDate != null &&
          _customEndDate != null) {
        // Rango personalizado explícito
              data = await _analyticsRepo.getDashboardDataForRange(
          user.id,
          _customStartDate!,
          _customEndDate!,
        );
      } else {
        // Filtro predefinido: calcular fechas
        final now = DateTime.now();
        DateTime desde;

        switch (_currentFilter) {
          case DateFilter.today:
            desde = DateTime(now.year, now.month, now.day);
            break;
          case DateFilter.week:
            desde = now.subtract(const Duration(days: 7));
            break;
          case DateFilter.month:
            desde = DateTime(now.year, now.month, 1);
            break;
          case DateFilter.custom:
            // Si no hay rango custom definido, usar última semana por defecto
            desde = now.subtract(const Duration(days: 7));
            break;
        }

        data = await _analyticsRepo.getDashboardDataForRange(
            user.id, desde, now);
      }

      if (mounted) {
        setState(() {
          _dashboardData = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _onFilterChanged(DateFilter filter) async {
    setState(() {
      _currentFilter = filter;
    });
    await _loadDashboard();
  }

  Future<void> _onCustomRangeSelected(DateTimeRange range) async {
    setState(() {
      _customStartDate = range.start;
      _customEndDate = range.end;
    });
    await _loadDashboard();
  }

  Future<void> _exportAsPdf() async {
    if (_dashboardData == null) return;

    final user = Supabase.instance.client.auth.currentUser;
    final metadata = await Supabase.instance.client
        .from('usuario')
        .select('nombre, institucion_id')
        .eq('id', user?.id ?? '')
        .maybeSingle();

    String userName = 'Docente';
    String institution = 'Institución';

    if (metadata != null) {
      userName = metadata['nombre'] as String? ?? 'Docente';
      // TODO: Obtener nombre de institución desde tabla institucion
    }

    await _exportService.exportDashboardAsPdf(
      context: context,
      userName: userName,
      institution: institution,
      data: _dashboardData!,
    );
  }

  Future<void> _exportAsImage() async {
    final imageBytes = await _exportService.exportAsImage(_dashboardKey);
    if (imageBytes != null) {
      final filePath = await _exportService.saveImageToStorage(imageBytes);
      if (mounted && filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dashboard guardado como imagen:\n$filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        color: const Color(0xFFD4730A),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          child: RepaintBoundary(
            key: _dashboardKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Filtros
                FilterBar(
                  selectedFilter: _currentFilter,
                  customStartDate: _customStartDate,
                  customEndDate: _customEndDate,
                  onFilterChanged: _onFilterChanged,
                  onCustomRangeSelected: _onCustomRangeSelected,
                ),

                const SizedBox(height: 16),

                // Estado de carga/error
                if (_loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        color: Color(0xFFD4730A),
                      ),
                    ),
                  )
                else if (_error != null)
                  _buildError()
                else if (_dashboardData != null)
                  _buildDashboardContent(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF5C2E00),
      elevation: 0,
      title: const Text(
        'Analytics Dashboard',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
          tooltip: 'Exportar PDF',
          onPressed: _exportAsPdf,
        ),
        IconButton(
          icon: const Icon(Icons.download, color: Colors.white),
          tooltip: 'Guardar Imagen',
          onPressed: _exportAsImage,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Error al cargar datos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Error desconocido',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadDashboard,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4730A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    final data = _dashboardData!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ========== KPIs ==========
        _buildKpisSection(data),

        const SizedBox(height: 24),

        // ========== Bar Chart: XP por día ==========
        if (data.xpPorDia.isNotEmpty)
          BarChartWidget(
            data: data.xpPorDia,
            title: 'XP por Día (últimos 7 días)',
            barColor: const Color(0xFFD4730A),
          )
        else
          _buildEmptyChart('XP por Día'),

        const SizedBox(height: 8),

        // ========== Line Chart: Progreso Semanal ==========
        if (data.progresoSemanal.isNotEmpty)
          LineChartWidget(
            data: data.progresoSemanal,
            title: 'Progreso Semanal (Lecciones)',
            lineColor: const Color(0xFF5C2E00),
          )
        else
          _buildEmptyChart('Progreso Semanal'),

        const SizedBox(height: 8),

        // ========== Charts Row: Pie + Radar ==========
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: data.actividadPorCategoria.isNotEmpty
                  ? PieChartWidget(
                      data: data.actividadPorCategoria,
                      title: 'Actividad por Categoría',
                    )
                  : _buildEmptyChart('Actividad por Categoría',
                      halfWidth: true),
            ),
            Expanded(
              child: data.progresoNivel.isNotEmpty
                  ? RadarChartWidget(
                      data: data.progresoNivel,
                      title: 'Progreso de Nivel',
                    )
                  : _buildEmptyChart('Progreso de Nivel', halfWidth: true),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ========== Footer Info ==========
        _buildFooterInfo(),
      ],
    );
  }

  Widget _buildKpisSection(DashboardData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Métricas Clave',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5C2E00),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                KpiCard(
                  label: 'XP Total',
                  value: data.totalXp,
                  icon: Icons.stars,
                  color: const Color(0xFFD4730A),
                ),
                KpiCard(
                  label: 'Racha Actual',
                  value: data.racha,
                  icon: Icons.local_fire_department,
                  color: const Color(0xFFFF6B35),
                  trend: data.racha > 0 ? '+${data.racha} días' : null,
                ),
                KpiCard(
                  label: 'Lecciones',
                  value: data.lecciones,
                  icon: Icons.book,
                  color: const Color(0xFF5C2E00),
                ),
                KpiCard(
                  label: 'Escaneos',
                  value: data.escaneos,
                  icon: Icons.qr_code_scanner,
                  color: const Color(0xFF4CAF50),
                ),
                if (data.vocablosAprendidos > 0)
                  KpiCard(
                    label: 'Vocablos',
                    value: data.vocablosAprendidos,
                    icon: Icons.translate,
                    color: const Color(0xFF9C27B0),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String title, {bool halfWidth = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'No hay datos para\n$title',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            'Datos sincronizados localmente • '
            'Última actualización: ${DateFormat('HH:mm').format(DateTime.now())}',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF8A6E5C),
            ),
          ),
        ],
      ),
    );
  }
}