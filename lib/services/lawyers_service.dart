import '../models/lawyer.dart';
import 'api_client.dart';

/// The public lawyer directory, served by the platform's mobile API.
///
/// `GET /api/mobile/lawyers` returns approved, active lawyers for a country —
/// the same directory the website's "find a lawyer" page reads. The endpoint
/// has no per-category filter, no lawyer-detail route and no bookmarks, so
/// those are intentionally absent rather than faked.
class LawyersService {
  final ApiClient api;
  LawyersService(this.api);

  Future<List<Lawyer>> directory({String countryCode = 'BH'}) async {
    final data = await api.get('/api/mobile/lawyers', query: {'countryCode': countryCode});
    final list = data['data'];
    if (list is! List) return const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(Lawyer.fromJson)
        .toList();
  }
}

