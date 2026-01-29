import 'package:flutter/material.dart';

class PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final List<String> periods;
  final Function(String) onPeriodChanged;
  final double padding;
  final double fontSize;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.periods,
    required this.onPeriodChanged,
    required this.padding,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: periods.map((period) {
        final isSelected = selectedPeriod == period;
        return Padding(
          padding: EdgeInsets.only(right: padding * 0.5),
          child: GestureDetector(
            onTap: () => onPeriodChanged(period),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: padding,
                vertical: padding * 0.5,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF8AC926)
                    : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                period,
                style: TextStyle(
                  fontSize: fontSize,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white : Colors.black87),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
