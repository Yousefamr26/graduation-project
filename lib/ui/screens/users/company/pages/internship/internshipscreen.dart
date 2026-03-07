import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../../../data/models/company/internship-model.dart';
import '../../../../../widgets/common/CustomDropdown.dart';
import '../../../../../widgets/common/action_button.dart';
import 'Internship mock data.dart';
import 'InternshipHistoryScreen.dart';
import 'addnewinternship.dart';
import 'internshipdetails.dart';


class InternshipsScreen extends StatefulWidget {
  const InternshipsScreen({super.key});

  @override
  State<InternshipsScreen> createState() => _InternshipsScreenState();
}

class _InternshipsScreenState extends State<InternshipsScreen> {
  final List<InternshipModel> internships = [];
  final List<InternshipModel> internshipHistory = [];

  String searchText = "";
  String selectedFilter = "All";
  List<InternshipModel> filteredInternships = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInternships();
  }

  // ✅ MOCK: جيب البيانات من الـ static list
  Future<void> _fetchInternships() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    await Future.delayed(const Duration(milliseconds: 400));
    final fetched = InternshipMockData.getInternships();

    // ❌ BACKEND:
    // final fetched = await _internshipRepo.getAllInternships();

    if (!mounted) return;

    final historyIds = internshipHistory.map((i) => i.id).toSet();

    setState(() {
      internships.clear();
      for (var item in fetched) {
        if (!historyIds.contains(item.id)) internships.add(item);
      }
      applyFilters();
      isLoading = false;
    });
  }

  void applyFilters() {
    setState(() {
      filteredInternships = internships.where((internship) {
        if (selectedFilter != "All" && internship.status != selectedFilter) return false;
        if (searchText.isEmpty) return true;
        return _matchesSearch(internship, searchText.toLowerCase());
      }).toList();
    });
  }

  bool _matchesSearch(InternshipModel internship, String searchLower) {
    if (internship.title.toLowerCase().contains(searchLower)) return true;
    if (internship.description.toLowerCase().contains(searchLower)) return true;
    if (internship.companyName?.toLowerCase().contains(searchLower) ?? false) return true;
    if (internship.type.toLowerCase().contains(searchLower)) return true;
    if (internship.duration.toLowerCase().contains(searchLower)) return true;
    if (internship.location?.toLowerCase().contains(searchLower) ?? false) return true;
    return false;
  }

  void _deleteInternship(int index) {
    final internshipToDelete = filteredInternships[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 8),
            Text("Delete Internship"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Are you sure you want to delete this internship?"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(
                internshipToDelete.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
            child: const Text("Cancel", style: TextStyle(color: Color(0xff1676C4))),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _performDelete(internshipToDelete);
            },
            icon: const Icon(Icons.delete),
            label: const Text("Delete"),
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

  void _performDelete(InternshipModel internship) {
    setState(() {
      internshipHistory.add(internship);
      internships.remove(internship);
      applyFilters();
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Internship moved to History'),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              final lastDeleted = internshipHistory.removeLast();
              internships.add(lastDeleted);
              applyFilters();
            });
          },
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildLogoWidget(InternshipModel internship) {
    if (internship.logoPath == null || internship.logoPath!.isEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xff1676C4).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.school, color: Color(0xff1676C4), size: 30),
      );
    }
    if (internship.logoPath!.startsWith("http")) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(internship.logoPath!, width: 60, height: 60, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 30))),
      );
    }
    if (File(internship.logoPath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(File(internship.logoPath!), width: 60, height: 60, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 30))),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newInternship = await Navigator.push<InternshipModel>(
            context,
            MaterialPageRoute(builder: (_) => const CreateEditInternshipScreen()),
          );
          if (newInternship != null && mounted) {
            // ✅ MOCK: الـ CreateEditInternshipScreen حط في الـ static list مسبقاً
            // بس نعمل fetch عشان الـ UI يتحدث
            await _fetchInternships();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Internship created successfully!'), backgroundColor: Colors.green),
              );
            }
          }
        },
        backgroundColor: const Color(0xff1676C4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [_buildAppBar(), _buildSearchAndFilter(), _buildInternshipsList()],
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
                Text("My Internships",
                    style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500)),
                SizedBox(height: 4),
                Text("Manage your internship postings",
                    style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w300)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _fetchInternships,
                tooltip: 'Refresh',
              ),
              IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.history, color: Colors.white),
                    if (internshipHistory.isNotEmpty)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Center(
                            child: Text(
                              '${internshipHistory.length > 99 ? '99+' : internshipHistory.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () async {
                  final restoredInternship = await Navigator.push<InternshipModel>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InternshipHistoryScreen(internshipHistory: internshipHistory),
                    ),
                  );
                  if (restoredInternship != null && mounted) {
                    setState(() {
                      internships.add(restoredInternship);
                      internshipHistory.remove(restoredInternship);
                      applyFilters();
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Internship restored successfully!'), backgroundColor: Colors.green),
                      );
                    }
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
                hintText: "Search internships...",
                prefixIcon: const Icon(Icons.search, color: Color(0xff1676C4)),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xff1676C4), width: 2)),
              ),
              onChanged: (value) {
                setState(() { searchText = value; applyFilters(); });
              },
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 160,
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: CustomDropdown(
                items: const ["All", "Draft", "Published", "Closed"],
                value: selectedFilter,
                onChanged: (value) {
                  setState(() { selectedFilter = value!; applyFilters(); });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInternshipsList() {
    return Expanded(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredInternships.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(searchText.isEmpty ? "No internships yet" : "No internships found",
                style: TextStyle(fontSize: 18, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text(
              searchText.isEmpty ? "Create your first internship posting!" : "Try a different search",
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchInternships,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredInternships.length,
          itemBuilder: (context, index) => _buildInternshipCard(index),
        ),
      ),
    );
  }

  Widget _buildInternshipCard(int index) {
    final internship = filteredInternships[index];

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo and Title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogoWidget(internship),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(internship.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      if (internship.companyName != null && internship.companyName!.isNotEmpty)
                        Text(internship.companyName!,
                            style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            internship.type == 'Remote 🌐' ? Icons.home_work
                                : internship.type == 'On-site 🏢' ? Icons.location_on : Icons.hub,
                            size: 16, color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(internship.type, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Duration and Payment Status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: const Color(0xff1676C4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6)),
                  child: Row(children: [
                    const Icon(Icons.schedule, size: 16, color: Color(0xff1676C4)),
                    const SizedBox(width: 4),
                    Text(internship.duration,
                        style: const TextStyle(color: Color(0xff1676C4), fontWeight: FontWeight.w600, fontSize: 12)),
                  ]),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: internship.isPaid ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6)),
                  child: Row(children: [
                    Icon(internship.isPaid ? Icons.attach_money : Icons.money_off,
                        size: 16, color: internship.isPaid ? Colors.green[700] : Colors.grey[700]),
                    const SizedBox(width: 4),
                    Text(internship.isPaid ? "Paid" : "Unpaid",
                        style: TextStyle(
                            color: internship.isPaid ? Colors.green[700] : Colors.grey[700],
                            fontWeight: FontWeight.w600, fontSize: 12)),
                  ]),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(internship.description,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                maxLines: 2, overflow: TextOverflow.ellipsis),

            const SizedBox(height: 12),

            // Status and Stats
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: internship.status == "Published"
                        ? Colors.green.withOpacity(0.15)
                        : internship.status == "Closed"
                        ? Colors.grey.withOpacity(0.15)
                        : Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    internship.status,
                    style: TextStyle(
                      color: internship.status == "Published"
                          ? Colors.green
                          : internship.status == "Closed" ? Colors.grey[700] : Colors.orange,
                      fontWeight: FontWeight.bold, fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.people, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text("${internship.applicantsCount} applicants",
                    style: TextStyle(fontSize: 13, color: Colors.grey[700])),
              ],
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ActionButton(
                  icon: Icons.info_outline,
                  text: "Details",
                  color: Colors.green,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => InternshipDetailsScreen(internship: internship))),
                ),
                ActionButton(
                  icon: Icons.edit,
                  text: "Edit",
                  color: const Color(0xff1676C4),
                  onTap: () async {
                    final updatedInternship = await Navigator.push<InternshipModel>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateEditInternshipScreen(internship: internship),
                      ),
                    );
                    if (updatedInternship != null && mounted) {
                      // ✅ MOCK: الـ CreateEditInternshipScreen حدّث الـ static list مسبقاً
                      // بس نعمل fetch عشان الـ UI يتحدث
                      await _fetchInternships();
                    }
                  },
                ),
                ActionButton(
                  icon: Icons.delete,
                  text: "Delete",
                  color: Colors.red,
                  onTap: () => _deleteInternship(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}