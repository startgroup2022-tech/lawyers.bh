import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../services/api_client.dart';
import '../services/messages_service.dart';
import '../theme/app_theme.dart';

/// The caller's conversations, shared by the client and lawyer workspaces.
///
/// The backend scopes the list to conversations the account is a member of,
/// so the same screen serves both rooms without any role branch on the client
/// side: a lawyer sees the threads they were pulled into, a client sees theirs.
class MessagesScreen extends StatefulWidget {
  /// When set, tapping a thread opens the conversation directly.
  final int? initialConversationId;

  const MessagesScreen({super.key, this.initialConversationId});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<Conversation> _conversations = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await context.read<AppState>().messages.conversations();
      if (!mounted) return;
      setState(() {
        _conversations = list;
      });
      final target = widget.initialConversationId;
      if (target != null) {
        final matches = list.where((c) => c.id == target);
        if (matches.isNotEmpty) _open(matches.first);
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message ?? 'تعذّر تحميل المحادثات');
    } catch (_) {
      if (mounted) setState(() => _error = 'تعذّر تحميل المحادثات');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _open(Conversation conversation) => Navigator.of(context)
      .push(MaterialPageRoute(
        builder: (_) => MessageThreadScreen(conversation: conversation),
      ))
      .then((_) => _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الرسائل')),
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _ErrorState(message: _error!, onRetry: _load);
    if (_conversations.isEmpty) {
      return const _EmptyState(
        icon: Icons.forum_outlined,
        message: 'لا توجد محادثات بعد. تُفتح المحادثة تلقائيًا مع كل استشارة أو قضية.',
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _conversations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final c = _conversations[i];
          return InkWell(
            onTap: () => _open(c),
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.neutralBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.chat_bubble_outline,
                        size: 19, color: AppColors.neutralInk),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.subject?.isNotEmpty == true ? c.subject! : _typeLabel(c.type),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.cairo(size: 13, weight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Text(
                          c.lastMessagePreview?.isNotEmpty == true
                              ? c.lastMessagePreview!
                              : 'لا رسائل بعد',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.tajawal(size: 11, color: AppColors.ink2),
                        ),
                      ],
                    ),
                  ),
                  if (c.messagesCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.neutralBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${c.messagesCount}',
                          style: AppTextStyles.cairo(
                              size: 11, weight: FontWeight.w700, color: AppColors.neutralInk)),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static String _typeLabel(String type) {
    switch (type) {
      case 'case':
        return 'محادثة قضية';
      case 'support':
        return 'الدعم';
      default:
        return 'محادثة';
    }
  }
}

/// One conversation's messages, with a composer.
class MessageThreadScreen extends StatefulWidget {
  final Conversation conversation;

  const MessageThreadScreen({super.key, required this.conversation});

  @override
  State<MessageThreadScreen> createState() => _MessageThreadScreenState();
}

class _MessageThreadScreenState extends State<MessageThreadScreen> {
  final _composer = TextEditingController();
  final _scroll = ScrollController();
  List<Message> _messages = const [];
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _composer.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list =
          await context.read<AppState>().messages.messages(widget.conversation.id);
      if (!mounted) return;
      setState(() {
        _messages = list;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message ?? 'تعذّر تحميل الرسائل');
    } catch (_) {
      if (mounted) setState(() => _error = 'تعذّر تحميل الرسائل');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final body = _composer.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await context.read<AppState>().messages.send(widget.conversation.id, body);
      _composer.clear();
      await _load();
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'تعذّر إرسال الرسالة')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = context.read<AppState>().currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversation.subject?.isNotEmpty == true
            ? widget.conversation.subject!
            : 'المحادثة'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _body(me?.id)),
            _composerBar(),
          ],
        ),
      ),
    );
  }

  Widget _body(int? myUserId) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _ErrorState(message: _error!, onRetry: _load);
    if (_messages.isEmpty) {
      return const _EmptyState(
        icon: Icons.mark_chat_unread_outlined,
        message: 'ابدأ المحادثة بإرسال أول رسالة.',
      );
    }
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, i) {
        final m = _messages[i];
        final mine = myUserId != null && m.senderUserId == myUserId;
        return Align(
          alignment: mine ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: mine ? AppColors.brandRed : AppColors.surface,
              border: mine ? null : Border.all(color: AppColors.line),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Column(
              crossAxisAlignment:
                  mine ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                if (!mine)
                  Text(m.senderName,
                      style: AppTextStyles.cairo(
                          size: 11, weight: FontWeight.w700, color: AppColors.ink2)),
                Text(m.body,
                    style: AppTextStyles.tajawal(
                        size: 12.5, color: mine ? Colors.white : AppColors.ink)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _composerBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _composer,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: const InputDecoration(hintText: 'اكتب رسالة…'),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            style: IconButton.styleFrom(backgroundColor: AppColors.brandRed),
            onPressed: _sending ? null : _send,
            icon: _sending
                ? const SizedBox(
                    width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.send, size: 18),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: AppColors.ink3),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: AppTextStyles.tajawal(size: 13, color: AppColors.ink2)),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 40, color: AppColors.ink3),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: AppTextStyles.tajawal(size: 12.5, color: AppColors.ink2)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ),
      ),
    );
  }
}
