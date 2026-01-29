import 'package:flutter/material.dart';
import 'package:life_auctor/utils/date_formatter.dart';

class DatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;
  final String placeholder;

  const DatePickerField({
    super.key,
    required this.selectedDate,
    required this.onTap,
    this.placeholder = 'Select date',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormatter.formatDateOrPlaceholder(selectedDate, placeholder),
              style: TextStyle(
                color: selectedDate != null
                    ? (isDark ? Colors.white : Colors.black87)
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
