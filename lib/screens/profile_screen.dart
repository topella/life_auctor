import 'package:flutter/material.dart';
import 'package:life_auctor/utils/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:life_auctor/providers/item_provider_v3.dart';
import 'package:life_auctor/providers/auth_provider.dart';
import 'package:life_auctor/widgets/nav_bar/app_bar.dart';
import 'package:life_auctor/screens/settings_screen.dart';
import 'package:life_auctor/screens/edit_profile_screen.dart';
import 'package:life_auctor/screens/auth/signup_screen.dart';

class _ProfileTheme {
  final double width;
  final bool isDark;

  const _ProfileTheme(this.width, this.isDark);

  // Sizes
  double get padding => width * 0.04;
  double get spacing => width * 0.06;
  double get sectionTitleSize => width * 0.03;
  double get avatarSize => width * 0.13;
  double get nameFontSize => width * 0.042;
  double get emailFontSize => width * 0.037;
  double get badgeFontSize => width * 0.026;
  double get membershipTitleSize => width * 0.042;
  double get membershipTextSize => width * 0.032;
  double get membershipPriceSize => width * 0.037;
  double get buttonFontSize => width * 0.032;
  double get activityFontSize => width * 0.037;
  double get iconSize => width * 0.053;

  // Colors
  Color get cardColor => isDark ? const Color(0xFF1E1E1E) : Colors.white;
  Color get backgroundColor =>
      isDark ? const Color(0xFF121212) : Colors.grey[100]!;
  Color get textColor => isDark ? Colors.white : Colors.black87;
  Color get subtitleColor => isDark ? Colors.grey[400]! : Colors.grey[600]!;
  Color get dividerColor => isDark ? Colors.grey[800]! : Colors.grey[200]!;
  Color get sectionTitleColor => isDark ? Colors.grey[400]! : Colors.black54;

  // Text styles
  TextStyle get sectionTitleStyle => TextStyle(
    fontSize: sectionTitleSize,
    fontWeight: FontWeight.w600,
    color: sectionTitleColor,
    letterSpacing: 1.2,
  );
}

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final Function(int)? onNavigate;

  const ProfileScreen({super.key, this.onBack, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      appBar: const CustomAppBar(
        showBackButton: false,
      ),
      body: SafeArea(
        child: Consumer2<ItemProviderV3, AuthProvider>(
          builder: (context, itemProvider, authProvider, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final theme = _ProfileTheme(constraints.maxWidth, isDark);

                return SingleChildScrollView(
                  padding: EdgeInsets.all(theme.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AccountDetailsCard(
                        authProvider: authProvider,
                        theme: theme,
                      ),
                      SizedBox(height: theme.spacing),
                      _MembershipCard(authProvider: authProvider, theme: theme),
                      SizedBox(height: theme.spacing),
                      _ActivitySection(
                        itemProvider: itemProvider,
                        theme: theme,
                      ),
                      SizedBox(height: theme.spacing),
                      _QuickActionsCard(
                        authProvider: authProvider,
                        theme: theme,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AccountDetailsCard extends StatelessWidget {
  final AuthProvider authProvider;
  final _ProfileTheme theme;

  const _AccountDetailsCard({required this.authProvider, required this.theme});

  @override
  Widget build(BuildContext context) {
    final userName = authProvider.userData?['name'] ?? 'Guest';
    final userEmail = authProvider.userData?['email'] ?? 'No email';
    final isGuest = authProvider.isGuest;
    final isPremium = authProvider.userData?['isPremium'] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ACCOUNT DETAILS', style: theme.sectionTitleStyle),
        SizedBox(height: theme.padding * 0.7),
        Container(
          padding: EdgeInsets.all(theme.padding),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: theme.avatarSize,
                height: theme.avatarSize,
                decoration: BoxDecoration(
                  color: AppConstants.primaryGreen.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'G',
                    style: TextStyle(
                      fontSize: theme.avatarSize * 0.4,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryGreen,
                    ),
                  ),
                ),
              ),
              SizedBox(width: theme.padding * 0.8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: theme.nameFontSize,
                        fontWeight: FontWeight.w600,
                        color: theme.textColor,
                      ),
                    ),
                    SizedBox(height: theme.padding * 0.1),
                    Text(
                      userEmail,
                      style: TextStyle(
                        fontSize: theme.emailFontSize,
                        color: theme.subtitleColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isGuest) ...[
                      SizedBox(height: theme.padding * 0.4),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            ).signOut();
                            await Future.delayed(
                              const Duration(milliseconds: 100),
                            );
                            if (!context.mounted) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SignupScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: theme.padding * 0.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Sign Up / Login',
                            style: TextStyle(
                              fontSize: theme.emailFontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (!isGuest && isPremium) ...[
                      SizedBox(height: theme.padding * 0.2),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: theme.padding * 0.5,
                          vertical: theme.padding * 0.1,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryGreen.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'PREMIUM',
                          style: TextStyle(
                            fontSize: theme.badgeFontSize,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: theme.subtitleColor,
                size: theme.avatarSize * 0.5,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MembershipCard extends StatelessWidget {
  final AuthProvider authProvider;
  final _ProfileTheme theme;

  const _MembershipCard({required this.authProvider, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isPremium = authProvider.userData?['isPremium'] ?? false;
    final isGuest = authProvider.isGuest;

    if (isGuest || !isPremium) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('MEMBERSHIP', style: theme.sectionTitleStyle),
        SizedBox(height: theme.padding * 0.7),
        Container(
          padding: EdgeInsets.all(theme.padding),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppConstants.primaryGreen.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 300) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MembershipInfo(theme: theme),
                    SizedBox(height: theme.padding),
                    SizedBox(
                      width: double.infinity,
                      child: _ManageButton(theme: theme),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: _MembershipInfo(theme: theme)),
                  _ManageButton(theme: theme),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MembershipInfo extends StatelessWidget {
  final _ProfileTheme theme;

  const _MembershipInfo({required this.theme});

  @override
  Widget build(BuildContext context) {
    final spacing = theme.membershipTextSize * 0.3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PREMIUM',
          style: TextStyle(
            fontSize: theme.membershipTitleSize,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryGreen,
          ),
        ),
        SizedBox(height: spacing),
        Text(
          'Active since: 17 January 2025',
          style: TextStyle(
            fontSize: theme.membershipTextSize,
            color: theme.subtitleColor,
          ),
        ),
        SizedBox(height: spacing * 0.3),
        Text(
          'Next billing date: 17 June 2025',
          style: TextStyle(
            fontSize: theme.membershipTextSize,
            color: theme.subtitleColor,
          ),
        ),
        SizedBox(height: spacing * 0.5),
        Text(
          '2.99\$ /month',
          style: TextStyle(
            fontSize: theme.membershipPriceSize,
            fontWeight: FontWeight.w600,
            color: theme.textColor,
          ),
        ),
      ],
    );
  }
}

class _ManageButton extends StatelessWidget {
  final _ProfileTheme theme;

  const _ManageButton({required this.theme});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(
          horizontal: theme.padding,
          vertical: theme.padding * 0.6,
        ),
      ),
      child: Text(
        'Manage Plan',
        style: TextStyle(
          fontSize: theme.buttonFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActivitySection extends StatelessWidget {
  final ItemProviderV3 itemProvider;
  final _ProfileTheme theme;

  const _ActivitySection({required this.itemProvider, required this.theme});

  @override
  Widget build(BuildContext context) {
    final itemsCount = itemProvider.items.length;
    final favoritesCount = itemProvider.favorites.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ACTIVITY', style: theme.sectionTitleStyle),
        SizedBox(height: theme.padding * 0.7),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _ActivityRow(
                label: 'Items added',
                value: itemsCount.toString(),
                theme: theme,
              ),
              Divider(height: 1, color: theme.dividerColor),
              _ActivityRow(
                label: 'Favorites',
                value: favoritesCount.toString(),
                theme: theme,
              ),
              Divider(height: 1, color: theme.dividerColor),
              _ActivityRow(label: 'Lists created', value: '0', theme: theme),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final String label;
  final String value;
  final _ProfileTheme theme;

  const _ActivityRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: theme.padding,
        vertical: theme.padding * 0.85,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: theme.activityFontSize,
                color: theme.subtitleColor,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: theme.activityFontSize,
              fontWeight: FontWeight.w600,
              color: theme.textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  final AuthProvider authProvider;
  final _ProfileTheme theme;

  const _QuickActionsCard({required this.authProvider, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('QUICK ACTIONS', style: theme.sectionTitleStyle),
        SizedBox(height: theme.padding * 0.7),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _ActionRow(
                icon: Icons.person_outline,
                label: 'Edit Profile',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditProfileScreen(onBack: () => Navigator.pop(context)),
                  ),
                ),
                theme: theme,
              ),
              Divider(height: 1, color: theme.dividerColor),
              _ActionRow(
                icon: Icons.notifications_outlined,
                label: 'Notification Settings',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SettingsScreen(onBack: () => Navigator.pop(context)),
                  ),
                ),
                theme: theme,
              ),
              Divider(height: 1, color: theme.dividerColor),
              _ActionRow(
                icon: Icons.security_outlined,
                label: 'Privacy & Security',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Privacy & Security - Coming soon'),
                  ),
                ),
                theme: theme,
              ),
              Divider(height: 1, color: theme.dividerColor),
              _ActionRow(
                icon: Icons.help_outline,
                label: 'Help & Support',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help & Support - Coming soon')),
                ),
                theme: theme,
              ),
              Divider(height: 1, color: theme.dividerColor),
              _ActionRow(
                icon: Icons.logout,
                label: 'Log Out',
                onTap: () => _showLogoutDialog(context, authProvider, theme),
                isDestructive: true,
                theme: theme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(
    BuildContext context,
    AuthProvider authProvider,
    _ProfileTheme theme,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Log Out',
          style: TextStyle(
            color: theme.textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: theme.subtitleColor, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: theme.subtitleColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final _ProfileTheme theme;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : theme.subtitleColor;
    final textColor = isDestructive ? Colors.red : theme.textColor;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: theme.padding,
          vertical: theme.padding * 0.85,
        ),
        child: Row(
          children: [
            Icon(icon, size: theme.iconSize, color: color),
            SizedBox(width: theme.padding * 0.7),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: theme.activityFontSize,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: theme.iconSize,
              color: theme.subtitleColor,
            ),
          ],
        ),
      ),
    );
  }
}
