import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../../../data/models/company/Chat models.dart';
import '../../../../../../data/repositories/Chat repository.dart';

class ChatMessagesScreen extends StatefulWidget {
  final ChatRoom room;
  final String myId;

  const ChatMessagesScreen({
    super.key,
    required this.room,
    required this.myId,
  });

  @override
  State<ChatMessagesScreen> createState() => _ChatMessagesScreenState();
}

class _OptimisticMessage {
  final ChatMessage message;
  final bool isPending;
  final bool hasFailed;

  const _OptimisticMessage({
    required this.message,
    this.isPending = false,
    this.hasFailed = false,
  });

  _OptimisticMessage copyWith({bool? isPending, bool? hasFailed}) {
    return _OptimisticMessage(
      message: message,
      isPending: isPending ?? this.isPending,
      hasFailed: hasFailed ?? this.hasFailed,
    );
  }
}

class _ChatMessagesScreenState extends State<ChatMessagesScreen>
    with WidgetsBindingObserver {
  final ChatRepository _repo = ChatRepository();
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final FocusNode _focusNode = FocusNode();

  List<_OptimisticMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String _error = '';
  Timer? _pollTimer;
  int _tempIdCounter = -1;

  // ✅ FIX: flag عشان نمنع تشغيل poll جديد لو في واحد شغال
  bool _isPolling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMessages();
    _startPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
    _ctrl.dispose();
    _scroll.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startPolling() {
    _stopPolling(); // ✅ FIX: دايماً وقف القديم الأول
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted && !_isPolling) _silentRefresh();
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _stopPolling();
    } else if (state == AppLifecycleState.resumed) {
      _silentRefresh();
      _startPolling(); // ✅ FIX: _startPolling بتوقف القديم أوتوماتيك
    }
  }

  // ✅ FIX: silent refresh منفصلة بـ guard
  Future<void> _silentRefresh() async {
    if (_isPolling) return;
    _isPolling = true;
    try {
      await _loadMessages(silent: true);
    } finally {
      _isPolling = false;
    }
  }

  Future<void> _loadMessages({bool silent = false}) async {
    if (!silent) setState(() { _isLoading = true; _error = ''; });
    try {
      final response = await _repo.getMessages(widget.room.id);
      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> list = [];

        if (data is List) {
          list = data;
        } else if (data is Map) {
          list = data['data'] ?? data['messages'] ?? data['result'] ?? [];
        }

        final confirmed = list
            .map((e) => ChatMessage.fromJson(
            e as Map<String, dynamic>, widget.myId))
            .toList();

        confirmed.sort((a, b) => a.sentAt.compareTo(b.sentAt));

        if (mounted) {
          setState(() {
            final serverIds = confirmed.map((m) => m.id).toSet();

            // ✅ FIX: بس الـ pending اللي لسه مش موجودة على السيرفر
            final pendingOnly = _messages
                .where((m) =>
            m.isPending &&
                !m.hasFailed &&
                m.message.id < 0 &&
                !serverIds.contains(m.message.id))
                .toList();

            _messages = [
              ...confirmed.map((m) => _OptimisticMessage(message: m)),
              ...pendingOnly,
            ];
            _isLoading = false;
          });
          _scrollToBottom();
        }
      } else {
        if (!silent && mounted) {
          setState(() {
            _error = 'Failed to load messages (${response.statusCode})';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (!silent && mounted) {
        setState(() { _error = 'Error: $e'; _isLoading = false; });
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _isSending) return;

    _ctrl.clear();

    final tempId = _tempIdCounter--;
    final optimisticMsg = ChatMessage(
      id: tempId,
      roomId: widget.room.id,
      content: text,
      senderId: widget.myId,
      senderName: '',
      sentAt: DateTime.now().toUtc().toIso8601String(),
      isRead: false,
      isMine: true,
    );

    setState(() {
      _isSending = true;
      _messages.add(_OptimisticMessage(message: optimisticMsg, isPending: true));
    });
    _scrollToBottom();

    try {
      final response = await _repo.sendMessage(
        roomId: widget.room.id,
        content: text,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ FIX: اشيل الـ pending message الأول قبل ما تجيب من السيرفر
        if (mounted) {
          setState(() {
            _messages.removeWhere((m) => m.message.id == tempId);
          });
        }
        await _loadMessages(silent: true);
      } else {
        if (mounted) {
          setState(() {
            final idx = _messages.indexWhere((m) => m.message.id == tempId);
            if (idx != -1) {
              _messages[idx] = _messages[idx].copyWith(
                isPending: false,
                hasFailed: true,
              );
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to send. Tap to retry.'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => _retryMessage(tempId, text),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          final idx = _messages.indexWhere((m) => m.message.id == tempId);
          if (idx != -1) {
            _messages[idx] = _messages[idx].copyWith(
              isPending: false,
              hasFailed: true,
            );
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _retryMessage(tempId, text),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _retryMessage(int tempId, String text) async {
    setState(() {
      _messages.removeWhere((m) => m.message.id == tempId);
    });
    _ctrl.text = text;
    await _sendMessage();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(String raw) {
    if (raw.isEmpty) return '';
    try {
      final normalized = raw.endsWith('Z') ? raw : '${raw}Z';
      final dt = DateTime.parse(normalized).toLocal();
      final now = DateTime.now();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');

      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        return '$h:$m';
      }
      return '${dt.day}/${dt.month} $h:$m';
    } catch (_) {
      return raw;
    }
  }

  bool _showDateSeparator(int index) {
    if (index == 0) return true;
    try {
      final currRaw = _messages[index].message.sentAt;
      final prevRaw = _messages[index - 1].message.sentAt;
      final currNorm = currRaw.endsWith('Z') ? currRaw : '${currRaw}Z';
      final prevNorm = prevRaw.endsWith('Z') ? prevRaw : '${prevRaw}Z';
      final curr = DateTime.parse(currNorm).toLocal();
      final prev = DateTime.parse(prevNorm).toLocal();
      return curr.day != prev.day ||
          curr.month != prev.month ||
          curr.year != prev.year;
    } catch (_) {
      return false;
    }
  }

  String _formatDate(String raw) {
    try {
      final normalized = raw.endsWith('Z') ? raw : '${raw}Z';
      final dt = DateTime.parse(normalized).toLocal();
      final now = DateTime.now();
      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        return 'Today';
      }
      final yesterday = now.subtract(const Duration(days: 1));
      if (dt.day == yesterday.day &&
          dt.month == yesterday.month &&
          dt.year == yesterday.year) return 'Yesterday';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      resizeToAvoidBottomInset: true,
      body: Column(children: [
        _buildHeader(),
        Expanded(child: _buildMessages()),
        _buildInputBar(),
      ]),
    );
  }

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff1676C4), Color(0xff0d5fa3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 16),
          child: Row(children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            _buildHeaderAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.room.participantName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('Online',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8), fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
              onPressed: () => _loadMessages(),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeaderAvatar() {
    const double size = 40;
    final logo = widget.room.participantLogo;
    if (logo.isNotEmpty) {
      final url = logo.startsWith('http')
          ? logo
          : 'http://smartcareerhub.runasp.net$logo';
      return ClipOval(
        child: Image.network(url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initialsCircle(size)),
      );
    }
    return _initialsCircle(size);
  }

  Widget _initialsCircle(double size) {
    final name = widget.room.participantName;
    final initials = name.trim().isEmpty
        ? '?'
        : name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.25),
      ),
      child: Center(
        child: Text(initials,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ── Messages list ─────────────────────────────────────────────
  Widget _buildMessages() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xff1676C4)));
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(_error, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadMessages,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1676C4)),
            child:
            const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ]),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.waving_hand, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('Say hello! 👋',
              style: TextStyle(fontSize: 16, color: Colors.grey[400])),
        ]),
      );
    }

    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (_, i) {
        final wrapper = _messages[i];
        return Column(children: [
          if (_showDateSeparator(i))
            _buildDateSeparator(wrapper.message.sentAt),
          _buildMessageBubble(wrapper),
        ]);
      },
    );
  }

  Widget _buildDateSeparator(String raw) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Expanded(child: Divider(color: Colors.grey[300])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            _formatDate(raw),
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[300])),
      ]),
    );
  }

  Widget _buildMessageBubble(_OptimisticMessage wrapper) {
    final msg = wrapper.message;
    final isMine = msg.isMine;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment:
        isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            _buildSmallAvatar(),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Opacity(
              opacity: wrapper.isPending ? 0.65 : 1.0,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isMine
                      ? (wrapper.hasFailed
                      ? Colors.red.shade400
                      : const Color(0xff1676C4))
                      : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMine ? 18 : 4),
                    bottomRight: Radius.circular(isMine ? 4 : 18),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: isMine
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg.content,
                      style: TextStyle(
                          fontSize: 14,
                          color:
                          isMine ? Colors.white : Colors.grey[800],
                          height: 1.4),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(msg.sentAt),
                          style: TextStyle(
                              fontSize: 10,
                              color: isMine
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.grey[400]),
                        ),
                        if (isMine) ...[
                          const SizedBox(width: 4),
                          if (wrapper.hasFailed)
                            const Icon(Icons.error_outline,
                                size: 14, color: Colors.white)
                          else if (wrapper.isPending)
                            Icon(Icons.schedule,
                                size: 14,
                                color: Colors.white.withOpacity(0.6))
                          else
                            Icon(
                              msg.isRead ? Icons.done_all : Icons.done,
                              size: 14,
                              color: msg.isRead
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.6),
                            ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isMine) const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _buildSmallAvatar() {
    const double size = 28;
    final logo = widget.room.participantLogo;
    if (logo.isNotEmpty) {
      final url = logo.startsWith('http')
          ? logo
          : 'http://smartcareerhub.runasp.net$logo';
      return ClipOval(
        child: Image.network(url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _tinyInitials(size)),
      );
    }
    return _tinyInitials(size);
  }

  Widget _tinyInitials(double size) {
    final name = widget.room.participantName;
    final initials = name.trim().isEmpty
        ? '?'
        : name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
            colors: [Color(0xff1676C4), Color(0xff0d5fa3)]),
      ),
      child: Center(
        child: Text(initials,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ── Input bar ─────────────────────────────────────────────────
  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, -3))
          ],
        ),
        child: Row(children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xffF5F7FB),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _ctrl,
                focusNode: _focusNode,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xff1676C4), Color(0xff0d5fa3)]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xff1676C4).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ],
              ),
              child: _isSending
                  ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ]),
      ),
    );
  }
}