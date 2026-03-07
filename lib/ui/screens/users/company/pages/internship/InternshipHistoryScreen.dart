import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../../../data/models/company/internship-model.dart';

class InternshipHistoryScreen extends StatefulWidget {
  final List<InternshipModel> internshipHistory;

  const InternshipHistoryScreen({Key? key, required this.internshipHistory}) : super(key: key);

  @override
  State<InternshipHistoryScreen> createState() => _InternshipHistoryScreenState();
}

class _InternshipHistoryScreenState extends State<InternshipHistoryScreen> {
  String _searchQuery = '';
  String _sortBy = 'date'; // 'date', 'title', 'duration'

  List<InternshipModel> get _filteredHistory {
    var filtered = widget.internshipHistory.where((internship) {
      final title = internship.title.toLowerCase();
      final description = internship.description.toLowerCase();
      final companyName = (internship.companyName ?? '').toLowerCase();
      final type = internship.type.toLowerCase();
      final duration = internship.duration.toLowerCase();
      final query = _searchQuery.toLowerCase();

      return title.contains(query) ||
          description.contains(query) ||
          companyName.contains(query) ||
          type.contains(query) ||
          duration.contains(query);
    }).toList();

    // Sort
    filtered.sort((a, b) {
      if (_sortBy == 'title') {
        return a.title.compareTo(b.title);
      } else if (_sortBy == 'duration') {
        return a.duration.compareTo(b.duration);
      } else {
        return widget.internshipHistory.indexOf(b).compareTo(widget.internshipHistory.indexOf(a));
      }
    });

    return filtered;
  }

  String _formatDeletedDate(InternshipModel internship) {
    return 'Recently deleted';
  }

  void _showRestoreDialog(InternshipModel internship) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.restore, color: Colors.green),
            SizedBox(width: 8),
            Text('Restore Internship'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to restore this internship?'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    internship.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    internship.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, internship);
            },
            icon: Icon(Icons.restore),
            label: Text('Restore'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeletePermanentlyDialog(InternshipModel internship, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red),
            SizedBox(width: 8),
            Text(
              'Delete Permanently',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This action cannot be undone. Are you sure?'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(
                internship.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                widget.internshipHistory.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Internship deleted permanently'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            icon: Icon(Icons.delete_forever),
            label: Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoWidget(InternshipModel internship) {
    if (internship.logoPath == null || internship.logoPath!.isEmpty) {
      return Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.delete_outline,
          color: Colors.red[400],
          size: 32,
        ),
      );
    }

    if (internship.logoPath!.startsWith("http")) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          internship.logoPath!,
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 70,
              height: 70,
              color: Colors.grey[300],
              child: Icon(
                Icons.broken_image,
                color: Colors.grey[500],
              ),
            );
          },
        ),
      );
    }

    return Image.file(
      File(internship.logoPath!),
      width: 70,
      height: 70,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 70,
          height: 70,
          color: Colors.grey[300],
          child: Icon(
            Icons.broken_image,
            color: Colors.grey[500],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredHistory;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Deleted Internships",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "${filteredList.length} ${filteredList.length == 1 ? 'item' : 'items'}",
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xff1676C4),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.sort, color: Colors.white),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 20),
                    SizedBox(width: 8),
                    Text('Sort by Date'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'title',
                child: Row(
                  children: [
                    Icon(Icons.title, size: 20),
                    SizedBox(width: 8),
                    Text('Sort by Title'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'duration',
                child: Row(
                  children: [
                    Icon(Icons.schedule, size: 20),
                    SizedBox(width: 8),
                    Text('Sort by Duration'),
                  ],
                ),
              ),
            ],
          ),
        ],
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Container(
            color: Color(0xff1676C4),
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search internships...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: filteredList.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _searchQuery.isEmpty ? Icons.delete_outline : Icons.search_off,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty ? "No deleted internships yet." : "No results found",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_searchQuery.isEmpty) ...[
                    SizedBox(height: 8),
                    Text(
                      "Deleted internships will appear here",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final internship = filteredList[index];
                final actualIndex = widget.internshipHistory.indexOf(internship);

                return Dismissible(
                  key: Key(internship.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_forever, color: Colors.white, size: 32),
                        SizedBox(height: 4),
                        Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    bool? confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete Permanently?'),
                        content: Text('This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    return confirm ?? false;
                  },
                  onDismissed: (direction) {
                    setState(() {
                      widget.internshipHistory.removeAt(actualIndex);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Internship deleted permanently'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showRestoreDialog(internship),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLogoWidget(internship),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        internship.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      if (internship.companyName != null && internship.companyName!.isNotEmpty)
                                        Text(
                                          internship.companyName!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      SizedBox(height: 4),
                                      Text(
                                        internship.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Color(0xff1676C4).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.schedule,
                                                    size: 14,
                                                    color: Color(0xff1676C4),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    internship.duration,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xff1676C4),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: internship.isPaid
                                                    ? Colors.green[50]
                                                    : Colors.grey[100],
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    internship.isPaid ? Icons.attach_money : Icons.money_off,
                                                    size: 14,
                                                    color: internship.isPaid ? Colors.green[700] : Colors.grey[700],
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    internship.isPaid ? "Paid" : "Unpaid",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: internship.isPaid ? Colors.green[700] : Colors.grey[700],
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Colors.red[400],
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            _formatDeletedDate(internship),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.red[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Divider(height: 1, thickness: 1),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: () => _showRestoreDialog(internship),
                                    icon: Icon(Icons.restore, color: Colors.green, size: 20),
                                    label: Text(
                                      'Restore',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 30,
                                  color: Colors.grey[300],
                                ),
                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: () => _showDeletePermanentlyDialog(internship, actualIndex),
                                    icon: Icon(Icons.delete_forever, color: Colors.red, size: 20),
                                    label: Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                    ),
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
    );
  }
}