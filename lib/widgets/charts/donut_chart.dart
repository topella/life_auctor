import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DonutChart extends StatelessWidget {
  final List<DonutChartData> data;
  final double size;
  final double centerHoleRadius;

  const DonutChart({
    super.key,
    required this.data,
    this.size = 200,
    this.centerHoleRadius = 60,
  });

  @override
  Widget build(BuildContext context) {
    // if all values are zero
    final totalValue = data.fold<double>(0, (sum, item) => sum + item.value);
    final hasData = totalValue > 0;

    return SizedBox(
      height: size,
      width: size,
      child: PieChart(
        PieChartData(
          sectionsSpace: hasData ? 2 : 0,
          centerSpaceRadius: centerHoleRadius,
          sections: hasData
              ? data
                    .where(
                      (item) => item.value > 0,
                    ) // Only show non-zero values
                    .map((item) {
                      return PieChartSectionData(
                        value: item.value,
                        title: item.percentage,
                        color: item.color,
                        radius: (size - centerHoleRadius * 2) / 2,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        badgeWidget: item.showBadge
                            ? Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  item.icon,
                                  color: item.color,
                                  size: 16,
                                ),
                              )
                            : null,
                        badgePositionPercentageOffset: 1.3,
                      );
                    })
                    .toList()
              : [
                  // Show gray placeholder when no data
                  PieChartSectionData(
                    value: 1,
                    title: '',
                    color: Colors.grey.shade300,
                    radius: (size - centerHoleRadius * 2) / 2,
                    titleStyle: const TextStyle(fontSize: 0),
                  ),
                ],
        ),
      ),
    );
  }
}

class DonutChartData {
  final double value;
  final String percentage;
  final Color color;
  final IconData? icon;
  final bool showBadge;

  DonutChartData({
    required this.value,
    required this.percentage,
    required this.color,
    this.icon,
    this.showBadge = false,
  });
}
