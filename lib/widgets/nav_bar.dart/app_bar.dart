import 'package:flutter/material.dart';
import 'package:life_auctor/utils/app_constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final VoidCallback? onBack;

  const CustomAppBar({
    super.key,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : Colors.black;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? Colors.white70 : Colors.black87;

    return AppBar(
      toolbarHeight: AppConstants.appBarHeight,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: iconColor),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
            )
          : null,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star,
            size: AppConstants.appBarLogoSize,
            color: iconColor,
          ),
          SizedBox(height: AppConstants.spacing6),
          Text(
            'LifeAuctor',
            style: AppConstants.appBarTitle.copyWith(color: textColor),
          ),
          SizedBox(height: AppConstants.spacing4),
          Text(
            'Your choice. Your contribution. Your savings.',
            style: AppConstants.appBarSubtitle.copyWith(color: subtitleColor),
          ),
        ],
      ),
      centerTitle: true,
      backgroundColor: isDark
          ? AppConstants.darkBackground
          : AppConstants.lightGreen,
      elevation: 0,
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppConstants.appBarHeight);
}
