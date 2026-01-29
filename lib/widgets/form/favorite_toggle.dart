import 'package:flutter/material.dart';

class FavoriteToggle extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const FavoriteToggle({
    super.key,
    required this.isFavorite,
    required this.onTap,
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
              'Add to favorites',
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite
                  ? Colors.amber
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
