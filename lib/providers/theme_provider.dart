import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_auctor/utils/app_constants.dart';

class ThemeProvider extends ChangeNotifier {
  SharedPreferences? _prefs;
  bool _isDarkMode = false;
  bool _isLoading = true;

  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _isDarkMode = _prefs!.getBool('isDarkMode') ?? false;
    } catch (e) {
      _isDarkMode = false;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setBool('isDarkMode', _isDarkMode);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.grey[100],
      primaryColor: AppConstants.primaryGreen,
      colorScheme: ColorScheme.light(
        primary: AppConstants.primaryGreen,
        secondary: AppConstants.primaryGreen,
        surface: Colors.white,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
        onError: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppConstants.primaryGreen,
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.white,
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      primaryColor: AppConstants.primaryGreen,
      colorScheme: ColorScheme.dark(
        primary: AppConstants.primaryGreen,
        secondary: AppConstants.primaryGreen,
        surface: AppConstants.darkBackground,
        error: Colors.red[300]!,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onError: Colors.black,
      ),
      cardTheme: CardThemeData(
        color: AppConstants.darkBackground,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppConstants.primaryGreen,
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.white,
      ),
      dividerColor: Colors.grey[800],
    );
  }
}
