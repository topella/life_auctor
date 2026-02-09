import 'package:flutter/material.dart';
import 'package:life_auctor/utils/app_constants.dart';
import 'package:life_auctor/widgets/nav_bar/app_bar.dart';

class CommunityScreen extends StatelessWidget {
  final Function(int)? onNavigate;
  final VoidCallback? onBack;

  const CommunityScreen({super.key, this.onNavigate, this.onBack});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      appBar: CustomAppBar(showBackButton: true, onBack: onBack),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final padding = width * 0.04;
            final titleSize = width * 0.072;
            final subtitleSize = width * 0.042;

            return Center(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Community',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: padding * 2),
                    Icon(
                      Icons.people_outline,
                      size: width * 0.25,
                      color: AppConstants.primaryGreen.withValues(alpha: 0.5),
                    ),
                    SizedBox(height: padding * 2),
                    Text(
                      'Coming Soon',
                      style: TextStyle(
                        fontSize: subtitleSize,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.primaryGreen,
                      ),
                    ),
                    SizedBox(height: padding),
                    Text(
                      'Community features are currently in development.\nStay tuned for updates!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: subtitleSize * 0.8,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
