import 'api_client.dart';

/// A conversation the caller is a member of.
class Conversation {
  final int id;
  final String? subject;
  final String type;
  final int? caseId;
  final String? lastMessagePreview;
  final int messagesCount;

  Conversation({
    required this.id,
    required this.type,
    this.subject,
    this.caseId,
    this.lastMessagePreview,
    this.messagesCount = 0,
  });
}

class Message {
  final int id;
  final String body;
  final String senderName;
  final String createdAt;

  Message({
    required this.id,
    required this.body,
    required this.senderName,
    required this.createdAt,
  });
}

/// Client messaging is not exposed by the platform API.
///
/// The production communications routes (`/api/mobile/communications/*`) are
/// scoped to a lawyer session or to a per-request capability token issued during
/// an emergency (SOS) flow. There is no endpoint that lists a client's
/// conversations by account, so these methods report the gap instead of calling
/// a route that does not exist and rendering an empty list.
class MessagesService {
  final ApiClient api;
  MessagesService(this.api);

  static const unavailable = ApiException(
    'feature_not_available',
    501,
    message: 'المحادثات غير متاحة في تطبيق العميل حاليًا',
  );

  Future<List<Conversation>> conversations() async => throw unavailable;

  Future<List<Message>> messages(int conversationId) async => throw unavailable;

  Future<int> send(int conversationId, String body) async => throw unavailable;
}
