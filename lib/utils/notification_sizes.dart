class NotificationSizes {
  final double padding;
  final double titleSize;
  final double filterFontSize;
  final double badgeSize;
  final double messageSize;
  final double timeSize;
  final double iconSize;
  final double emptyIconSize;
  final double emptyTextSize;
  final double cardPadding;
  final double cardSpacing;
  final double filterSpacing;

  NotificationSizes(double screenWidth)
      : padding = screenWidth * 0.04,
        titleSize = screenWidth * 0.072,
        filterFontSize = screenWidth * 0.037,
        badgeSize = screenWidth * 0.053,
        messageSize = screenWidth * 0.04,
        timeSize = screenWidth * 0.032,
        iconSize = screenWidth * 0.064,
        emptyIconSize = screenWidth * 0.21,
        emptyTextSize = screenWidth * 0.045,
        cardPadding = screenWidth * 0.04,
        cardSpacing = screenWidth * 0.026,
        filterSpacing = screenWidth * 0.021;
}
