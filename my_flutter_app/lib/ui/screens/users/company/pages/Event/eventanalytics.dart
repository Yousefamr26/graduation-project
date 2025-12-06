import 'package:flutter/material.dart';
import '../../../../../../data/models/event-model.dart'; // أضف الـ import

class EventAnalyticsScreen extends StatelessWidget {
  final EventModel event; // غيّر النوع

  const EventAnalyticsScreen({required this.event, super.key});

  @override
  Widget build(BuildContext context) {
    // هنا هتحتاج تتأكد إن الـ EventModel عندك فيه الـ properties دي
    // لو مش موجودة، هتحتاج تضيفها للـ model أو تستخدم قيم افتراضية
    final int attendeesCount = 0; // عدّل حسب الـ model بتاعك
    final int registeredCount = 0; // عدّل حسب الـ model بتاعك
    final int pointsAttendance = event.minPoints.toInt(); // مثال
    final int pointsParticipation = 0; // عدّل حسب الـ model بتاعك

    return Scaffold(
      appBar: AppBar(
        title: Text("Event Analytics", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff1893ff),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                event.title,
                style: TextStyle(
                    color: Color(0xff1893ff),
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            _buildStatCard("Total Attendees", attendeesCount),
            _buildStatCard("Total Registered", registeredCount),
            _buildStatCard("Points for Attendance", pointsAttendance),
            _buildStatCard("Points for Participation", pointsParticipation),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Color(0xff1893ff).withOpacity(0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16)),
          Text(value.toString(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}