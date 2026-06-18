import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/repositories/roadmap_repository.dart';
import '../../../../data/services/api_service.dart';
import '../../../../data/models/Student/quiz-model.dart';
import '../../../widgets/common/CustomDropdown.dart';
import '../../../widgets/common/NetworkImageWidget.dart';

import '../company/pages/Roadmaps/create_edit_roadmap.dart';
import '../company/pages/Roadmaps/roadmapHistory.dart';
import '../company/pages/Roadmaps/Ai quiz screen.dart';

class TrainingCourseManagement extends StatefulWidget {
  const TrainingCourseManagement({super.key});

  @override
  State<TrainingCourseManagement> createState() =>
      _TrainingCourseManagementState();
}

class _TrainingCourseManagementState extends State<TrainingCourseManagement> {
  final roadmapRepo = RoadmapRepository();

  final List<Map<String, dynamic>> roadmaps = [];
  final List<Map<String, dynamic>> roadmapHistory = [];

  static const String _historyKey = 'roadmap_history_ids';

  String searchText = "";
  String selectedFilter = "All";
  List<Map<String, dynamic>> filteredRoadmaps = [];
  bool isLoading = true;

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
            decoded.map((item) => Map<String, dynamic>.from(item)).toList(),
          );
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
      debugPrint(
        "🔍 [SCREEN] Fetched ${fetchedRoadmaps.length} roadmaps from API",
      );
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
          backgroundColor: Colors.red,
        ),
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
        if (selectedFilter != "All" && roadmap["status"] != selectedFilter) {
          return false;
        }
        if (searchText.isEmpty) return true;
        final s = searchText.toLowerCase();
        return _stringContains(roadmap["title"], s) ||
            _stringContains(roadmap["description"], s) ||
            _listContains(roadmap["target"], s) ||
            _listContains(roadmap["skills"], s) ||
            _listContains(roadmap["projects"], s) ||
            _listContains(roadmap["quizzes"], s);
      }).toList();
      debugPrint("🔎 filteredRoadmaps: ${filteredRoadmaps.length}");
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
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.archive_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Move to History?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              "This roadmap will be moved to History.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xff1676C4).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xff1676C4).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xff1676C4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.map_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      roadmapToMove['title'] ?? 'No Title',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xff1676C4),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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
                        color: Color(0xff1676C4),
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.archive_outlined, size: 20),
                    label: const Text(
                      "Move",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1676C4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${roadmapToMove['title']} moved to History',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xff1676C4),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
          content: Row(
            children: [
              const Icon(Icons.restore, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${restoredRoadmap['title']} restored successfully!',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
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
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${deletedRoadmap['title']} permanently deleted',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showQuizzes(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuizzesSheet(
        roadmapId: item['id'] ?? item['workshopId'],
        isPublished: item['isPublished'] ?? (item['status'] == 'Published'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavBarHeight = kBottomNavigationBarHeight;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: bottomNavBarHeight + 60),
        child: FloatingActionButton(
          heroTag: 'tc_add_roadmap_fab',
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const Create_editRoadmap(roadmapData: null),
              ),
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
            toolbarHeight: 90,
            automaticallyImplyLeading: false,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Course Management",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Manage your academy learning paths and courses",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
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
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Center(
                            child: Text(
                              '${roadmapHistory.length > 99 ? '99+' : roadmapHistory.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
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
                      builder: (_) =>
                          HistoryScreen(roadmapHistory: roadmapHistory),
                    ),
                  );
                  if (result != null && mounted) _handleHistoryResult(result);
                },
                tooltip: 'History / Bin',
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
                hintText: "Search...",
                prefixIcon: const Icon(Icons.search, color: Color(0xff1676C4)),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xff1676C4),
                    width: 2,
                  ),
                ),
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
                borderRadius: BorderRadius.circular(10),
              ),
              child: CustomDropdown(
                items: const ["All", "Draft", "Published"],
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
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xff1676C4)),
            )
          : filteredRoadmaps.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    searchText.isEmpty
                        ? "No roadmaps yet"
                        : "No roadmaps found",
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    searchText.isEmpty
                        ? "Create your first roadmap!"
                        : "Try a different search",
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchRoadmaps,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: filteredRoadmaps.length,
                itemBuilder: (context, index) {
                  return _buildRoadmapCard(index);
                },
              ),
            ),
    );
  }

  Widget _buildMiniBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoadmapCard(int globalIndex) {
    final item = filteredRoadmaps[globalIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child:
                    item['coverImage'] != null &&
                        item['coverImage'].toString().isNotEmpty
                    ? NetworkImageWidget(
                        imageUrl: item["coverImage"],
                        height: 160,
                        width: double.infinity,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      )
                    : Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xff1676C4).withOpacity(0.05),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map_outlined,
                              size: 50,
                              color: const Color(0xff1676C4).withOpacity(0.4),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "No Cover Image",
                              style: TextStyle(
                                color: const Color(0xff1676C4).withOpacity(0.6),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: item["status"] == "Published"
                        ? Colors.blueAccent
                        : Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    item["status"] ?? "Draft",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: item['isFree'] == true
                        ? Colors.green
                        : Colors.amber[800],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item['isFree'] == true
                            ? Icons.stars
                            : Icons.attach_money,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item['isFree'] == true
                            ? 'Free'
                            : '\$${(item['price'] as double?)?.toStringAsFixed(2) ?? '0.00'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["title"] ?? "Untitled",
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item['description'] ?? 'No description provided.',
                  style: TextStyle(color: Colors.grey[600], height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildMiniBadge(
                      Icons.group_outlined,
                      "Target: ${item['target']?.join(', ') ?? item['targetRole'] ?? 'Any'}",
                    ),
                    _buildMiniBadge(
                      Icons.calendar_today_outlined,
                      "${_formatDate(item['startDate'])} - ${_formatDate(item['endDate'])}",
                    ),
                    _buildMiniBadge(
                      Icons.trending_up,
                      "Enrolled: ${item['enrolled'] ?? 0}",
                    ),
                    _buildMiniBadge(
                      Icons.check_circle_outline,
                      "Completion: ${item['completion'] ?? 0}%",
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildIconAction(
                      Icons.edit_outlined,
                      "Edit",
                      Colors.blue[700]!,
                      () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Create_editRoadmap(roadmapData: item),
                          ),
                        );
                        if (result == true && mounted) {
                          await _fetchRoadmaps();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Course updated successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      },
                    ),
                    Container(width: 1, height: 30, color: Colors.grey[200]),
                    _buildIconAction(
                      Icons.quiz_outlined,
                      "Quiz",
                      Colors.green[600]!,
                      () => _showQuizzes(item),
                    ),
                    Container(width: 1, height: 30, color: Colors.grey[200]),
                    _buildIconAction(
                      Icons.delete_outline,
                      "Delete",
                      Colors.red[600]!,
                      () => _moveToHistory(globalIndex),
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

class _QuizzesSheet extends StatefulWidget {
  final dynamic roadmapId;
  final bool isPublished;

  const _QuizzesSheet({required this.roadmapId, required this.isPublished});

  @override
  State<_QuizzesSheet> createState() => _QuizzesSheetState();
}

class _QuizzesSheetState extends State<_QuizzesSheet> {
  static const Color kPrimary = Color(0xff1676C4);
  bool _loading = true;
  String? _error;
  QuizModel? _latestQuiz;

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
  }

  Future<void> _fetchQuizzes() async {
    try {
      final res = await ApiService.get(
        '/Roadmaps/${widget.roadmapId}/generated-quiz',
        userType: 'training_center',
      );

      List<QuizModel> quizzes = [];
      if (res is Map && res['data'] is List) {
        quizzes = (res['data'] as List)
            .map((q) => QuizModel.fromMap(q))
            .toList();
      } else if (res is List) {
        quizzes = res.map((q) => QuizModel.fromMap(q)).toList();
      }

      if (quizzes.isNotEmpty) {
        quizzes.sort((a, b) => b.id.compareTo(a.id));
        _latestQuiz = quizzes.first;
      }

      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  String _extractLetter(String opt) {
    final match = RegExp(
      r'^([A-Z])[\)\.]',
    ).firstMatch(opt.trim().toUpperCase());
    if (match != null) return match.group(1)!;
    return opt.isNotEmpty ? opt[0].toUpperCase() : '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xffF0F9FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.quiz_outlined, color: kPrimary, size: 28),
                const SizedBox(width: 10),
                const Text(
                  "AI Generated Quizzes",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Text(
                    "Roadmap Exams",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          if (_loading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: kPrimary),
                    SizedBox(height: 16),
                    Text(
                      "Loading quizzes ...",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_error != null)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    "Error loading quizzes: $_error",
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          else if (_latestQuiz == null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.quiz_outlined,
                      size: 72,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No quizzes generated yet",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Close bottom sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AiQuizScreen(
                              roadmapId: widget.roadmapId,
                              isPublished: widget.isPublished,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.auto_awesome, color: Colors.white),
                      label: const Text(
                        "Generate AI Quiz",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _latestQuiz!.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.stars,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${_latestQuiz!.points} pts",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _latestQuiz!.questions.length,
                      itemBuilder: (context, qIdx) {
                        final q = _latestQuiz!.questions[qIdx];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: kPrimary,
                                      child: Text(
                                        "${qIdx + 1}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        q.text,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.stars,
                                            size: 12,
                                            color: Colors.amber,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            "${q.points} pts",
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.amber,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...q.options.map((opt) {
                                  final String ca = q.correctAnswer
                                      .toLowerCase()
                                      .trim();
                                  final String optClean = opt.trim();
                                  bool isCorrect = false;

                                  if (optClean.isNotEmpty && ca.isNotEmpty) {
                                    if (optClean.toLowerCase().startsWith(ca)) {
                                      isCorrect = true;
                                    } else if (optClean.toLowerCase() == ca) {
                                      isCorrect = true;
                                    } else {
                                      final optLetter = _extractLetter(
                                        optClean,
                                      ).toLowerCase();
                                      if (optLetter == ca) {
                                        isCorrect = true;
                                      }
                                    }
                                  }

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isCorrect
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isCorrect
                                            ? Colors.green.withOpacity(0.4)
                                            : Colors.grey[200]!,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isCorrect
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          size: 16,
                                          color: isCorrect
                                              ? Colors.green
                                              : Colors.grey[400],
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            opt,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isCorrect
                                                  ? Colors.green[800]
                                                  : Colors.black87,
                                              fontWeight: isCorrect
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        if (isCorrect) ...[
                                          const SizedBox(width: 6),
                                          Icon(
                                            Icons.check,
                                            size: 14,
                                            color: Colors.green[700],
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            'Correct Answer',
                                            style: TextStyle(
                                              color: Colors.green[700],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey[200]!)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Showing latest quiz only (sorted by ID descending)",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
