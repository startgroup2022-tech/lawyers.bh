import 'package:lawyers_bh/domain/entities/notification.dart';
import 'package:lawyers_bh/domain/repositories/repositories.dart';

class GetNotificationsUseCase {
  final NotificationsRepository _repository;

  GetNotificationsUseCase(this._repository);

  Future<List<Notification>> call({bool unreadOnly = false, int page = 1, int limit = 20}) {
    return _repository.getNotifications(unreadOnly: unreadOnly, page: page, limit: limit);
  }
}

class GetUnreadNotificationsCountUseCase {
  final NotificationsRepository _repository;

  GetUnreadNotificationsCountUseCase(this._repository);

  Future<int> call() {
    return _repository.getUnreadCount();
  }
}

class MarkNotificationAsReadUseCase {
  final NotificationsRepository _repository;

  MarkNotificationAsReadUseCase(this._repository);

  Future<void> call(String id) {
    return _repository.markAsRead(id);
  }
}

class MarkAllNotificationsAsReadUseCase {
  final NotificationsRepository _repository;

  MarkAllNotificationsAsReadUseCase(this._repository);

  Future<void> call() {
    return _repository.markAllAsRead();
  }
}

class DeleteNotificationUseCase {
  final NotificationsRepository _repository;

  DeleteNotificationUseCase(this._repository);

  Future<void> call(String id) {
    return _repository.deleteNotification(id);
  }
}