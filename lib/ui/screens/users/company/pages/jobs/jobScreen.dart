// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../data/repositories/Job repository.dart';
import '../../../../../widgets/common/CustomDropdown.dart';
import '../../../../../widgets/common/NetworkImageWidget.dart';
import '../../../../../widgets/common/action_button.dart';
import 'addnewjob.dart';
import 'jobhistory.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final jobRepo = JobRepository();

  final List<Map<String, dynamic>> jobs       = [];
  final List<Map<String, dynamic>> jobHistory = [];

  static const String _historyKey  = 'job_history_ids';
  static const int    _itemsPerPage = 4;

  String searchText     = "";
  String selectedFilter = "All";
  List<Map<String, dynamic>> filteredJobs = [];
  bool isLoading        = true;
  int  _currentPage     = 1;

  // ✅ اسم الشركة المسجلة — هنفلتر بيه لأن الـ API مش بيرجع companyId
  String? _currentCompanyName;

  int get _totalPages =>
      (filteredJobs.length / _itemsPerPage).ceil().clamp(1, 999);

  List<Map<String, dynamic>> get _currentPageItems {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end   = (start + _itemsPerPage).clamp(0, filteredJobs.length);
    return filteredJobs.sublist(start, end);
  }

  @override
  void initState() {
    super.initState();
    _loadCompanyNameThenHistory();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ جيب اسم الشركة من SharedPreferences
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadCompanyNameThenHistory() async {
    try {
      final prefs        = await SharedPreferences.getInstance();
      final userDataJson = prefs.getString('company_user_data');

      if (userDataJson != null && userDataJson.isNotEmpty) {
        final Map<String, dynamic> userData = jsonDecode(userDataJson);
        _currentCompanyName = userData['name']?.toString()?.trim();
        debugPrint("🏢 [JOBS] Current Company Name: '$_currentCompanyName'");
      }

      if (_currentCompanyName == null || _currentCompanyName!.isEmpty) {
        debugPrint("⚠️ [JOBS] No company name found — will show all jobs");
      }
    } catch (e) {
      debugPrint("Error loading company name: $e");
    }

    await _loadHistoryFromStorage();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Storage
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadHistoryFromStorage() async {
    try {
      final prefs       = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      if (historyJson != null && historyJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(historyJson);
        setState(() {
          jobHistory.clear();
          jobHistory.addAll(
              decoded.map((item) => Map<String, dynamic>.from(item)).toList());
        });
      }
    } catch (e) {
      debugPrint("Error loading job history: $e");
    }
    await _fetchJobs();
  }

  Future<void> _saveHistoryToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_historyKey, jsonEncode(jobHistory));
    } catch (e) {
      debugPrint("Error saving job history: $e");
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ Fetch + فلترة بالـ companyName
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _fetchJobs() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final fetchedJobs = await jobRepo.getAllJobs();
      debugPrint("🔍 [SCREEN] Fetched ${fetchedJobs.length} jobs from API");

      if (!mounted) return;

      final Set<String> historyIds = jobHistory
          .map((j) => j['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();

      setState(() {
        jobs.clear();

        for (var item in fetchedJobs) {
          final jobId = item['id']?.toString() ?? '';

          // ✅ فلترة بالـ companyName — لأن الـ API مش بيرجع companyId
          if (_currentCompanyName != null && _currentCompanyName!.isNotEmpty) {
            final jobCompanyName =
                item['companyName']?.toString()?.trim() ?? '';

            if (jobCompanyName.toLowerCase() !=
                _currentCompanyName!.toLowerCase()) {
              debugPrint(
                  "⏭️ Skipping job '${item['title']}' — companyName: '$jobCompanyName' ≠ '$_currentCompanyName'");
              continue;
            }
          }

          // ✅ استثناء الـ history items
          if (historyIds.contains(jobId)) {
            debugPrint("⏭️ Skipping history item: $jobId");
            continue;
          }

          debugPrint(
              "✅ [SCREEN] Adding job '${item['title']}' companyName: '${item['companyName']}'");
          jobs.add(item);
        }

        debugPrint("✅ [SCREEN] Total jobs to show: ${jobs.length}");
        applyFilters();
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching jobs: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to load jobs: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helper: Normalize Status
  // ─────────────────────────────────────────────────────────────────────────

  String _normalizeStatus(Map<String, dynamic> job) {
    final rawStatus = job['status']?.toString() ?? '';
    if (rawStatus.toLowerCase() == 'published' || job['isPublished'] == true) {
      return 'Published';
    } else if (rawStatus.toLowerCase() == 'closed') {
      return 'Closed';
    } else {
      return 'Draft';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Filters
  // ─────────────────────────────────────────────────────────────────────────

  void applyFilters() {
    if (!mounted) return;
    setState(() {
      filteredJobs = jobs.where((job) {
        if (selectedFilter != "All") {
          final normalizedStatus = _normalizeStatus(job);
          if (normalizedStatus != selectedFilter) return false;
        }
        if (searchText.isEmpty) return true;
        final s = searchText.toLowerCase();
        return _stringContains(job['title'], s) ||
            _stringContains(job['description'], s) ||
            _stringContains(job['location'], s) ||
            _stringContains(job['experienceLevel'], s) ||
            _stringContains(job['jobType'], s);
      }).toList();
      _currentPage = 1;
    });
  }

  bool _stringContains(dynamic value, String search) =>
      value != null && value.toString().toLowerCase().contains(search);

  // ─────────────────────────────────────────────────────────────────────────
  // Move to History (Soft Delete)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _moveToHistory(int globalIndex) async {
    final jobToMove = filteredJobs[globalIndex];

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
            Text("This job will be moved to History.",
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
                    child: const Icon(Icons.work_outline,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(jobToMove['title'] ?? 'No Title',
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
                      side:
                      const BorderSide(color: Color(0xff1676C4), width: 2),
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
        jobToMove['deletedAt'] = DateTime.now().toIso8601String();
        jobHistory.add(jobToMove);
        jobs.removeWhere((j) => j['id'] == jobToMove['id']);
        applyFilters();
      });
      await _saveHistoryToStorage();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                  child: Text('${jobToMove['title']} moved to History',
                      overflow: TextOverflow.ellipsis)),
            ]),
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

  // ─────────────────────────────────────────────────────────────────────────
  // Handle History Result
  // ─────────────────────────────────────────────────────────────────────────

  void _handleHistoryResult(Map<String, dynamic> result) async {
    if (result['action'] == 'restore') {
      final restoredJob = result['job'];
      setState(() {
        jobs.add(restoredJob);
        jobHistory.remove(restoredJob);
        applyFilters();
      });
      await _saveHistoryToStorage();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.restore, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                  child: Text('${restoredJob['title']} restored successfully!',
                      overflow: TextOverflow.ellipsis)),
            ]),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else if (result['action'] == 'deleted') {
      final deletedJob = result['job'];
      setState(() => jobHistory.remove(deletedJob));
      await _saveHistoryToStorage();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                  child: Text('${deletedJob['title']} permanently deleted',
                      overflow: TextOverflow.ellipsis)),
            ]),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const CreateEditJobScreen(jobData: null)),
            );
            if (result == true && mounted) await _fetchJobs();
          },
          backgroundColor: const Color(0xff1676C4),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          _buildAppBar(),
          _buildSearchAndFilter(),
          _buildJobsList(),
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("My Jobs",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500)),
                SizedBox(height: 4),
                Text("Manage your job postings",
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w300)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _fetchJobs,
                tooltip: 'Refresh',
              ),
              IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.history, color: Colors.white),
                    if (jobHistory.isNotEmpty)
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
                              '${jobHistory.length > 99 ? '99+' : jobHistory.length}',
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
                  final result =
                  await Navigator.push<Map<String, dynamic>?>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          JobHistoryScreen(jobHistory: jobHistory),
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
                hintText: "Search jobs...",
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
                items: const ["All", "Draft", "Published", "Closed"],
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

  Widget _buildJobsList() {
    return Expanded(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredJobs.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline,
                size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
                searchText.isEmpty
                    ? "No jobs yet"
                    : "No jobs found",
                style: TextStyle(
                    fontSize: 18, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text(
                searchText.isEmpty
                    ? "Create your first job posting!"
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
              onRefresh: _fetchJobs,
              child: ListView.builder(
                padding:
                const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: _currentPageItems.length,
                itemBuilder: (context, index) {
                  final globalIndex =
                      (_currentPage - 1) * _itemsPerPage + index;
                  return _buildJobCard(globalIndex);
                },
              ),
            ),
          ),
          _buildPaginationBar(),
        ],
      ),
    );
  }

  // ── Pagination ──────────────────────────────────────────────
  Widget _buildPaginationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, -2)),
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

  // ── Job Card ──────────────────────────────────────────────
  Widget _buildJobCard(int globalIndex) {
    final job = filteredJobs[globalIndex];

    final status = _normalizeStatus(job);

    final salaryDisplay = job['salaryRange']?.toString().isNotEmpty == true
        ? job['salaryRange']
        : '${job['salaryMin'] ?? ''} - ${job['salaryMax'] ?? ''}';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Logo + Title ──────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NetworkImageThumbnail(
                  imageUrl: job['companyLogo'],
                  size: 60,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job['title'] ?? 'Untitled',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      if ((job['companyName'] ?? '').toString().isNotEmpty)
                        Text(job['companyName'],
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[700])),
                      const SizedBox(height: 4),
                      Row(children: [
                        Icon(Icons.location_on,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            job['location']?.toString().isNotEmpty == true
                                ? job['location']
                                : 'Remote',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Salary + Experience ───────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (salaryDisplay.toString().trim().isNotEmpty &&
                    salaryDisplay != ' - ')
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.attach_money,
                          size: 16, color: Colors.green[700]),
                      Text(salaryDisplay,
                          style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 12)),
                    ]),
                  ),
                if ((job['experienceLevel'] ?? '').toString().isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                        color: const Color(0xff1676C4).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.work_history,
                          size: 14, color: Color(0xff1676C4)),
                      const SizedBox(width: 4),
                      Text(job['experienceLevel'],
                          style: const TextStyle(
                              color: Color(0xff1676C4),
                              fontWeight: FontWeight.w600,
                              fontSize: 11)),
                    ]),
                  ),
                if ((job['jobType'] ?? job['employmentType'] ?? '')
                    .toString()
                    .isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(
                        job['jobType'] ?? job['employmentType'] ?? '',
                        style: TextStyle(
                            color: Colors.purple[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 11)),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Description ───────────────────────────────────
            Text(job['description'] ?? 'No description',
                style:
                TextStyle(color: Colors.grey[700], fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),

            const SizedBox(height: 12),

            // ── Status + Deadline ─────────────────────────────
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status == "Published"
                      ? Colors.green.withOpacity(0.15)
                      : status == "Closed"
                      ? Colors.grey.withOpacity(0.15)
                      : Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == "Published"
                        ? Colors.green
                        : status == "Closed"
                        ? Colors.grey[700]
                        : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              if ((job['deadline'] ?? job['applicationDeadline'] ?? '')
                  .toString()
                  .isNotEmpty) ...[
                Icon(Icons.flag, size: 16, color: Colors.red[400]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(
                      job['deadline'] ?? job['applicationDeadline']),
                  style:
                  TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ]),

            const SizedBox(height: 16),

            // ── Action Buttons ────────────────────────────────
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
                              CreateEditJobScreen(jobData: job)),
                    );
                    if (result == true && mounted) {
                      await _fetchJobs();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Job updated successfully!'),
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
    );
  }
}