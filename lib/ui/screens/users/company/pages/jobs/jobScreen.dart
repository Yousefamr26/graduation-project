// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  Future<void> _loadCompanyNameThenHistory() async {
    try {
      final prefs        = await SharedPreferences.getInstance();
      final userDataJson = prefs.getString('company_user_data');
      if (userDataJson != null && userDataJson.isNotEmpty) {
        final Map<String, dynamic> userData = jsonDecode(userDataJson);
        _currentCompanyName = userData['name']?.toString()?.trim();
      }
    } catch (e) {
      debugPrint("Error loading company name: $e");
    }
    await _loadHistoryFromStorage();
  }

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

  Future<void> _fetchJobs() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final fetchedJobs = await jobRepo.getAllJobs();
      if (!mounted) return;
      final Set<String> historyIds = jobHistory
          .map((j) => j['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
      setState(() {
        jobs.clear();
        for (var item in fetchedJobs) {
          final jobId = item['id']?.toString() ?? '';
          if (_currentCompanyName != null && _currentCompanyName!.isNotEmpty) {
            final jobCompanyName = item['companyName']?.toString()?.trim() ?? '';
            if (jobCompanyName.toLowerCase() != _currentCompanyName!.toLowerCase()) continue;
          }
          if (historyIds.contains(jobId)) continue;
          jobs.add(item);
        }
        applyFilters();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load jobs: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _normalizeStatus(Map<String, dynamic> job) {
    final rawStatus = job['status']?.toString().toLowerCase() ?? '';
    if (rawStatus == 'published') return 'Published';
    if (rawStatus == 'closed') return 'Closed';
    if (rawStatus == 'draft') return 'Draft';
    if (job['isPublished'] == true) return 'Published';
    return 'Published';
  }

  void applyFilters() {
    if (!mounted) return;
    setState(() {
      filteredJobs = jobs.where((job) {
        if (selectedFilter != "All") {
          if (_normalizeStatus(job) != selectedFilter) return false;
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
  // ✅ DELETE (بدل Archive)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _deleteJob(Map<String, dynamic> jobToDelete) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Delete Job?',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(
              "This job will be permanently deleted and cannot be restored.",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.red.withOpacity(0.3), width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.work_outline,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      jobToDelete['title'] ?? 'No Title',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.red),
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
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[400]!),
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
                    icon: const Icon(Icons.delete_outline, size: 20),
                    label: const Text("Delete",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
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

    if (confirm != true) return;

    // ── Call API ──
    try {
      final response = await jobRepo.deleteJob(jobToDelete['id']);
      if (!mounted) return;

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 204)) {
        setState(() {
          jobs.removeWhere((j) => j['id'] == jobToDelete['id']);
          applyFilters();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(
                      '${jobToDelete['title']} deleted successfully',
                      overflow: TextOverflow.ellipsis)),
            ]),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to delete: ${response?.statusCode ?? 'No response'}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ Details Bottom Sheet
  // ─────────────────────────────────────────────────────────────────────────

  void _showJobDetails(Map<String, dynamic> job) {
    final status = _normalizeStatus(job);
    final salaryDisplay = job['salaryRange']?.toString().isNotEmpty == true
        ? job['salaryRange']
        : '${job['salaryMin'] ?? ''} - ${job['salaryMax'] ?? ''}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff1676C4), Color(0xff0d9de8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    NetworkImageThumbnail(imageUrl: job['companyLogo'], size: 56),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(job['title'] ?? 'Untitled',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(job['companyName'] ?? '',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(status,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if ((job['jobType'] ?? '').toString().isNotEmpty)
                          _detailChip(Icons.work_outline, job['jobType'], Colors.purple),
                        if ((job['experienceLevel'] ?? '').toString().isNotEmpty)
                          _detailChip(Icons.trending_up, job['experienceLevel'],
                              const Color(0xff1676C4)),
                        if ((job['location'] ?? '').toString().isNotEmpty)
                          _detailChip(Icons.location_on, job['location'], Colors.teal),
                        if (salaryDisplay.toString().trim().isNotEmpty &&
                            salaryDisplay != ' - ')
                          _detailChip(Icons.attach_money, salaryDisplay, Colors.green),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if ((job['description'] ?? '').toString().isNotEmpty) ...[
                      _sectionTitle('Description'),
                      const SizedBox(height: 8),
                      Text(job['description'],
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.6)),
                      const SizedBox(height: 20),
                    ],
                    if ((job['requiredSkills'] ?? '').toString().isNotEmpty) ...[
                      _sectionTitle('Required Skills'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: job['requiredSkills']
                            .toString()
                            .split(',')
                            .map<Widget>((skill) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xff1676C4)
                                .withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xff1676C4)
                                    .withOpacity(0.3)),
                          ),
                          child: Text(skill.trim(),
                              style: const TextStyle(
                                  color: Color(0xff1676C4),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                    _sectionTitle('Details'),
                    const SizedBox(height: 10),
                    _detailRow(Icons.calendar_today, 'Posted',
                        _formatDate(job['createdAt'])),
                    if ((job['deadline'] ?? job['applicationDeadline'] ?? '')
                        .toString()
                        .isNotEmpty)
                      _detailRow(
                          Icons.flag,
                          'Deadline',
                          _formatDate(
                              job['deadline'] ?? job['applicationDeadline'])),
                    const SizedBox(height: 24),

                    // ── Buttons ──
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _openEdit(job);
                            },
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit Job',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff1676C4),
                              foregroundColor: Colors.white,
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteJob(job); // ✅ delete بدل archive
                            },
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Delete',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openEdit(Map<String, dynamic> job) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateEditJobScreen(jobData: job)),
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
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  Widget _detailChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color(0xff1676C4)),
  );

  Widget _detailRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Text('$label: ',
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500)),
        Text(value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    ),
  );

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
                            JobHistoryScreen(jobHistory: jobHistory)),
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
                hintText: "Search ",
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
                const EdgeInsets.fromLTRB(16, 8, 16, 8),
                itemCount: _currentPageItems.length,
                itemBuilder: (context, index) {
                  final globalIndex =
                      (_currentPage - 1) * _itemsPerPage + index;
                  return _buildJobCard(globalIndex);
                },
              ),
            ),
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
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xff1676C4)
              : enabled
              ? Colors.white
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
            isActive ? const Color(0xff1676C4) : Colors.grey[300]!,
            width: isActive ? 2 : 1,
          ),
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
              fontWeight:
              isActive ? FontWeight.bold : FontWeight.w500,
              fontSize: 16,
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

    return GestureDetector(
      onTap: () => _showJobDetails(job),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 10),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NetworkImageThumbnail(
                      imageUrl: job['companyLogo'], size: 52),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job['title'] ?? 'Untitled',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(children: [
                          Icon(Icons.location_on,
                              size: 13, color: Colors.grey[500]),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              job['location']?.toString().isNotEmpty ==
                                  true
                                  ? job['location']
                                  : 'Remote',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: status == "Published"
                          ? Colors.green.withOpacity(0.12)
                          : status == "Closed"
                          ? Colors.grey.withOpacity(0.12)
                          : Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
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
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if ((job['jobType'] ?? '').toString().isNotEmpty)
                    _chip(job['jobType'], Colors.purple),
                  if ((job['experienceLevel'] ?? '').toString().isNotEmpty)
                    _chip(job['experienceLevel'], const Color(0xff1676C4)),
                  if (salaryDisplay.toString().trim().isNotEmpty &&
                      salaryDisplay != ' - ')
                    _chip('💰 $salaryDisplay', Colors.green),
                ],
              ),

              const SizedBox(height: 10),

              // ── Buttons: Edit + Delete ──
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openEdit(job),
                      icon: const Icon(Icons.edit, size: 14),
                      label: const Text("Edit",
                          style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xff1676C4),
                        side: const BorderSide(
                            color: Color(0xff1676C4)),
                        padding:
                        const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _deleteJob(job), // ✅ delete
                      icon: const Icon(Icons.delete_outline, size: 14),
                      label: const Text("Delete",
                          style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding:
                        const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontWeight: FontWeight.w600, fontSize: 11),
      ),
    );
  }
}