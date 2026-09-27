import 'package:lawyers_bh/core/network/api_client.dart';
import 'package:lawyers_bh/data/models/lawyer_models.dart';

abstract class LawyersRemoteDataSource {
  Future<LawyersListMobileResponseModel> getLawyersMobile({String countryCode = 'BH'});
  Future<LawyerDetailResponseModel> getLawyerDetails(String id);
  Future<LawyersListMobileResponseModel> searchLawyers(String query, {String countryCode = 'BH'});
  Future<LawyerModel> getLawyerProfile();
  Future<void> updateLocation(String lawyerId, double latitude, double longitude);
}

class LawyersRemoteDataSourceImpl implements LawyersRemoteDataSource {
  final ApiClient _apiClient;

  LawyersRemoteDataSourceImpl(this._apiClient);

  @override
  Future<LawyersListMobileResponseModel> getLawyersMobile({String countryCode = 'BH'}) async {
    final response = await _apiClient.get(
      '/api/mobile/lawyers',
      queryParameters: {'countryCode': countryCode},
    );
    return LawyersListMobileResponseModel.fromJson(response.data);
  }

  @override
  Future<LawyerDetailResponseModel> getLawyerDetails(String id) async {
    final response = await _apiClient.get('/api/lawyers/$id');
    return LawyerDetailResponseModel.fromJson(response.data);
  }

  @override
  Future<LawyersListMobileResponseModel> searchLawyers(String query, {String countryCode = 'BH'}) async {
    final params = {'q': query, 'countryCode': countryCode};
    final response = await _apiClient.get('/api/mobile/lawyers/search', queryParameters: params);
    return LawyersListMobileResponseModel.fromJson(response.data);
  }

  @override
  Future<LawyerModel> getLawyerProfile() async {
    final response = await _apiClient.get('/api/mobile/lawyer/profile');
    final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
    return LawyerModel.fromJson(data);
  }

  @override
  Future<void> updateLocation(String lawyerId, double latitude, double longitude) async {
    await _apiClient.put(
      '/api/lawyers/location',
      data: {
        'lawyerId': lawyerId,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }
}