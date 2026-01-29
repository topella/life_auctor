import 'package:flutter/material.dart';

enum ItemCategory {
  food('Food', Icons.fastfood, Color(0xFF8AC926)),
  tech('Tech', Icons.devices, Color(0xFF2196F3)),
  makeup('Makeup', Icons.face, Color(0xFFE91E63)),
  home('Home', Icons.home, Color(0xFFFF9800)),
  other('Other', Icons.category, Color(0xFF9E9E9E));

  final String displayName;
  final IconData icon;
  final Color color;

  const ItemCategory(this.displayName, this.icon, this.color);

  // Get category from string (case-insensitive)
  static ItemCategory fromString(String value) {
    return values.firstWhere(
      (cat) => cat.displayName.toLowerCase() == value.toLowerCase(),
      orElse: () => ItemCategory.other,
    );
  }

  // category names
  static List<String> get categoryNames =>
      values.map((cat) => cat.displayName).toList();

  // categories except other
  static List<ItemCategory> get mainCategories =>
      values.where((cat) => cat != ItemCategory.other).toList();
}
