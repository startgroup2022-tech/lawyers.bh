import 'package:shared_preferences/shared_preferences.dart';
import 'package:lawyers_bh/core/constants/app_constants.dart';

abstract class PreferencesStorage {
  Future<void> setLanguage(String languageCode);
  Future<String> getLanguage();
  Future<void> setThemeMode(String themeMode);
  Future<String> getThemeMode();
  Future<void> setOnboardingCompleted(bool completed);
  Future<bool> isOnboardingCompleted();
  Future<void> setBiometricEnabled(bool enabled);
  Future<bool> isBiometricEnabled();
  Future<void> saveSearchHistory(List<String> history);
  Future<List<String>> getSearchHistory();
  Future<void> addToSearchHistory(String query);
  Future<void> clearSearchHistory();
  Future<void> setLastSelectedRole(String role);
  Future<String?> getLastSelectedRole();
}

class PreferencesStorageImpl implements PreferencesStorage {
  final SharedPreferences _prefs;

  PreferencesStorageImpl(this._prefs);

  @override
  Future<void> setLanguage(String languageCode) async {
    await _prefs.setString(AppConstants.languageKey, languageCode);
  }

  @override
  Future<String> getLanguage() async {
    return _prefs.getString(AppConstants.languageKey) ?? 'ar';
  }

  @override
  Future<void> setThemeMode(String themeMode) async {
    await _prefs.setString(AppConstants.themeKey, themeMode);
  }

  @override
  Future<String> getThemeMode() async {
    return _prefs.getString(AppConstants.themeKey) ?? 'light';
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(AppConstants.onboardingKey, completed);
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    return _prefs.getBool(AppConstants.onboardingKey) ?? false;
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool(AppConstants.biometricEnabledKey, enabled);
  }

  @override
  Future<bool> isBiometricEnabled() async {
    return _prefs.getBool(AppConstants.biometricEnabledKey) ?? false;
  }

  @override
  Future<void> saveSearchHistory(List<String> history) async {
    await _prefs.setStringList('search_history', history.take(AppConstants.maxSearchHistory).toList());
  }

  @override
  Future<List<String>> getSearchHistory() async {
    return _prefs.getStringList('search_history') ?? [];
  }

  @override
  Future<void> addToSearchHistory(String query) async {
    final history = await getSearchHistory();
    history.remove(query);
    history.insert(0, query);
    await saveSearchHistory(history);
  }

  @override
  Future<void> clearSearchHistory() async {
    await _prefs.remove('search_history');
  }

  @override
  Future<void> setLastSelectedRole(String role) async {
    await _prefs.setString('last_selected_role', role);
  }

  @override
  Future<String?> getLastSelectedRole() async {
    return _prefs.getString('last_selected_role');
  }
}