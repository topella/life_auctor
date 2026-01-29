import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DonutChartAnalytics extends StatelessWidget {
  final double size;
  final int usedCount;
  final int expiredCount;

  const DonutChartAnalytics({
    super.key,
    required this.size,
    required this.usedCount,
    required this.expiredCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = usedCount + expiredCount;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: size * 0.25,
              sections: _buildSections(total),
              startDegreeOffset: -90,
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Text(
                '$total',
                style: TextStyle(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(int total) {
    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey.shade300,
          value: 1,
          title: '',
          radius: size * 0.2,
          showTitle: false,
        ),
      ];
    }

    return [
      PieChartSectionData(
        color: const Color(0xFF8AC926),
        value: usedCount.toDouble(),
        title: '',
        radius: size * 0.2,
        showTitle: false,
      ),
      PieChartSectionData(
        color: Colors.red.shade300,
        value: expiredCount.toDouble(),
        title: '',
        radius: size * 0.2,
        showTitle: false,
      ),
    ];
  }
}
