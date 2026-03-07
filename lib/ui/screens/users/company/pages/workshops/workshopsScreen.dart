import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../../widgets/common/CustomDropdown.dart';
import '../../../../../widgets/common/action_button.dart';
import '../../../university/pages/workshop/WorkshopHistoryScreen.dart';
import 'Workshop mock data.dart';
import 'WorkshopAnalytics.dart';
import 'editworkshop.dart';

class WorkshopsScreen extends StatefulWidget {
  const WorkshopsScreen({super.key});

  @override
  State<WorkshopsScreen> createState() => _WorkshopsScreenState();
}

class _WorkshopsScreenState extends State<WorkshopsScreen> {
  // ─── Loaded from mock data ───────────────────────────────────────────────
  final List<Map<String, dynamic>> workshops =
  workshopMockData.map((e) => Map<String, dynamic>.from(e)).toList();

  final List<Map<String, dynamic>> workshopHistory = [];

  String searchText = "";
  String selectedFilter = "All";
  List<Map<String, dynamic>> filteredWorkshops = [];

  @override
  void initState() {
    super.initState();
    filteredWorkshops = List.from(workshops);
  }

  // ─── Filtering ───────────────────────────────────────────────────────────
  void applyFilters() {
    setState(() {
      filteredWorkshops = workshops.where((workshop) {
        if (selectedFilter != "All" && workshop["status"] != selectedFilter) {
          return false;
        }
        if (searchText.isEmpty) return true;
        return _matchesSearch(workshop, searchText.toLowerCase());
      }).toList();
    });
  }

  bool _matchesSearch(Map<String, dynamic> w, String s) =>
      _contains(w["title"], s) ||
          _contains(w["description"], s) ||
          _contains(w["location"], s);

  bool _contains(dynamic v, String s) =>
      v != null && v.toString().toLowerCase().contains(s);

  // ─── Delete ──────────────────────────────────────────────────────────────
  void _deleteWorkshop(int index) {
    final target = filteredWorkshops[index];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 8),
            Text("Delete Workshop"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Are you sure you want to delete this workshop?"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(
                target['title'] ?? 'No Title',
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            Text("You can restore it from History later.",
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel",
                style: TextStyle(color: Color(0xff1676C4))),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _performDelete(target);
            },
            icon: const Icon(Icons.delete),
            label: const Text("Delete"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  void _performDelete(Map<String, dynamic> workshop) {
    setState(() {
      workshop['deletedAt'] = DateTime.now().toIso8601String();
      workshopHistory.add(workshop);
      workshops.remove(workshop);
      applyFilters();
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Workshop moved to History'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              final last = workshopHistory.removeLast();
              workshops.add(last);
              applyFilters();
            });
          },
        ),
      ),
    );
  }

  // ─── Image / Banner ──────────────────────────────────────────────────────
  Widget _buildBanner(Map<String, dynamic> item) {
    final path = item["coverImagePath"];
    if (path != null && path.toString().isNotEmpty) {
      final f = File(path);
      if (f.existsSync()) {
        return Image.file(f,
            width: double.infinity,
            height: 150,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholderBanner(item));
      }
    }
    return _placeholderBanner(item);
  }

  Widget _placeholderBanner(Map<String, dynamic> item) {
    final isPublished = item["status"] == "Published";
    return Container(
      width: double.infinity,
      height: 110,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPublished
              ? [const Color(0xff1676C4), const Color(0xff42a5f5)]
              : [Colors.orange.shade400, Colors.orange.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event, color: Colors.white, size: 36),
            const SizedBox(height: 4),
            Text(
              item["workshopType"] ?? "",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff1676C4),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const crate_editWorkshop(workshopData: null, isEdit: false),
            ),
          );
          if (result != null && mounted) {
            setState(() {
              workshops.add(result);
              applyFilters();
            });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Workshop created successfully!'),
              backgroundColor: Colors.green,
            ));
          }
        },
      ),
      body: Column(
        children: [
          _buildAppBar(),
          _buildSearchAndFilter(),
          _buildWorkshopList(),
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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("My Workshops",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  "${workshops.length} workshops  •  "
                      "${workshops.where((w) => w['status'] == 'Published').length} published",
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w300),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.history, color: Colors.white),
                    if (workshopHistory.isNotEmpty)
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
                              '${workshopHistory.length > 99 ? '99+' : workshopHistory.length}',
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
                  final restored = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkshopHistoryScreen(
                          workshopHistory: workshopHistory),
                    ),
                  );
                  if (restored != null && mounted) {
                    setState(() {
                      workshops.add(restored);
                      workshopHistory.remove(restored);
                      applyFilters();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Workshop restored successfully!'),
                      backgroundColor: Colors.green,
                    ));
                  }
                },
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
                hintText: "Search workshops...",
                prefixIcon:
                const Icon(Icons.search, color: Color(0xff1676C4)),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                  const BorderSide(color: Color(0xff1676C4), width: 2),
                ),
              ),
              onChanged: (v) {
                setState(() {
                  searchText = v;
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
                items: const ["All", "Draft", "Published"],
                value: selectedFilter,
                onChanged: (v) {
                  setState(() {
                    selectedFilter = v!;
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

  Widget _buildWorkshopList() {
    return Expanded(
      child: filteredWorkshops.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_outlined,
                size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              searchText.isEmpty
                  ? "No workshops yet"
                  : "No workshops found",
              style:
              TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              searchText.isEmpty
                  ? "Tap + to create your first workshop"
                  : "Try a different search",
              style:
              TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredWorkshops.length,
        itemBuilder: (_, i) => _buildWorkshopCard(i),
      ),
    );
  }

  Widget _buildWorkshopCard(int index) {
    final item = filteredWorkshops[index];
    final isPublished = item["status"] == "Published";

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(12)),
            child: _buildBanner(item),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item["title"] ?? "Untitled",
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPublished
                            ? Colors.green.withOpacity(0.15)
                            : Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item["status"] ?? "Draft",
                        style: TextStyle(
                          color:
                          isPublished ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item['description'] ?? 'No description',
                  style:
                  TextStyle(color: Colors.grey[700], fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (item['location'] != null)
                      _infoChip(
                          Icons.location_on, item['location'], Colors.blue),
                    if (item['startDate'] != null)
                      _infoChip(Icons.calendar_today, item['startDate'],
                          Colors.purple),
                    if (item['capacity'] != null)
                      _infoChip(Icons.people,
                          "${item['capacity']} seats", Colors.teal),
                    if (item['university'] != null)
                      _infoChip(Icons.school, item['university'],
                          Colors.indigo),
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
                        final updated =
                        await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => crate_editWorkshop(
                                workshopData: item, isEdit: true),
                          ),
                        );
                        if (updated != null && mounted) {
                          setState(() {
                            final idx = workshops.indexOf(item);
                            if (idx != -1) workshops[idx] = updated;
                            applyFilters();
                          });
                        }
                      },
                    ),
                    ActionButton(
                      icon: Icons.delete,
                      text: "Delete",
                      color: Colors.red,
                      onTap: () => _deleteWorkshop(index),
                    ),
                    ActionButton(
                      icon: Icons.analytics_outlined,
                      text: "Analytics",
                      color: Colors.green,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              WorkshopAnalytics(workshop: item),
                        ),
                      ),
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

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}