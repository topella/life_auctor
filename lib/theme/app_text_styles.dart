import 'package:flutter/material.dart';

class AppTextStyles {
  // Title style for main headings
  static TextStyle title(BuildContext context, double size) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.white : Colors.black87,
    );
  }

  // Label style for secondary text
  static TextStyle label(BuildContext context, double size) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: size,
      color: isDark ? Colors.grey[400] : Colors.grey[600],
    );
  }

  // Value style for numbers and data
  static TextStyle value(BuildContext context, double size) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.white : Colors.black87,
    );
  }
}
