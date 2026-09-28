import '../models/category.dart';
import '../models/lawyer.dart';
import 'api_client.dart';

class LawyersService {
  final ApiClient api;
  LawyersService(this.api);

  /// Browse categories shown on the home screen.
  Future<List<LegalCategory>> categories() async {
    final data = await api.get('/api/v1/categories');
    return (data['categories'] as List).map((e) => LegalCategory.fromJson(e)).toList();
  }

  /// Specializations a lawyer can be filtered by.
  Future<List<LegalCategory>> specializations() async {
    final data = await api.get('/api/v1/specializations');
    return (data['specializations'] as List).map((e) => LegalCategory.fromJson(e)).toList();
  }

  Future<List<Lawyer>> search({int? categoryId, String? query, String sort = 'rating'}) async {
    final data = await api.get('/api/v1/lawyers', query: {
      if (categoryId != null) 'category_id': categoryId,
      if (query != null && query.isNotEmpty) 'q': query,
      'sort': sort,
    });
    return (data['lawyers'] as List).map((e) => Lawyer.fromJson(e)).toList();
  }

  /// Accepts the numeric id shown in the directory, or a UUID.
  Future<Lawyer> detail(Object id) async {
    final data = await api.get('/api/v1/lawyers/$id');
    return Lawyer.fromJson(data['lawyer']);
  }

  Future<bool> toggleBookmark(int lawyerId) async {
    final data = await api.post('/api/v1/lawyers/$lawyerId/bookmark');
    return data['bookmarked'] == true;
  }
}

