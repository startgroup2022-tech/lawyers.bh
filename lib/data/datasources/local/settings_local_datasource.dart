import 'package:lawyers_bh/core/storage/preferences_storage.dart';

abstract class SettingsLocalDataSource {
  Future<void> setLanguage(String languageCode);
  Future<String> getLanguage();
  Future<void> setThemeMode(String themeMode);
  Future<String> getThemeMode();
  Future<void> setBiometricEnabled(bool enabled);
  Future<bool> isBiometricEnabled();
  Future<void> saveSearchHistory(List<String> history);
  Future<List<String>> getSearchHistory();
  Future<void> addToSearchHistory(String query);
  Future<void> clearSearchHistory();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final PreferencesStorage _preferencesStorage;

  SettingsLocalDataSourceImpl(this._preferencesStorage);

  @override
  Future<void> setLanguage(String languageCode) async {
    await _preferencesStorage.setLanguage(languageCode);
  }

  @override
  Future<String> getLanguage() async {
    return _preferencesStorage.getLanguage();
  }

  @override
  Future<void> setThemeMode(String themeMode) async {
    await _preferencesStorage.setThemeMode(themeMode);
  }

  @override
  Future<String> getThemeMode() async {
    return _preferencesStorage.getThemeMode();
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await _preferencesStorage.setBiometricEnabled(enabled);
  }

  @override
  Future<bool> isBiometricEnabled() async {
    return _preferencesStorage.isBiometricEnabled();
  }

  @override
  Future<void> saveSearchHistory(List<String> history) async {
    await _preferencesStorage.saveSearchHistory(history);
  }

  @override
  Future<List<String>> getSearchHistory() async {
    return _preferencesStorage.getSearchHistory();
  }

  @override
  Future<void> addToSearchHistory(String query) async {
    await _preferencesStorage.addToSearchHistory(query);
  }

  @override
  Future<void> clearSearchHistory() async {
    await _preferencesStorage.clearSearchHistory();
  }
}