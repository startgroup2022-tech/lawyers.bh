import 'api_client.dart';

/// A notification as the lawyer inbox models it.
class AppNotification {
  final int id;
  final String title;
  final String? body;
  final String category;
  final String priority;
  final bool isRead;
  final String? actionUrl;
  final String createdAt;

  AppNotification({
    required this.id,
    required this.title,
    this.body,
    required this.category,
    required this.priority,
    required this.isRead,
    this.actionUrl,
    required this.createdAt,
  });
}

/// The notification inbox is scoped to a lawyer session.
///
/// `/api/mobile/notifications` and `/api/mobile/lawyer/notifications` both
/// require a mobile **lawyer** session token (or an SOS dispatch token); there
/// is no notification feed for a client account. Client notification
/// preferences are settable (`/api/mobile/notification-preferences`), but the
/// feed itself is not exposed, so listing is reported as unavailable.
class NotificationsService {
  final ApiClient api;
  NotificationsService(this.api);

  static ApiException _unavailable() => ApiException.featureUnavailable(
        'الإشعارات غير متاحة في تطبيق العميل حاليًا',
      );

  Future<(List<AppNotification> items, int unread)> list({bool unreadOnly = false}) async =>
      throw _unavailable();

  Future<void> markRead(int id) async => throw _unavailable();

  Future<int> markAllRead() async => throw _unavailable();
}
