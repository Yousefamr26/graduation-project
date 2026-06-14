import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

import '../../../../../../data/repositories/Internship repository.dart';
import '../../../../../widgets/common/NetworkImageWidget.dart';

class InternshipHistoryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> internshipHistory;

  const InternshipHistoryScreen({
    Key? key,
    required this.internshipHistory,
  }) : super(key: key);

  @override
  State<InternshipHistoryScreen> createState() =>
      _InternshipHistoryScreenState();
}

class _InternshipHistoryScreenState
    extends State<InternshipHistoryScreen> {
  final InternshipRepository _internshipRepo = InternshipRepository();

  String _searchQuery = '';
  String _sortBy = 'date';
  bool _isDeleting = false;

  List<Map<String, dynamic>> get _filteredHistory {
    var filtered = widget.internshipHistory.where((internship) {
      final title =
      (internship['title'] ?? '').toString().toLowerCase();
      final desc =
      (internship['description'] ?? '').toString().toLowerCase();
      final type =
      (internship['type'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) ||
          desc.contains(query) ||
          type.contains(query);
    }).toList();

    filtered.sort((a, b) {
      if (_sortBy == 'title') {
        return (a['title'] ?? '')
            .toString()
            .compareTo((b['title'] ?? '').toString());
      } else if (_sortBy == 'duration') {
        return (a['duration'] ?? '')
            .toString()
            .compareTo((b['duration'] ?? '').toString());
      } else {
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
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0)
          return '${difference.inMinutes} minutes ago';
        return '${difference.inHours} hours ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('MMM dd, yyyy').format(date);
      }
    } catch (_) {
      return dateStr;
    }
  }

  // ── Restore Dialog ─────────────────────────────────────

  void _showRestoreDialog(Map<String, dynamic> internship) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
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
                child: Text('Restore Internship',
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
            Text('Are you sure you want to restore this internship?',
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
                    color: const Color(0xff1676C4).withOpacity(0.3),
                    width: 2),
              ),
              child: Row(
                children: [
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
                    child: Text(
                      internship['title'] ?? 'No Title',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xff1676C4)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 20, color: Colors.green[700]),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Internship will be restored to active list",
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.green[800],
                          fontWeight: FontWeight.w600),
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
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(
                          color: Colors.grey[400]!, width: 2),
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Cancel",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      internship.remove('deletedAt');
                      Navigator.pop(context, {
                        'action': 'restore',
                        'internship': internship,
                      });
                    },
                    icon: const Icon(Icons.restore_rounded, size: 20),
                    label: const Text("Restore",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
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
  }

  // ── Delete Permanently Dialog ───────────────────────────

  void _showDeletePermanentlyDialog(Map<String, dynamic> internship) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red[400]!, Colors.red[600]!],
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
            ],
          ),
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
                border: Border.all(color: Colors.red[200]!, width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_rounded,
                      color: Colors.red[700], size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '⚠️ This action CANNOT be undone!',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                          fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border:
                Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(8)),
                        child: Icon(Icons.school_outlined,
                            color: Colors.red[700], size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          internship['title'] ?? 'No Title',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (internship['id'] != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        'ID: ${internship['id']}',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[700],
                            fontFamily: 'monospace'),
                      ),
                    ),
                  ],
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
                    onPressed: _isDeleting
                        ? null
                        : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(
                          color: Colors.grey[400]!, width: 2),
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Cancel",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isDeleting
                        ? null
                        : () {
                      Navigator.pop(context);
                      _deletePermanently(internship);
                    },
                    icon: _isDeleting
                        ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                            AlwaysStoppedAnimation<Color>(
                                Colors.white)))
                        : const Icon(Icons.delete_forever_rounded,
                        size: 20),
                    label: Text(_isDeleting
                        ? 'Deleting...'
                        : 'Delete Forever',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
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
  }

  // ── Actual Delete ───────────────────────────────────────

  Future<void> _deletePermanently(
      Map<String, dynamic> internship) async {
    final internshipId = internship['id']?.toString();

    if (internshipId == null || internshipId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: Internship ID not found'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isDeleting = true);

    try {
      debugPrint(
          "🗑️ Permanently deleting internship ID: $internshipId");

      final response =
      await _internshipRepo.deleteInternship(internshipId);

      if (!mounted) {
        setState(() => _isDeleting = false);
        return;
      }

      if (response != null &&
          (response.statusCode == 200 ||
              response.statusCode == 204 ||
              response.statusCode == 404)) {
        setState(() {
          widget.internshipHistory
              .removeWhere((i) => i['id'] == internship['id']);
          _isDeleting = false;
        });

        final message = response.statusCode == 404
            ? 'Internship was already deleted'
            : 'Internship deleted permanently';

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

        Navigator.pop(context, {
          'action': 'deleted',
          'internship': internship,
        });
      } else {
        setState(() => _isDeleting = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Delete failed: ${response?.statusCode ?? "Unknown"}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () =>
                  _showDeletePermanentlyDialog(internship),
            ),
          ),
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getDioErrorMessage(e)),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getDioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Check your internet.';
      case DioExceptionType.badResponse:
        final s = e.response?.statusCode;
        if (s == 401) return 'Unauthorized. Please log in again.';
        if (s == 403) return 'Forbidden. No permission to delete.';
        if (s == 404) return 'Internship not found on server.';
        if (s == 500) return 'Server error. Try again later.';
        return 'Server error: $s';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      default:
        return 'Network error: ${e.message ?? "Unknown"}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredHistory;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Deleted Internships",
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
              PopupMenuItem(
                value: 'date',
                child: Row(children: [
                  Icon(Icons.access_time,
                      size: 20,
                      color: _sortBy == 'date'
                          ? const Color(0xff1676C4)
                          : Colors.grey[700]),
                  const SizedBox(width: 8),
                  Text('Sort by Date',
                      style: TextStyle(
                          color: _sortBy == 'date'
                              ? const Color(0xff1676C4)
                              : Colors.grey[800],
                          fontWeight: _sortBy == 'date'
                              ? FontWeight.bold
                              : FontWeight.normal)),
                ]),
              ),
              PopupMenuItem(
                value: 'title',
                child: Row(children: [
                  Icon(Icons.title,
                      size: 20,
                      color: _sortBy == 'title'
                          ? const Color(0xff1676C4)
                          : Colors.grey[700]),
                  const SizedBox(width: 8),
                  Text('Sort by Title',
                      style: TextStyle(
                          color: _sortBy == 'title'
                              ? const Color(0xff1676C4)
                              : Colors.grey[800],
                          fontWeight: _sortBy == 'title'
                              ? FontWeight.bold
                              : FontWeight.normal)),
                ]),
              ),
              PopupMenuItem(
                value: 'duration',
                child: Row(children: [
                  Icon(Icons.schedule,
                      size: 20,
                      color: _sortBy == 'duration'
                          ? const Color(0xff1676C4)
                          : Colors.grey[700]),
                  const SizedBox(width: 8),
                  Text('Sort by Duration',
                      style: TextStyle(
                          color: _sortBy == 'duration'
                              ? const Color(0xff1676C4)
                              : Colors.grey[800],
                          fontWeight: _sortBy == 'duration'
                              ? FontWeight.bold
                              : FontWeight.normal)),
                ]),
              ),
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
              // Search bar
              Container(
                color: const Color(0xff1676C4),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
                  onChanged: (value) =>
                      setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search internships...',
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

              // List
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
                            ? "No deleted internships yet."
                            : "No results found",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500),
                      ),
                      if (_searchQuery.isEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          "Deleted internships will appear here",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500]),
                        ),
                      ],
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final internship = filteredList[index];
                    return Dismissible(
                      key: Key(
                          '${internship['id']}_${DateTime.now().millisecondsSinceEpoch}'),
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
                          children: [
                            const Icon(
                                Icons.delete_forever,
                                color: Colors.white,
                                size: 32),
                            const SizedBox(height: 4),
                            const Text('Delete',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                    FontWeight.bold)),
                          ],
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        _showDeletePermanentlyDialog(
                            internship);
                        return false;
                      },
                      child: Card(
                        margin:
                        const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12)),
                        child: InkWell(
                          borderRadius:
                          BorderRadius.circular(12),
                          onTap: () =>
                              _showRestoreDialog(internship),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    // Logo placeholder
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: Colors.red[50],
                                        borderRadius:
                                        BorderRadius
                                            .circular(8),
                                      ),
                                      child: Icon(
                                          Icons.delete_outline,
                                          color: Colors.red[400],
                                          size: 32),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                        children: [
                                          Text(
                                            internship['title'] ??
                                                "No Title",
                                            style: const TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .bold,
                                                fontSize: 16),
                                            maxLines: 2,
                                            overflow:
                                            TextOverflow
                                                .ellipsis,
                                          ),
                                          const SizedBox(
                                              height: 4),
                                          if (internship[
                                          'description'] !=
                                              null)
                                            Text(
                                              internship[
                                              'description'],
                                              maxLines: 2,
                                              overflow:
                                              TextOverflow
                                                  .ellipsis,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors
                                                      .grey[700]),
                                            ),
                                          const SizedBox(
                                              height: 8),
                                          // Type + paid badges
                                          SingleChildScrollView(
                                            scrollDirection:
                                            Axis.horizontal,
                                            child: Row(
                                              children: [
                                                _badge(
                                                  internship[
                                                  'type'] ??
                                                      '',
                                                  Icons.work_outline,
                                                  const Color(
                                                      0xff1676C4),
                                                ),
                                                const SizedBox(
                                                    width: 8),
                                                _badge(
                                                  internship['isPaid'] ==
                                                      true
                                                      ? 'Paid'
                                                      : 'Unpaid',
                                                  internship['isPaid'] ==
                                                      true
                                                      ? Icons
                                                      .attach_money
                                                      : Icons
                                                      .money_off,
                                                  internship['isPaid'] ==
                                                      true
                                                      ? Colors
                                                      .green
                                                      : Colors
                                                      .grey,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                              height: 6),
                                          Row(
                                            children: [
                                              Icon(
                                                  Icons
                                                      .access_time,
                                                  size: 14,
                                                  color: Colors
                                                      .red[400]),
                                              const SizedBox(
                                                  width: 4),
                                              Text(
                                                _formatDeletedDate(
                                                    internship[
                                                    'deletedAt']),
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors
                                                        .red[600],
                                                    fontWeight:
                                                    FontWeight
                                                        .w500),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 12),
                                  child: Divider(
                                      height: 1, thickness: 1),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextButton.icon(
                                        onPressed: _isDeleting
                                            ? null
                                            : () => _showRestoreDialog(
                                            internship),
                                        icon: Icon(
                                            Icons.restore,
                                            color: _isDeleting
                                                ? Colors.grey
                                                : Colors.green,
                                            size: 20),
                                        label: Text('Restore',
                                            style: TextStyle(
                                                color: _isDeleting
                                                    ? Colors.grey
                                                    : Colors
                                                    .green)),
                                        style:
                                        TextButton.styleFrom(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                vertical:
                                                8)),
                                      ),
                                    ),
                                    Container(
                                        width: 1,
                                        height: 30,
                                        color: Colors.grey[300]),
                                    Expanded(
                                      child: TextButton.icon(
                                        onPressed: _isDeleting
                                            ? null
                                            : () => _showDeletePermanentlyDialog(
                                            internship),
                                        icon: Icon(
                                            Icons.delete_forever,
                                            color: _isDeleting
                                                ? Colors.grey
                                                : Colors.red,
                                            size: 20),
                                        label: Text('Delete',
                                            style: TextStyle(
                                                color: _isDeleting
                                                    ? Colors.grey
                                                    : Colors
                                                    .red)),
                                        style:
                                        TextButton.styleFrom(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                vertical:
                                                8)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Loading overlay
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
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xff1676C4)),
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 20),
                        const Text('Deleting permanently...',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff1676C4))),
                        const SizedBox(height: 6),
                        Text('Please wait',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600])),
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

  Widget _badge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}