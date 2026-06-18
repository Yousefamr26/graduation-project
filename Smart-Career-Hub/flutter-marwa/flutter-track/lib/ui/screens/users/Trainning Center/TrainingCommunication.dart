import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/services/api_service.dart';
import '../../../../core/Constants/apiConstants.dart';

class TrainingCommunication extends StatefulWidget {
  const TrainingCommunication({super.key});
  @override
  State<TrainingCommunication> createState() => _TrainingCommunicationState();
}

class _TrainingCommunicationState extends State<TrainingCommunication> {
  static const Color kPrimary = Color(0xff1676C4);
  static const Color kBg = Color(0xffF0F9FF);

  // ── Trainees from API ──
  List<Map<String, dynamic>> _rooms = [];
  bool _loading = true;

  // ── Messages remain local ──
  Map<String, List<Map<String, dynamic>>> _messages = {};

  String? _activeRoom;
  String? _activeRoomName;
  final _msgCtrl = TextEditingController();
  String _search = '';

  String? _error;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _loadLocalMessages();
    await _loadCandidates();
  }

  Future<void> _loadLocalMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString('training_center_messages');
      if (str != null) {
        final decoded = json.decode(str) as Map<String, dynamic>;
        setState(() {
          _messages = decoded.map((key, value) => MapEntry(
            key,
            List<Map<String, dynamic>>.from(value as List),
          ));
        });
      }
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  Future<void> _saveLocalMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('training_center_messages', json.encode(_messages));
    } catch (e) {
      print('Error saving messages: $e');
    }
  }

  Future<void> _loadCandidates() async {
    try {
      final res = await ApiService.get('/Candidates', userType: 'training_center');
      final raw = (res is List ? res : res?['data'] ?? res?['items'] ?? []) as List;

      final Map<String, Map<String, dynamic>> grouped = {};
      for (final item in raw) {
        final map = Map<String, dynamic>.from(item as Map);
        final uid = map['userId']?.toString() ?? '';
        if (uid.isEmpty) continue;

        if (!grouped.containsKey(uid)) {
          // Pre-populate last message if we have local history
          String lastMsg = '';
          String lastTime = '';
          if (_messages.containsKey(uid) && _messages[uid]!.isNotEmpty) {
            final last = _messages[uid]!.last;
            lastMsg = last['content'] ?? '';
            lastTime = last['sentAt'] ?? '';
          }

          grouped[uid] = {
            'id': uid,
            'name': map['fullName'] ?? 'Candidate',
            'course': map['roadmapName'] ?? '',
            'profileImage': map['profileImage'] ?? '',
            'roadmapCount': 1,
            'lastMessage': lastMsg,
            'lastMessageAt': lastTime,
            'unreadCount': 0,
            'isOnline': false,
          };
        } else {
          grouped[uid]!['roadmapCount'] = (grouped[uid]!['roadmapCount'] as int) + 1;
          if ((map['profileImage'] ?? '').toString().isNotEmpty) {
            grouped[uid]!['profileImage'] = map['profileImage'];
          }
        }
      }
      if (mounted) {
        setState(() {
        _rooms = grouped.values.toList();
        _error = null;
      });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
      print('Error loading candidates: $e');
    }
    if (mounted) setState(() => _loading = false);
  }


  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  void _send(String roomId) {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    setState(() {
      _messages.putIfAbsent(roomId, () => []);
      _messages[roomId]!.add({
        'content': text,
        'isMe': true,
        'sentAt': TimeOfDay.now().format(context),
        'senderName': 'Me',
      });
      // Update last message in room list
      final roomIndex = _rooms.indexWhere((r) => r['id'] == roomId);
      if (roomIndex != -1) {
        _rooms[roomIndex]['lastMessage'] = text;
        _rooms[roomIndex]['lastMessageAt'] = TimeOfDay.now().format(context);
        _rooms[roomIndex]['unreadCount'] = 0;
      }
    });
    _saveLocalMessages();
  }

  List<Map<String, dynamic>> get _filteredRooms => _search.isEmpty
      ? _rooms
      : _rooms.where((r) {
          final name = (r['name'] ?? '').toString().toLowerCase();
          final course = (r['course'] ?? '').toString().toLowerCase();
          return name.contains(_search.toLowerCase()) || course.contains(_search.toLowerCase());
        }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kPrimary, elevation: 0, automaticallyImplyLeading: false,
        leading: _activeRoom != null
          ? IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => setState(() { _activeRoom = null; _activeRoomName = null; }))
          : null,
        title: Text(_activeRoomName ?? 'Trainee Communication',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: kPrimary))
        : _activeRoom != null
          ? _buildChat(_activeRoom!)
          : _buildRoomList(),
    );
  }

  Widget _buildRoomList() {
    final rooms = _filteredRooms;
    if (_error != null) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextButton(onPressed: _loadCandidates, child: const Text('Try Again')),
        ]),
      ));
    }
    if (_rooms.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
        const SizedBox(height: 12),
        Text('No candidates found', style: TextStyle(color: Colors.grey[500])),
        TextButton(onPressed: _loadCandidates, child: const Text('Refresh')),
      ]));
    }

    return Column(children: [
      Padding(padding: const EdgeInsets.all(12), child: TextField(
        onChanged: (v) => setState(() => _search = v),
        decoration: InputDecoration(
          hintText: 'Search trainees...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 12)),
      )),
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: rooms.length,
        itemBuilder: (_, i) {
          final r = rooms[i];
          final id = r['id']?.toString() ?? '$i';
          final name = r['name'] ?? 'Trainee';
          final last = r['lastMessage'] ?? '';
          final time = r['lastMessageAt']?.toString() ?? '';
          final unread = r['unreadCount'] ?? 0;
          final online = r['isOnline'] ?? false;
          final course = r['course'] ?? '';
          final roadmapCount = r['roadmapCount'] ?? 1;
          final profileImage = r['profileImage']?.toString() ?? '';
          final fullImageUrl = profileImage.isNotEmpty ? ApiConstants.getImageUrl(profileImage) : '';

          return GestureDetector(
            onTap: () {
              setState(() {
                _activeRoom = id;
                _activeRoomName = name.toString();
                // Clear unread count when opening
                r['unreadCount'] = 0;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
              child: Row(children: [
                Stack(children: [
                  CircleAvatar(radius: 24, backgroundColor: kPrimary.withOpacity(0.15),
                    backgroundImage: fullImageUrl.isNotEmpty ? NetworkImage(fullImageUrl) : null,
                    child: fullImageUrl.isEmpty
                      ? Text(name.toString()[0].toUpperCase(),
                          style: const TextStyle(color: kPrimary, fontWeight: FontWeight.bold, fontSize: 18))
                      : null,
                  ),
                  if (online) Positioned(bottom: 0, right: 0, child: Container(width: 12, height: 12,
                    decoration: BoxDecoration(color: const Color(0xff22C55E), shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2)))),
                ]),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(name.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ]),
                  if (course.toString().isNotEmpty)
                    Text(roadmapCount > 1 ? '$course +${roadmapCount - 1} more' : course.toString(),
                      style: const TextStyle(fontSize: 11, color: kPrimary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(child: Text(last.toString(), style: TextStyle(fontSize: 12, color: unread > 0 ? Colors.black87 : Colors.grey, fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                    if (unread > 0) Container(width: 20, height: 20,
                      decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle),
                      child: Center(child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)))),
                  ]),
                ])),
              ]),
            ),
          );
        },
      )),
    ]);
  }

  Widget _buildChat(String roomId) {
    final msgs = _messages[roomId] ?? [];
    return Column(children: [
      Expanded(child: msgs.isEmpty
        ? const Center(child: Text('Start a conversation', style: TextStyle(color: Colors.grey)))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: msgs.length,
            itemBuilder: (_, i) {
              final m = msgs[i];
              final isMe = m['isMe'] == true;
              final text = m['content'] ?? '';
              final timeStr = m['sentAt']?.toString() ?? '';

              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                  decoration: BoxDecoration(
                    color: isMe ? kPrimary : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(text.toString(), style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(timeStr, style: TextStyle(color: isMe ? Colors.white60 : Colors.grey, fontSize: 10)),
                  ]),
                ),
              );
            }),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
        decoration: BoxDecoration(color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -3))]),
        child: Row(children: [
          Expanded(child: TextField(controller: _msgCtrl,
            onSubmitted: (_) => _send(roomId),
            decoration: InputDecoration(
              hintText: 'Write your message...',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true, fillColor: const Color(0xffF0F9FF),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
          )),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _send(roomId),
            child: Container(width: 44, height: 44,
              decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20)),
          ),
        ]),
      ),
    ]);
  }
}
