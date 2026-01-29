import 'package:flutter/material.dart';
import 'package:life_auctor/utils/analytics_calculator.dart';
import 'package:life_auctor/widgets/charts/donut_chart_analytics.dart';
import 'package:life_auctor/theme/app_text_styles.dart';

class ProductStatisticsCard extends StatelessWidget {
  final AnalyticsData data;
  final double padding;
  final double titleSize;
  final double labelSize;
  final double valueSize;
  final double percentSize;
  final double chartSize;

  const ProductStatisticsCard({
    super.key,
    required this.data,
    required this.padding,
    required this.titleSize,
    required this.labelSize,
    required this.valueSize,
    required this.percentSize,
    required this.chartSize,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Product Statistics', style: AppTextStyles.title(context, titleSize)),
          SizedBox(height: padding),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatRow(
                      icon: Icons.add_circle_outline,
                      iconColor: const Color(0xFF8AC926),
                      label: 'Totally Added:',
                      value: data.totalAdded.toString(),
                      labelSize: labelSize,
                      valueSize: valueSize,
                      padding: padding,
                    ),
                    SizedBox(height: padding * 0.7),
                    _StatRow(
                      icon: Icons.check_circle_outline,
                      iconColor: const Color(0xFF8AC926),
                      label: 'Used Before Expiry:',
                      value: data.usedBeforeExpiry.toString(),
                      percent: '${data.usedPercent.toStringAsFixed(1)}%',
                      percentColor: const Color(0xFF8AC926),
                      labelSize: labelSize,
                      valueSize: valueSize,
                      percentSize: percentSize,
                      padding: padding,
                    ),
                    SizedBox(height: padding * 0.7),
                    _StatRow(
                      icon: Icons.cancel_outlined,
                      iconColor: Colors.red,
                      label: 'Expired:',
                      value: data.expiredItems.toString(),
                      percent: '${data.expiredPercent.toStringAsFixed(1)}%',
                      percentColor: Colors.red,
                      labelSize: labelSize,
                      valueSize: valueSize,
                      percentSize: percentSize,
                      padding: padding,
                    ),
                  ],
                ),
              ),
              SizedBox(width: padding),
              DonutChartAnalytics(
                size: chartSize,
                usedCount: data.usedBeforeExpiry,
                expiredCount: data.expiredItems,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? percent;
  final Color? percentColor;
  final double labelSize;
  final double valueSize;
  final double padding;
  final double? percentSize;

  const _StatRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.percent,
    this.percentColor,
    required this.labelSize,
    required this.valueSize,
    required this.padding,
    this.percentSize,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, color: iconColor, size: labelSize * 1.3),
        SizedBox(width: padding * 0.4),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: labelSize,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: valueSize,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        if (percent != null) ...[
          SizedBox(width: padding * 0.3),
          Text(
            percent!,
            style: TextStyle(
              fontSize: percentSize,
              color: percentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
