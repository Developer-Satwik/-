import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isHighContrast = false;
  double _textScaleFactor = 1.0;
  bool _isScreenReaderEnabled = false;
  bool _isSoundEnabled = true;
  bool _isVibrationEnabled = true;
  bool _isDarkMode = false;
  ThemeProvider() {
    _loadSettings();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isHighContrast => _isHighContrast;
  double get textScaleFactor => _textScaleFactor;
  bool get isScreenReaderEnabled => _isScreenReaderEnabled;
  bool get isSoundEnabled => _isSoundEnabled;
  bool get isVibrationEnabled => _isVibrationEnabled;
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      final window = WidgetsBinding.instance.window;
      return window.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 0];
    _isHighContrast = prefs.getBool('isHighContrast') ?? false;
    _textScaleFactor = prefs.getDouble('textScaleFactor') ?? 1.0;
    _isScreenReaderEnabled = prefs.getBool('isScreenReaderEnabled') ?? false;
    _isSoundEnabled = prefs.getBool('isSoundEnabled') ?? true;
    _isVibrationEnabled = prefs.getBool('isVibrationEnabled') ?? true;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', _themeMode.index);
    await prefs.setBool('isHighContrast', _isHighContrast);
    await prefs.setDouble('textScaleFactor', _textScaleFactor);
    await prefs.setBool('isScreenReaderEnabled', _isScreenReaderEnabled);
    await prefs.setBool('isSoundEnabled', _isSoundEnabled);
    await prefs.setBool('isVibrationEnabled', _isVibrationEnabled);
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveSettings();
    notifyListeners();
  }

  void toggleHighContrast() {
    _isHighContrast = !_isHighContrast;
    _saveSettings();
    notifyListeners();
  }

  void setTextScaleFactor(double scale) {
    _textScaleFactor = scale;
    _saveSettings();
    notifyListeners();
  }

  void toggleScreenReader() {
    _isScreenReaderEnabled = !_isScreenReaderEnabled;
    _saveSettings();
    notifyListeners();
  }

  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
    _saveSettings();
    notifyListeners();
  }

  void toggleVibration() {
    _isVibrationEnabled = !_isVibrationEnabled;
    _saveSettings();
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveSettings();
    notifyListeners();
  }

  ThemeData get currentTheme {
    final isSystemDark = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    final effectiveDarkMode = _themeMode == ThemeMode.system ? isSystemDark : _themeMode == ThemeMode.dark;
    
    if (_isHighContrast) {
      return effectiveDarkMode ? AppTheme.highContrastDarkTheme : AppTheme.highContrastLightTheme;
    }
    
    return effectiveDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
  }

  // Helper methods for widgets
  BoxDecoration getGlassDecoration(BuildContext context) {
    return AppTheme.getGlassDecoration(context, isDarkMode);
  }

  EdgeInsets getScreenPadding(BuildContext context) {
    return AppTheme.getScreenPadding(context);
  }
} 