import 'package:flutter/material.dart';
// import 'Graduate data store.dart'; // استبدل بـ data store الخاص بك

class GraduateHomeScreen extends StatefulWidget {
  const GraduateHomeScreen({super.key});

  @override
  State<GraduateHomeScreen> createState() => _GraduateHomeScreenState();
}

class _GraduateHomeScreenState extends State<GraduateHomeScreen> {
  static const Color kPrimary = Color(0xff1676C4);
  static const Color kPrimaryDark = Color(0xff0d5fa3);
  static const Color kBg = Color(0xffF0F9FF);

  int _selectedIndex = 0;

  // ───── بيانات الخريج ─────
  final String graduateName = 'Ahmed Mohamed';
  final String major = 'Computer Science';
  final String university = 'Cairo University';
  final String graduationYear = '2024';

  // ───── بيانات وهمية ─────
  final List<Map<String, String>> jobApplications = [
    {
      'title': 'Flutter Developer',
      'company': 'Tech Corp',
      'date': '10 May 2026',
      'status': 'Under Review',
    },
    {
      'title': 'Mobile Developer',
      'company': 'StartupX',
      'date': '08 May 2026',
      'status': 'Accepted',
    },
  ];

  final List<Map<String, String>> interviews = [
    {
      'title': 'Technical Interview',
      'company': 'Tech Corp',
      'date': '15 May 2026',
      'time': '10:00 AM',
    },
  ];

  final List<Map<String, String>> opportunities = [];

  // ───────────────── Coming Soon ─────────────────

  void showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming Soon')),
    );
  }

  // ───────────────── Status Badge ─────────────────

  Widget _statusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'accepted':
        bgColor = const Color(0xffDCFCE7);
        textColor = const Color(0xff16A34A);
        break;
      case 'rejected':
        bgColor = const Color(0xffFEE2E2);
        textColor = const Color(0xffDC2626);
        break;
      default:
        bgColor = const Color(0xffFEF9C3);
        textColor = const Color(0xffCA8A04);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  // ───────────────── Drawer ─────────────────

  Widget _buildDrawer() {
    final drawerItems = [
      {'icon': Icons.calendar_today_outlined, 'label': 'Calendar'},
      {'icon': Icons.event_outlined, 'label': 'Events'},
      {'icon': Icons.handyman_outlined, 'label': 'Workshops'},
      {'icon': Icons.work_outline, 'label': 'Job Board'},
      {'icon': Icons.description_outlined, 'label': 'My CV'},
      {'icon': Icons.lightbulb_outline, 'label': 'Career Tips'},
      {'icon': Icons.message_outlined, 'label': 'Message HR'},
      {'icon': Icons.settings_outlined, 'label': 'Settings'},
    ];

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Logo ──
            Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPrimary, kPrimaryDark],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.hub_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Graduate Career Hub',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Graduate Mini Profile ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: kPrimary.withOpacity(0.15),
                    child: const Icon(Icons.person, color: kPrimary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          graduateName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          major,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(),

            // ── Menu Items ──
            Expanded(
              child: ListView(
                children: [
                  ...drawerItems.map(
                    (item) => ListTile(
                      leading: Icon(item['icon'] as IconData, color: kPrimary),
                      title: Text(item['label'] as String),
                      onTap: () {
                        Navigator.pop(context);
                        showComingSoon();
                      },
                    ),
                  ),

                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/chooseUser',
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────── AppBar ─────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: kPrimary,
      elevation: 0,
      leading: Builder(
        builder: (ctx) => GestureDetector(
          onTap: () => Scaffold.of(ctx).openDrawer(),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.25),
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ),
      ),
      title: const Text(
        'Graduate Career Hub',
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: showComingSoon,
        ),
      ],
    );
  }

  // ───────────────── Section Header ─────────────────

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: showComingSoon,
            child: const Text(
              'See All',
              style: TextStyle(color: kPrimary),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── Bottom Nav ─────────────────

  Widget _buildBottomNav() {
    final items = [
      Icons.home_rounded,
      Icons.work_outline_rounded,
      Icons.description_outlined,
      Icons.bar_chart_rounded,
      Icons.person_outline_rounded,
    ];

    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: kPrimary,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() => _selectedIndex = index);
        if (index != 0) showComingSoon();
      },
      items: items
          .map(
            (icon) => BottomNavigationBarItem(
              icon: Icon(icon),
              label: '',
            ),
          )
          .toList(),
    );
  }

  // ───────────────── Empty State ─────────────────

  Widget _emptyState(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ───────────────── Job Application Card ─────────────────

  Widget _applicationCard(Map<String, String> app) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.work, color: kPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app['title']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      app['company']!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(app['status']!),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Applied: ${app['date']}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────── Interview Card ─────────────────

  Widget _interviewCard(Map<String, String> interview) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xffEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  interview['date']!.split(' ')[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: kPrimary,
                  ),
                ),
                Text(
                  interview['date']!.split(' ')[1],
                  style: const TextStyle(fontSize: 10, color: kPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  interview['title']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  interview['company']!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 12, color: kPrimary),
                const SizedBox(width: 4),
                Text(
                  interview['time']!,
                  style: const TextStyle(fontSize: 11, color: kPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── Build ─────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ───── Profile / Welcome Banner ─────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimary, kPrimaryDark],
                ),
              ),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, $graduateName 👋',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$major • $university',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Class of $graduationYear',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Edit profile
                  IconButton(
                    onPressed: showComingSoon,
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // ───── Stats Row ─────
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statItem('${jobApplications.length}', 'Applications'),
                  _divider(),
                  _statItem('${interviews.length}', 'Interviews'),
                  _divider(),
                  _statItem('0', 'Offers'),
                ],
              ),
            ),

            // ───── Job Applications ─────
            _sectionHeader('My Applications'),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: jobApplications.isEmpty
                  ? _emptyState('No applications yet', Icons.work_outline)
                  : Column(
                      children: jobApplications
                          .map((app) => _applicationCard(app))
                          .toList(),
                    ),
            ),

            // ───── Interviews ─────
            _sectionHeader('My Interviews'),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: interviews.isEmpty
                  ? _emptyState('No interviews scheduled', Icons.event_outlined)
                  : Column(
                      children: interviews
                          .map((i) => _interviewCard(i))
                          .toList(),
                    ),
            ),

            // ───── Opportunities ─────
            _sectionHeader('Opportunities For You'),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: opportunities.isEmpty
                  ? _emptyState(
                      'No opportunities yet',
                      Icons.lightbulb_outline,
                    )
                  : const SizedBox(),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ───────────────── Helpers ─────────────────

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 36, color: Colors.grey[200]);
  }
}