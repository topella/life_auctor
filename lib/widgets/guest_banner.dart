import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_auctor/providers/auth_provider.dart';
import 'package:life_auctor/screens/auth/signup_screen.dart';
import 'package:life_auctor/utils/app_constants.dart';
import 'package:life_auctor/utils/app_strings.dart';
import 'package:life_auctor/utils/theme_extensions.dart';

class GuestBanner extends StatefulWidget {
  final String message;
  final IconData? icon;

  const GuestBanner({
    super.key,
    required this.message,
    this.icon,
  });

  @override
  State<GuestBanner> createState() => _GuestBannerState();
}

class _GuestBannerState extends State<GuestBanner> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _loadVisibility();
  }

  Future<void> _loadVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isVisible = prefs.getBool(AppConstants.prefKeyGuestBannerVisible) ?? true;
      });
    }
  }

  Future<void> _hideBanner() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefKeyGuestBannerVisible, false);
    if (mounted) {
      setState(() {
        _isVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Show banner only for guests and if not closed
    if (!authProvider.isGuest || !_isVisible) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.all(AppConstants.spacing16),
      padding: EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: context.adaptiveSecondaryBackgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
        border: Border.all(
          color: AppConstants.primaryGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            widget.icon ?? Icons.info_outline,
            color: AppConstants.primaryGreen,
            size: AppConstants.guestBannerIconSize,
          ),
          SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.message,
                  style: TextStyle(
                    fontSize: AppConstants.fontSize14,
                    color: context.adaptiveTextColor,
                  ),
                ),
                SizedBox(height: AppConstants.spacing8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    );
                  },
                  child: Text(
                    AppStrings.guestBannerSignUp,
                    style: TextStyle(
                      fontSize: AppConstants.fontSize14,
                      color: AppConstants.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppConstants.spacing8),
          InkWell(
            onTap: () async {
              await _hideBanner();
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: EdgeInsets.all(AppConstants.spacing4),
              child: Icon(
                Icons.close,
                color: context.adaptiveSecondaryTextColor,
                size: AppConstants.iconSize20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Dialog offering registration
void showGuestLimitationDialog(BuildContext context, String feature) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: dialogContext.adaptiveSecondaryBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.guestBannerDialogBorderRadius),
      ),
      icon: Icon(
        Icons.lock_outline,
        color: AppConstants.primaryGreen,
        size: AppConstants.guestBannerDialogIconSize,
      ),
      title: Text(
        AppStrings.guestDialogTitle,
        style: TextStyle(
          color: dialogContext.adaptiveTextColor,
          fontSize: AppConstants.fontSize20,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      content: Text(
        AppStrings.guestDialogMessage(feature),
        style: TextStyle(
          color: dialogContext.adaptiveSecondaryTextColor,
          fontSize: AppConstants.fontSize14,
        ),
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(
            AppStrings.guestDialogLater,
            style: TextStyle(
              color: dialogContext.adaptiveSecondaryTextColor,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SignupScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius8),
            ),
          ),
          child: Text(AppStrings.guestDialogSignUp),
        ),
      ],
    ),
  );
}
