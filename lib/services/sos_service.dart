import 'api_client.dart';

class SosService {
  final ApiClient api;
  SosService(this.api);

  Future<void> trigger({double? latitude, double? longitude, String? note}) => api.post(
        '/api/v1/sos',
        {
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (note != null) 'note': note,
        },
      );
}
