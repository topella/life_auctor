import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_auctor/providers/item_provider_v3.dart';
import 'package:life_auctor/widgets/nav_bar/app_bar.dart';
import 'package:life_auctor/widgets/analytics/period_selector.dart';
import 'package:life_auctor/widgets/analytics/product_statistics_card.dart';
import 'package:life_auctor/widgets/analytics/expense_history_card.dart';
import 'package:life_auctor/widgets/analytics/frequently_expired_card.dart';
import 'package:life_auctor/utils/analytics_calculator.dart';
import 'package:life_auctor/theme/app_sizes.dart';
import 'package:life_auctor/theme/app_text_styles.dart';

class AnalyticsScreen extends StatefulWidget {
  final Function(int)? onNavigate;
  final VoidCallback? onBack;

  const AnalyticsScreen({super.key, this.onNavigate, this.onBack});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'Week';
  final List<String> _periods = ['Week', 'Month', 'Quarter', 'All time'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      appBar: CustomAppBar(
        showBackButton: true,
        onBack: widget.onBack,
      ),
      body: SafeArea(
        child: Consumer<ItemProviderV3>(
          builder: (context, itemProvider, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                // Calculate responsive sizes
                final padding = AppSizes.padding(width);
                final titleSize = AppSizes.titleSize(width);
                final sectionTitleSize = AppSizes.sectionTitleSize(width);
                final labelSize = AppSizes.labelSize(width);
                final valueSize = AppSizes.valueSize(width);
                final percentSize = AppSizes.percentSize(width);
                final chartSize = AppSizes.chartSize(width);

                // Calculate analytics data
                final productStats = AnalyticsCalculator.calculateProductStats(
                  itemProvider.items,
                  _selectedPeriod,
                );
                final expenseData = AnalyticsCalculator.calculateExpenseHistory(
                  itemProvider.items,
                );
                final frequentlyExpired =
                    AnalyticsCalculator.getFrequentlyExpired(
                      itemProvider.items,
                    );

                return SingleChildScrollView(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analytics',
                        style: AppTextStyles.title(context, titleSize),
                      ),
                      SizedBox(height: padding),

                      PeriodSelector(
                        selectedPeriod: _selectedPeriod,
                        periods: _periods,
                        onPeriodChanged: (period) =>
                            setState(() => _selectedPeriod = period),
                        padding: padding,
                        fontSize: labelSize,
                      ),

                      SizedBox(height: padding * 1.5),

                      ProductStatisticsCard(
                        data: productStats,
                        padding: padding,
                        titleSize: sectionTitleSize,
                        labelSize: labelSize,
                        valueSize: valueSize,
                        percentSize: percentSize,
                        chartSize: chartSize,
                      ),

                      SizedBox(height: padding * 1.5),

                      ExpenseHistoryCard(
                        data: expenseData,
                        padding: padding,
                        titleSize: sectionTitleSize,
                        valueSize: valueSize,
                      ),

                      SizedBox(height: padding * 1.5),

                      FrequentlyExpiredCard(
                        products: frequentlyExpired,
                        padding: padding,
                        titleSize: sectionTitleSize,
                        labelSize: labelSize,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
