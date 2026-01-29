import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const Color primaryGreen = Color(0xFF8AC926);
  static const Color lightGreen = Color(0xFFB4D455);
  static const Color darkBackground = Color(0xFF1E1E1E);

  //////////////////////////////////////Sizes
  // AppBar
  static const double appBarHeight = 120.0;
  static const double appBarLogoSize = 70.0;

  // BottomBar
  static const double bottomBarIconSize = 40.0;
  static const double bottomBarSelectedFontSize = 12.0;
  static const double bottomBarUnselectedFontSize = 10.0;

  // Spacing
  static const double spacing4 = 4.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing18 = 18.0;

  // Border Radius
  static const double borderRadius8 = 8.0;
  static const double borderRadius12 = 12.0;

  // Icon Sizes
  static const double iconSize20 = 20.0;
  static const double iconSize30 = 30.0;

  // Font Sizes
  static const double fontSize10 = 10.0;
  static const double fontSize11 = 11.0;
  static const double fontSize12 = 12.0;
  static const double fontSize14 = 14.0;
  static const double fontSize16 = 16.0;
  static const double fontSize20 = 20.0;

  // Product Summary
  static const double summaryCardBorderRadius = 16.0;
  static const double summaryItemWidth = 80.0;
  static const double summaryItemHeight = 40.0;
  static const double summaryItemBorderRadius = 25.0;

  // Guest Banner
  static const double guestBannerIconSize = 24.0;
  static const double guestBannerDialogIconSize = 48.0;
  static const double guestBannerDialogBorderRadius = 16.0;

  // Quick Actions
  static const double quickActionIconSize = 30.0;
  static const double quickActionIconSize18 = 18.0;
  static const double quickActionDateIconSize = 20.0;

  //////////////////////////////////////////text style
  static const TextStyle appBarTitle = TextStyle(
    fontSize: fontSize14,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  static const TextStyle appBarSubtitle = TextStyle(
    fontSize: fontSize10,
    letterSpacing: 0.3,
  );

  ////////////////////////////////sharedpreferences
  static const String prefKeyGuestBannerVisible = 'guest_banner_visible';
}

class BannerText {
  BannerText._();

  static const String offline = 'You are offline';
  static const String syncing = 'Syncing...';

  static String operationsPending(int count) =>
      '$count operation${count > 1 ? 's' : ''} pending';
}
