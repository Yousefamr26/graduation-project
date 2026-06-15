import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../data/repositories/Internship repository.dart';
import '../../../../../widgets/common/CustomDropdown.dart';
import '../../../../../widgets/common/action_button.dart';
import 'InternshipHistoryScreen.dart';
import 'addnewinternship.dart';
import 'internship_details_from_map.dart';

class InternshipsScreen extends StatefulWidget {
  const InternshipsScreen({super.key});

  @override
  State<InternshipsScreen> createState() => _InternshipsScreenState();
}

class _InternshipsScreenState extends State<InternshipsScreen> {
  final _internshipRepo = InternshipRepository();

  final List<Map<String, dynamic>> internships = [];
  final List<Map<String, dynamic>> internshipHistory = [];

  static const String _historyKey = 'internship_history_ids';
  static const int _itemsPerPage = 4;

  String searchText = "";
  String selectedFilter = "All";
  List<Map<String, dynamic>> filteredInternships = [];
  bool isLoading = true;
  int _currentPage = 1;

  int get _totalPages =>
      (filteredInternships.length / _itemsPerPage).ceil().clamp(1, 999);

  List<Map<String, dynamic>> get _currentPageItems {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(0, filteredInternships.length);
    return filteredInternships.sublist(start, end);
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
          internshipHistory.clear();
          internshipHistory.addAll(
              decoded.map((item) => Map<String, dynamic>.from(item)).toList());
        });
      }
    } catch (e) {
      debugPrint("Error loading internship history: $e");
    }
    await _fetchInternships();
  }

  Future<void> _saveHistoryToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_historyKey, jsonEncode(internshipHistory));
    } catch (e) {
      debugPrint("Error saving internship history: $e");
    }
  }

  Future<void> _fetchInternships() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final fetched = await _internshipRepo.getAllInternships();
      if (!mounted) return;

      final Set<String> historyIds = internshipHistory
          .map((i) => i['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();

      setState(() {
        internships.clear();
        for (var item in fetched) {
          if (!historyIds.contains(item['id']?.toString() ?? ''))
            internships.add(item);
        }
        applyFilters();
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching internships: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to load internships: $e'),
          backgroundColor: Colors.red));
    }
  }

  void applyFilters() {
    if (!mounted) return;
    setState(() {
      filteredInternships = internships.where((i) {
        if (selectedFilter != "All" && (i["status"] ?? '') != selectedFilter)
          return false;
        if (searchText.isEmpty) return true;
        final s = searchText.toLowerCase();
        return _contains(i["title"], s) ||
            _contains(i["companyName"], s) ||
            _contains(i["type"], s) ||
            _contains(i["location"], s);
      }).toList();
      _currentPage = 1;
    });
  }

  bool _contains(dynamic value, String search) =>
      value != null && value.toString().toLowerCase().contains(search);

  Future<void> _moveToHistory(int globalIndex) async {
    final item = filteredInternships[globalIndex];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xff1676C4), Color(0xff0d7de8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.archive_outlined,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
                child: Text('Move to History?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold))),
          ]),
        ),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Text("This internship will be moved to History.",
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
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: const Color(0xff1676C4),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.school_outlined,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(item['title'] ?? 'No Title',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xff1676C4)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis)),
            ]),
          ),
          const SizedBox(height: 12),
          Text("You can restore it from History or permanently delete it later.",
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ]),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xff1676C4),
                    side: const BorderSide(color: Color(0xff1676C4), width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Cancel",
                      style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(ctx, true),
                  icon: const Icon(Icons.archive_outlined, size: 20),
                  label: const Text("Move",
                      style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1676C4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ]),
          ),
        ],
        actionsPadding: EdgeInsets.zero,
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      setState(() {
        item['deletedAt'] = DateTime.now().toIso8601String();
        internshipHistory.add(item);
        internships.removeWhere((i) => i['id'] == item['id']);
        applyFilters();
      });
      await _saveHistoryToStorage();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle),
              child:
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text('${item['title']} moved to History',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14))),
          ]),
          backgroundColor: const Color(0xff1676C4),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  void _handleHistoryResult(Map<String, dynamic> result) async {
    if (result['action'] == 'restore') {
      final restored = result['internship'];
      setState(() {
        internships.add(restored);
        internshipHistory.removeWhere((i) => i['id'] == restored['id']);
        applyFilters();
      });
      await _saveHistoryToStorage();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.restore, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
                child: Text('${restored['title']} restored!',
                    overflow: TextOverflow.ellipsis)),
          ]),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ));
      }
    } else if (result['action'] == 'deleted') {
      final deleted = result['internship'];
      setState(
              () => internshipHistory.removeWhere((i) => i['id'] == deleted['id']));
      await _saveHistoryToStorage();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
                child: Text('${deleted['title']} permanently deleted',
                    overflow: TextOverflow.ellipsis)),
          ]),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ));
      }
    }
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
                MaterialPageRoute(builder: (_) => const CreateEditInternshipScreen()));
            if (result == true && mounted) await _fetchInternships();
          },
          backgroundColor: const Color(0xff1676C4),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: Column(children: [
        _buildAppBar(),
        _buildSearchAndFilter(),
        _buildInternshipList(),
      ]),
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("My Internships",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500)),
                SizedBox(height: 4),
                Text("Manage your internship postings",
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w300)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _fetchInternships,
                tooltip: 'Refresh',
              ),
              IconButton(
                icon: Stack(clipBehavior: Clip.none, children: [
                  const Icon(Icons.history, color: Colors.white),
                  if (internshipHistory.isNotEmpty)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                        constraints:
                        const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Center(
                          child: Text(
                            '${internshipHistory.length > 99 ? '99+' : internshipHistory.length}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ]),
                onPressed: () async {
                  final result = await Navigator.push<Map<String, dynamic>?>(
                    context,
                    MaterialPageRoute(
                        builder: (_) => InternshipHistoryScreen(
                            internshipHistory: internshipHistory)),
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
      child: Row(children: [
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
                  borderSide:
                  const BorderSide(color: Color(0xff1676C4), width: 2)),
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
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: CustomDropdown(
              items: const ["All", "Published", "Closed"], // ✅ شيل Draft
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
      ]),
    );
  }

  Widget _buildInternshipList() {
    return Expanded(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredInternships.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined,
                size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
                searchText.isEmpty
                    ? "No internships yet"
                    : "No internships found",
                style: TextStyle(
                    fontSize: 18, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text(
              searchText.isEmpty
                  ? "Create your first internship!"
                  : "Try a different search",
              style:
              TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      )
          : Column(children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchInternships,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: _currentPageItems.length,
              itemBuilder: (context, index) {
                final globalIndex =
                    (_currentPage - 1) * _itemsPerPage + index;
                return _buildInternshipCard(globalIndex);
              },
            ),
          ),
        ),
        _buildPaginationBar(),
      ]),
    );
  }

  Widget _buildPaginationBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _pageBtn(
              label: '«',
              isActive: false,
              enabled: _currentPage > 1,
              onTap: () => setState(() => _currentPage--)),
          const SizedBox(width: 6),
          for (int i = 1; i <= _totalPages; i++) ...[
            _pageBtn(
                label: '$i',
                isActive: i == _currentPage,
                enabled: true,
                onTap: () => setState(() => _currentPage = i)),
            if (i != _totalPages) const SizedBox(width: 6),
          ],
          const SizedBox(width: 6),
          _pageBtn(
              label: '»',
              isActive: false,
              enabled: _currentPage < _totalPages,
              onTap: () => setState(() => _currentPage++)),
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
                offset: const Offset(0, 2))
          ]
              : [],
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  color: isActive
                      ? Colors.white
                      : enabled
                      ? Colors.grey[700]
                      : Colors.grey[400],
                  fontWeight:
                  isActive ? FontWeight.bold : FontWeight.w500,
                  fontSize: 15)),
        ),
      ),
    );
  }

  Widget _buildInternshipCard(int globalIndex) {
    final item = filteredInternships[globalIndex];

    final String status = item['status'] ?? 'Draft';
    final bool isPaid = item['isPaid'] ?? false;
    final String type = item['type'] ?? '';
    final String duration = item['duration'] ?? '';
    final String location = (item['location'] ?? '').toString().trim();
    final String companyName = (item['companyName'] ?? '').toString().trim();

    Color statusColor;
    switch (status) {
      case "Published":
        statusColor = Colors.green;
        break;
      case "Closed":
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 10), // ✅ تصغير المسافة بين الكروت
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12), // ✅ تصغير الـ padding الداخلي
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 48, // ✅ تصغير الأيقونة
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xff1676C4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.school,
                    color: Color(0xff1676C4), size: 24), // ✅ تصغير الأيقونة
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title'] ?? 'Untitled',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)), // ✅ تصغير الخط
                    if (companyName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(companyName,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[600])),
                    ],
                    if (type.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(children: [
                        Icon(
                          type == 'Remote 🌐'
                              ? Icons.home_work
                              : type == 'On-site 🏢'
                              ? Icons.location_on
                              : Icons.hub,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(type,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[700])),
                      ]),
                    ],
                  ],
                ),
              ),
            ]),

            const SizedBox(height: 8), // ✅ تصغير المسافة

            // ── Badges ──
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (duration.isNotEmpty)
                  _badge(duration, Icons.schedule, const Color(0xff1676C4)),
                _badge(
                  isPaid ? 'Paid' : 'Unpaid',
                  isPaid ? Icons.attach_money : Icons.money_off,
                  isPaid ? Colors.green : Colors.grey,
                ),
              ],
            ),

            // ── Location ──
            if (location.isNotEmpty) ...[
              const SizedBox(height: 6), // ✅ تصغير المسافة
              Row(children: [
                Icon(Icons.location_on_outlined,
                    size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(location,
                    style:
                    TextStyle(fontSize: 12, color: Colors.grey[700])),
              ]),
            ],

            const SizedBox(height: 8), // ✅ تصغير المسافة

            // ── Actions ──
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
                            builder: (_) =>
                                CreateEditInternshipScreen(internship: item)));
                    if (result == true && mounted) {
                      await _fetchInternships();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                Text('Internship updated successfully!'),
                                backgroundColor: Colors.green));
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
                ActionButton(
                  icon: Icons.info_outline,
                  text: "Details",
                  color: Colors.green,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              InternshipDetailsFromMap(internship: item))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // ✅ تصغير
      decoration: BoxDecoration(
          color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Row(children: [
        Icon(icon, size: 14, color: color), // ✅ تصغير الأيقونة
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w600, fontSize: 11)), // ✅ تصغير الخط
      ]),
    );
  }
}