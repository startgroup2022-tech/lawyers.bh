import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lawyers_bh/domain/entities/notification.dart';

part 'notification_models.freezed.dart';
part 'notification_models.g.dart';

@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    required String title,
    required String body,
    required String type,
    required String priority,
    String? relatedId,
    String? relatedType,
    required bool isRead,
    required String createdAt,
    String? readAt,
    Map<String, dynamic>? data,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);

  Notification toEntity() {
    return Notification(
      id: id,
      title: title,
      body: body,
      type: NotificationType.values.byName(type),
      priority: NotificationPriority.values.byName(priority),
      relatedId: relatedId,
      relatedType: relatedType,
      isRead: isRead,
      createdAt: DateTime.parse(createdAt),
      readAt: readAt != null ? DateTime.parse(readAt!) : null,
      data: data,
    );
  }
}

@freezed
class NotificationsListResponseModel with _$NotificationsListResponseModel {
  const factory NotificationsListResponseModel({
    required List<NotificationModel> data,
    required int total,
    required int page,
    required int limit,
    required int totalPages,
  }) = _NotificationsListResponseModel;

  factory NotificationsListResponseModel.fromJson(Map<String, dynamic> json) => _$NotificationsListResponseModelFromJson(json);
}