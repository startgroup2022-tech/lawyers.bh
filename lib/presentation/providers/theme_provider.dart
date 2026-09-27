import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawyers_bh/core/storage/preferences_storage.dart';

class ThemeProvider extends StateNotifier<ThemeMode> {
  final PreferencesStorage _preferencesStorage;

  ThemeProvider(this._preferencesStorage) : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final themeMode = await _preferencesStorage.getThemeMode();
    state = themeMode == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _preferencesStorage.setThemeMode(mode == ThemeMode.dark ? 'dark' : 'light');
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }
}