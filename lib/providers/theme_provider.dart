import 'package:flutter/material.dart';
import 'package:tracker/services/database_helper.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({bool? initialIsDark}) {
    if (initialIsDark != null) {
      _themeMode = initialIsDark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDark =>
      _themeMode == ThemeMode.dark ||
      (_themeMode == ThemeMode.system &&
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark);

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    notifyListeners();
    await DatabaseHelper().setIsDarkTheme(_themeMode == ThemeMode.dark);
  }
}
