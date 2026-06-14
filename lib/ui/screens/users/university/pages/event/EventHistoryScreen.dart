import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../../../data/models/company/event-model.dart';

class EventHistoryScreen extends StatefulWidget {
  final List<EventModel> eventHistory;

  const EventHistoryScreen({Key? key, required this.eventHistory}) : super(key: key);

  @override
  State<EventHistoryScreen> createState() => _EventHistoryScreenState();
}

class _EventHistoryScreenState extends State<EventHistoryScreen> {
  String _searchQuery = '';
  String _sortBy = 'date';

  List<EventModel> get _filteredHistory {
    var filtered = widget.eventHistory.where((event) {
      final title       = event.title.toLowerCase();
      final description = event.description.toLowerCase();
      final type        = (event.type ?? '').toLowerCase();
      final mode        = (event.mode ?? '').toLowerCase();
      final location    = event.location.toLowerCase();
      final query       = _searchQuery.toLowerCase();
      return title.contains(query) || description.contains(query) ||
          type.contains(query) || mode.contains(query) || location.contains(query);
    }).toList();

    filtered.sort((a, b) {
      if (_sortBy == 'title') return a.title.compareTo(b.title);
      if (_sortBy == 'type')  return (a.type ?? '').compareTo(b.type ?? '');
      return widget.eventHistory.indexOf(b).compareTo(widget.eventHistory.indexOf(a));
    });

    return filtered;
  }

  void _showRestoreDialog(EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.restore, color: Colors.green),
          SizedBox(width: 8),
          Text('Restore Event'),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to restore this event?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(event.description, style: TextStyle(fontSize: 14, color: Colors.grey[700]), maxLines: 2, overflow: TextOverflow.ellipsis),
              ]),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () { Navigator.pop(context); Navigator.pop(context, event); },
            icon: const Icon(Icons.restore),
            label: const Text('Restore'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          ),
        ],
      ),
    );
  }

  void _showDeletePermanentlyDialog(EventModel event, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.delete_forever, color: Colors.red),
          SizedBox(width: 8),
          Text('Delete Permanently', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This action cannot be undone. Are you sure?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red[200]!)),
              child: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () {
              setState(() { widget.eventHistory.removeAt(index); });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Event deleted permanently'), backgroundColor: Colors.red),
              );
            },
            icon: const Icon(Icons.delete_forever),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(EventModel event) {
    final path = event.coverImagePath;

    if (path == null || path.isEmpty) {
      return Container(
        width: 70, height: 70,
        decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
        child: Icon(Icons.delete_outline, color: Colors.red[400], size: 32),
      );
    }

    // ✅ network image
    if (path.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(path, width: 70, height: 70, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(width: 70, height: 70, color: Colors.grey[300], child: Icon(Icons.broken_image, color: Colors.grey[500]))),
      );
    }

    // local file
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(File(path), width: 70, height: 70, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(width: 70, height: 70, color: Colors.grey[300], child: Icon(Icons.broken_image, color: Colors.grey[500]))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredHistory;

    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Deleted Events', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
          Text('${filteredList.length} ${filteredList.length == 1 ? 'item' : 'items'}', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
        ]),
        backgroundColor: const Color(0xff1676C4),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: (value) => setState(() => _sortBy = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'date',  child: Row(children: [Icon(Icons.access_time, size: 20), SizedBox(width: 8), Text('Sort by Date')])),
              const PopupMenuItem(value: 'title', child: Row(children: [Icon(Icons.title, size: 20), SizedBox(width: 8), Text('Sort by Title')])),
              const PopupMenuItem(value: 'type',  child: Row(children: [Icon(Icons.category, size: 20), SizedBox(width: 8), Text('Sort by Type')])),
            ],
          ),
        ],
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: Column(children: [
        Container(
          color: const Color(0xff1676C4),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search events...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchQuery = '')) : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: filteredList.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(_searchQuery.isEmpty ? Icons.delete_outline : Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(_searchQuery.isEmpty ? 'No deleted events yet.' : 'No results found', style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500)),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 8),
              Text('Deleted events will appear here', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
            ],
          ]))
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final event       = filteredList[index];
              final actualIndex = widget.eventHistory.indexOf(event);

              return Dismissible(
                key: Key(event.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
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
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete')),
                      ],
                    ),
                  ) ?? false;
                },
                onDismissed: (direction) {
                  setState(() { widget.eventHistory.removeAt(actualIndex); });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event deleted permanently'), backgroundColor: Colors.red));
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _showRestoreDialog(event),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _buildImageWidget(event),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(event.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(children: [
                                if (event.type != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                                      const Icon(Icons.category, size: 14, color: Color(0xff1676C4)),
                                      const SizedBox(width: 4),
                                      Text(event.type!, style: const TextStyle(fontSize: 12, color: Color(0xff1676C4), fontWeight: FontWeight.w500)),
                                    ]),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                if (event.mode != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.purple[50], borderRadius: BorderRadius.circular(6)),
                                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                                      Icon(event.mode == 'Online' ? Icons.computer : event.mode == 'Onsite' ? Icons.location_on : Icons.hub, size: 14, color: Colors.purple[700]),
                                      const SizedBox(width: 4),
                                      Text(event.mode!, style: TextStyle(fontSize: 12, color: Colors.purple[700], fontWeight: FontWeight.w500)),
                                    ]),
                                  ),
                              ]),
                            ),
                            const SizedBox(height: 6),
                            Row(children: [
                              Icon(Icons.access_time, size: 14, color: Colors.red[400]),
                              const SizedBox(width: 4),
                              Text('Recently deleted', style: TextStyle(fontSize: 12, color: Colors.red[600], fontWeight: FontWeight.w500)),
                            ]),
                          ])),
                        ]),
                        const Padding(padding: EdgeInsets.only(top: 12), child: Divider(height: 1, thickness: 1)),
                        Row(children: [
                          Expanded(child: TextButton.icon(
                            onPressed: () => _showRestoreDialog(event),
                            icon: const Icon(Icons.restore, color: Colors.green, size: 20),
                            label: const Text('Restore', style: TextStyle(color: Colors.green)),
                            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                          )),
                          Container(width: 1, height: 30, color: Colors.grey[300]),
                          Expanded(child: TextButton.icon(
                            onPressed: () => _showDeletePermanentlyDialog(event, actualIndex),
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