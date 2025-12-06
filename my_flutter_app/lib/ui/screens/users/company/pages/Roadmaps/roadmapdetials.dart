import 'dart:io';
import 'package:flutter/material.dart';

class RoadmapDetailsPage extends StatelessWidget {
  final Map<String, dynamic> roadmap;

  const RoadmapDetailsPage({Key? key, required this.roadmap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(roadmap['title'] ?? "Roadmap Details",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff1893ff),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- Cover Image ----------------
            if (roadmap['coverImage'] != null && roadmap['coverImage'].isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: roadmap['coverImage'].startsWith("http")
                    ? Image.network(
                  roadmap['coverImage'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                )
                    : Image.file(
                  File(roadmap['coverImage']),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 16),

            // ---------------- Title & Description ----------------
            Text(
              roadmap['title'] ?? "No Title",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              roadmap['description'] ?? "No Description",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // ---------------- Target & Status ----------------
            Text(
              "Target Role: ${roadmap['target']?.join(', ') ?? "N/A"}",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            Text(
              "Status: ${roadmap['status'] ?? "N/A"}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: roadmap['status'] == "Published" ? Colors.green : Colors.orange,
              ),
            ),
            SizedBox(height: 16),

            // ---------------- Skills ----------------
            if (roadmap['skills'] != null && (roadmap['skills'] as List).isNotEmpty) ...[
              Text("Skills", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...List.generate(roadmap['skills'].length, (index) {
                final skill = roadmap['skills'][index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(skill['name'] ?? ""),
                  subtitle: Text(
                    "Level: ${skill['level'] ?? "N/A"} | Points: ${skill['points'] ?? 0}",
                  ),
                );
              }),
              SizedBox(height: 16),
            ],

            // ---------------- Videos ----------------
            if (roadmap['videos'] != null && (roadmap['videos'] as List).isNotEmpty) ...[
              Text("Videos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...List.generate(roadmap['videos'].length, (index) {
                final video = roadmap['videos'][index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(video['title'] ?? ""),
                  subtitle: Text("Points: ${video['points'] ?? 0}"),
                  trailing: video['file'] != null
                      ? Icon(Icons.play_circle_fill, color: Colors.blue)
                      : null,
                  onTap: () {
                    if (video['file'] != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Video file: ${video['file']}")),
                      );
                    }
                  },
                );
              }),
              SizedBox(height: 16),
            ],

            // ---------------- Projects ----------------
            if (roadmap['projects'] != null && (roadmap['projects'] as List).isNotEmpty) ...[
              Text("Projects", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...List.generate(roadmap['projects'].length, (index) {
                final project = roadmap['projects'][index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(project['title'] ?? ""),
                  subtitle: Text(
                      "Difficulty: ${project['difficulty'] ?? "N/A"} | Points: ${project['points'] ?? 0}"),
                );
              }),
              SizedBox(height: 16),
            ],

            // ---------------- Quizzes ----------------
            if (roadmap['quizzes'] != null && (roadmap['quizzes'] as List).isNotEmpty) ...[
              Text("Quizzes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),

              ...List.generate(roadmap['quizzes'].length, (index) {
                final quiz = roadmap['quizzes'][index];

                return Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz['title'] ??
                            quiz['titleController']?.text ??
                            "",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),

                      SizedBox(height: 4),
                      Text(
                        "Type: ${quiz['type'] ?? "N/A"} | Points: ${quiz['points'] ?? 0}",
                        style: TextStyle(color: Colors.grey[700]),
                      ),

                      SizedBox(height: 6),

                      // عرض ملف الأسئلة لو موجود
                      if (quiz['questionsFile'] != null)
                        Row(
                          children: [
                            Icon(Icons.attach_file, color: Colors.blue),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                quiz['questionsFile']
                                    .toString()
                                    .split("/")
                                    .last,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
