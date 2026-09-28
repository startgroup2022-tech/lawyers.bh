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

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: int.parse(json['id'].toString()),
        type: json['conversation_type'] ?? 'client_lawyer',
        subject: json['subject'],
        caseId: json['case_id'] == null ? null : int.parse(json['case_id'].toString()),
        lastMessagePreview: json['last_message_preview'],
        messagesCount: int.tryParse('${json['messages_count']}') ?? 0,
      );
}

class Message {
  final int id;
  final String body;
  final int senderUserId;
  final String senderName;
  final String createdAt;

  Message({
    required this.id,
    required this.body,
    required this.senderUserId,
    required this.senderName,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: int.parse(json['id'].toString()),
        body: json['body'] ?? '',
        senderUserId: int.parse(json['sender_user_id'].toString()),
        senderName: json['sender_name'] ?? '',
        createdAt: json['created_at'] ?? '',
      );
}

class MessagesService {
  final ApiClient api;
  MessagesService(this.api);

  Future<List<Conversation>> conversations() async {
    final data = await api.get('/api/v1/conversations');
    return (data['conversations'] as List).map((e) => Conversation.fromJson(e)).toList();
  }

  Future<List<Message>> messages(int conversationId) async {
    final data = await api.get('/api/v1/conversations/$conversationId/messages');
    return (data['messages'] as List).map((e) => Message.fromJson(e)).toList();
  }

  Future<int> send(int conversationId, String body) async {
    final data = await api.post('/api/v1/conversations/$conversationId/messages', {'body': body});
    return int.parse('${data['id']}');
  }
}
