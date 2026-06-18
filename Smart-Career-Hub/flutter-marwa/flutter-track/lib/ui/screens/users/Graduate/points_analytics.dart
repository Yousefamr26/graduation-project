import 'package:flutter/material.dart';

class PointsAnalytics extends StatefulWidget {
  const PointsAnalytics({super.key});

  @override
  State<PointsAnalytics> createState() => _PointsAnalyticsState();
}

class _PointsAnalyticsState extends State<PointsAnalytics> {
  int _selectedIndex = 3;
  static const Color primaryBlue = Color(0xff1676C4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text(
          'Points & Analytics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.emoji_events,
                              size: 40, color: Colors.amber),
                          const SizedBox(height: 8),
                          const Text(
                            '2450',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Total Points',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(Icons.trending_up,
                              size: 40, color: Colors.green),
                          const SizedBox(height: 8),
                          const Text(
                            '+320',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'This Month',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Smart Points Section
                    _buildSection(
                      title: 'Smart Points',
                      items: [
                        {'name': 'Profile Updates', 'points': '500 pts'},
                        {
                          'name': 'Interview Scheduled',
                          'points': '300 pts'
                        },
                        {'name': 'Job Applied', 'points': '150 pts'},
                        {'name': 'Course Completed', 'points': '400 pts'},
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Achievements
                    const Text(
                      'Achievements',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      child: GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        children: [
                          _buildAchievementCard(
                              Icons.workspace_premium, 'First Interview'),
                          _buildAchievementCard(
                              Icons.check_circle, 'Verified Email'),
                          _buildAchievementCard(
                              Icons.star, 'Top Performer'),
                          _buildAchievementCard(
                              Icons.school, 'Course Master'),
                          _buildAchievementCard(
                              Icons.people, 'Team Player'),
                          _buildAchievementCard(
                              Icons.trending_up, 'Go Getter'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Latest Earned Points
                    _buildSection(
                      title: 'Latest Earned Points',
                      items: [
                        {
                          'activity': 'Completed Flutter Course',
                          'date': 'Oct 15, 2024',
                          'points': '+400'
                        },
                        {
                          'activity': 'Scheduled Interview',
                          'date': 'Oct 12, 2024',
                          'points': '+300'
                        },
                        {
                          'activity': 'Applied to Microsoft',
                          'date': 'Oct 10, 2024',
                          'points': '+150'
                        },
                        {
                          'activity': 'Updated Profile',
                          'date': 'Oct 08, 2024',
                          'points': '+200'
                        },
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Leaderboard
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Leaderboard',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildLeaderboardItem('1', 'Ahmed', 4500),
                          _buildLeaderboardItem('2', 'Fatima', 4200),
                          _buildLeaderboardItem('3', 'Sara', 3950),
                          _buildLeaderboardItem('4', 'Mohamed', 3800),
                          _buildLeaderboardItem('5', 'Noor', 3650),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildSection({required String title, required List<Map> items}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: List.generate(
              items.length,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: index < items.length - 1 ? 12 : 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items[index]['name'] ?? items[index]['activity'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (items[index]['date'] != null)
                            Text(
                              items[index]['date'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      items[index]['points'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: items[index]['points']
                                    ?.toString()
                                    .startsWith('+') ??
                                false
                            ? Colors.green
                            : const Color(0xff1676C4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: Colors.amber),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(String rank, String name, int points) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xff1676C4).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1676C4),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            '$points',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xff1676C4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, 0),
              _buildNavItem(Icons.lightbulb_outline, 1),
              _buildNavItem(Icons.people_outline, 2),
              _buildNavItem(Icons.show_chart, 3),
              _buildNavItem(Icons.person_outline, 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff1676C4) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey,
          size: 24,
        ),
      ),
    );
  }
}

// Alias wrapper for navigation
class GraduatePointsAnalytics extends PointsAnalytics {
  const GraduatePointsAnalytics({super.key});
}

// ─── Real API version helper (called from GraduateHome) ───
// The existing PointsAnalytics screen already has UI, just needs API data
// It uses the same endpoint as Student Points - handled by StudentPointsAnalyticsScreen
// which detects user type from SharedPreferences
