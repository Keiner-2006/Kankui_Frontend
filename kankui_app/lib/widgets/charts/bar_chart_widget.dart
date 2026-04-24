import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kankui_app/models/dashboard_data.dart';

class BarChartWidget extends StatelessWidget {
  final List<ChartData> data;
  final String? title;
  final Color? barColor;
  final Color? bgColor;

  const BarChartWidget({
    super.key,
    required this.data,
    this.title,
    this.barColor,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBgColor =
        bgColor ?? (isDark ? Color(0xFF1E1E1E) : Colors.white);
    final effectiveBarColor = barColor ?? Color(0xFFD4730A);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
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
            child: BarChart(
              _buildBarChartData(effectiveBgColor, effectiveBarColor),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.bar_chart, size: 14, color: effectiveBarColor),
              SizedBox(width: 4),
              Text(
                '${data.length} categorías',
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

  BarChartData _buildBarChartData(Color bgColor, Color barColor) {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: _getMaxY(),
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.grey[800]!,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            if (groupIndex >= data.length) return null;
            return BarTooltipItem(
              data[groupIndex].label,
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: '\n${rod.toY.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(
                  fontSize: 10,
                  color: bgColor.computeLuminance() > 0.5
                      ? Colors.black54
                      : Colors.white70,
                ),
              );
            },
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
      borderData: FlBorderData(show: false),
      barGroups: data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: item.valor,
              color: barColor.withOpacity(0.8 - (index * 0.05)),
              width: 20,
              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart, size: 48, color: Colors.grey[300]),
          SizedBox(height: 12),
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
