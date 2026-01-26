import 'package:flutter/material.dart';
import 'package:tracker/services/database_helper.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({bool? initialIsDark, int? initialPolylineColor}) {
    if (initialIsDark != null) {
      _themeMode = initialIsDark ? ThemeMode.dark : ThemeMode.light;
    }
    if (initialPolylineColor != null) {
      _polylineColor = Color(initialPolylineColor);
    }
  }

  ThemeMode _themeMode = ThemeMode.system;
  Color _polylineColor = const Color(0xFF6366F1); // Default Indigo

  ThemeMode get themeMode => _themeMode;
  Color get polylineColor => _polylineColor;

  bool get isDark =>
      _themeMode == ThemeMode.dark ||
      (_themeMode == ThemeMode.system &&
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark);

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  Future<void> setPolylineColor(Color color) async {
    _polylineColor = color;
    notifyListeners();
    await DatabaseHelper().setPolylineColor(color.value);
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    notifyListeners();
    await DatabaseHelper().setIsDarkTheme(_themeMode == ThemeMode.dark);
  }
}
