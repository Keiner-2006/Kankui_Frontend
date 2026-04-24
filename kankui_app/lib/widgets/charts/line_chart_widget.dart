import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kankui_app/models/dashboard_data.dart';

class LineChartWidget extends StatelessWidget {
  final List<ChartData> data;
  final String? title;
  final Color? lineColor;
  final Color? bgColor;

  const LineChartWidget({
    super.key,
    required this.data,
    this.title,
    this.lineColor,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBgColor =
        bgColor ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white);
    final effectiveLineColor = lineColor ?? const Color(0xFF5C2E00);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: effectiveBgColor,
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
            child: LineChart(
              _buildLineChartData(effectiveBgColor, effectiveLineColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.timeline, size: 14, color: effectiveLineColor),
              const SizedBox(width: 4),
              Text(
                '${data.length} puntos',
                style: TextStyle(
                  fontSize: 11,
                  color: effectiveBgColor.computeLuminance() > 0.5
                      ? Colors.black54
                      : Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  LineChartData _buildLineChartData(Color bgColor, Color lineColor) {
  return LineChartData(
    maxY: _getMaxY(),
    minY: 0,
    lineTouchData: LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (touchedSpot) => Colors.grey[800]!,
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((touchedSpot) {
            return LineTooltipItem(
              '${data[touchedSpot.spotIndex].label}\n',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: '${touchedSpot.y.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }).toList();
        },
      ),
    ),
    titlesData: FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < data.length) {
              // Usar Padding directamente
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  data[index].label,
                  style: TextStyle(
                    fontSize: 10,
                    color: bgColor.computeLuminance() > 0.5
                        ? Colors.black54
                        : Colors.white70,
                  ),
                ),
              );
            }
            return const SizedBox();
          },
          reservedSize: 30,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                value.toInt().toString(),
                style: TextStyle(
                  fontSize: 10,
                  color: bgColor.computeLuminance() > 0.5
                      ? Colors.black54
                      : Colors.white70,
                ),
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false)
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false)
      ),
    ),
    gridData: FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: _getMaxY() / 5,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: bgColor.computeLuminance() > 0.5
              ? Colors.grey[300]!
              : Colors.grey[700]!,
          strokeWidth: 0.5,
        );
      },
    ),
    borderData:  FlBorderData(show: false),
    lineBarsData: [
      LineChartBarData(
        spots: data.asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.valor.toDouble());
        }).toList(),
        isCurved: true,
        color: lineColor,
        barWidth: 3,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 5,
              color: lineColor,
              strokeWidth: 2,
              strokeColor: bgColor,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          color: lineColor.withOpacity(0.2),
        ),
      ),
    ],
  );
}

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timeline, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'Sin datos disponibles',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  double _getMaxY() {
    if (data.isEmpty) return 10;
    final maxValue = data.map((d) => d.valor).reduce((a, b) => a > b ? a : b);
    return (maxValue / 10).ceil() * 10 + 10;
  }
}