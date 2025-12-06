import 'package:flutter/material.dart';
import 'package:my_flutter_app/ui/screens/users/company/pages/Roadmaps/roadmapHistory.dart';
import 'package:my_flutter_app/ui/screens/users/company/pages/Roadmaps/roadmapdetials.dart';
import '../../../../../widgets/CustomDropdown.dart';
import 'RoadmapAnalytics.dart';
import 'editRoadmap.dart';
import 'dart:io';

class MyRoadmapsScreen extends StatefulWidget {
  const MyRoadmapsScreen({super.key});

  @override
  State<MyRoadmapsScreen> createState() => _MyRoadmapsScreenState();
}

class _MyRoadmapsScreenState extends State<MyRoadmapsScreen> {
  final List<Map<String, dynamic>> roadmaps = [];
  final List<Map<String, dynamic>> roadmapHistory = [];

  String searchText = "";
  String selectedFilter = "All";
  List<Map<String, dynamic>> filteredRoadmaps = [];

  @override
  void initState() {
    super.initState();
    filteredRoadmaps = roadmaps; // أول مرة يعرض كل حاجة
  }

  void applyFilters() {
    setState(() {
      filteredRoadmaps = roadmaps.where((roadmap) {
        final searchLower = searchText.toLowerCase();

        // ---- Title ----
        final matchesTitle = roadmap["title"] != null
            ? roadmap["title"].toString().toLowerCase().contains(searchLower)
            : false;
        // ---- Description ----
        final matchesDescription = roadmap["description"] != null
            ? roadmap["description"].toString().toLowerCase().contains(searchLower)
            : false;
        // ---- Target (List) ----
        final matchesTarget = roadmap["target"] != null
            ? (roadmap["target"] as List)
            .any((t) => t.toString().toLowerCase().contains(searchLower))
            : false;
        // ---- Skills (List) ----
        final matchesSkills = roadmap["skills"] != null
            ? (roadmap["skills"] as List)
            .any((s) => s.toString().toLowerCase().contains(searchLower))
            : false;
        // ---- Projects (List) ----
        final matchesProjects = roadmap["projects"] != null
            ? (roadmap["projects"] as List)
            .any((p) => p.toString().toLowerCase().contains(searchLower))
            : false;
        // ---- Videos (List) ----
        final matchesVideos = roadmap["videos"] != null
            ? (roadmap["videos"] as List)
            .any((v) => v.toString().toLowerCase().contains(searchLower))
            : false;
        // ---- Quizzes (List) ----
        final matchesQuizzes = roadmap["quizzes"] != null
            ? (roadmap["quizzes"] as List)
            .any((q) => q.toString().toLowerCase().contains(searchLower))
            : false;

        // ---- Filter status ----
        final matchesFilter = selectedFilter == "All"
            ? true
            : roadmap["status"] == selectedFilter;

        // ---- رجع true لو اي حاجة matches ----
        return (matchesTitle ||
            matchesDescription ||
            matchesTarget ||
            matchesSkills ||
            matchesProjects ||
            matchesVideos ||
            matchesQuizzes) &&
            matchesFilter;
      }).toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newRoadmap = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditRoadmap(roadmapData: null)),
          );
          if (newRoadmap != null) {
            setState(() {
              roadmaps.add(newRoadmap);
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
                        "My Roadmaps",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Manage your created learning paths",
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
                      builder: (_) => HistoryScreen(roadmapHistory: roadmapHistory),
                    ),
                  );

                  // لو فيه roadmap رجعت، نضيفها للقائمة ونشيلها من التاريخ
                  if (restoredRoadmap != null) {
                    setState(() {
                      roadmaps.add(restoredRoadmap);        // اضيفه لقائمة MyRoadmaps
                      roadmapHistory.remove(restoredRoadmap); // شيله من History
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
                      prefixIcon: const Icon(Icons.search,color: Color(0xff1893ff)),
                      filled: true, // عشان نقدر نحط لون خلفية
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey), // الحدود الزرقاء لما مش focused
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xff1893ff), width: 2), // الحدود الزرقاء لما focused
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
                  width: 160, // أو أي قيمة تكفي عشان الكلمة كلها تظهر
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
              itemCount: filteredRoadmaps.length,
              itemBuilder: (context, index) {
                final item = filteredRoadmaps[index];

                Widget imageWidget;
                if (item["coverImage"] != null && item["coverImage"].isNotEmpty) {
                  if (item["coverImage"].startsWith("http")) {
                    imageWidget = Image.network(
                      item["coverImage"],
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    );
                  } else {
                    imageWidget = Image.file(
                      File(item["coverImage"]),
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    );
                  }
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
                        borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                        child: imageWidget,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["title"],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Description: ${item['description']}",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Created: ${item['date']}",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Target: ${item['target'].join(", ")}",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: item["status"] == "Published"
                                    ? Colors.green.withOpacity(0.15)
                                    : Colors.orange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item["status"],
                                style: TextStyle(
                                  color: item["status"] == "Published"
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.group, size: 20),
                                    const SizedBox(width: 4),
                                    Text("Enrolled: ${item['enrolled']}"),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.show_chart, size: 20),
                                    const SizedBox(width: 4),
                                    Text("Completion: ${item['completion']}%"),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _actionBtn(Icons.edit, "Edit",
                                    color: const Color(0xff1893ff), onTap: () async {
                                      final updatedRoadmap = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditRoadmap(
                                            roadmapData: item,
                                          ),
                                        ),
                                      );
                                      if (updatedRoadmap != null) {
                                        setState(() {
                                          roadmaps[index] = updatedRoadmap;
                                          applyFilters();
                                        });
                                      }
                                    }),
                                _actionBtn(
                                  Icons.delete,
                                  "Delete",
                                  color: Colors.red,
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: Text("Delete Roadmap"),
                                        content: Text("Are you sure you want to delete this roadmap?"),
                                        actions: [
                                          TextButton(
                                            child: Text("Cancel",style: TextStyle(color: Color(0xff1893ff))),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                          TextButton(
                                            child: Text("Delete", style: TextStyle(color: Colors.red)),
                                            onPressed: () {
                                              setState(() {
                                                // أولًا احفظ نسخة في history
                                                roadmapHistory.add(filteredRoadmaps[index]);

                                                // بعدين احذفها من الليست
                                                roadmaps.remove(filteredRoadmaps[index]);
                                                applyFilters(); // لتحديث العرض بعد الحذف
                                              });
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                                _actionBtn(Icons.visibility, "View",
                                    color: Colors.lime[900], onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => RoadmapDetailsPage(roadmap: item,)),
                                      );
                                    }),
                                _actionBtn(Icons.analytics_outlined, "Analytics",
                                    color: Colors.green, onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => RoadmapAnalytics(roadmap: item,)),
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

  Widget _actionBtn(IconData icon, String text,
      {Color? color, VoidCallback? onTap}) {
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
