import 'dart:io';
import 'package:flutter/material.dart';

class WorkshopDetailsPage extends StatelessWidget {
  final Map<String, dynamic> workshop;

  const WorkshopDetailsPage({Key? key, required this.workshop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workshop['title'] ?? "Workshop Details", style: TextStyle(color: Colors.white)),
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
            if (workshop['coverImagePath'] != null && workshop['coverImagePath'].isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: workshop['coverImagePath'].startsWith("http")
                    ? Image.network(
                  workshop['coverImagePath'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                )
                    : Image.file(
                  File(workshop['coverImagePath']),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 16),

            // ---------------- Title & Description ----------------
            Text(
              workshop['title'] ?? "No Title",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              workshop['description'] ?? "No Description",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // ---------------- University & Location ----------------
            Text(
              "University: ${workshop['university'] ?? "N/A"}",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 4),
            Text(
              "Location: ${workshop['location'] ?? "N/A"}",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 16),

            // ---------------- Dates & Times ----------------
            Text(
              "Start: ${workshop['startDate'] ?? "N/A"} | ${workshop['startTime'] ?? "N/A"}",
              style: TextStyle(fontSize: 14),
            ),
            Text(
              "End: ${workshop['endDate'] ?? "N/A"} | ${workshop['endTime'] ?? "N/A"}",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),

            // ---------------- Capacity & Type ----------------
            Text("Capacity: ${workshop['capacity'] ?? "N/A"}"),
            Text("Type: ${workshop['workshopType'] ?? "N/A"}"),
            SizedBox(height: 16),

            // ---------------- Materials ----------------
            if (workshop['materials'] != null && (workshop['materials'] as List).isNotEmpty) ...[
              Text("Materials", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...List.generate(workshop['materials'].length, (i) {
                final m = workshop['materials'][i];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(m['title'] ?? ""),
                  subtitle: Text("Points: ${m['points'] ?? 0}"),
                  trailing: m['filePath'] != null ? Icon(Icons.attach_file, color: Colors.blue) : null,
                );
              }),
              SizedBox(height: 16),
            ],

            // ---------------- Activities ----------------
            if (workshop['activities'] != null && (workshop['activities'] as List).isNotEmpty) ...[
              Text("Activities", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...List.generate(workshop['activities'].length, (i) {
                final a = workshop['activities'][i];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(a['title'] ?? ""),
                  subtitle: Text("Difficulty: ${a['difficulty'] ?? "N/A"} | Points: ${a['points'] ?? 0}"),
                );
              }),
              SizedBox(height: 16),
            ],

            // ---------------- Registration Requirements ----------------
            if (workshop['requireCv'] != null || workshop['requireRoadmap'] != null) ...[
              Text("Registration Requirements", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              if (workshop['requireCv'] == true) Text("Requires CV"),
              if (workshop['requireRoadmap'] == true) Text("Requires Roadmap"),
              if (workshop['minProgress'] != null) Text("Minimum Progress: ${workshop['minProgress']}%"),
              SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}
