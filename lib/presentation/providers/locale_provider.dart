import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawyers_bh/core/storage/preferences_storage.dart';

class LocaleProvider extends StateNotifier<Locale> {
  final PreferencesStorage _preferencesStorage;

  LocaleProvider(this._preferencesStorage) : super(const Locale('ar')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final languageCode = await _preferencesStorage.getLanguage();
    state = Locale(languageCode);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _preferencesStorage.setLanguage(locale.languageCode);
  }

  Future<void> toggleLanguage() async {
    final newLocale = state.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    await setLocale(newLocale);
  }
}