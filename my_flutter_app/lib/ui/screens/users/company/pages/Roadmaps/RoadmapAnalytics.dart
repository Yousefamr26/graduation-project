import 'package:flutter/material.dart';

class RoadmapAnalytics extends StatelessWidget {
  final Map<String, dynamic> roadmap;

  const RoadmapAnalytics({required this.roadmap, super.key});

  @override
  Widget build(BuildContext context) {
    final videosCount = (roadmap["videos"] ?? []).length;
    final materialsCount = (roadmap["materials"] ?? []).length;
    final quizzesCount = (roadmap["quizzes"] ?? []).length;
    final skillsCount = (roadmap["skills"] ?? []).length;
    final projectsCount = (roadmap["projects"] ?? []).length;

    return Scaffold(
      appBar: AppBar(
         title: Text("Analytics",
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
              child: Text("  ${roadmap['title'] ?? ''}",
                style: TextStyle(color: Color(0xff1893ff),
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            )
            ,
            SizedBox(height: 20,),
            _buildStatCard("Total Videos", videosCount),
            _buildStatCard("Total Materials", materialsCount),
            _buildStatCard("Total Quizzes", quizzesCount),
            _buildStatCard("Total Skills", skillsCount),
            _buildStatCard("Total Projects", projectsCount),

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
          Text(value.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

