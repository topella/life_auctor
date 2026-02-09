import 'package:flutter/material.dart';
import 'package:life_auctor/utils/app_constants.dart';

class BottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BottomNavigationBar(
      backgroundColor: isDark ? AppConstants.darkBackground : AppConstants.primaryGreen,
      iconSize: AppConstants.bottomBarIconSize,
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: isDark ? AppConstants.primaryGreen : Colors.grey,
      unselectedItemColor: isDark ? Colors.grey[400] : Colors.white,
      selectedFontSize: AppConstants.bottomBarSelectedFontSize,
      unselectedFontSize: AppConstants.bottomBarUnselectedFontSize,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
