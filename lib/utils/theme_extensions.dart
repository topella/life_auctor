import 'package:flutter/material.dart';

extension ThemeExtension on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  Color get adaptiveTextColor => isDark ? Colors.white : Colors.black87;
  Color get adaptiveBackgroundColor =>
      isDark ? const Color(0xFF1E1E1E) : Colors.white;
  Color get adaptiveSecondaryBackgroundColor =>
      isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5);

  Color get adaptiveBorderColor =>
      isDark ? Colors.grey[700]! : Colors.grey.shade300;
  Color get adaptiveIconColor => isDark ? Colors.white : Colors.black;
  Color get adaptiveSubtitleColor => isDark ? Colors.white70 : Colors.black87;
  Color get adaptiveSecondaryTextColor =>
      isDark ? Colors.grey[400]! : Colors.grey[600]!;
}
