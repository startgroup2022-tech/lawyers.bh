import 'package:equatable/equatable.dart';

enum NotificationType { hearing, payment, document, message, system, reminder, dispute }
enum NotificationPriority { low, normal, high, urgent }

class Notification extends Equatable {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final String? relatedId;
  final String? relatedType;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic>? data;

  const Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.priority,
    this.relatedId,
    this.relatedType,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.data,
  });

  @override
  List<Object?> get props => [
    id, title, body, type, priority, relatedId, relatedType,
    isRead, createdAt, readAt, data,
  ];

  Notification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    String? relatedId,
    String? relatedType,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    Map<String, dynamic>? data,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      relatedId: relatedId ?? this.relatedId,
      relatedType: relatedType ?? this.relatedType,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      data: data ?? this.data,
    );
  }
}