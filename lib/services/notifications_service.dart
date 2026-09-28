import 'api_client.dart';

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

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: int.parse(json['id'].toString()),
        title: json['title'] ?? '',
        body: json['body'],
        category: json['category'] ?? 'system',
        priority: json['priority'] ?? 'normal',
        isRead: json['is_read'] == true || json['is_read'] == 1,
        actionUrl: json['action_url'],
        createdAt: json['created_at'] ?? '',
      );
}

class NotificationsService {
  final ApiClient api;
  NotificationsService(this.api);

  /// Returns the caller's notifications plus the unread count.
  Future<(List<AppNotification> items, int unread)> list({bool unreadOnly = false}) async {
    final data = await api.get('/api/v1/notifications', query: {
      if (unreadOnly) 'unread_only': true,
    });
    final items = (data['notifications'] as List)
        .map((e) => AppNotification.fromJson(e))
        .toList();
    return (items, int.tryParse('${data['unread_count']}') ?? 0);
  }

  Future<void> markRead(int id) => api.post('/api/v1/notifications/$id/read');

  Future<int> markAllRead() async {
    final data = await api.post('/api/v1/notifications/read-all');
    return int.tryParse('${data['marked_read']}') ?? 0;
  }
}
