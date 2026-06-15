// ignore_for_file: avoid_print
// ═══════════════════════════════════════════════════════════════════════════════
// FILE 1: workshops_screen.dart
// ═══════════════════════════════════════════════════════════════════════════════
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../data/repositories/Workshopuni repository.dart';
import '../../../../../widgets/common/CustomDropdown.dart';
import '../../../../../widgets/common/NetworkImageWidget.dart';
import '../../../../../widgets/common/action_button.dart';
import 'crate_editWorkshopUni.dart';


class WorkshopsUniScreen extends StatefulWidget {
  const WorkshopsUniScreen({super.key});

  @override
  State<WorkshopsUniScreen> createState() => _WorkshopsUniScreenState();
}

class _WorkshopsUniScreenState extends State<WorkshopsUniScreen> {
  final workshopRepo = WorkshopUniRepository();

  final List<Map<String, dynamic>> workshops       = [];
  final List<Map<String, dynamic>> workshopHistory = [];

  static const String _historyKey  = 'workshop_history_ids';
  static const int    _itemsPerPage = 4;

  String searchText     = "";
  String selectedFilter = "All";
  List<Map<String, dynamic>> filteredWorkshops = [];
  bool isLoading  = true;
  int  _currentPage = 1;

  int get _totalPages =>
      (filteredWorkshops.length / _itemsPerPage).ceil().clamp(1, 999);

  List<Map<String, dynamic>> get _currentPageItems {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end   = (start + _itemsPerPage).clamp(0, filteredWorkshops.length);
    return filteredWorkshops.sublist(start, end);
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
          workshopHistory.clear();
          workshopHistory.addAll(decoded.map((e) => Map<String, dynamic>.from(e)));
        });
      }
    } catch (e) { debugPrint("Error loading workshop history: $e"); }
    await _fetchWorkshops();
  }

  Future<void> _saveHistoryToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_historyKey, jsonEncode(workshopHistory));
    } catch (e) { debugPrint("Error saving workshop history: $e"); }
  }

  Future<void> _fetchWorkshops() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final fetched = await workshopRepo.getAllWorkshops();
      if (!mounted) return;
      final historyIds = workshopHistory.map((w) => w['id']?.toString() ?? '').where((id) => id.isNotEmpty).toSet();
      setState(() {
        workshops.clear();
        for (var item in fetched) {
          if (!historyIds.contains(item['id']?.toString() ?? '')) workshops.add(item);
        }
        applyFilters();
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching workshops: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load workshops: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void applyFilters() {
    if (!mounted) return;
    setState(() {
      filteredWorkshops = workshops.where((w) {
        if (selectedFilter != "All") {
          final status = w['status']?.toString() ?? (w['isPublished'] == true ? 'Published' : 'Draft');
          if (status != selectedFilter) return false;
        }
        if (searchText.isEmpty) return true;
        final s = searchText.toLowerCase();
        return _sc(w['title'], s) || _sc(w['description'], s) || _sc(w['location'], s);
      }).toList();
      _currentPage = 1;
    });
  }

  bool _sc(dynamic v, String s) => v != null && v.toString().toLowerCase().contains(s);

  Future<void> _moveToHistory(int globalIndex) async {
    final target = filteredWorkshops[globalIndex];
    final confirm = await _showConfirmDialog(
      title: 'Move to History?',
      content: '${target['title']} will be moved to History.',
      icon: Icons.archive_outlined,
    );
    if (confirm == true) {
      setState(() {
        target['deletedAt'] = DateTime.now().toIso8601String();
        workshopHistory.add(target);
        workshops.removeWhere((w) => w['id'] == target['id']);
        applyFilters();
      });
      await _saveHistoryToStorage();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${target['title']} moved to History'),
            backgroundColor: const Color(0xff1676C4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _handleHistoryResult(Map<String, dynamic> result) async {
    if (result['action'] == 'restore') {
      final r = result['workshop'];
      setState(() { workshops.add(r); workshopHistory.remove(r); applyFilters(); });
      await _saveHistoryToStorage();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${r['title']} restored!'), backgroundColor: Colors.green),
      );
    } else if (result['action'] == 'deleted') {
      final d = result['workshop'];
      setState(() => workshopHistory.remove(d));
      await _saveHistoryToStorage();
    }
  }

  Future<bool?> _showConfirmDialog({required String title, required String content, required IconData icon}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xff1676C4), Color(0xff0d7de8)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 28)),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
          ]),
        ),
        content: Text(content, style: TextStyle(fontSize: 15, color: Colors.grey[700])),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xff1676C4),
                      side: const BorderSide(color: Color(0xff1676C4), width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text("Cancel", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff1676C4), foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text("Move", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)))),
            ]),
          ),
        ],
        actionsPadding: EdgeInsets.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CreateEditWorkshopUniScreen(workshopData: null)));
            if (result == true && mounted) await _fetchWorkshops();
          },
          backgroundColor: const Color(0xff1676C4),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: Column(children: [_buildAppBar(), _buildSearchAndFilter(), _buildList()]),
    );
  }

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: Color(0xff1676C4),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AppBar(
            backgroundColor: Colors.transparent, elevation: 0, toolbarHeight: 130,
            leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
            title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("My Workshops", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500)),
              SizedBox(height: 4),
              Text("Manage your workshop events", style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w300)),
            ]),
            actions: [
              IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _fetchWorkshops, tooltip: 'Refresh'),
              IconButton(
                icon: Stack(clipBehavior: Clip.none, children: [
                  const Icon(Icons.history, color: Colors.white),
                  if (workshopHistory.isNotEmpty)
                    Positioned(right: -2, top: -2, child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Center(child: Text('${workshopHistory.length > 99 ? '99+' : workshopHistory.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
                    )),
                ]),
                onPressed: () async {
                  final result = await Navigator.push<Map<String, dynamic>?>(context,
                      MaterialPageRoute(builder: (_) => WorkshopHistoryScreen(workshopHistory: workshopHistory)));
                  if (result != null && mounted) _handleHistoryResult(result);
                },
                tooltip: 'History',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Expanded(child: TextField(
          decoration: InputDecoration(
            hintText: "Search ",
            prefixIcon: const Icon(Icons.search, color: Color(0xff1676C4)),
            filled: true, fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff1676C4), width: 2)),
          ),
          onChanged: (v) { setState(() { searchText = v; applyFilters(); }); },
        )),
        const SizedBox(width: 10),
        SizedBox(width: 160, child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: CustomDropdown(items: const ["All", "Draft", "Published"], value: selectedFilter,
              onChanged: (v) { setState(() { selectedFilter = v!; applyFilters(); }); }),
        )),
      ]),
    );
  }

  Widget _buildList() {
    return Expanded(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredWorkshops.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.event_outlined, size: 80, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(searchText.isEmpty ? "No workshops yet" : "No workshops found",
            style: TextStyle(fontSize: 18, color: Colors.grey[600])),
        const SizedBox(height: 8),
        Text(searchText.isEmpty ? "Tap + to create your first workshop" : "Try a different search",
            style: TextStyle(fontSize: 14, color: Colors.grey[500])),
      ]))
          : Column(children: [
        Expanded(child: RefreshIndicator(
          onRefresh: _fetchWorkshops,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            itemCount: _currentPageItems.length,
            itemBuilder: (_, i) {
              final globalIndex = (_currentPage - 1) * _itemsPerPage + i;
              return _buildCard(globalIndex);
            },
          ),
        )),
        _buildPaginationBar(),
      ]),
    );
  }

  // ✅ FIX: pagination bar مش بتتغطى بأزرار الموبايل
  Widget _buildPaginationBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
      decoration: BoxDecoration(color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))]),
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

  Widget _pageBtn(String label, bool isActive, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180), width: 38, height: 38,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xff1676C4) : enabled ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? const Color(0xff1676C4) : Colors.grey[300]!, width: isActive ? 2 : 1),
          boxShadow: isActive ? [BoxShadow(color: const Color(0xff1676C4).withOpacity(0.35), blurRadius: 6, offset: const Offset(0, 2))] : [],
        ),
        child: Center(child: Text(label, style: TextStyle(
            color: isActive ? Colors.white : enabled ? Colors.grey[700] : Colors.grey[400],
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500, fontSize: 15))),
      ),
    );
  }

  Widget _buildCard(int globalIndex) {
    final w = filteredWorkshops[globalIndex];
    final status = w['status']?.toString() ?? (w['isPublished'] == true ? 'Published' : 'Draft');
    final isPublished = status == 'Published';

    return Card(
      elevation: 3, margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: w['banner'] != null && w['banner'].toString().isNotEmpty
              ? NetworkImageWidget(imageUrl: w['banner'], height: 150, width: double.infinity,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)))
              : Container(height: 110, width: double.infinity,
              decoration: BoxDecoration(gradient: LinearGradient(
                  colors: isPublished
                      ? [const Color(0xff1676C4), const Color(0xff42a5f5)]
                      : [Colors.orange.shade400, Colors.orange.shade200],
                  begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.event, color: Colors.white, size: 36),
                const SizedBox(height: 4),
                Text(w['workshopType'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ]))),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(w['title'] ?? 'Untitled', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: isPublished ? Colors.green.withOpacity(0.15) : Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(status, style: TextStyle(color: isPublished ? Colors.green : Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ]),
            const SizedBox(height: 6),
            Text(w['description'] ?? '', style: TextStyle(color: Colors.grey[700], fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: [
              if (w['location'] != null) _chip(Icons.location_on, w['location'], Colors.blue),
              if (w['workshopType'] != null) _chip(Icons.category, w['workshopType'], Colors.purple),
              if (w['maxCapacity'] != null) _chip(Icons.people, "${w['maxCapacity']} seats", Colors.teal),
              if (w['requireCV'] == true) _chip(Icons.description, "CV Required", Colors.orange),
            ]),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              ActionButton(icon: Icons.edit, text: "Edit", color: const Color(0xff1676C4),
                  onTap: () async {
                    final result = await Navigator.push(context,
                        MaterialPageRoute(builder: (_) => CreateEditWorkshopUniScreen(workshopData: w)));
                    if (result == true && mounted) { await _fetchWorkshops();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Workshop updated successfully!'), backgroundColor: Colors.green));
                    }
                  }),
              ActionButton(icon: Icons.delete, text: "Delete", color: Colors.red, onTap: () => _moveToHistory(globalIndex)),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _chip(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: color), const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// FILE 2: workshop_history.dart
// ═══════════════════════════════════════════════════════════════════════════════

class WorkshopHistoryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> workshopHistory;
  const WorkshopHistoryScreen({Key? key, required this.workshopHistory}) : super(key: key);

  @override
  State<WorkshopHistoryScreen> createState() => _WorkshopHistoryScreenState();
}

class _WorkshopHistoryScreenState extends State<WorkshopHistoryScreen> {
  final WorkshopUniRepository workshopRepo = WorkshopUniRepository();

  String _searchQuery = '';
  String _sortBy      = 'date';
  bool   _isDeleting  = false;

  List<Map<String, dynamic>> get _filtered {
    var list = widget.workshopHistory.where((w) {
      final q = _searchQuery.toLowerCase();
      return (w['title'] ?? '').toString().toLowerCase().contains(q) ||
          (w['description'] ?? '').toString().toLowerCase().contains(q) ||
          (w['location'] ?? '').toString().toLowerCase().contains(q);
    }).toList();
    list.sort((a, b) {
      if (_sortBy == 'title') return (a['title'] ?? '').toString().compareTo((b['title'] ?? '').toString());
      final da = a['deletedAt'] ?? ''; final db = b['deletedAt'] ?? '';
      return db.compareTo(da);
    });
    return list;
  }

  String _ago(String? d) {
    if (d == null) return 'Unknown';
    try {
      final diff = DateTime.now().difference(DateTime.parse(d));
      if (diff.inDays == 0) return diff.inHours == 0 ? '${diff.inMinutes} min ago' : '${diff.inHours} hrs ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7)  return '${diff.inDays} days ago';
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(d));
    } catch (_) { return d; }
  }

  void _restore(Map<String, dynamic> w) {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: _dialogHeader('Restore Workshop', Icons.restore_rounded, Colors.green),
      content: Text('Restore "${w['title']}"?', style: TextStyle(fontSize: 15, color: Colors.grey[700])),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.grey[600],
                  side: BorderSide(color: Colors.grey[400]!), padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold)))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton.icon(
            onPressed: () { Navigator.pop(context); w.remove('deletedAt');
            Navigator.pop(context, {'action': 'restore', 'workshop': w}); },
            icon: const Icon(Icons.restore_rounded, size: 20), label: const Text("Restore", style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          )),
        ]),
      ],
    ));
  }

  void _deletePermanentlyDialog(Map<String, dynamic> w) {
    showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: _dialogHeader('Delete Permanently', Icons.delete_forever_rounded, Colors.red),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red[200]!, width: 2)),
            child: Row(children: [Icon(Icons.warning_rounded, color: Colors.red[700], size: 24), const SizedBox(width: 10),
              Expanded(child: Text('⚠️ This action CANNOT be undone!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[700], fontSize: 14)))])),
        const SizedBox(height: 12),
        Text('Workshop: ${w['title']}', style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: _isDeleting ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey[400]!), padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold)))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton.icon(
            onPressed: _isDeleting ? null : () { Navigator.pop(context); _deletePermanently(w); },
            icon: const Icon(Icons.delete_forever_rounded, size: 20), label: const Text("Delete Forever", style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          )),
        ]),
      ],
    ));
  }

  Future<void> _deletePermanently(Map<String, dynamic> w) async {
    final id = w['id']?.toString();
    if (id == null || id.isEmpty) return;
    setState(() => _isDeleting = true);
    try {
      final response = await workshopRepo.deleteWorkshop(id);
      if (!mounted) { setState(() => _isDeleting = false); return; }
      if (response != null && (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 404)) {
        setState(() { widget.workshopHistory.removeWhere((x) => x['id'] == w['id']); _isDeleting = false; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Workshop deleted permanently'), backgroundColor: Colors.red));
        Navigator.pop(context, {'action': 'deleted', 'workshop': w});
      } else {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: ${response?.statusCode}'), backgroundColor: Colors.red));
      }
    } on DioException catch (e) {
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Network error: ${e.message}'), backgroundColor: Colors.red));
    } catch (e) {
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Widget _dialogHeader(String title, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.8), color], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 28)),
      const SizedBox(width: 12),
      Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Deleted Workshops", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
          Text("${list.length} ${list.length == 1 ? 'item' : 'items'}", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
        ]),
        backgroundColor: const Color(0xff1676C4),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [PopupMenuButton<String>(icon: const Icon(Icons.sort, color: Colors.white), color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (v) => setState(() => _sortBy = v),
            itemBuilder: (_) => [
              _sortItem('date', Icons.access_time, 'Sort by Date'),
              _sortItem('title', Icons.title, 'Sort by Title'),
            ])],
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: Stack(children: [
        Column(children: [
          Container(color: const Color(0xff1676C4), padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextField(onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(hintText: 'Search workshops...', prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchQuery = '')) : null,
                    filled: true, fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
              )),
          Expanded(child: list.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(_searchQuery.isEmpty ? Icons.delete_outline : Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(_searchQuery.isEmpty ? "No deleted workshops yet." : "No results found",
                style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          ]))
              : ListView.builder(padding: const EdgeInsets.all(16), itemCount: list.length,
              itemBuilder: (_, i) {
                final w = list[i];
                return Dismissible(
                  key: Key('${w['id']}_${DateTime.now().millisecondsSinceEpoch}'),
                  direction: DismissDirection.endToStart,
                  background: Container(margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
                      child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.delete_forever, color: Colors.white, size: 32),
                        Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ])),
                  confirmDismiss: (_) async { _deletePermanentlyDialog(w); return false; },
                  child: Card(margin: const EdgeInsets.only(bottom: 12), elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => _restore(w),
                        child: Padding(padding: const EdgeInsets.all(12),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              NetworkImageThumbnail(imageUrl: w['banner'], size: 70),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(w['title'] ?? 'No Title', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                                if (w['description'] != null) ...[const SizedBox(height: 4),
                                  Text(w['description'], maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: Colors.grey[700]))],
                                const SizedBox(height: 8),
                                if (w['location'] != null) Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                                      Icon(Icons.location_on, size: 14, color: Colors.blue[700]),
                                      const SizedBox(width: 4),
                                      Text(w['location'], style: TextStyle(fontSize: 12, color: Colors.blue[700], fontWeight: FontWeight.w500)),
                                    ])),
                                const SizedBox(height: 6),
                                Row(children: [Icon(Icons.access_time, size: 14, color: Colors.red[400]), const SizedBox(width: 4),
                                  Text(_ago(w['deletedAt']), style: TextStyle(fontSize: 12, color: Colors.red[600], fontWeight: FontWeight.w500))]),
                              ])),
                            ]),
                            Padding(padding: const EdgeInsets.only(top: 12), child: Divider(height: 1, thickness: 1)),
                            Row(children: [
                              Expanded(child: TextButton.icon(onPressed: _isDeleting ? null : () => _restore(w),
                                  icon: Icon(Icons.restore, color: _isDeleting ? Colors.grey : Colors.green, size: 20),
                                  label: Text('Restore', style: TextStyle(color: _isDeleting ? Colors.grey : Colors.green)),
                                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)))),
                              Container(width: 1, height: 30, color: Colors.grey[300]),
                              Expanded(child: TextButton.icon(onPressed: _isDeleting ? null : () => _deletePermanentlyDialog(w),
                                  icon: Icon(Icons.delete_forever, color: _isDeleting ? Colors.grey : Colors.red, size: 20),
                                  label: Text('Delete', style: TextStyle(color: _isDeleting ? Colors.grey : Colors.red)),
                                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)))),
                            ]),
                          ]),
                        )),
                  ),
                );
              })),
        ]),
        if (_isDeleting) Container(color: Colors.black.withOpacity(0.5),
            child: Center(child: Card(elevation: 8, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: const Padding(padding: EdgeInsets.all(32),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xff1676C4)), strokeWidth: 3),
                      SizedBox(height: 20),
                      Text('Deleting permanently...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1676C4))),
                    ]))))),
      ]),
    );
  }

  PopupMenuItem<String> _sortItem(String v, IconData icon, String label) => PopupMenuItem(value: v,
      child: Container(
          decoration: _sortBy == v ? BoxDecoration(color: const Color(0xff1676C4).withOpacity(0.1), borderRadius: BorderRadius.circular(8)) : null,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(children: [
            Icon(icon, size: 20, color: _sortBy == v ? const Color(0xff1676C4) : Colors.grey[700]),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: _sortBy == v ? const Color(0xff1676C4) : Colors.grey[800],
                fontWeight: _sortBy == v ? FontWeight.bold : FontWeight.normal)),
          ])));
}