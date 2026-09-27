import 'package:lawyers_bh/core/network/api_client.dart';
import 'package:lawyers_bh/data/models/lawyer_models.dart';

abstract class LawyersRemoteDataSource {
  Future<LawyersListResponseModel> getLawyers({Map<String, dynamic>? query});
  Future<LawyerModel> getLawyerDetails(String id);
  Future<LawyersListResponseModel> searchLawyers(String query, {Map<String, dynamic>? filters});
  Future<LawyersListResponseModel> getRecommendedLawyers({int limit = 10});
  Future<LawyersListResponseModel> getLawyersBySpecialty(String specialty, {int limit = 20});
  Future<void> toggleFavorite(String lawyerId);
  Future<LawyersListResponseModel> getFavoriteLawyers();
}

class LawyersRemoteDataSourceImpl implements LawyersRemoteDataSource {
  final ApiClient _apiClient;

  LawyersRemoteDataSourceImpl(this._apiClient);

  @override
  Future<LawyersListResponseModel> getLawyers({Map<String, dynamic>? query}) async {
    final response = await _apiClient.get('/lawyers', queryParameters: query);
    return LawyersListResponseModel.fromJson(response.data);
  }

  @override
  Future<LawyerModel> getLawyerDetails(String id) async {
    final response = await _apiClient.get('/lawyers/$id');
    return LawyerModel.fromJson(response.data);
  }

  @override
  Future<LawyersListResponseModel> searchLawyers(String query, {Map<String, dynamic>? filters}) async {
    final params = {'q': query, ...?filters};
    final response = await _apiClient.get('/lawyers/search', queryParameters: params);
    return LawyersListResponseModel.fromJson(response.data);
  }

  @override
  Future<LawyersListResponseModel> getRecommendedLawyers({int limit = 10}) async {
    final response = await _apiClient.get('/lawyers/recommended', queryParameters: {'limit': limit});
    return LawyersListResponseModel.fromJson(response.data);
  }

  @override
  Future<LawyersListResponseModel> getLawyersBySpecialty(String specialty, {int limit = 20}) async {
    final response = await _apiClient.get('/lawyers/specialty/$specialty', queryParameters: {'limit': limit});
    return LawyersListResponseModel.fromJson(response.data);
  }

  @override
  Future<void> toggleFavorite(String lawyerId) async {
    await _apiClient.post('/lawyers/$lawyerId/favorite');
  }

  @override
  Future<LawyersListResponseModel> getFavoriteLawyers() async {
    final response = await _apiClient.get('/lawyers/favorites');
    return LawyersListResponseModel.fromJson(response.data);
  }
}