import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../../../data/models/event-model.dart'; // أضف الـ import

class EventHistoryScreen extends StatelessWidget {
  final List<EventModel> eventHistory; // غيّر النوع

  const EventHistoryScreen({Key? key, required this.eventHistory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Event History",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff1893ff),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: eventHistory.isEmpty
          ? Center(
        child: Text(
          "No events yet.",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: eventHistory.length,
        itemBuilder: (context, index) {
          final event = eventHistory[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: EdgeInsets.all(12),
              title: Text(
                event.title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Type: ${event.type ?? 'N/A'}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  Text(
                    "Mode: ${event.mode ?? 'N/A'}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
              leading: event.coverImagePath != null && File(event.coverImagePath!).existsSync()
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(event.coverImagePath!),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              )
                  : Icon(Icons.event, color: Colors.grey[700]),
              trailing: IconButton(
                icon: Icon(Icons.restore, color: Colors.green),
                tooltip: "Restore Event",
                onPressed: () {
                  Navigator.pop(context, event);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}