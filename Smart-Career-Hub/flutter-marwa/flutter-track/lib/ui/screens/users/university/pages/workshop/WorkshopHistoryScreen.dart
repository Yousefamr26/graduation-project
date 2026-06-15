import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkshopHistoryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> workshopHistory;

  /// Called when the user chooses to restore a workshop.
  final void Function(Map<String, dynamic> workshop)? onRestore;

  /// Called when the user permanently deletes a workshop from history.
  final void Function(Map<String, dynamic> workshop)? onPermanentDelete;

  const WorkshopHistoryScreen({
    Key? key,
    required this.workshopHistory,
    this.onRestore,
    this.onPermanentDelete,
  }) : super(key: key);

  @override
  State<WorkshopHistoryScreen> createState() => _WorkshopHistoryScreenState();
}

class _WorkshopHistoryScreenState extends State<WorkshopHistoryScreen> {
  // ── Local copy so mutations don't affect the parent list directly ─────────
  late List<Map<String, dynamic>> _localHistory;

  String _searchQuery = '';
  String _sortBy      = 'date';

  @override
  void initState() {
    super.initState();
    _localHistory = List.from(widget.workshopHistory);
  }

  // ── Filtered & sorted list ────────────────────────────────────────────────

  List<Map<String, dynamic>> get _filteredHistory {
    var filtered = _localHistory.where((workshop) {
      final title       = (workshop['title']       ?? '').toString().toLowerCase();
      final description = (workshop['description'] ?? '').toString().toLowerCase();
      final location    = (workshop['location']    ?? '').toString().toLowerCase();
      final query       = _searchQuery.toLowerCase();
      return title.contains(query) ||
          description.contains(query) ||
          location.contains(query);
    }).toList();

    filtered.sort((a, b) {
      if (_sortBy == 'title')    return (a['title'] ?? '').toString().compareTo((b['title'] ?? '').toString());
      if (_sortBy == 'location') return (a['location'] ?? '').toString().compareTo((b['location'] ?? '').toString());
      final dateA = a['deletedAt'] ?? '';
      final dateB = b['deletedAt'] ?? '';
      return dateB.compareTo(dateA);
    });

    return filtered;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

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

  void _permanentlyDelete(Map<String, dynamic> workshop) {
    setState(() => _localHistory.remove(workshop));
    widget.onPermanentDelete?.call(workshop);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workshop deleted permanently'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────

  void _showRestoreDialog(Map<String, dynamic> workshop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.restore, color: Colors.green),
          SizedBox(width: 8),
          Text('Restore Workshop'),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to restore this workshop?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  workshop['title'] ?? 'No Title',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (workshop['description'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    workshop['description'],
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (workshop['location'] != null) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      workshop['location'],
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ]),
                ],
              ]),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              widget.onRestore?.call(workshop);
              Navigator.pop(context, workshop); // return to caller if needed
            },
            icon: const Icon(Icons.restore),
            label: const Text('Restore'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeletePermanentlyDialog(Map<String, dynamic> workshop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.delete_forever, color: Colors.red),
          SizedBox(width: 8),
          Text(
            'Delete Permanently',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This action cannot be undone. Are you sure?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(
                workshop['title'] ?? 'No Title',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _permanentlyDelete(workshop);
            },
            icon: const Icon(Icons.delete_forever),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Image widget ──────────────────────────────────────────────────────────

  Widget _buildImageWidget(Map<String, dynamic> workshop) {
    final path = (workshop['banner'] ?? workshop['coverImagePath'] ?? '').toString();

    if (path.isEmpty) {
      return Container(
        width: 70, height: 70,
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.event_busy, color: Colors.red[400], size: 32),
      );
    }

    if (path.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          path, width: 70, height: 70, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 70, height: 70,
            color: Colors.grey[300],
            child: Icon(Icons.broken_image, color: Colors.grey[500]),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(path), width: 70, height: 70, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 70, height: 70,
          color: Colors.grey[300],
          child: Icon(Icons.broken_image, color: Colors.grey[500]),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredHistory;

    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            'Deleted Workshops',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
          ),
          Text(
            '${filteredList.length} ${filteredList.length == 1 ? 'item' : 'items'}',
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
          ),
        ]),
        backgroundColor: const Color(0xff1676C4),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: (value) => setState(() => _sortBy = value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'date',
                child: Row(children: [Icon(Icons.access_time, size: 20), SizedBox(width: 8), Text('Sort by Date')]),
              ),
              const PopupMenuItem(
                value: 'title',
                child: Row(children: [Icon(Icons.title, size: 20), SizedBox(width: 8), Text('Sort by Title')]),
              ),
              const PopupMenuItem(
                value: 'location',
                child: Row(children: [Icon(Icons.location_on, size: 20), SizedBox(width: 8), Text('Sort by Location')]),
              ),
            ],
          ),
        ],
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: Column(children: [
        // ── Search bar ──────────────────────────────────────────────────────
        Container(
          color: const Color(0xff1676C4),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search workshops...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => _searchQuery = ''),
              )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),

        // ── List ────────────────────────────────────────────────────────────
        Expanded(
          child: filteredList.isEmpty
              ? Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                _searchQuery.isEmpty ? Icons.delete_outline : Icons.search_off,
                size: 80, color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty ? 'No deleted workshops yet.' : 'No results found',
                style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
              if (_searchQuery.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Deleted workshops will appear here',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ]),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final workshop = filteredList[index];

              return Dismissible(
                key: Key(workshop['id']?.toString() ?? workshop.hashCode.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.delete_forever, color: Colors.white, size: 32),
                    SizedBox(height: 4),
                    Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ]),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Permanently?'),
                      content: const Text('This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  ) ?? false;
                },
                onDismissed: (direction) => _permanentlyDelete(workshop),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _showRestoreDialog(workshop),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _buildImageWidget(workshop),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(
                              workshop['title'] ?? 'No Title',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (workshop['description'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                workshop['description'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(Icons.location_on, size: 14, color: Color(0xff1676C4)),
                                const SizedBox(width: 4),
                                Text(
                                  workshop['location'] ?? 'N/A',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xff1676C4),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ]),
                            ),
                            const SizedBox(height: 6),
                            Row(children: [
                              Icon(Icons.access_time, size: 14, color: Colors.red[400]),
                              const SizedBox(width: 4),
                              Text(
                                _formatDeletedDate(workshop['deletedAt']),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ]),
                          ])),
                        ]),
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Divider(height: 1, thickness: 1),
                        ),
                        Row(children: [
                          Expanded(child: TextButton.icon(
                            onPressed: () => _showRestoreDialog(workshop),
                            icon: const Icon(Icons.restore, color: Colors.green, size: 20),
                            label: const Text('Restore', style: TextStyle(color: Colors.green)),
                            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                          )),
                          Container(width: 1, height: 30, color: Colors.grey[300]),
                          Expanded(child: TextButton.icon(
                            onPressed: () => _showDeletePermanentlyDialog(workshop),
                            icon: const Icon(Icons.delete_forever, color: Colors.red, size: 20),
                            label: const Text('Delete', style: TextStyle(color: Colors.red)),
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
    );
  }
}