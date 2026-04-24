import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kankui_app/models/dashboard_data.dart';

class PieChartWidget extends StatelessWidget {
  final List<ChartData> data;
  final String? title;
  final List<Color>? colors;
  final Color? bgColor;

  const PieChartWidget({
    super.key,
    required this.data,
    this.title,
    this.colors,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState(context);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBgColor =
        bgColor ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white);

    final defaultColors = [
      const Color(0xFFD4730A),
      const Color(0xFF5C2E00),
      const Color(0xFFF4A535),
      const Color(0xFF8B6914),
      const Color(0xFFD4956A),
      const Color(0xFFA67C52),
    ];

    final pieColors = colors ?? defaultColors;

    final total = data.fold<double>(0, (sum, item) => sum + item.valor);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                title!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: effectiveBgColor.computeLuminance() > 0.5
                      ? Colors.black87
                      : Colors.white,
                ),
              ),
            ),
          SizedBox(
            height: 250,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    _buildPieChartData(pieColors, total, effectiveBgColor),
                    duration: const Duration(milliseconds: 300),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child:
                      _buildLegend(data, pieColors, total, effectiveBgColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PieChartData _buildPieChartData(
      List<Color> colors, double total, Color bgColor) {
    return PieChartData(
      sectionsSpace: 2,
      centerSpaceRadius: 60,
      pieTouchData: PieTouchData(
        enabled: true,
        touchCallback: (event, response) {},
      ),
      sections: data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final percentage = total > 0 ? (item.valor / total) : 0.0;

        return PieChartSectionData(
          value: item.valor,
          color: colors[index % colors.length],
          radius: 50,
          title: percentage > 0.05
              ? '${(percentage * 100).toStringAsFixed(1)}%'
              : '',
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLegend(
    List<ChartData> data,
    List<Color> colors,
    double total,
    Color bgColor,
  ) {
    final isLight = bgColor.computeLuminance() > 0.5;
    final textColor = isLight ? Colors.black87 : Colors.white70;

    return ListView.separated(
      shrinkWrap: true,
      itemCount: data.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = data[index];
        final percentage = total > 0 ? (item.valor / total * 100) : 0.0;
        final color = colors[index % colors.length];

        return Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(fontSize: 12, color: textColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: bgColor ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pie_chart, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Sin datos disponibles',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}