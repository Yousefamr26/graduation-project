import 'dart:io';
import 'package:flutter/material.dart';

class WorkshopHistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> workshopHistory;

  const WorkshopHistoryScreen({Key? key, required this.workshopHistory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Deleted Workshops",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff1893ff),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: workshopHistory.isEmpty
          ? Center(
        child: Text(
          "No deleted workshops yet.",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: workshopHistory.length,
        itemBuilder: (context, index) {
          final workshop = workshopHistory[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: EdgeInsets.all(12),
              title: Text(
                workshop['title'] ?? "No Title",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (workshop['description'] != null)
                    Text(
                      workshop['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: 4),
                  Text(
                    "Location: ${workshop['location'] ?? 'N/A'}",
                    style:
                    TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  if (workshop['deletedAt'] != null)
                    Text(
                      "Deleted at: ${workshop['deletedAt']}",
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                ],
              ),
              leading: workshop['coverImagePath'] != null
                  ? Image.file(
                File(workshop['coverImagePath']),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
                  : Icon(Icons.delete, color: Colors.red),
              trailing: IconButton(
                icon: Icon(Icons.restore, color: Colors.green),
                tooltip: "Restore Workshop",
                onPressed: () {
                  Navigator.pop(context, workshop); // بيرجع العنصر اللي ضغطنا عليه
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
