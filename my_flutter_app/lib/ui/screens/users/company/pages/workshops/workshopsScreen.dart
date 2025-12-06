import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_flutter_app/ui/screens/users/company/pages/workshops/workshopHistory.dart';
import '../../../../../widgets/CustomDropdown.dart';
import 'WorkshopAnalytics.dart';
import 'WorkshopDetailsPage.dart';
import 'editworkshop.dart'; // تم التغيير هنا

class WorkshopsScreen extends StatefulWidget {
  const WorkshopsScreen({super.key});

  @override
  State<WorkshopsScreen> createState() => _WorkshopsScreenState();
}

class _WorkshopsScreenState extends State<WorkshopsScreen> {
  final List<Map<String, dynamic>> workshops = [];
  final List<Map<String, dynamic>> workshopHistory = [];

  String searchText = "";
  String selectedFilter = "All";
  List<Map<String, dynamic>> filteredWorkshops = [];

  @override
  void initState() {
    super.initState();
    filteredWorkshops = workshops;
  }

  void applyFilters() {
    setState(() {
      filteredWorkshops = workshops.where((ws) {
        final searchLower = searchText.toLowerCase();
        final matchesTitle = ws["title"]?.toLowerCase().contains(searchLower) ?? false;
        final matchesDescription = ws["description"]?.toLowerCase().contains(searchLower) ?? false;
        final matchesFilter = selectedFilter == "All" ? true : ws["status"] == selectedFilter;
        return (matchesTitle || matchesDescription) && matchesFilter;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newWorkshop = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => crate_editWorkshop(
                workshopData: null,   // Create Mode
                isEdit: false,
              ),
            ),
          );

          if (newWorkshop != null) {
            setState(() {
              workshops.add(newWorkshop);
              applyFilters();
            });
          }
        },
        backgroundColor: const Color(0xff1893ff),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Column(
        children: [
          // -------- CUSTOM APPBAR --------
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xff1893ff),
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
                    children: const [
                      Text(
                        "My Workshops",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Manage your created workshops",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.history, color: Colors.white),
                      onPressed: () async {
                        // نفتح HistoryScreen وننتظر الرودماب اللي هيرجع
                        final restoredRoadmap = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkshopHistoryScreen(workshopHistory: workshopHistory),
                          ),
                        );

                        // لو فيه roadmap رجعت، نضيفها للقائمة ونشيلها من التاريخ
                        if (restoredRoadmap != null) {
                          setState(() {
                            workshops.add(restoredRoadmap);        // اضيفه لقائمة MyRoadmaps
                            workshopHistory.remove(restoredRoadmap); // شيله من History
                            applyFilters(); // تحديث العرض بعد الإضافة
                          });
                        }
                      },
                    ),

                  ],
                ),
              ),
            ),
          ),

          // -------- SEARCH + FILTER --------
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefixIcon: const Icon(Icons.search, color: Color(0xff1893ff)),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xff1893ff), width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      searchText = value;
                      applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 160,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: CustomDropdown(
                      items: const ["All", "Draft", "Published"],
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
          ),

          // -------- LISTVIEW --------
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredWorkshops.length,
              itemBuilder: (context, index) {
                final item = filteredWorkshops[index];

                Widget imageWidget;
                if (item["coverImagePath"] != null) {
                  imageWidget = File(item["coverImagePath"]).existsSync()
                      ? Image.file(File(item["coverImagePath"]),
                      width: double.infinity, height: 150, fit: BoxFit.cover)
                      : const SizedBox.shrink();
                } else {
                  imageWidget = const SizedBox.shrink();
                }

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        child: imageWidget,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item["title"], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text("Description: ${item['description']}", style: TextStyle(color: Colors.grey[700])),
                            const SizedBox(height: 6),
                            Text("Date: ${item['date']}", style: TextStyle(color: Colors.grey[700])),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: item["status"] == "Published"
                                    ? Colors.green.withOpacity(0.15)
                                    : Colors.orange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(item["status"],
                                  style: TextStyle(
                                      color: item["status"] == "Published" ? Colors.green : Colors.orange,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _actionBtn(Icons.edit, "Edit", color: const Color(0xff1893ff),
                                  onTap: () async {
                                    final updatedWorkshop = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => crate_editWorkshop(
                                          workshopData: workshops[index],  // Edit Mode
                                          isEdit: true,
                                        ),
                                      ),
                                    );

                                    if (updatedWorkshop != null) {
                                      setState(() {
                                        workshops[index] = updatedWorkshop;
                                        applyFilters();
                                      });
                                    }
                                  },
                                ),
                                _actionBtn(Icons.delete, "Delete", color: Colors.red, onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Delete Workshop"),
                                      content: const Text("Are you sure you want to delete this workshop?"),
                                      actions: [
                                        TextButton(
                                          child: const Text("Cancel", style: TextStyle(color: Color(0xff1893ff))),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                        TextButton(
                                          child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                          onPressed: () {
                                            setState(() {
                                              workshopHistory.add(filteredWorkshops[index]);
                                              workshops.remove(filteredWorkshops[index]);
                                              applyFilters();
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                _actionBtn(Icons.visibility, "View", color: Colors.lime[900], onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => WorkshopDetailsPage(workshop: item)),
                                  );
                                }),
                                _actionBtn(Icons.analytics_outlined, "Analytics", color: Colors.green, onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => WorkshopAnalytics(workshop: item)),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String text, {Color? color, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color ?? Colors.black),
          const SizedBox(height: 4),
          Text(text, style: TextStyle(color: color ?? Colors.black)),
        ],
      ),
    );
  }
}
