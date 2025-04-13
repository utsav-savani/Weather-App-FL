import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/core/utils/constants.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final SharedPreferences prefs;

  ThemeCubit({required this.prefs}) : super(const ThemeState()) {
    _loadTheme();
  }

  void _loadTheme() {
    final savedThemeIndex = prefs.getInt(ApiConstants.selectedThemeKey);
    if (savedThemeIndex != null) {
      final appThemeMode = AppThemeMode.values[savedThemeIndex];
      final flutterThemeMode = _convertToFlutterThemeMode(appThemeMode);
      emit(state.copyWith(themeMode: flutterThemeMode));
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final appThemeMode = _convertToAppThemeMode(mode);
    await prefs.setInt(ApiConstants.selectedThemeKey, appThemeMode.index);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> toggleTheme() async {
    final newThemeMode =
        state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;

    await setThemeMode(newThemeMode);
  }

  bool get isDarkMode => state.themeMode == ThemeMode.dark;

  // Conversion helpers
  ThemeMode _convertToFlutterThemeMode(AppThemeMode appThemeMode) {
    switch (appThemeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  AppThemeMode _convertToAppThemeMode(ThemeMode flutterThemeMode) {
    switch (flutterThemeMode) {
      case ThemeMode.light:
        return AppThemeMode.light;
      case ThemeMode.dark:
        return AppThemeMode.dark;
      case ThemeMode.system:
        return AppThemeMode.system;
    }
  }
}
