import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawyers_bh/domain/usecases/notifications/get_notifications_usecase.dart';
import 'package:lawyers_bh/domain/usecases/notifications/get_unread_notifications_count_usecase.dart';
import 'package:lawyers_bh/domain/usecases/notifications/mark_notification_as_read_usecase.dart';
import 'package:lawyers_bh/domain/usecases/notifications/mark_all_notifications_as_read_usecase.dart';
import 'package:lawyers_bh/domain/usecases/notifications/delete_notification_usecase.dart';
import 'package:lawyers_bh/domain/entities/notification.dart';
import 'package:lawyers_bh/core/errors/exceptions.dart';

class NotificationsState {
  final List<Notification> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? error;

  const NotificationsState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
  });

  NotificationsState copyWith({
    List<Notification>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? error,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NotificationsProvider extends StateNotifier<NotificationsState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final GetUnreadNotificationsCountUseCase _getUnreadCountUseCase;
  final MarkNotificationAsReadUseCase _markAsReadUseCase;
  final MarkAllNotificationsAsReadUseCase _markAllAsReadUseCase;
  final DeleteNotificationUseCase _deleteNotificationUseCase;

  NotificationsProvider({
    required GetNotificationsUseCase getNotificationsUseCase,
    required GetUnreadNotificationsCountUseCase getUnreadCountUseCase,
    required MarkNotificationAsReadUseCase markAsReadUseCase,
    required MarkAllNotificationsAsReadUseCase markAllAsReadUseCase,
    required DeleteNotificationUseCase deleteNotificationUseCase,
  })  : _getNotificationsUseCase = getNotificationsUseCase,
        _getUnreadCountUseCase = getUnreadCountUseCase,
        _markAsReadUseCase = markAsReadUseCase,
        _markAllAsReadUseCase = markAllAsReadUseCase,
        _deleteNotificationUseCase = deleteNotificationUseCase,
        super(const NotificationsState());

  Future<void> loadNotifications({bool unreadOnly = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final notifications = await _getNotificationsUseCase(unreadOnly: unreadOnly);
      final unreadCount = await _getUnreadCountUseCase();
      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: false,
      );
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'حدث خطأ غير متوقع');
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _markAsReadUseCase(id);
      final updatedNotifications = state.notifications.map((n) {
        if (n.id == id) return n.copyWith(isRead: true);
        return n;
      }).toList();
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
      );
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _markAllAsReadUseCase();
      final updatedNotifications = state.notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );
    } catch (_) {}
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _deleteNotificationUseCase(id);
      final notification = state.notifications.firstWhere((n) => n.id == id);
      final updatedNotifications = state.notifications
          .where((n) => n.id != id)
          .toList();
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: notification.isRead ? state.unreadCount : state.unreadCount - 1,
      );
    } catch (_) {}
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}