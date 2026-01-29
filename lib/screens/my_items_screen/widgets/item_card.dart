import 'package:flutter/material.dart';
import 'package:life_auctor/models/item.dart';
import 'package:life_auctor/utils/app_constants.dart';
import 'package:life_auctor/utils/date_formatter.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final double width;
  final VoidCallback onToggleFavorite;
  final VoidCallback onToggleConsumed;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ItemCard({
    super.key,
    required this.item,
    required this.width,
    required this.onToggleFavorite,
    required this.onToggleConsumed,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysLeft = _getDaysLeft();

    // Calculate sizes based on width
    final cardPadding = width * 0.032;
    final nameFontSize = width * 0.042;
    final detailsFontSize = width * 0.032;
    final starIconSize = width * 0.074;
    final menuIconSize = width * 0.084;
    final deleteIconSize = width * 0.063;
    final indicatorSize = width * 0.116;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: cardPadding * 1.25),
        color: Colors.red,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: deleteIconSize,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          border: Border(
            bottom: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: [
            ExpiryIndicator(daysLeft: daysLeft, size: indicatorSize),
            SizedBox(width: cardPadding),
            Expanded(
              child: Opacity(
                opacity: item.isConsumed ? 0.5 : 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: nameFontSize,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                        decoration: item.isConsumed ? TextDecoration.lineThrough : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: cardPadding * 0.17),
                    Text(
                      '${item.quantity ?? ''},   Added ${DateFormatter.formatDate(item.createdAt)}',
                      style: TextStyle(
                        fontSize: detailsFontSize,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${item.location ?? ''},  ${item.category}${item.price != null ? '  •  €${item.price!.toStringAsFixed(2)}' : ''}',
                      style: TextStyle(
                        fontSize: detailsFontSize,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: onToggleConsumed,
              child: Icon(
                item.isConsumed ? Icons.check_circle : Icons.check_circle_outline,
                color: item.isConsumed ? AppConstants.primaryGreen : (isDark ? Colors.grey[600] : Colors.grey[300]),
                size: starIconSize,
              ),
            ),
            SizedBox(width: cardPadding * 0.5),
            GestureDetector(
              onTap: onToggleFavorite,
              child: Icon(
                item.isFavorite ? Icons.star : Icons.star_border,
                color: item.isFavorite ? Colors.amber : (isDark ? Colors.grey[600] : Colors.grey[300]),
                size: starIconSize,
              ),
            ),
            SizedBox(width: cardPadding * 0.75),
            GestureDetector(
              onTap: onEdit,
              child: Container(
                width: menuIconSize,
                height: menuIconSize,
                decoration: BoxDecoration(
                  color: AppConstants.primaryGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: menuIconSize * 0.56,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int? _getDaysLeft() {
    if (item.expiryDate == null) return null;
    return item.expiryDate!.difference(DateTime.now()).inDays;
  }
}

class ExpiryIndicator extends StatelessWidget {
  final int? daysLeft;
  final double size;

  const ExpiryIndicator({
    super.key,
    required this.daysLeft,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = size * 0.55;
    final fontSize = size * 0.27;

    if (daysLeft == null) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFFE3F2FD),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.all_inclusive,
          color: const Color(0xFF1976D2),
          size: iconSize,
        ),
      );
    }

    Color bgColor;
    Color textColor;
    String text;

    if (daysLeft! < 0) {
      bgColor = const Color(0xFFFFCDD2);
      textColor = const Color(0xFFC62828);
      text = 'Exp';
    } else if (daysLeft! <= 1) {
      bgColor = const Color(0xFFFFEBEE);
      textColor = const Color(0xFFD32F2F);
      text = daysLeft == 1 ? '1d' : '<1d';
    } else if (daysLeft! <= 7) {
      bgColor = const Color(0xFFFFF8E1);
      textColor = const Color(0xFFF9A825);
      text = '${daysLeft}d';
    } else {
      bgColor = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF388E3C);
      text = '${daysLeft}d';
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
