import 'package:flutter/material.dart';
import 'package:life_auctor/utils/analytics_calculator.dart';
import 'package:life_auctor/utils/date_formatter.dart';
import 'package:life_auctor/theme/app_text_styles.dart';

class FrequentlyExpiredCard extends StatelessWidget {
  final List<FrequentlyExpiredProduct> products;
  final double padding;
  final double titleSize;
  final double labelSize;

  const FrequentlyExpiredCard({
    super.key,
    required this.products,
    required this.padding,
    required this.titleSize,
    required this.labelSize,
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
          Text('Frequently Expired Products', style: AppTextStyles.title(context, titleSize)),
          SizedBox(height: padding),
          if (products.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: padding),
              child: Text('No expired products yet', style: AppTextStyles.label(context, labelSize)),
            )
          else
            Table(
              border: TableBorder.symmetric(
                inside: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
              ),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  children: [
                    _buildTableHeader('Product', labelSize, padding, isDark),
                    _buildTableHeader('Expired', labelSize, padding, isDark),
                    _buildTableHeader('Last Time', labelSize, padding, isDark),
                  ],
                ),
                ...products.map((product) {
                  return TableRow(
                    children: [
                      _buildTableCell(product.name, labelSize, padding, isDark),
                      _buildTableCell(
                        product.count == 1 ? '1 time' : '${product.count} times',
                        labelSize,
                        padding,
                        isDark,
                      ),
                      _buildTableCell(
                        DateFormatter.timeAgo(product.lastExpired),
                        labelSize,
                        padding,
                        isDark,
                      ),
                    ],
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text, double fontSize, double padding, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding * 0.5),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, double fontSize, double padding, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding * 0.7),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: isDark ? Colors.grey[400] : Colors.grey[700],
        ),
      ),
    );
  }
}
