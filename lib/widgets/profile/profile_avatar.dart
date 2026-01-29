import 'package:flutter/material.dart';
import 'package:life_auctor/utils/app_constants.dart';
import 'package:life_auctor/utils/theme_extensions.dart';

class ProfileAvatar extends StatelessWidget {
  final double radius;
  final VoidCallback? onTap;
  final String? photoUrl;

  const ProfileAvatar({
    super.key,
    required this.radius,
    this.onTap,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: AppConstants.primaryGreen.withValues(alpha: 0.2),
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
            child: photoUrl == null
                ? Icon(Icons.person, size: radius, color: AppConstants.primaryGreen)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppConstants.primaryGreen,
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.adaptiveBackgroundColor,
                  width: 3,
                ),
              ),
              padding: EdgeInsets.all(radius * 0.1),
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: radius * 0.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
