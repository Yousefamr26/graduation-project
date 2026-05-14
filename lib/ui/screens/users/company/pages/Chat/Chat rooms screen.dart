import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../data/models/company/Chat models.dart';
import '../../../../../../data/repositories/Chat repository.dart';
import 'Chat messages screen.dart';

class ChatRoomsScreen extends StatefulWidget {
  const ChatRoomsScreen({super.key});

  @override
  State<ChatRoomsScreen> createState() => _ChatRoomsScreenState();
}

class _ChatRoomsScreenState extends State<ChatRoomsScreen> {
  final ChatRepository _repo = ChatRepository();
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://smartcareerhub.runasp.net/api/',
    headers: {'Accept': 'application/json'},
    validateStatus: (s) => s! < 500,
  ));

  List<ChatRoom> _rooms = [];
  bool _isLoading = true;
  String _myId = '';
  String _error = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadMyId();
    await _loadRooms();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('company_token') ??
        prefs.getString('university_token') ??
        prefs.getString('token');
  }

  Future<void> _loadMyId() async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) return;
      final parts = token.split('.');
      if (parts.length == 3) {
        final decoded = utf8.decode(
            base64Url.decode(base64Url.normalize(parts[1])));
        final payload = jsonDecode(decoded) as Map<String, dynamic>;
        _myId = payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier']
            ?.toString() ??
            payload['nameid']?.toString() ??
            payload['sub']?.toString() ??
            payload['id']?.toString() ??
            '';
        debugPrint('✅ [MY ID] $_myId');
      }
    } catch (e) {
      debugPrint('⚠️ [TOKEN] $e');
    }
  }

  Future<void> _loadRooms() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final response = await _repo.getRooms();
      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data is Map) {
          list = data['data'] ?? data['rooms'] ?? data['result'] ?? [];
        }

        // ✅ DEBUG: اطبع أول room عشان تشوف أسماء الـ fields (شيلها بعد التأكد)
        if (list.isNotEmpty) {
          debugPrint('🖼️ [ROOM JSON SAMPLE] ${list.first}');
        }

        // ✅ FIX: deduplication — لو في روومين بنفس الـ participant، ابقي الأحدث بس
        final allRooms = list
            .map((e) => ChatRoom.fromJson(e as Map<String, dynamic>, _myId))
            .toList();

        // رتب من الأحدث للأقدم
        allRooms.sort((a, b) {
          if (a.lastMessageTime.isEmpty && b.lastMessageTime.isEmpty) return 0;
          if (a.lastMessageTime.isEmpty) return 1;
          if (b.lastMessageTime.isEmpty) return -1;
          try {
            final aNorm = a.lastMessageTime.endsWith('Z')
                ? a.lastMessageTime
                : '${a.lastMessageTime}Z';
            final bNorm = b.lastMessageTime.endsWith('Z')
                ? b.lastMessageTime
                : '${b.lastMessageTime}Z';
            return DateTime.parse(bNorm).compareTo(DateTime.parse(aNorm));
          } catch (_) {
            return 0;
          }
        });

        // ابقي أول room لكل participant (الأحدث بسبب الترتيب فوق)
        final seen = <String>{};
        final uniqueRooms = allRooms.where((room) {
          final key = room.participantId.isNotEmpty
              ? room.participantId
              : room.participantName.toLowerCase().trim();
          if (key.isEmpty || seen.contains(key)) return false;
          seen.add(key);
          return true;
        }).toList();

        setState(() {
          _rooms = uniqueRooms;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load chats (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCandidates() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        'Candidates',
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
      debugPrint('📥 [CANDIDATES] Status: ${response.statusCode}');
      debugPrint('📥 [CANDIDATES] Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data is Map) {
          list = data['data'] ??
              data['candidates'] ??
              data['items'] ??
              data['result'] ??
              data['users'] ??
              [];
        }
        return list.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      debugPrint('❌ [CANDIDATES] $e');
    }
    return [];
  }

  Future<void> _createRoom(String participantId) async {
    if (participantId.trim().isEmpty) return;
    try {
      final response =
      await _repo.createRoom(participantId: participantId.trim());
      debugPrint('📥 [CREATE ROOM] ${response.statusCode} | ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _loadRooms();

        try {
          final roomData = response.data is Map
              ? response.data as Map<String, dynamic>
              : null;
          if (roomData != null && mounted) {
            final newRoom = ChatRoom.fromJson(roomData, _myId);

            final existingRoom = _rooms.firstWhere(
                  (r) => r.id == newRoom.id,
              orElse: () => newRoom,
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ChatMessagesScreen(room: existingRoom, myId: _myId),
              ),
            ).then((_) => _loadRooms());
          }
        } catch (_) {}
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed (${response.statusCode}): ${response.data}'),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _showCandidatesPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CandidatesPickerSheet(
        fetchCandidates: _fetchCandidates,
        onSelect: (id) {
          Navigator.pop(ctx);
          _createRoom(id);
        },
      ),
    );
  }

  // ✅ FIX: normalize timestamp عشان يتعامل صح مع UTC
  String _formatTime(String raw) {
    if (raw.isEmpty) return '';
    try {
      final normalized = raw.endsWith('Z') ? raw : '${raw}Z';
      final dt = DateTime.parse(normalized).toLocal();
      final now = DateTime.now();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');

      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'now';
      if (diff.inHours < 1) return '${diff.inMinutes}m';
      if (diff.inDays < 1) return '$h:$m';
      if (diff.inDays < 7) return '${dt.day}/${dt.month}';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: Column(children: [
        _buildHeader(),
        Expanded(child: _buildBody()),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCandidatesPicker,
        backgroundColor: const Color(0xff1676C4),
        shape: const CircleBorder(),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Row(children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 4),
            const Expanded(
              child: Text('Messages',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadRooms,
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xff1676C4)));
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(_error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadRooms,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1676C4)),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ]),
      );
    }

    if (_rooms.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No conversations yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500])),
          const SizedBox(height: 8),
          Text('Tap the button below to start a new chat',
              style: TextStyle(fontSize: 14, color: Colors.grey[400])),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCandidatesPicker,
            icon: const Icon(Icons.edit, color: Colors.white, size: 18),
            label: const Text('New Conversation',
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff1676C4),
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ]),
      );
    }

    return RefreshIndicator(
      color: const Color(0xff1676C4),
      onRefresh: _loadRooms,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: _rooms.length,
        separatorBuilder: (_, __) => const SizedBox(height: 0),
        itemBuilder: (_, i) => _buildRoomTile(_rooms[i]),
      ),
    );
  }

  Widget _buildRoomTile(ChatRoom room) {
    final hasUnread = room.unreadCount > 0;
    return InkWell(
      onTap: () async {
        _repo.markAsRead(room.id);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatMessagesScreen(room: room, myId: _myId),
          ),
        );
        _loadRooms();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
          border: hasUnread
              ? Border.all(color: const Color(0xff1676C4).withOpacity(0.3))
              : null,
        ),
        child: Row(children: [
          _buildAvatar(room),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(
                      room.participantName,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: hasUnread
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: Colors.grey[800]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatTime(room.lastMessageTime),
                    style: TextStyle(
                        fontSize: 12,
                        color: hasUnread
                            ? const Color(0xff1676C4)
                            : Colors.grey[400]),
                  ),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  Expanded(
                    child: Text(
                      room.lastMessage.isEmpty
                          ? 'No messages yet'
                          : room.lastMessage,
                      style: TextStyle(
                          fontSize: 13,
                          color: hasUnread
                              ? Colors.grey[700]
                              : Colors.grey[400],
                          fontWeight: hasUnread
                              ? FontWeight.w500
                              : FontWeight.normal),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasUnread)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xff1676C4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        room.unreadCount > 99 ? '99+' : '${room.unreadCount}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildAvatar(ChatRoom room) {
    const double size = 52;
    if (room.participantLogo.isNotEmpty) {
      final url = room.participantLogo.startsWith('http')
          ? room.participantLogo
          : 'http://smartcareerhub.runasp.net${room.participantLogo}';
      return ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _initialsAvatar(room.participantName, size),
        ),
      );
    }
    return _initialsAvatar(room.participantName, size);
  }

  Widget _initialsAvatar(String name, double size) {
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
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Candidates Picker Bottom Sheet
// ══════════════════════════════════════════════════════════════════════════════
class _CandidatesPickerSheet extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> Function() fetchCandidates;
  final void Function(String participantId) onSelect;

  const _CandidatesPickerSheet({
    required this.fetchCandidates,
    required this.onSelect,
  });

  @override
  State<_CandidatesPickerSheet> createState() => _CandidatesPickerSheetState();
}

class _CandidatesPickerSheetState extends State<_CandidatesPickerSheet> {
  List<Map<String, dynamic>> _all = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await widget.fetchCandidates();
    if (mounted) {
      final seen = <String>{};
      final unique = list.where((c) {
        final id = c['userId']?.toString() ?? c['id']?.toString() ?? '';
        if (id.isEmpty || seen.contains(id)) return false;
        seen.add(id);
        return true;
      }).toList();

      setState(() {
        _all = unique;
        _filtered = unique;
        _isLoading = false;
      });
    }
  }

  void _onSearch(String q) {
    setState(() {
      _search = q;
      _filtered = q.isEmpty
          ? _all
          : _all.where((c) {
        final name = _getName(c).toLowerCase();
        final email = (c['email']?.toString() ?? '').toLowerCase();
        return name.contains(q.toLowerCase()) ||
            email.contains(q.toLowerCase());
      }).toList();
    });
  }

  String _getName(Map<String, dynamic> c) {
    if (c['firstName'] != null || c['lastName'] != null) {
      return '${c['firstName'] ?? ''} ${c['lastName'] ?? ''}'.trim();
    }
    return c['fullName']?.toString() ??
        c['name']?.toString() ??
        c['userName']?.toString() ??
        c['email']?.toString() ??
        'Unknown';
  }

  String _getId(Map<String, dynamic> c) {
    return c['userId']?.toString() ??
        c['id']?.toString() ??
        c['studentId']?.toString() ??
        '';
  }

  String _getLogo(Map<String, dynamic> c) {
    return c['profileImage']?.toString() ??
        c['profilePicture']?.toString() ??
        c['logoUrl']?.toString() ??
        c['avatarUrl']?.toString() ??
        c['logo']?.toString() ??
        '';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Icon(Icons.people_outline, color: Color(0xff1676C4)),
              SizedBox(width: 8),
              Text('Start New Conversation',
                  style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xffF5F7FB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(
                child: CircularProgressIndicator(
                    color: Color(0xff1676C4)))
                : _filtered.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off_outlined,
                      size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    _search.isEmpty
                        ? 'No candidates found'
                        : 'No results for "$_search"',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            )
                : ListView.builder(
              controller: scrollCtrl,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final c = _filtered[i];
                final name = _getName(c);
                final id = _getId(c);
                final logo = _getLogo(c);
                final email = c['email']?.toString() ?? '';

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  leading: _buildAvatar(name, logo),
                  title: Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                  subtitle: email.isNotEmpty
                      ? Text(email,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500]))
                      : null,
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.grey),
                  onTap:
                  id.isEmpty ? null : () => widget.onSelect(id),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildAvatar(String name, String logo) {
    const double size = 44;
    if (logo.isNotEmpty) {
      final url = logo.startsWith('http')
          ? logo
          : 'http://smartcareerhub.runasp.net$logo';
      return ClipOval(
        child: Image.network(url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initials(name, size)),
      );
    }
    return _initials(name, size);
  }

  Widget _initials(String name, double size) {
    final i = name.trim().isEmpty
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
        child: Text(i,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}