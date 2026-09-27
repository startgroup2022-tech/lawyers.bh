import 'package:lawyers_bh/core/network/api_client.dart';
import 'package:lawyers_bh/data/models/notification_models.dart';

abstract class NotificationsRemoteDataSource {
  Future<NotificationsListResponseModel> getNotifications({Map<String, dynamic>? query});
  Future<int> getUnreadCount();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final ApiClient _apiClient;

  NotificationsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<NotificationsListResponseModel> getNotifications({Map<String, dynamic>? query}) async {
    final response = await _apiClient.get('/notifications', queryParameters: query);
    return NotificationsListResponseModel.fromJson(response.data);
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _apiClient.get('/notifications/unread-count');
    return response.data['count'] as int;
  }

  @override
  Future<void> markAsRead(String id) async {
    await _apiClient.patch('/notifications/$id/read');
  }

  @override
  Future<void> markAllAsRead() async {
    await _apiClient.patch('/notifications/read-all');
  }

  @override
  Future<void> deleteNotification(String id) async {
    await _apiClient.delete('/notifications/$id');
  }
}