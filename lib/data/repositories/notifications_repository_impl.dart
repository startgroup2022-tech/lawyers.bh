import 'package:lawyers_bh/data/datasources/remote/notifications_remote_datasource.dart';
import 'package:lawyers_bh/domain/repositories/notifications_repository.dart';
import 'package:lawyers_bh/domain/entities/notification.dart';
import 'package:lawyers_bh/core/errors/exceptions.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource _remoteDataSource;

  NotificationsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Notification>> getNotifications({bool unreadOnly = false, int page = 1, int limit = 20}) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (unreadOnly) {
        query['unread_only'] = true;
      }

      final response = await _remoteDataSource.getNotifications(query: query);
      return response.data.map((e) => e.toEntity()).toList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      return await _remoteDataSource.getUnreadCount();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _remoteDataSource.markAsRead(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _remoteDataSource.markAllAsRead();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      await _remoteDataSource.deleteNotification(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }
}