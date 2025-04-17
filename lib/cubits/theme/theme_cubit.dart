import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'is_dark_mode';

  ThemeCubit() : super(const ThemeState()) {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDarkMode = prefs.getBool(_themeKey) ?? false;
      emit(ThemeState(isDarkMode: isDarkMode));
    } catch (e) {
      // Fallback to light mode if there's an error
      emit(const ThemeState(isDarkMode: false));
    }
  }

  Future<void> toggleTheme() async {
    emit(ThemeState(isDarkMode: !state.isDarkMode));
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, state.isDarkMode);
    } catch (e) {
      // Handle error silently
    }
  }
}