import 'dart:convert';
import 'package:smart_career_hub/ui/screens/users/company/pages/Roadmaps/roadmapHistory.dart';
import 'package:flutter/material.dart';
import '../../../../../widgets/common/CustomDropdown.dart';
import '../../../../../widgets/common/NetworkImageWidget.dart';
import '../../../../../widgets/common/action_button.dart';
import '../../../../../../data/repositories/roadmap_repository.dart';
import 'create_edit_roadmap.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyRoadmapsScreen extends StatefulWidget {
  const MyRoadmapsScreen({super.key});

  @override
  State<MyRoadmapsScreen> createState() => _MyRoadmapsScreenState();
}

class _MyRoadmapsScreenState extends State<MyRoadmapsScreen> {
  final roadmapRepo = RoadmapRepository();

  final List<Map<String, dynamic>> roadmaps = [];
  final List<Map<String, dynamic>> roadmapHistory = [];

  static const String _historyKey = 'roadmap_history_ids';
  static const int _itemsPerPage = 4;

  String searchText = "";
  String selectedFilter = "All";
  List<Map<String, dynamic>> filteredRoadmaps = [];
  bool isLoading = true;
  int _currentPage = 1;

  int get _totalPages =>
      (filteredRoadmaps.length / _itemsPerPage).ceil().clamp(1, 999);

  List<Map<String, dynamic>> get _currentPageItems {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(0, filteredRoadmaps.length);
    return filteredRoadmaps.sublist(start, end);
  }

  @override
  void initState() {
    super.initState();
    _loadHistoryFromStorage();
  }

  Future<void> _loadHistoryFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString(_historyKey);
      if (historyJson != null && historyJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(historyJson);
        setState(() {
          roadmapHistory.clear();
          roadmapHistory.addAll(
              decoded.map((item) => Map<String, dynamic>.from(item)).toList());
        });
      }
    } catch (e) {
      debugPrint("Error loading history: $e");
    }
    await _fetchRoadmaps();
  }

  Future<void> _saveHistoryToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_historyKey, jsonEncode(roadmapHistory));
    } catch (e) {
      debugPrint("Error saving history: $e");
    }
  }

  Future<void> _fetchRoadmaps() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final fetchedRoadmaps = await roadmapRepo.getAllRoadmaps();
      debugPrint("🔍 [SCREEN] Fetched ${fetchedRoadmaps.length} roadmaps from API");
      if (!mounted) return;

      final Set<String> historyIds = roadmapHistory
          .map((r) => r['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();

      setState(() {
        roadmaps.clear();
        for (var item in fetchedRoadmaps) {
          try {
            final roadmapId = item['id']?.toString() ?? '';
            if (historyIds.contains(roadmapId)) continue;
            roadmaps.add(item);
          } catch (e) {
            debugPrint("Error adding roadmap: $e");
          }
        }
        debugPrint("✅ [SCREEN] Total roadmaps to show: ${roadmaps.length}");
        applyFilters();
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching roadmaps: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to load roadmaps: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  void applyFilters() {
    if (!mounted) return;
    setState(() {
      filteredRoadmaps = roadmaps.where((roadmap) {
        if (selectedFilter != "All" && roadmap["status"] != selectedFilter)
          return false;
        if (searchText.isEmpty) return true;
        final s = searchText.toLowerCase();
        return _stringContains(roadmap["title"], s) ||
            _stringContains(roadmap["description"], s) ||
            _listContains(roadmap["target"], s) ||
            _listContains(roadmap["skills"], s) ||
            _listContains(roadmap["projects"], s) ||
            _listContains(roadmap["quizzes"], s);
      }).toList();
      _currentPage = 1;
      debugPrint("🔎 filteredRoadmaps: ${filteredRoadmaps.length}, totalPages: $_totalPages");
    });
  }

  bool _stringContains(dynamic value, String search) =>
      value != null && value.toString().toLowerCase().contains(search);

  bool _listContains(dynamic value, String search) {
    if (value == null || value is! List) return false;
    return value.any((item) => item.toString().toLowerCase().contains(search));
  }

  Future<void> _moveToHistory(int globalIndex) async {
    final roadmapToMove = filteredRoadmaps[globalIndex];

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xff1676C4), Color(0xff0d7de8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle),
                child: const Icon(Icons.archive_outlined,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Move to History?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text("This roadmap will be moved to History.",
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xff1676C4).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xff1676C4).withOpacity(0.3), width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: const Color(0xff1676C4),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.map_outlined,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(roadmapToMove['title'] ?? 'No Title',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xff1676C4)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xff1676C4),
                      side: const BorderSide(
                          color: Color(0xff1676C4), width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Cancel",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.archive_outlined, size: 20),
                    label: const Text("Move",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1676C4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        actionsPadding: EdgeInsets.zero,
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      setState(() {
        roadmapToMove['deletedAt'] = DateTime.now().toIso8601String();
        roadmapHistory.add(roadmapToMove);
        roadmaps.removeWhere((r) => r['id'] == roadmapToMove['id']);
        applyFilters();
      });
      await _saveHistoryToStorage();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('${roadmapToMove['title']} moved to History',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ],
            ),
            backgroundColor: const Color(0xff1676C4),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _handleHistoryResult(Map<String, dynamic> result) async {
    if (result['action'] == 'restore') {
      final restoredRoadmap = result['roadmap'];
      setState(() {
        roadmaps.add(restoredRoadmap);
        roadmapHistory.remove(restoredRoadmap);
        applyFilters();
      });
      await _saveHistoryToStorage();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.restore, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
                child: Text(
                    '${restoredRoadmap['title']} restored successfully!',
                    overflow: TextOverflow.ellipsis)),
          ]),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (result['action'] == 'deleted') {
      final deletedRoadmap = result['roadmap'];
      setState(() => roadmapHistory.remove(deletedRoadmap));
      await _saveHistoryToStorage();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
                child: Text('${deletedRoadmap['title']} permanently deleted',
                    overflow: TextOverflow.ellipsis)),
          ]),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavBarHeight = kBottomNavigationBarHeight;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: bottomNavBarHeight + 60,
        ),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                  const Create_editRoadmap(roadmapData: null)),
            );
            if (mounted) await _fetchRoadmaps();
          },
          backgroundColor: const Color(0xff1676C4),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          _buildAppBar(),
          _buildSearchAndFilter(),
          _buildRoadmapList(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xff1676C4),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 130,
            automaticallyImplyLeading: false, // ✅ شيل سهم الرجوع
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("My Roadmaps",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500)),
                SizedBox(height: 4),
                Text("Manage your created learning paths",
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w300)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _fetchRoadmaps,
                tooltip: 'Refresh',
              ),
              IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.history, color: Colors.white),
                    if (roadmapHistory.isNotEmpty)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          constraints: const BoxConstraints(
                              minWidth: 18, minHeight: 18),
                          child: Center(
                            child: Text(
                              '${roadmapHistory.length > 99 ? '99+' : roadmapHistory.length}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () async {
                  final result = await Navigator.push<Map<String, dynamic>?>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HistoryScreen(
                        roadmapHistory: roadmapHistory,
                      ),
                    ),
                  );
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon:
                const Icon(Icons.search, color: Color(0xff1676C4)),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color(0xff1676C4), width: 2)),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                  applyFilters();
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 160,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)),
              child: CustomDropdown(
                items: const ["All", "Draft", "Published"], // Roadmaps لسه فيها Draft
                value: selectedFilter,
                onChanged: (value) {
                  setState(() {
                    selectedFilter = value!;
                    applyFilters();
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapList() {
    return Expanded(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredRoadmaps.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined,
                size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
                searchText.isEmpty
                    ? "No roadmaps yet"
                    : "No roadmaps found",
                style: TextStyle(
                    fontSize: 18, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text(
                searchText.isEmpty
                    ? "Create your first roadmap!"
                    : "Try a different search",
                style: TextStyle(
                    fontSize: 14, color: Colors.grey[500])),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchRoadmaps,
              child: ListView.builder(
                padding:
                const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: _currentPageItems.length,
                itemBuilder: (context, index) {
                  final globalIndex =
                      (_currentPage - 1) * _itemsPerPage + index;
                  return _buildRoadmapCard(globalIndex);
                },
              ),
            ),
          ),
          _buildPaginationBar(),
        ],
      ),
    );
  }

  Widget _buildPaginationBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const bottomNavHeight = kBottomNavigationBarHeight;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        19 + bottomPadding + bottomNavHeight,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _pageBtn(
            label: '«',
            isActive: false,
            enabled: _currentPage > 1,
            onTap: () => setState(() => _currentPage--),
          ),
          const SizedBox(width: 6),
          for (int i = 1; i <= _totalPages; i++) ...[
            _pageBtn(
              label: '$i',
              isActive: i == _currentPage,
              enabled: true,
              onTap: () => setState(() => _currentPage = i),
            ),
            if (i != _totalPages) const SizedBox(width: 6),
          ],
          const SizedBox(width: 6),
          _pageBtn(
            label: '»',
            isActive: false,
            enabled: _currentPage < _totalPages,
            onTap: () => setState(() => _currentPage++),
          ),
        ],
      ),
    );
  }

  Widget _pageBtn({
    required String label,
    required bool isActive,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xff1676C4)
              : enabled
              ? Colors.white
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? const Color(0xff1676C4) : Colors.grey[300]!,
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: const Color(0xff1676C4).withOpacity(0.35),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive
                  ? Colors.white
                  : enabled
                  ? Colors.grey[700]
                  : Colors.grey[400],
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoadmapCard(int globalIndex) {
    final item = filteredRoadmaps[globalIndex];

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: item['coverImage'] != null &&
                item['coverImage'].toString().isNotEmpty
                ? NetworkImageWidget(
              imageUrl: item["coverImage"],
              height: 150,
              width: double.infinity,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8)),
            )
                : Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xff1676C4).withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined,
                      size: 50,
                      color:
                      const Color(0xff1676C4).withOpacity(0.5)),
                  const SizedBox(height: 8),
                  Text(
                    "No Cover Image",
                    style: TextStyle(
                        color: const Color(0xff1676C4).withOpacity(0.7),
                        fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item["title"] ?? "Untitled",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(item['description'] ?? 'No description',
                    style: TextStyle(color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "${_formatDate(item['startDate'])} → ${_formatDate(item['endDate'])}",
                        style: TextStyle(
                            color: Colors.grey[700], fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                    "Target: ${item['target']?.join(", ") ?? item['targetRole'] ?? 'Not specified'}",
                    style: TextStyle(color: Colors.grey[700]),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: item['isFree'] == true
                            ? Colors.green.withOpacity(0.15)
                            : Colors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item['isFree'] == true
                                ? Icons.stars
                                : Icons.attach_money,
                            size: 16,
                            color: item['isFree'] == true
                                ? Colors.green
                                : Colors.amber[800],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item['isFree'] == true
                                ? 'Free'
                                : '\$${(item['price'] as double?)?.toStringAsFixed(2) ?? '0.00'}',
                            style: TextStyle(
                              color: item['isFree'] == true
                                  ? Colors.green
                                  : Colors.amber[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: item["status"] == "Published"
                            ? Colors.blue.withOpacity(0.15)
                            : Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item["status"] ?? "Draft",
                        style: TextStyle(
                          color: item["status"] == "Published"
                              ? Colors.blue
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      const Icon(Icons.group, size: 20),
                      const SizedBox(width: 4),
                      Text("Enrolled: ${item['enrolled'] ?? 0}"),
                    ]),
                    Row(children: [
                      const Icon(Icons.show_chart, size: 20),
                      const SizedBox(width: 4),
                      Text("Completion: ${item['completion'] ?? 0}%"),
                    ]),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ActionButton(
                      icon: Icons.edit,
                      text: "Edit",
                      color: const Color(0xff1676C4),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Create_editRoadmap(roadmapData: item)),
                        );
                        if (result == true && mounted) {
                          await _fetchRoadmaps();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                  Text('Roadmap updated successfully!'),
                                  backgroundColor: Colors.green),
                            );
                          }
                        }
                      },
                    ),
                    ActionButton(
                      icon: Icons.delete,
                      text: "Delete",
                      color: Colors.red,
                      onTap: () => _moveToHistory(globalIndex),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}