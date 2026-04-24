import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kankui_app/models/dashboard_data.dart';

class RadarChartWidget extends StatelessWidget {
  final List<ChartData> data;
  final String? title;
  final Color? fillColor;
  final Color? bgColor;

  const RadarChartWidget({
    super.key,
    required this.data,
    this.title,
    this.fillColor,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    if (data.length < 3) {
      return _buildEmptyState(context);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = bgColor ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white);
    final baseColor = fillColor ?? const Color(0xFFD4730A);

    final chartData = data.length > 6 ? data.sublist(0, 6) : data;

    final maxValue = chartData
        .map((e) => e.valor)
        .reduce((a, b) => a > b ? a : b);

    final safeMax = maxValue <= 0 ? 10.0 : maxValue * 1.2;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          if (title != null)
            Text(
              title!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: RadarChart(
              RadarChartData(
                dataSets: [
                  RadarDataSet(
                    dataEntries: chartData
                        .map((e) => RadarEntry(value: e.valor))
                        .toList(),
                    fillColor: baseColor.withOpacity(0.4),
                    borderColor: baseColor,
                    borderWidth: 2,
                  ),
                ],

                // 🔥 IMPORTANTE: estos nombres cambiaron
                radarBorderData: const BorderSide(color: Colors.grey),
                gridBorderData: const BorderSide(color: Colors.grey),
                tickBorderData: const BorderSide(color: Colors.grey),

                titlePositionPercentageOffset: 0.2,

                // ✅ NUEVA FORMA en v1.x
                getTitle: (index, angle) {
                  if (index >= chartData.length) {
                    return const RadarChartTitle(text: '');
                  }

                  final label = chartData[index].label;

                  return RadarChartTitle(
                    text: label.length > 10
                        ? '${label.substring(0, 8)}…'
                        : label,
                  );
                },

                // 🔥 CAMBIO CLAVE: ya NO es maxValue
             
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: bgColor ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.radar, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          const Text(
            'Se necesitan al menos 3 datos',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}