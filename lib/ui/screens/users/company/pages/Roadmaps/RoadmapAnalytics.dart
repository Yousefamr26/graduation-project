import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../widgets/common/timeline_row_widget.dart';

class RoadmapAnalytics extends StatelessWidget {
  final Map<String, dynamic> roadmap;

  const RoadmapAnalytics({required this.roadmap, super.key});

  int _calculateTotalPoints() {
    int total = 0;

    final skills = roadmap["skills"] ?? [];
    for (var skill in skills) {
      total += _safeToInt(skill['points']);
    }

    final learningMaterials = roadmap["learningMaterials"] ?? [];
    for (var learningMaterial in learningMaterials) {
      total += _safeToInt(learningMaterial['points']);
    }

    final projects = roadmap["projects"] ?? [];
    for (var project in projects) {
      total += _safeToInt(project['points']);
    }

    final quizzes = roadmap["quizzes"] ?? [];
    for (var quiz in quizzes) {
      total += _safeToInt(quiz['points']);
    }

    return total;
  }

  int _calculateTotalQuestions() {
    int total = 0;
    final quizzes = roadmap["quizzes"] ?? [];
    for (var quiz in quizzes) {
      final questions = quiz['questions'] ?? [];
      if (questions is List) {
        total += questions.length;
      }
    }
    return total;
  }

  String _calculateDuration() {
    if (roadmap['startDate'] == null || roadmap['endDate'] == null) {
      return 'Not set';
    }

    try {
      DateTime start = DateFormat('yyyy-MM-dd').parse(roadmap['startDate']);
      DateTime end = DateFormat('yyyy-MM-dd').parse(roadmap['endDate']);
      int days = end.difference(start).inDays;

      if (days == 0) {
        return 'Same day';
      } else if (days < 7) {
        return '$days ${days == 1 ? "day" : "days"}';
      } else if (days < 30) {
        int weeks = (days / 7).ceil();
        return '$weeks ${weeks == 1 ? "week" : "weeks"}';
      } else {
        int months = (days / 30).ceil();
        return '$months ${months == 1 ? "month" : "months"}';
      }
    } catch (e) {
      return 'Invalid dates';
    }
  }

  Map<String, int> _getSkillsBreakdown() {
    Map<String, int> breakdown = {
      'Beginner': 0,
      'Intermediate': 0,
      'Advanced': 0,
    };

    final skills = roadmap["skills"] ?? [];
    for (var skill in skills) {
      String level = skill['level'] ?? 'Beginner';
      breakdown[level] = (breakdown[level] ?? 0) + 1;
    }

    return breakdown;
  }

  Map<String, int> _getProjectsDifficulty() {
    Map<String, int> difficulty = {
      'Easy': 0,
      'Medium': 0,
      'Hard': 0,
    };

    final projects = roadmap["projects"] ?? [];
    for (var project in projects) {
      String diff = project['difficulty'] ?? 'Easy';
      difficulty[diff] = (difficulty[diff] ?? 0) + 1;
    }

    return difficulty;
  }

  int _safeToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Not set';

    try {
      DateTime date;
      if (dateStr.contains('T')) {
        date = DateTime.parse(dateStr);
      } else {
        date = DateFormat('yyyy-MM-dd').parse(dateStr);
      }
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final videosCount = (roadmap["learningMaterials"] ?? []).length;
    final materialsCount = (roadmap["materials"] ?? []).length;
    final quizzesCount = (roadmap["quizzes"] ?? []).length;
    final skillsCount = (roadmap["skills"] ?? []).length;
    final projectsCount = (roadmap["projects"] ?? []).length;
    final totalPoints = _calculateTotalPoints();
    final totalQuestions = _calculateTotalQuestions();
    final duration = _calculateDuration();
    final skillsBreakdown = _getSkillsBreakdown();
    final projectsDifficulty = _getProjectsDifficulty();

    // ✅ Pricing data
    final bool isFree = roadmap['isFree'] ?? true;
    final double? price = roadmap['price'] != null
        ? (roadmap['price'] as num).toDouble()
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Analytics",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Color(0xff1676C4),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff1676C4), Color(0xff0d7ce8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  Icon(Icons.map, size: 48, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    roadmap['title'] ?? 'Roadmap',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      roadmap['status'] ?? 'Draft',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Cards
                  _buildSectionTitle("Overview", Icons.dashboard),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOverviewCard(
                          "Total Points",
                          totalPoints.toString(),
                          Icons.stars,
                          Colors.amber,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildOverviewCard(
                          "Duration",
                          duration,
                          Icons.schedule,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOverviewCard(
                          "Enrolled",
                          _safeToInt(roadmap['enrolled']).toString(),
                          Icons.people,
                          Colors.green,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildOverviewCard(
                          "Completion",
                          "${_safeToInt(roadmap['completion'])}%",
                          Icons.trending_up,
                          Color(0xff1676C4),
                        ),
                      ),
                    ],
                  ),

                  // ✅ Pricing Card
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isFree
                            ? [Colors.green[400]!, Colors.green[600]!]
                            : [Colors.amber[400]!, Colors.amber[700]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (isFree ? Colors.green : Colors.amber).withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFree ? Icons.stars : Icons.attach_money,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pricing',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                isFree
                                    ? 'Free'
                                    : '\$${price?.toStringAsFixed(2) ?? '0.00'}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),
                  _buildSectionTitle("Content Statistics", Icons.library_books),
                  SizedBox(height: 12),
                  _buildStatCard(
                    title: "Skills",
                    value: skillsCount,
                    icon: Icons.psychology_outlined,
                    color: Colors.teal,
                  ),
                  _buildStatCard(
                    title: "Videos",
                    value: videosCount,
                    icon: Icons.play_circle_outline,
                    color: Colors.red,
                  ),
                  _buildStatCard(
                    title: "Materials",
                    value: materialsCount,
                    icon: Icons.description_outlined,
                    color: Colors.orange,
                  ),
                  _buildStatCard(
                    title: "Projects",
                    value: projectsCount,
                    icon: Icons.code_outlined,
                    color: Colors.indigo,
                  ),
                  _buildStatCard(
                    title: "Quizzes",
                    value: quizzesCount,
                    icon: Icons.quiz_outlined,
                    color: Colors.purple,
                  ),
                  _buildStatCard(
                    title: "Total Questions",
                    value: totalQuestions,
                    icon: Icons.question_answer_outlined,
                    color: Colors.deepPurple,
                  ),

                  SizedBox(height: 24),

                  if (skillsCount > 0) ...[
                    _buildSectionTitle("Skills Breakdown", Icons.bar_chart),
                    SizedBox(height: 12),
                    _buildBreakdownCard(
                      items: [
                        _BreakdownItem("Beginner", skillsBreakdown['Beginner']!, Colors.green),
                        _BreakdownItem("Intermediate", skillsBreakdown['Intermediate']!, Colors.orange),
                        _BreakdownItem("Advanced", skillsBreakdown['Advanced']!, Colors.red),
                      ],
                      total: skillsCount,
                    ),
                    SizedBox(height: 24),
                  ],

                  if (projectsCount > 0) ...[
                    _buildSectionTitle("Projects Difficulty", Icons.work_outline),
                    SizedBox(height: 12),
                    _buildBreakdownCard(
                      items: [
                        _BreakdownItem("Easy", projectsDifficulty['Easy']!, Colors.green),
                        _BreakdownItem("Medium", projectsDifficulty['Medium']!, Colors.orange),
                        _BreakdownItem("Hard", projectsDifficulty['Hard']!, Colors.red),
                      ],
                      total: projectsCount,
                    ),
                    SizedBox(height: 24),
                  ],

                  // Timeline
                  _buildSectionTitle("Timeline", Icons.calendar_today),
                  SizedBox(height: 12),
                  _buildTimelineCard(),

                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Color(0xff1676C4), size: 24),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard({
    required List<_BreakdownItem> items,
    required int total,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items.map((item) {
          double percentage = total > 0 ? (item.count / total) * 100 : 0;
          return Padding(
            padding: EdgeInsets.only(bottom: item == items.last ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      "${item.count} (${percentage.toStringAsFixed(0)}%)",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: item.color,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(item.color),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TimelineRowWidget(
            label: "Start Date",
            value: _formatDate(roadmap['startDate']),
            icon: Icons.play_arrow,
            color: Colors.green,
          ),
          SizedBox(height: 12),
          Divider(height: 1),
          SizedBox(height: 12),
          TimelineRowWidget(
            label: "End Date",
            value: _formatDate(roadmap['endDate']),
            icon: Icons.flag,
            color: Colors.red,
          ),
          SizedBox(height: 12),
          Divider(height: 1),
          SizedBox(height: 12),
          TimelineRowWidget(
            label: "Created",
            value: _formatDate(roadmap['date']),
            icon: Icons.access_time,
            color: Color(0xff1676C4),
          ),
        ],
      ),
    );
  }
}

class _BreakdownItem {
  final String label;
  final int count;
  final Color color;

  _BreakdownItem(this.label, this.count, this.color);
}