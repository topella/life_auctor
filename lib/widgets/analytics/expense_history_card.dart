import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:life_auctor/utils/analytics_calculator.dart';
import 'package:life_auctor/theme/app_text_styles.dart';

class ExpenseHistoryCard extends StatelessWidget {
  final ExpenseData data;
  final double padding;
  final double titleSize;
  final double valueSize;

  const ExpenseHistoryCard({
    super.key,
    required this.data,
    required this.padding,
    required this.titleSize,
    required this.valueSize,
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
          Text('Expense History', style: AppTextStyles.title(context, titleSize)),
          SizedBox(height: padding * 0.7),
          Text('Spent in this month:', style: AppTextStyles.label(context, valueSize * 0.85)),
          SizedBox(height: padding * 0.3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '€${data.currentMonthTotal.toStringAsFixed(2)}',
                style: AppTextStyles.value(context, valueSize * 1.8),
              ),
              if (data.prevMonthTotal > 0) ...[
                SizedBox(width: padding * 0.5),
                Padding(
                  padding: EdgeInsets.only(bottom: padding * 0.3),
                  child: Text(
                    '${data.percentChange >= 0 ? '+' : ''}${data.percentChange.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: valueSize * 0.9,
                      color: data.percentChange < 0 ? const Color(0xFF8AC926) : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: padding),
          if (data.monthlyExpenses.any((e) => e > 0))
            _FlBarChart(expenses: data.monthlyExpenses, padding: padding, isDark: isDark)
          else
            Padding(
              padding: EdgeInsets.symmetric(vertical: padding),
              child: Text(
                'No expense data yet. Add prices to items to track expenses.',
                style: TextStyle(
                  fontSize: valueSize * 0.75,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FlBarChart extends StatelessWidget {
  final List<double> expenses;
  final double padding;
  final bool isDark;

  const _FlBarChart({
    required this.expenses,
    required this.padding,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxHeight = width * 0.2;

    final colors = [
      Colors.red.shade300,
      Colors.orange.shade300,
      Colors.yellow.shade600,
      Colors.lime.shade500,
      const Color(0xFF8AC926),
    ];

    return SizedBox(
      height: maxHeight,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY: expenses.reduce((a, b) => a > b ? a : b) * 1.2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: false,
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          barGroups: List.generate(expenses.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: expenses[index],
                  color: colors[index % colors.length],
                  width: width * 0.1,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
