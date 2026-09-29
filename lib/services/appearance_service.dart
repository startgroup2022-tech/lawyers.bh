import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_appearance.dart';
import 'api_client.dart';

const _cacheKey = 'app_appearance';

/// Reads the app background configured by the admin panel.
///
/// `GET /api/mobile/appearance` is public and returns the whole appearance
/// record for a country. The last successful response is cached locally so a
/// cold start without a connection still paints the background the admin set,
/// rather than flashing the plain default.
class AppearanceService {
  final ApiClient api;
  AppearanceService(this.api);

  Future<AppAppearance> load({String countryCode = 'BH'}) async {
    try {
      final data = await api.get('/api/mobile/appearance', query: {'countryCode': countryCode});
      // Fill in the bundled image when the backend configured none, so the
      // global background is visible even before an admin uploads one.
      final appearance =
          AppAppearance.fromJson(_record(data)).withVisibleBackground();
      await _cache(appearance);
      return appearance;
    } on ApiException {
      // A background is decoration; an outage must never block the app. Fall
      // back to the last known value, or the bundled default.
      return _cached();
    }
  }

  /// Reads the cached record without touching the network.
  Future<AppAppearance> cached() => _cached();

  Map<String, dynamic> _record(Map<String, dynamic> data) {
    final appearance = data['appearance'];
    return appearance is Map<String, dynamic> ? appearance : data;
  }

  Future<void> _cache(AppAppearance appearance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(appearance.toJson()));
  }

  Future<AppAppearance> _cached() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return AppAppearance.demoBackground;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return AppAppearance.fromJson(decoded).withVisibleBackground();
      }
    } catch (_) {
      // Corrupt cache: fall through to the bundled default rather than crashing.
    }
    return AppAppearance.demoBackground;
  }
}
