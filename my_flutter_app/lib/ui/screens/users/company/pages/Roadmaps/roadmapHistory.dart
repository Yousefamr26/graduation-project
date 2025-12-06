import 'dart:io';
import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> roadmapHistory;

  const HistoryScreen({Key? key, required this.roadmapHistory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Deleted Roadmaps",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff1893ff),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: roadmapHistory.isEmpty
          ? Center(
        child: Text(
          "No deleted roadmaps yet.",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: roadmapHistory.length,
        itemBuilder: (context, index) {
          final roadmap = roadmapHistory[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: EdgeInsets.all(12),
              title: Text(
                roadmap['title'] ?? "No Title",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (roadmap['description'] != null)
                    Text(roadmap['description'],
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4),
                  Text(
                    "Target: ${roadmap['target']?.join(', ') ?? 'N/A'}",
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[700]),
                  ),
                  if (roadmap['deletedAt'] != null)
                    Text(
                      "Deleted at: ${roadmap['deletedAt']}",
                      style: TextStyle(
                          fontSize: 12, color: Colors.red),
                    ),
                ],
              ),
              leading: roadmap['coverImage'] != null
                  ? Image.file(
                File(roadmap['coverImage']),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
                  : Icon(Icons.delete, color: Colors.red),
              trailing: IconButton(
                icon: Icon(Icons.restore, color: Colors.green),
                tooltip: "Restore Roadmap",
                onPressed: () {
                  Navigator.pop(context, roadmap); // ده بيرجع العنصر اللي ضغطنا عليه
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
