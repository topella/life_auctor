import 'package:flutter/material.dart';
import 'package:life_auctor/utils/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:life_auctor/widgets/nav_bar.dart/app_bar.dart';
import 'package:life_auctor/providers/theme_provider.dart';
import 'package:life_auctor/providers/item_provider_v3.dart';
import 'package:life_auctor/providers/settings_provider.dart';
import 'package:life_auctor/screens/terms_screen.dart';
import 'package:life_auctor/screens/privacy_policy_screen.dart';

// Settings theme configuration
class _SettingsTheme {
  final double width;
  final bool isDark;

  _SettingsTheme(this.width, this.isDark);

  // Sizes
  double get padding => width * 0.04;
  double get titleSize => width * 0.072;
  double get sectionTitleSize => width * 0.048;
  double get itemTitleSize => width * 0.04;
  double get itemSubtitleSize => width * 0.035;
  double get iconSize => width * 0.065;
  double get cardRadius => width * 0.03;

  // Colors
  Color get backgroundColor =>
      isDark ? const Color(0xFF121212) : Colors.grey[100]!;
  Color get cardColor => isDark ? const Color(0xFF1E1E1E) : Colors.white;
  Color get textColor => isDark ? Colors.white : Colors.black87;
  Color get subtitleColor => isDark ? Colors.grey[400]! : Colors.grey[600]!;
  Color get dividerColor => isDark ? Colors.grey[800]! : Colors.grey[300]!;
  Color get dropdownColor => isDark ? const Color(0xFF2C2C2C) : Colors.white;
  Color get trailingIconColor => isDark ? Colors.grey[600]! : Colors.grey[400]!;

  // Divider
  Divider get divider => Divider(height: padding, color: dividerColor);
}

class SettingsScreen extends StatefulWidget {
  final Function(int)? onNavigate;
  final VoidCallback? onBack;

  const SettingsScreen({super.key, this.onNavigate, this.onBack});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<int> _reminderOptions = [1, 2, 3, 5, 7];
  final List<String> _dateFormats = ['DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      appBar: CustomAppBar(
        showBackButton: widget.onBack != null,
        onBack: widget.onBack,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final theme = _SettingsTheme(constraints.maxWidth, isDark);

            return SingleChildScrollView(
              padding: EdgeInsets.all(theme.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: theme.titleSize,
                      fontWeight: FontWeight.bold,
                      color: theme.textColor,
                    ),
                  ),
                  SizedBox(height: theme.padding * 1.5),

                  // Notifications
                  _SectionTitle(
                    title: 'Notifications',
                    icon: Icons.notifications_outlined,
                    theme: theme,
                  ),
                  SizedBox(height: theme.padding * 0.5),
                  _SettingCard(
                    theme: theme,
                    children: [
                      _SwitchTile(
                        title: 'Enable Notifications',
                        subtitle: 'Receive alerts for expiring items',
                        icon: Icons.notifications_active_outlined,
                        value: settingsProvider.enableNotifications,
                        onChanged: settingsProvider.setEnableNotifications,
                        theme: theme,
                      ),
                      if (settingsProvider.enableNotifications) ...[
                        theme.divider,
                        _SwitchTile(
                          title: 'Sound',
                          subtitle: 'Play sound for notifications',
                          icon: Icons.volume_up_outlined,
                          value: settingsProvider.soundEnabled,
                          onChanged: settingsProvider.setSoundEnabled,
                          theme: theme,
                        ),
                        theme.divider,
                        _SwitchTile(
                          title: 'Vibration',
                          subtitle: 'Vibrate on notifications',
                          icon: Icons.vibration,
                          value: settingsProvider.vibrationEnabled,
                          onChanged: settingsProvider.setVibrationEnabled,
                          theme: theme,
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: theme.padding * 1.5),

                  // Expiry Reminders
                  _SectionTitle(
                    title: 'Expiry Reminders',
                    icon: Icons.schedule_outlined,
                    theme: theme,
                  ),
                  SizedBox(height: theme.padding * 0.5),
                  _SettingCard(
                    theme: theme,
                    children: [
                      _SwitchTile(
                        title: 'Expiry Reminders',
                        subtitle: 'Get notified before items expire',
                        icon: Icons.calendar_today_outlined,
                        value: settingsProvider.expiryReminders,
                        onChanged: settingsProvider.setExpiryReminders,
                        theme: theme,
                      ),
                      if (settingsProvider.expiryReminders) ...[
                        theme.divider,
                        _DropdownTile(
                          title: 'Remind me',
                          icon: Icons.timer_outlined,
                          value: settingsProvider.reminderDaysBefore,
                          options: _reminderOptions,
                          onChanged: (value) =>
                              settingsProvider.setReminderDaysBefore(value!),
                          theme: theme,
                          formatter: (days) =>
                              '$days day${days > 1 ? 's' : ''} before',
                        ),
                        theme.divider,
                        _SwitchTile(
                          title: 'Critical Alerts',
                          subtitle: 'High priority for items expiring today',
                          icon: Icons.warning_amber_outlined,
                          value: settingsProvider.criticalAlerts,
                          onChanged: settingsProvider.setCriticalAlerts,
                          theme: theme,
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: theme.padding * 1.5),

                  // Display
                  _SectionTitle(
                    title: 'Display',
                    icon: Icons.palette_outlined,
                    theme: theme,
                  ),
                  SizedBox(height: theme.padding * 0.5),
                  _SettingCard(
                    theme: theme,
                    children: [
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, child) => _SwitchTile(
                          title: 'Dark Mode',
                          subtitle: 'Use dark theme',
                          icon: Icons.dark_mode_outlined,
                          value: themeProvider.isDarkMode,
                          onChanged: (_) => themeProvider.toggleTheme(),
                          theme: theme,
                        ),
                      ),
                      theme.divider,
                      _StringDropdownTile(
                        title: 'Date Format',
                        icon: Icons.date_range_outlined,
                        value: settingsProvider.dateFormat,
                        options: _dateFormats,
                        onChanged: (value) =>
                            settingsProvider.setDateFormat(value!),
                        theme: theme,
                      ),
                    ],
                  ),
                  SizedBox(height: theme.padding * 1.5),

                  // Privacy & Data
                  _SectionTitle(
                    title: 'Privacy & Data',
                    icon: Icons.security_outlined,
                    theme: theme,
                  ),
                  SizedBox(height: theme.padding * 0.5),
                  _SettingCard(
                    theme: theme,
                    children: [
                      _SwitchTile(
                        title: 'Share Analytics',
                        subtitle: 'Help us improve the app',
                        icon: Icons.analytics_outlined,
                        value: settingsProvider.shareAnalytics,
                        onChanged: settingsProvider.setShareAnalytics,
                        theme: theme,
                      ),
                      theme.divider,
                      _SwitchTile(
                        title: 'Auto Backup',
                        subtitle: 'Backup data automatically',
                        icon: Icons.backup_outlined,
                        value: settingsProvider.autoBackup,
                        onChanged: settingsProvider.setAutoBackup,
                        theme: theme,
                      ),
                      theme.divider,
                      _ActionTile(
                        title: 'Export Data',
                        subtitle: 'Download your data as CSV',
                        icon: Icons.download_outlined,
                        onTap: () => _showExportDialog(context),
                        theme: theme,
                      ),
                      theme.divider,
                      _ActionTile(
                        title: 'Clear All Data',
                        subtitle: 'Delete all items permanently',
                        icon: Icons.delete_forever_outlined,
                        onTap: () => _showClearDataDialog(context),
                        theme: theme,
                        isDestructive: true,
                      ),
                    ],
                  ),
                  SizedBox(height: theme.padding * 1.5),

                  // About
                  _SectionTitle(
                    title: 'About',
                    icon: Icons.info_outlined,
                    theme: theme,
                  ),
                  SizedBox(height: theme.padding * 0.5),
                  _SettingCard(
                    theme: theme,
                    children: [
                      _ActionTile(
                        title: 'Version',
                        subtitle: '1.0.0',
                        icon: Icons.app_settings_alt_outlined,
                        theme: theme,
                      ),
                      theme.divider,
                      _ActionTile(
                        title: 'Terms of Service',
                        subtitle: 'Read our terms',
                        icon: Icons.description_outlined,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TermsScreen(
                              onBack: () => Navigator.pop(context),
                              onNavigate: widget.onNavigate,
                            ),
                          ),
                        ),
                        theme: theme,
                      ),
                      theme.divider,
                      _ActionTile(
                        title: 'Privacy Policy',
                        subtitle: 'How we handle your data',
                        icon: Icons.privacy_tip_outlined,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PrivacyPolicyScreen(
                              onBack: () => Navigator.pop(context),
                              onNavigate: widget.onNavigate,
                            ),
                          ),
                        ),
                        theme: theme,
                      ),
                    ],
                  ),
                  SizedBox(height: theme.padding * 2),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.download, color: AppConstants.primaryGreen),
            SizedBox(width: 12),
            Text('Export Data'),
          ],
        ),
        content: const Text(
          'Your data will be exported as a CSV file. You can import it later or share it with other apps.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data exported successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryGreen,
            ),
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.red),
            SizedBox(width: 12),
            Text('Clear All Data?'),
          ],
        ),
        content: const Text(
          'This will permanently delete all your items, lists, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final itemProvider = Provider.of<ItemProviderV3>(
                context,
                listen: false,
              );

              for (var item in itemProvider.items) {
                await itemProvider.deleteItem(item.id);
              }

              navigator.pop();
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('All data has been cleared'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}

// Section Title
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final _SettingsTheme theme;

  const _SectionTitle({
    required this.title,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppConstants.primaryGreen, size: theme.iconSize),
        SizedBox(width: theme.sectionTitleSize * 0.3),
        Text(
          title,
          style: TextStyle(
            fontSize: theme.sectionTitleSize,
            fontWeight: FontWeight.bold,
            color: theme.textColor,
          ),
        ),
      ],
    );
  }
}

// Setting Card Container
class _SettingCard extends StatelessWidget {
  final _SettingsTheme theme;
  final List<Widget> children;

  const _SettingCard({required this.theme, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(theme.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: theme.isDark ? 0.3 : 0.05),
            blurRadius: theme.padding * 0.5,
            offset: Offset(0, theme.padding * 0.1),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

// Switch Tile
class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final _SettingsTheme theme;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(
        title,
        style: TextStyle(
          fontSize: theme.itemTitleSize,
          fontWeight: FontWeight.w500,
          color: theme.textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: theme.itemSubtitleSize,
          color: theme.subtitleColor,
        ),
      ),
      secondary: Icon(
        icon,
        color: AppConstants.primaryGreen,
        size: theme.iconSize,
      ),
      activeColor: AppConstants.primaryGreen,
    );
  }
}

// Dropdown Tile                   INT
class _DropdownTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final int value;
  final List<int> options;
  final ValueChanged<int?> onChanged;
  final _SettingsTheme theme;
  final String Function(int) formatter;

  const _DropdownTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.theme,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppConstants.primaryGreen,
        size: theme.iconSize,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: theme.itemTitleSize,
          fontWeight: FontWeight.w500,
          color: theme.textColor,
        ),
      ),
      subtitle: DropdownButton<int>(
        value: value,
        isExpanded: true,
        underline: Container(),
        style: TextStyle(
          fontSize: theme.itemSubtitleSize,
          color: AppConstants.primaryGreen,
        ),
        dropdownColor: theme.dropdownColor,
        items: options
            .map(
              (val) =>
                  DropdownMenuItem(value: val, child: Text(formatter(val))),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// String Dropdown Tile
class _StringDropdownTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final _SettingsTheme theme;

  const _StringDropdownTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppConstants.primaryGreen,
        size: theme.iconSize,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: theme.itemTitleSize,
          fontWeight: FontWeight.w500,
          color: theme.textColor,
        ),
      ),
      subtitle: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: Container(),
        style: TextStyle(
          fontSize: theme.itemSubtitleSize,
          color: AppConstants.primaryGreen,
        ),
        dropdownColor: theme.dropdownColor,
        items: options
            .map((val) => DropdownMenuItem(value: val, child: Text(val)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// Action Tile
class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final _SettingsTheme theme;
  final bool isDestructive;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    required this.theme,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppConstants.primaryGreen,
        size: theme.iconSize,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: theme.itemTitleSize,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : theme.textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: theme.itemSubtitleSize,
          color: theme.subtitleColor,
        ),
      ),
      trailing: onTap != null
          ? Icon(Icons.chevron_right, color: theme.trailingIconColor)
          : null,
      onTap: onTap,
    );
  }
}
