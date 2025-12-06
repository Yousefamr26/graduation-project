import 'package:flutter/material.dart';

class WorkshopAnalytics extends StatelessWidget {
  final Map<String, dynamic> workshop;

  const WorkshopAnalytics({required this.workshop, super.key});

  @override
  Widget build(BuildContext context) {
    final videosCount = (workshop["videos"] ?? []).length;
    final quizzesCount = (workshop["quizzes"] ?? []).length;
    final materialsCount = (workshop["materials"] ?? []).length;
    final activitiesCount = (workshop["activities"] ?? []).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Analytics",
          style: TextStyle(color: Colors.white),
        ),
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
                "${workshop['title'] ?? ''}",
                style: TextStyle(
                  color: Color(0xff1893ff),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildStatCard("Total Videos", videosCount),
            _buildStatCard("Total Quizzes", quizzesCount),
            _buildStatCard("Total Materials", materialsCount),
            _buildStatCard("Total Activities", activitiesCount),
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
          Text(
            value.toString(),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
