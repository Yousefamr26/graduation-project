// ignore_for_file: avoid_print
// ═══════════════════════════════════════════════════════════════════════════════
// FILE: events_screen.dart
// ═══════════════════════════════════════════════════════════════════════════════
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../data/repositories/Eventuni repository.dart';
import '../../../../../widgets/common/CustomDropdown.dart';
import '../../../../../widgets/common/action_button.dart';
import 'CreateEditEventScreen.dart';



// ─────────────────────────────────────────────────────────────────────────────
// ✅ HELPER WIDGET: يعرض الصورة سواء URL أو Base64
// ─────────────────────────────────────────────────────────────────────────────
class EventBannerWidget extends StatelessWidget {
  final Map<String, dynamic> event;
  final double height;
  final bool isPublished;

  const EventBannerWidget({
    super.key,
    required this.event,
    required this.height,
    required this.isPublished,
  });

  @override
  Widget build(BuildContext context) {
    final bannerType  = event['bannerType']?.toString();
    final bannerValue = event['bannerValue']?.toString();

    if (bannerType == 'base64' && bannerValue != null && bannerValue.isNotEmpty) {
      try {
        final Uint8List bytes = base64Decode(bannerValue);
        return Image.memory(
          bytes, height: height, width: double.infinity, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        );
      } catch (e) {
        debugPrint("❌ [BASE64 DECODE ERROR]: $e");
        return _placeholder();
      }
    }

    if (bannerType == 'url' && bannerValue != null && bannerValue.isNotEmpty) {
      return Image.network(
        bannerValue, height: height, width: double.infinity, fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(height: height, color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator(color: Color(0xff1676C4))));
        },
        errorBuilder: (_, error, __) {
          debugPrint("❌ [URL IMAGE ERROR]: $error | url: $bannerValue");
          return _placeholder();
        },
      );
    }

    return _placeholder();
  }

  Widget _placeholder() => Container(
    height: height, width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: isPublished
            ? [const Color(0xff1676C4), const Color(0xff42a5f5)]
            : [Colors.orange.shade400, Colors.orange.shade200],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
    ),
    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.event, color: Colors.white, size: 36),
      const SizedBox(height: 4),
      Text(event['eventType'] ?? event['type'] ?? '',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
    ])),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ✅ THUMBNAIL for History Screen
// ─────────────────────────────────────────────────────────────────────────────
class EventThumbnailWidget extends StatelessWidget {
  final Map<String, dynamic> event;
  final double size;

  const EventThumbnailWidget({super.key, required this.event, this.size = 70});

  @override
  Widget build(BuildContext context) {
    final bannerType  = event['bannerType']?.toString();
    final bannerValue = event['bannerValue']?.toString();

    Widget imageWidget;

    if (bannerType == 'base64' && bannerValue != null && bannerValue.isNotEmpty) {
      try {
        final bytes = base64Decode(bannerValue);
        imageWidget = Image.memory(bytes, width: size, height: size, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallback());
      } catch (_) {
        imageWidget = _fallback();
      }
    } else if (bannerType == 'url' && bannerValue != null && bannerValue.isNotEmpty) {
      imageWidget = Image.network(bannerValue, width: size, height: size, fit: BoxFit.cover,
          loadingBuilder: (_, child, p) => p == null ? child :
          SizedBox(width: size, height: size, child: const Center(child: SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xff1676C4))))),
          errorBuilder: (_, __, ___) => _fallback());
    } else {
      imageWidget = _fallback();
    }

    return ClipRRect(borderRadius: BorderRadius.circular(8), child: imageWidget);
  }

  Widget _fallback() => Container(
    width: size, height: size,
    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
    child: Icon(Icons.event, color: Colors.grey[400], size: size * 0.5),
  );
}


// ═══════════════════════════════════════════════════════════════════════════════
// EVENTS SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class EventsUniScreen extends StatefulWidget {
  const EventsUniScreen({super.key});

  @override
  State<EventsUniScreen> createState() => _EventsUniScreenState();
}

class _EventsUniScreenState extends State<EventsUniScreen> {
  final eventRepo = EventUniRepository();

  final List<Map<String, dynamic>> events       = [];
  final List<Map<String, dynamic>> eventHistory = [];

  static const String _historyKey  = 'event_history_ids';
  static const int    _itemsPerPage = 4;

  String searchText     = "";
  String selectedFilter = "All";
  List<Map<String, dynamic>> filteredEvents = [];
  bool isLoading    = true;
  int  _currentPage = 1;

  int get _totalPages =>
      (filteredEvents.length / _itemsPerPage).ceil().clamp(1, 999);

  List<Map<String, dynamic>> get _currentPageItems {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end   = (start + _itemsPerPage).clamp(0, filteredEvents.length);
    return filteredEvents.sublist(start, end);
  }

  @override
  void initState() {
    super.initState();
    _loadHistoryFromStorage();
  }

  Future<void> _loadHistoryFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json  = prefs.getString(_historyKey);
      if (json != null && json.isNotEmpty) {
        final decoded = jsonDecode(json) as List<dynamic>;
        setState(() {
          eventHistory.clear();
          eventHistory.addAll(decoded.map((e) => Map<String, dynamic>.from(e)));
        });
      }
    } catch (e) { debugPrint("Error loading history: $e"); }
    await _fetchEvents();
  }

  Future<void> _saveHistoryToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_historyKey, jsonEncode(eventHistory));
    } catch (e) { debugPrint("Error saving history: $e"); }
  }

  Future<void> _fetchEvents() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final fetched = await eventRepo.getAllEvents();
      if (!mounted) return;
      final historyIds = eventHistory
          .map((e) => e['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
      setState(() {
        events.clear();
        for (var item in fetched) {
          if (!historyIds.contains(item['id']?.toString() ?? '')) events.add(item);
        }
        applyFilters();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load events: $e'), backgroundColor: Colors.red));
    }
  }

  void applyFilters() {
    if (!mounted) return;
    setState(() {
      filteredEvents = events.where((e) {
        if (selectedFilter != "All") {
          final status = e['status']?.toString() ??
              (e['isPublished'] == true ? 'Published' : 'Draft');
          if (status != selectedFilter) return false;
        }
        if (searchText.isEmpty) return true;
        final s = searchText.toLowerCase();
        return _sc(e['title'], s) || _sc(e['description'], s) ||
            _sc(e['eventType'], s) || _sc(e['mode'], s) || _sc(e['location'], s);
      }).toList();
      _currentPage = 1;
    });
  }

  bool _sc(dynamic v, String s) =>
      v != null && v.toString().toLowerCase().contains(s);

  String _formatDate(String? d) {
    if (d == null || d.isEmpty) return 'N/A';
    try { return DateFormat('dd/MM/yyyy').format(DateTime.parse(d)); }
    catch (_) { return d; }
  }

  Future<void> _moveToHistory(int gi) async {
    final target = filteredEvents[gi];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: _dialogHeader('Move to History?', Icons.archive_outlined, const Color(0xff1676C4)),
        content: Text('${target['title']} will be moved to History.',
            style: TextStyle(fontSize: 15, color: Colors.grey[700])),
        actionsPadding: EdgeInsets.zero,
        actions: [Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xff1676C4),
                  side: const BorderSide(color: Color(0xff1676C4), width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold)),
            )),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1676C4), foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("Move", style: TextStyle(fontWeight: FontWeight.bold)),
            )),
          ]),
        )],
      ),
    );

    if (confirm == true) {
      setState(() {
        target['deletedAt'] = DateTime.now().toIso8601String();
        eventHistory.add(target);
        events.removeWhere((e) => e['id'] == target['id']);
        applyFilters();
      });
      await _saveHistoryToStorage();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${target['title']} moved to History'),
        backgroundColor: const Color(0xff1676C4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  void _handleHistoryResult(Map<String, dynamic> result) async {
    if (result['action'] == 'restore') {
      final r = result['event'];
      setState(() { events.add(r); eventHistory.remove(r); applyFilters(); });
      await _saveHistoryToStorage();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${r['title']} restored!'), backgroundColor: Colors.green));
    } else if (result['action'] == 'deleted') {
      setState(() => eventHistory.remove(result['event']));
      await _saveHistoryToStorage();
    }
  }

  Widget _dialogHeader(String title, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 28)),
      const SizedBox(width: 12),
      Expanded(child: Text(title,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: kBottomNavigationBarHeight + MediaQuery.of(context).viewPadding.bottom + 16,
        ),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CreateEditEventUniScreen(eventData: null)));
            if (result == true && mounted) await _fetchEvents();
          },
          backgroundColor: const Color(0xff1676C4),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: Column(children: [_buildAppBar(), _buildSearchAndFilter(), _buildList()]),
    );
  }

  Widget _buildAppBar() => Container(
    width: double.infinity,
    decoration: const BoxDecoration(
        color: Color(0xff1676C4),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
    child: SafeArea(bottom: false,
      child: Padding(padding: const EdgeInsets.only(bottom: 16),
        child: AppBar(
          backgroundColor: Colors.transparent, elevation: 0, toolbarHeight: 130,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context)),
          title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("My Events",
                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500)),
            SizedBox(height: 4),
            Text("Manage your created events",
                style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w300)),
          ]),
          actions: [
            IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _fetchEvents),
            IconButton(
              icon: Stack(clipBehavior: Clip.none, children: [
                const Icon(Icons.history, color: Colors.white),
                if (eventHistory.isNotEmpty)
                  Positioned(right: -2, top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Center(child: Text(
                          '${eventHistory.length > 99 ? '99+' : eventHistory.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        )),
                      )),
              ]),
              onPressed: () async {
                final result = await Navigator.push<Map<String, dynamic>?>(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EventHistoryScreen(eventHistory: eventHistory)));
                if (result != null && mounted) _handleHistoryResult(result);
              },
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildSearchAndFilter() => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(children: [
      Expanded(child: TextField(
        decoration: InputDecoration(
            hintText: "Search ",
            prefixIcon: const Icon(Icons.search, color: Color(0xff1676C4)),
            filled: true, fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xff1676C4), width: 2))),
        onChanged: (v) => setState(() { searchText = v; applyFilters(); }),
      )),
      const SizedBox(width: 10),
      SizedBox(width: 160, child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: CustomDropdown(
            items: const ["All", "Draft", "Published"],
            value: selectedFilter,
            onChanged: (v) => setState(() { selectedFilter = v!; applyFilters(); })),
      )),
    ]),
  );

  Widget _buildList() => Expanded(
    child: isLoading
        ? const Center(child: CircularProgressIndicator())
        : filteredEvents.isEmpty
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.event_outlined, size: 80, color: Colors.grey[400]),
      const SizedBox(height: 16),
      Text(searchText.isEmpty ? "No events yet" : "No events found",
          style: TextStyle(fontSize: 18, color: Colors.grey[600])),
      const SizedBox(height: 8),
      Text(searchText.isEmpty ? "Create your first event!" : "Try a different search",
          style: TextStyle(fontSize: 14, color: Colors.grey[500])),
    ]))
        : Column(children: [
      Expanded(child: RefreshIndicator(
        onRefresh: _fetchEvents,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          itemCount: _currentPageItems.length,
          itemBuilder: (_, i) {
            final gi = (_currentPage - 1) * _itemsPerPage + i;
            return _buildCard(gi);
          },
        ),
      )),
      _buildPagination(),
    ]),
  );

  Widget _buildPagination() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2))],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _pageBtn('«', false, _currentPage > 1, () => setState(() => _currentPage--)),
        const SizedBox(width: 6),
        for (int i = 1; i <= _totalPages; i++) ...[
          _pageBtn('$i', i == _currentPage, true, () => setState(() => _currentPage = i)),
          if (i != _totalPages) const SizedBox(width: 6),
        ],
        const SizedBox(width: 6),
        _pageBtn('»', false, _currentPage < _totalPages, () => setState(() => _currentPage++)),
      ]),
    );
  }

  Widget _pageBtn(String label, bool isActive, bool enabled, VoidCallback onTap) =>
      GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 38, height: 38,
          decoration: BoxDecoration(
              color: isActive ? const Color(0xff1676C4) : enabled ? Colors.white : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: isActive ? const Color(0xff1676C4) : Colors.grey[300]!,
                  width: isActive ? 2 : 1)),
          child: Center(child: Text(label,
              style: TextStyle(
                  color: isActive ? Colors.white : enabled ? Colors.grey[700] : Colors.grey[400],
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  fontSize: 15))),
        ),
      );

  Widget _buildCard(int gi) {
    final e           = filteredEvents[gi];
    final status      = e['status']?.toString() ?? (e['isPublished'] == true ? 'Published' : 'Draft');
    final isPublished = status == 'Published';

    return Card(
      elevation: 3, margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: EventBannerWidget(event: e, height: 150, isPublished: isPublished),
        ),

        Padding(padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e['title'] ?? 'Untitled',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(e['description'] ?? '',
                style: TextStyle(color: Colors.grey[700]),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: [
              if (e['eventType'] != null || e['type'] != null)
                _chip(Icons.category, e['eventType'] ?? e['type'], Colors.indigo),
              if (e['mode'] != null)
                _chip(
                    e['mode'] == 'Online' ? Icons.computer
                        : e['mode'] == 'Onsite' ? Icons.location_on : Icons.hub,
                    e['mode'], Colors.purple),
              if (e['startDate'] != null)
                _chip(Icons.calendar_today, _formatDate(e['startDate']), Colors.blue),
              if (e['maxCapacity'] != null)
                _chip(Icons.people, "${e['maxCapacity']} seats", Colors.teal),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: isPublished
                        ? Colors.green.withOpacity(0.15)
                        : Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(status,
                    style: TextStyle(
                        color: isPublished ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const Spacer(),
              if (e['minPoints'] != null && (e['minPoints'] as num) > 0) ...[
                const Icon(Icons.stars, size: 18, color: Colors.amber),
                const SizedBox(width: 4),
                Text("${e['minimumRequiredPoints'] ?? e['minPoints']} pts",
                    style: TextStyle(fontSize: 13, color: Colors.grey[700])),
              ],
            ]),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              ActionButton(
                icon: Icons.edit, text: "Edit", color: const Color(0xff1676C4),
                onTap: () async {
                  final result = await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => CreateEditEventUniScreen(eventData: e)));
                  if (result == true && mounted) {
                    await _fetchEvents();
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Event updated!'), backgroundColor: Colors.green));
                  }
                },
              ),
              ActionButton(
                  icon: Icons.delete, text: "Delete",
                  color: Colors.red, onTap: () => _moveToHistory(gi)),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _chip(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: color), const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
    ]),
  );
}


// ═══════════════════════════════════════════════════════════════════════════════
// EVENT HISTORY SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class EventHistoryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> eventHistory;
  const EventHistoryScreen({Key? key, required this.eventHistory}) : super(key: key);

  @override
  State<EventHistoryScreen> createState() => _EventHistoryScreenState();
}

class _EventHistoryScreenState extends State<EventHistoryScreen> {
  final EventUniRepository eventRepo = EventUniRepository();
  String _searchQuery = '';
  String _sortBy      = 'date';
  bool   _isDeleting  = false;

  List<Map<String, dynamic>> get _filtered {
    var list = widget.eventHistory.where((e) {
      final q = _searchQuery.toLowerCase();
      return (e['title'] ?? '').toString().toLowerCase().contains(q) ||
          (e['description'] ?? '').toString().toLowerCase().contains(q) ||
          (e['eventType'] ?? e['type'] ?? '').toString().toLowerCase().contains(q);
    }).toList();
    list.sort((a, b) {
      if (_sortBy == 'title')
        return (a['title'] ?? '').toString().compareTo((b['title'] ?? '').toString());
      if (_sortBy == 'type')
        return (a['eventType'] ?? '').toString().compareTo((b['eventType'] ?? '').toString());
      return (b['deletedAt'] ?? '').compareTo(a['deletedAt'] ?? '');
    });
    return list;
  }

  String _ago(String? d) {
    if (d == null) return 'Unknown';
    try {
      final diff = DateTime.now().difference(DateTime.parse(d));
      if (diff.inDays == 0) return diff.inHours == 0
          ? '${diff.inMinutes} min ago' : '${diff.inHours} hrs ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7)  return '${diff.inDays} days ago';
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(d));
    } catch (_) { return d; }
  }

  void _restore(Map<String, dynamic> e) {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: _header('Restore Event', Icons.restore_rounded, Colors.green),
      content: Text('Restore "${e['title']}"?',
          style: TextStyle(fontSize: 15, color: Colors.grey[700])),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [Row(children: [
        Expanded(child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey[400]!),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold)))),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            e.remove('deletedAt');
            Navigator.pop(context, {'action': 'restore', 'event': e});
          },
          icon: const Icon(Icons.restore_rounded, size: 20),
          label: const Text("Restore", style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        )),
      ])],
    ));
  }

  void _deleteDialog(Map<String, dynamic> e) {
    showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: _header('Delete Permanently', Icons.delete_forever_rounded, Colors.red),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.red[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red[200]!, width: 2)),
          child: Row(children: [
            Icon(Icons.warning_rounded, color: Colors.red[700], size: 24),
            const SizedBox(width: 10),
            Expanded(child: Text('⚠️ This action CANNOT be undone!',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[700], fontSize: 14))),
          ]),
        ),
        const SizedBox(height: 12),
        Text('Event: ${e['title']}', style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [Row(children: [
        Expanded(child: OutlinedButton(
            onPressed: _isDeleting ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey[400]!),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold)))),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton.icon(
          onPressed: _isDeleting ? null : () { Navigator.pop(context); _deletePermanently(e); },
          icon: const Icon(Icons.delete_forever_rounded, size: 20),
          label: const Text("Delete Forever", style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        )),
      ])],
    ));
  }

  Future<void> _deletePermanently(Map<String, dynamic> e) async {
    final id = e['id']?.toString();
    if (id == null || id.isEmpty) return;
    setState(() => _isDeleting = true);
    try {
      final response = await eventRepo.deleteEvent(id);
      if (!mounted) { setState(() => _isDeleting = false); return; }
      if (response != null && [200, 204, 404].contains(response.statusCode)) {
        setState(() {
          widget.eventHistory.removeWhere((x) => x['id'] == e['id']);
          _isDeleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Event deleted permanently'), backgroundColor: Colors.red));
        Navigator.pop(context, {'action': 'deleted', 'event': e});
      } else {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Delete failed: ${response?.statusCode}'), backgroundColor: Colors.red));
      }
    } on DioException catch (err) {
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Network error: ${err.message}'), backgroundColor: Colors.red));
    } catch (err) {
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $err'), backgroundColor: Colors.red));
    }
  }

  Widget _header(String title, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 28)),
      const SizedBox(width: 12),
      Expanded(child: Text(title,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Deleted Events",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
          Text("${list.length} ${list.length == 1 ? 'item' : 'items'}",
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
        ]),
        backgroundColor: const Color(0xff1676C4),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        actions: [PopupMenuButton<String>(
          icon: const Icon(Icons.sort, color: Colors.white), color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (v) => setState(() => _sortBy = v),
          itemBuilder: (_) => [
            _sortItem('date', Icons.access_time, 'Sort by Date'),
            _sortItem('title', Icons.title, 'Sort by Title'),
            _sortItem('type', Icons.category, 'Sort by Type'),
          ],
        )],
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: Stack(children: [
        Column(children: [
          Container(
            color: const Color(0xff1676C4),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _searchQuery = ''))
                    : null,
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(_searchQuery.isEmpty ? Icons.delete_outline : Icons.search_off,
                  size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(_searchQuery.isEmpty ? "No deleted events yet." : "No results found",
                  style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500)),
            ]))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final e = list[i];
                return Dismissible(
                  key: Key('${e['id']}_${DateTime.now().millisecondsSinceEpoch}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.delete_forever, color: Colors.white, size: 32),
                      Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                  confirmDismiss: (_) async { _deleteDialog(e); return false; },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _restore(e),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            EventThumbnailWidget(event: e, size: 70),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(e['title'] ?? 'No Title',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                              if (e['description'] != null) ...[
                                const SizedBox(height: 4),
                                Text(e['description'], maxLines: 2, overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                              ],
                              const SizedBox(height: 8),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(children: [
                                  if (e['eventType'] != null || e['type'] != null)
                                    _historyChip(Icons.category, e['eventType'] ?? e['type'] ?? '', Colors.blue),
                                  if (e['mode'] != null) ...[
                                    const SizedBox(width: 8),
                                    _historyChip(Icons.computer, e['mode'], Colors.purple),
                                  ],
                                ]),
                              ),
                              const SizedBox(height: 6),
                              Row(children: [
                                Icon(Icons.access_time, size: 14, color: Colors.red[400]),
                                const SizedBox(width: 4),
                                Text(_ago(e['deletedAt']),
                                    style: TextStyle(fontSize: 12, color: Colors.red[600], fontWeight: FontWeight.w500)),
                              ]),
                            ])),
                          ]),
                          Padding(padding: const EdgeInsets.only(top: 12),
                              child: Divider(height: 1, thickness: 1)),
                          Row(children: [
                            Expanded(child: TextButton.icon(
                              onPressed: _isDeleting ? null : () => _restore(e),
                              icon: Icon(Icons.restore, color: _isDeleting ? Colors.grey : Colors.green, size: 20),
                              label: Text('Restore', style: TextStyle(color: _isDeleting ? Colors.grey : Colors.green)),
                              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                            )),
                            Container(width: 1, height: 30, color: Colors.grey[300]),
                            Expanded(child: TextButton.icon(
                              onPressed: _isDeleting ? null : () => _deleteDialog(e),
                              icon: Icon(Icons.delete_forever, color: _isDeleting ? Colors.grey : Colors.red, size: 20),
                              label: Text('Delete', style: TextStyle(color: _isDeleting ? Colors.grey : Colors.red)),
                              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                            )),
                          ]),
                        ]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
        if (_isDeleting) Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Padding(padding: EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xff1676C4)), strokeWidth: 3),
                SizedBox(height: 20),
                Text('Deleting permanently...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1676C4))),
              ]),
            ),
          )),
        ),
      ]),
    );
  }

  Widget _historyChip(IconData icon, String label, MaterialColor color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: color[50], borderRadius: BorderRadius.circular(6)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: color[700]),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 12, color: color[700], fontWeight: FontWeight.w500)),
    ]),
  );

  PopupMenuItem<String> _sortItem(String v, IconData icon, String label) =>
      PopupMenuItem(value: v,
        child: Container(
          decoration: _sortBy == v
              ? BoxDecoration(color: const Color(0xff1676C4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8)) : null,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(children: [
            Icon(icon, size: 20, color: _sortBy == v ? const Color(0xff1676C4) : Colors.grey[700]),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(
                color: _sortBy == v ? const Color(0xff1676C4) : Colors.grey[800],
                fontWeight: _sortBy == v ? FontWeight.bold : FontWeight.normal)),
          ]),
        ),
      );
}