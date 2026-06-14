// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

import '../../../../../../data/repositories/Job repository.dart';

import '../../../../../widgets/common/NetworkImageWidget.dart';

class JobHistoryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> jobHistory;

  const JobHistoryScreen({Key? key, required this.jobHistory}) : super(key: key);

  @override
  State<JobHistoryScreen> createState() => _JobHistoryScreenState();
}

class _JobHistoryScreenState extends State<JobHistoryScreen> {
  // ✅ نفس الـ Roadmap: Repository حقيقي للـ permanent delete
  final JobRepository jobRepo = JobRepository();

  String _searchQuery = '';
  String _sortBy      = 'date';
  bool   _isDeleting  = false;

  List<Map<String, dynamic>> get _filteredHistory {
    var filtered = widget.jobHistory.where((job) {
      final title    = (job['title'] ?? '').toString().toLowerCase();
      final desc     = (job['description'] ?? '').toString().toLowerCase();
      final location = (job['location'] ?? '').toString().toLowerCase();
      final query    = _searchQuery.toLowerCase();
      return title.contains(query) ||
          desc.contains(query) ||
          location.contains(query);
    }).toList();

    filtered.sort((a, b) {
      if (_sortBy == 'title') {
        return (a['title'] ?? '').toString().compareTo((b['title'] ?? '').toString());
      } else if (_sortBy == 'salary') {
        return (a['salaryRange'] ?? a['salaryMin'] ?? '')
            .toString()
            .compareTo((b['salaryRange'] ?? b['salaryMin'] ?? '').toString());
      } else {
        // date: الأحدث أولاً
        final dateA = a['deletedAt'] ?? '';
        final dateB = b['deletedAt'] ?? '';
        return dateB.compareTo(dateA);
      }
    });

    return filtered;
  }

  String _formatDeletedDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Unknown';
    try {
      final date       = DateTime.parse(dateStr);
      final now        = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) return '${difference.inMinutes} minutes ago';
        return '${difference.inHours} hours ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('MMM dd, yyyy').format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Restore Dialog
  // ─────────────────────────────────────────────────────────────────────────

  void _showRestoreDialog(Map<String, dynamic> job) {
    showDialog(
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
                child: const Icon(Icons.restore_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Restore Job',
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
            Text('Are you sure you want to restore this job?',
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
                  child: const Icon(Icons.work_outline,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(job['title'] ?? 'No Title',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xff1676C4)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green[200]!)),
              child: Row(children: [
                Icon(Icons.check_circle_outline,
                    size: 20, color: Colors.green[700]),
                const SizedBox(width: 10),
                Expanded(
                  child: Text("Job will be restored to active list",
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.green[800],
                          fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
          ],
        ),
        actions: [
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    side: BorderSide(color: Colors.grey[400]!, width: 2),
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
                  onPressed: () {
                    Navigator.pop(context);
                    job.remove('deletedAt');
                    // ✅ نفس منطق الـ Roadmap: بنرجع Map مع action
                    Navigator.pop(context, {
                      'action': 'restore',
                      'job': job,
                    });
                  },
                  icon: const Icon(Icons.restore_rounded, size: 20),
                  label: const Text("Restore",
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    shadowColor: Colors.green.withOpacity(0.3),
                  ),
                ),
              ),
            ]),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Delete Permanently Dialog — مثل الـ Roadmap: API call حقيقي
  // ─────────────────────────────────────────────────────────────────────────

  void _showDeletePermanentlyDialog(Map<String, dynamic> job) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.red[400]!, Colors.red[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle),
              child: const Icon(Icons.delete_forever_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Delete Permanently',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
          ]),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red[200]!, width: 2)),
              child: Row(children: [
                Icon(Icons.warning_rounded,
                    color: Colors.red[700], size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('⚠️ This action CANNOT be undone!',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                          fontSize: 14)),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Text('The job will be permanently deleted from the server.',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border:
                  Border.all(color: Colors.grey[300]!, width: 2)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.work_outline,
                          color: Colors.red[700], size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(job['title'] ?? 'No Title',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                  if (job['id'] != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6)),
                      child: Text('ID: ${job['id']}',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                              fontFamily: 'monospace')),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                  _isDeleting ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    side: BorderSide(color: Colors.grey[400]!, width: 2),
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
                  onPressed: _isDeleting
                      ? null
                      : () {
                    Navigator.pop(context);
                    _deletePermanently(job);
                  },
                  icon: _isDeleting
                      ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white)))
                      : const Icon(Icons.delete_forever_rounded, size: 20),
                  label: Text(
                    _isDeleting ? 'Deleting...' : 'Delete Forever',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    shadowColor: Colors.red.withOpacity(0.3),
                  ),
                ),
              ),
            ]),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Permanent Delete — API call حقيقي بالظبط زي الـ Roadmap
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _deletePermanently(Map<String, dynamic> job) async {
    final jobId = job['id']?.toString();

    if (jobId == null || jobId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: Job ID not found'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isDeleting = true);

    try {
      debugPrint("🗑️ Starting permanent delete for job ID: $jobId");

      final response = await jobRepo.deleteJob(jobId);

      if (!mounted) {
        setState(() => _isDeleting = false);
        return;
      }

      if (response != null &&
          (response.statusCode == 200 ||
              response.statusCode == 204 ||
              response.statusCode == 404)) {
        setState(() {
          widget.jobHistory.removeWhere((j) => j['id'] == job['id']);
          _isDeleting = false;
        });

        final message = response.statusCode == 404
            ? 'Job was already deleted'
            : 'Job deleted permanently';

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ]),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );

        debugPrint(
            "✅ Success: $message (Status: ${response.statusCode})");

        // ✅ نفس الـ Roadmap: بنرجع result للـ parent screen
        Navigator.pop(context, {
          'action': 'deleted',
          'job': job,
        });
      } else {
        setState(() => _isDeleting = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text('Delete failed: ${response?.statusCode ?? "Unknown"}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _showDeletePermanentlyDialog(job),
            ),
          ),
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.type} - ${e.message}');
      if (!mounted) return;
      setState(() => _isDeleting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getDioErrorMessage(e)),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _deletePermanently(job),
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Unexpected error: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  String _getDioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Check your internet.';
      case DioExceptionType.sendTimeout:
        return 'Server not responding (send timeout).';
      case DioExceptionType.receiveTimeout:
        return 'Server took too long to respond.';
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 401) return 'Unauthorized. Please log in again.';
        if (status == 403) return 'Forbidden. No permission to delete.';
        if (status == 404) return 'Job not found on server.';
        if (status == 500) return 'Server error. Try again later.';
        return 'Server error: $status';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      default:
        return 'Network error: ${e.message ?? "Unknown"}';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredHistory;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Deleted Jobs",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500)),
            Text(
              "${filteredList.length} ${filteredList.length == 1 ? 'item' : 'items'}",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.9), fontSize: 12),
            ),
          ],
        ),
        backgroundColor: const Color(0xff1676C4),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            onSelected: (value) => setState(() => _sortBy = value),
            itemBuilder: (context) => [
              _sortMenuItem('date', Icons.access_time, 'Sort by Date'),
              _sortMenuItem('title', Icons.title, 'Sort by Title'),
              _sortMenuItem(
                  'salary', Icons.attach_money, 'Sort by Salary'),
            ],
          ),
        ],
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          Column(
            children: [
              // ── Search Bar ─────────────────────────────────────
              Container(
                color: const Color(0xff1676C4),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
                  onChanged: (value) =>
                      setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search jobs...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () =>
                          setState(() => _searchQuery = ''),
                    )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),

              // ── List ───────────────────────────────────────────
              Expanded(
                child: filteredList.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.isEmpty
                            ? Icons.delete_outline
                            : Icons.search_off,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? "No deleted jobs yet."
                            : "No results found",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500),
                      ),
                      if (_searchQuery.isEmpty) ...[
                        const SizedBox(height: 8),
                        Text("Deleted jobs will appear here",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500])),
                      ],
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final job = filteredList[index];
                    return Dismissible(
                      key: Key(
                          '${job['id']}_${DateTime.now().millisecondsSinceEpoch}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin:
                        const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius:
                            BorderRadius.circular(12)),
                        alignment: Alignment.centerRight,
                        padding:
                        const EdgeInsets.only(right: 20),
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.delete_forever,
                                color: Colors.white, size: 32),
                            SizedBox(height: 4),
                            Text('Delete',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                    FontWeight.bold)),
                          ],
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        _showDeletePermanentlyDialog(job);
                        return false;
                      },
                      child: _buildHistoryCard(job),
                    );
                  },
                ),
              ),
            ],
          ),

          // ── Loading Overlay ───────────────────────────────────
          if (_isDeleting)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xff1676C4)),
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 20),
                        Text('Deleting permanently...',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff1676C4))),
                        SizedBox(height: 6),
                        Text('Please wait',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> job) {
    final salaryDisplay =
    job['salaryRange']?.toString().isNotEmpty == true
        ? job['salaryRange']
        : '${job['salaryMin'] ?? ''} - ${job['salaryMax'] ?? ''}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showRestoreDialog(job),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NetworkImageThumbnail(
                      imageUrl: job['companyLogo'], size: 70),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job['title'] ?? "No Title",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        if ((job['description'] ?? '').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(job['description'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700])),
                        ],
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(children: [
                            if (salaryDisplay.toString().trim().isNotEmpty &&
                                salaryDisplay != ' - ')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius:
                                    BorderRadius.circular(6)),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.attach_money,
                                          size: 14,
                                          color: Colors.green[700]),
                                      Text(salaryDisplay,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green[700],
                                              fontWeight:
                                              FontWeight.w500)),
                                    ]),
                              ),
                            if ((job['experienceLevel'] ?? '')
                                .toString()
                                .isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: const Color(0xff1676C4)
                                        .withOpacity(0.1),
                                    borderRadius:
                                    BorderRadius.circular(6)),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.work_history,
                                          size: 14,
                                          color: Color(0xff1676C4)),
                                      const SizedBox(width: 4),
                                      Text(job['experienceLevel'],
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xff1676C4),
                                              fontWeight:
                                              FontWeight.w500)),
                                    ]),
                              ),
                            ],
                          ]),
                        ),
                        const SizedBox(height: 6),
                        Row(children: [
                          Icon(Icons.access_time,
                              size: 14, color: Colors.red[400]),
                          const SizedBox(width: 4),
                          Text(
                            _formatDeletedDate(job['deletedAt']),
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[600],
                                fontWeight: FontWeight.w500),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Divider(height: 1, thickness: 1),
              ),
              Row(children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: _isDeleting
                        ? null
                        : () => _showRestoreDialog(job),
                    icon: Icon(Icons.restore,
                        color:
                        _isDeleting ? Colors.grey : Colors.green,
                        size: 20),
                    label: Text('Restore',
                        style: TextStyle(
                            color: _isDeleting
                                ? Colors.grey
                                : Colors.green)),
                    style: TextButton.styleFrom(
                        padding:
                        const EdgeInsets.symmetric(vertical: 8)),
                  ),
                ),
                Container(
                    width: 1, height: 30, color: Colors.grey[300]),
                Expanded(
                  child: TextButton.icon(
                    onPressed: _isDeleting
                        ? null
                        : () => _showDeletePermanentlyDialog(job),
                    icon: Icon(Icons.delete_forever,
                        color: _isDeleting ? Colors.grey : Colors.red,
                        size: 20),
                    label: Text('Delete',
                        style: TextStyle(
                            color:
                            _isDeleting ? Colors.grey : Colors.red)),
                    style: TextButton.styleFrom(
                        padding:
                        const EdgeInsets.symmetric(vertical: 8)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _sortMenuItem(
      String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      child: Container(
        decoration: _sortBy == value
            ? BoxDecoration(
            color: const Color(0xff1676C4).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8))
            : null,
        padding:
        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(children: [
          Icon(icon,
              size: 20,
              color: _sortBy == value
                  ? const Color(0xff1676C4)
                  : Colors.grey[700]),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  color: _sortBy == value
                      ? const Color(0xff1676C4)
                      : Colors.grey[800],
                  fontWeight: _sortBy == value
                      ? FontWeight.bold
                      : FontWeight.normal)),
        ]),
      ),
    );
  }
}