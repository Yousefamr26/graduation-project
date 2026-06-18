import 'package:flutter/material.dart';

class CareerTipsScreen extends StatefulWidget {
  const CareerTipsScreen({super.key});
  @override
  State<CareerTipsScreen> createState() => _CareerTipsScreenState();
}

class _CareerTipsScreenState extends State<CareerTipsScreen> {
  static const Color kPrimary = Color(0xff1676C4);
  static const Color kBg = Color(0xffF0F9FF);

  final List<Map<String, dynamic>> _tips = [
    {
      'icon': Icons.description_outlined,
      'iconColor': Color(0xff1676C4),
      'category': 'CV Writing',
      'title': 'Top 5 CV Mistakes to Avoid',
      'description':
          'Learn about the most common mistakes people make on their CVs and how to fix them.',
      'readTime': '3 min read',
    },
    {
      'icon': Icons.record_voice_over_outlined,
      'iconColor': Colors.orange,
      'category': 'Interview Tips',
      'title': 'How to Ace Your First Interview',
      'description':
          'Essential tips and tricks to prepare for and succeed in your first job interview.',
      'readTime': '5 min read',
    },
    {
      'icon': Icons.trending_up,
      'iconColor': Colors.green,
      'category': 'Career Growth',
      'title': 'How to Get Promoted Faster',
      'description':
          'Strategies to stand out in your workplace and advance your career quickly.',
      'readTime': '4 min read',
    },
    {
      'icon': Icons.people_alt_outlined,
      'iconColor': Colors.purple,
      'category': 'Networking',
      'title': 'Building Your Professional Network',
      'description':
          'Discover the best ways to connect with industry professionals and grow your network.',
      'readTime': '6 min read',
    },
    {
      'icon': Icons.computer_outlined,
      'iconColor': Colors.teal,
      'category': 'Tech Skills',
      'title': 'Most In-Demand Tech Skills in 2025',
      'description':
          'A breakdown of the top technical skills employers are looking for this year.',
      'readTime': '7 min read',
    },
    {
      'icon': Icons.self_improvement_outlined,
      'iconColor': Colors.pink,
      'category': 'Soft Skills',
      'title': 'Why Soft Skills Matter as Much as Technical Skills',
      'description':
          'Understand why communication, teamwork, and adaptability are key to career success.',
      'readTime': '4 min read',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Career Tips',
            style: TextStyle(
                color: kPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            child: Text(
              'Expert advice to help you succeed in your career journey',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _tips.length,
              itemBuilder: (_, i) => _tipCard(_tips[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipCard(Map<String, dynamic> tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon box
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (tip['iconColor'] as Color).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(tip['icon'] as IconData,
                color: tip['iconColor'] as Color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tip['category'],
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: tip['iconColor'] as Color)),
                const SizedBox(height: 4),
                Text(tip['title'],
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(tip['description'],
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 13, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(tip['readTime'],
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey[500])),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: [
                          const Text('Read More',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: kPrimary,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios,
                              size: 12, color: kPrimary),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}