import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  SharedPreferences? _prefs;

  // General
  bool _enableNotifications = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // Expiry Settings
  bool _expiryReminders = true;
  int _reminderDaysBefore = 3;
  bool _criticalAlerts = true;

  // Display Settings
  String _dateFormat = 'DD/MM/YYYY';

  // Privacy Settings
  bool _shareAnalytics = false;
  bool _autoBackup = true;

  // Getters
  bool get enableNotifications => _enableNotifications;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get expiryReminders => _expiryReminders;
  int get reminderDaysBefore => _reminderDaysBefore;
  bool get criticalAlerts => _criticalAlerts;
  String get dateFormat => _dateFormat;
  bool get shareAnalytics => _shareAnalytics;
  bool get autoBackup => _autoBackup;

  // Load settings from SharedPreferences
  Future<void> loadSettings() async {
    _prefs ??= await SharedPreferences.getInstance();

    _enableNotifications = _prefs!.getBool('enableNotifications') ?? true;
    _soundEnabled = _prefs!.getBool('soundEnabled') ?? true;
    _vibrationEnabled = _prefs!.getBool('vibrationEnabled') ?? true;
    _expiryReminders = _prefs!.getBool('expiryReminders') ?? true;
    _reminderDaysBefore = _prefs!.getInt('reminderDaysBefore') ?? 3;
    _criticalAlerts = _prefs!.getBool('criticalAlerts') ?? true;
    _dateFormat = _prefs!.getString('dateFormat') ?? 'DD/MM/YYYY';
    _shareAnalytics = _prefs!.getBool('shareAnalytics') ?? false;
    _autoBackup = _prefs!.getBool('autoBackup') ?? true;

    notifyListeners();
  }

  Future<void> _save<T>(String key, T value, void Function(T) update) async {
    update(value);
    _prefs ??= await SharedPreferences.getInstance();
    switch (value) {
      case bool v:
        await _prefs!.setBool(key, v);
      case int v:
        await _prefs!.setInt(key, v);
      case String v:
        await _prefs!.setString(key, v);
    }
    notifyListeners();
  }

  // _save method
  Future<void> setEnableNotifications(bool v) =>
      _save('enableNotifications', v, (val) => _enableNotifications = val);
  Future<void> setSoundEnabled(bool v) =>
      _save('soundEnabled', v, (val) => _soundEnabled = val);
  Future<void> setVibrationEnabled(bool v) =>
      _save('vibrationEnabled', v, (val) => _vibrationEnabled = val);
  Future<void> setExpiryReminders(bool v) =>
      _save('expiryReminders', v, (val) => _expiryReminders = val);
  Future<void> setReminderDaysBefore(int v) =>
      _save('reminderDaysBefore', v, (val) => _reminderDaysBefore = val);
  Future<void> setCriticalAlerts(bool v) =>
      _save('criticalAlerts', v, (val) => _criticalAlerts = val);
  Future<void> setDateFormat(String v) =>
      _save('dateFormat', v, (val) => _dateFormat = val);
  Future<void> setShareAnalytics(bool v) =>
      _save('shareAnalytics', v, (val) => _shareAnalytics = val);
  Future<void> setAutoBackup(bool v) =>
      _save('autoBackup', v, (val) => _autoBackup = val);
}
