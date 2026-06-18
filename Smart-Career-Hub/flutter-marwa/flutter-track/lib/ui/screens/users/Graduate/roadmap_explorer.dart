import 'package:flutter/material.dart';

class RoadmapExplorer extends StatefulWidget {
  const RoadmapExplorer({super.key});

  @override
  State<RoadmapExplorer> createState() => _RoadmapExplorerState();
}

class _RoadmapExplorerState extends State<RoadmapExplorer> {
  int _selectedIndex = 1;
  static const Color primaryBlue = Color(0xff1676C4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Roadmap Explorer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Explore company roadmaps and advance your career',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search roadmaps by title or field...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon:
                      Icon(Icons.search, color: Colors.grey, size: 22),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Roadmaps',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRoadmapCard(
                      title: 'Mobile App Development with Flutter',
                      category: 'Mobile',
                      description:
                          'Build beautiful cross-platform mobile apps with Flutter and Dart',
                      difficulty: 'Beginner',
                      duration: '16 weeks',
                      rating: 4.8,
                      enrolled: 1250,
                      image: Icons.phone_iphone,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    _buildRoadmapCard(
                      title: 'Web Development Roadmap',
                      category: 'Web',
                      description:
                          'Master frontend and backend technologies for web development',
                      difficulty: 'Intermediate',
                      duration: '20 weeks',
                      rating: 4.6,
                      enrolled: 980,
                      image: Icons.language,
                      color: Colors.purple,
                    ),
                    const SizedBox(height: 16),
                    _buildRoadmapCard(
                      title: 'Data Science & Analytics',
                      category: 'Data',
                      description:
                          'Learn data analysis, visualization, and machine learning',
                      difficulty: 'Advanced',
                      duration: '24 weeks',
                      rating: 4.9,
                      enrolled: 750,
                      image: Icons.analytics,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _buildRoadmapCard(
                      title: 'Cloud Computing with AWS',
                      category: 'Cloud',
                      description:
                          'Deploy and manage applications on Amazon Web Services',
                      difficulty: 'Intermediate',
                      duration: '18 weeks',
                      rating: 4.7,
                      enrolled: 650,
                      image: Icons.cloud,
                      color: Colors.orange,
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

  Widget _buildRoadmapCard({
    required String title,
    required String category,
    required String description,
    required String difficulty,
    required String duration,
    required double rating,
    required int enrolled,
    required IconData image,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(image, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ],
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
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoChip(difficulty),
                    _buildInfoChip(duration),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '$rating',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.people_outline, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      '$enrolled enrolled',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: TextButton(
              onPressed: () {
                print('Join Roadmap: $title');
              },
              child: const Text(
                'Join Roadmap',
                style: TextStyle(
                  color: Color(0xff1676C4),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
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
          color: isSelected ? primaryBlue : Colors.transparent,
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
class GraduateRoadmapExplorer extends RoadmapExplorer {
  const GraduateRoadmapExplorer({super.key});
}
