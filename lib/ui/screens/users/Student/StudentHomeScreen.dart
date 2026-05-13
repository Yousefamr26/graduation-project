import 'package:flutter/material.dart';
import 'Student data store.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  static const Color kPrimary = Color(0xff1676C4);
  static const Color kPrimaryDark = Color(0xff0d5fa3);
  static const Color kBg = Color(0xffF0F9FF);

  int _selectedIndex = 0;

  final String studentName = 'John Doe';

  final store = StudentDataStore();

  // ───────────────── Coming Soon ─────────────────

  void showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming Soon'),
      ),
    );
  }

  // ───────────────── Drawer ─────────────────

  Widget _buildDrawer() {
    final drawerItems = [
      {'icon': Icons.calendar_today_outlined, 'label': 'Calendar'},
      {'icon': Icons.event_outlined, 'label': 'Events'},
      {'icon': Icons.handyman_outlined, 'label': 'Workshops'},
      {'icon': Icons.work_outline, 'label': 'Internship'},
      {'icon': Icons.settings_outlined, 'label': 'Setting'},
      {'icon': Icons.lightbulb_outline, 'label': 'Career Tips'},
      {'icon': Icons.message_outlined, 'label': 'Message HR'},
    ];

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
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
                  'Smart Career Hub',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Divider(),

            Expanded(
              child: ListView(
                children: [
                  ...drawerItems.map(
                    (item) => ListTile(
                      leading: Icon(
                        item['icon'] as IconData,
                        color: kPrimary,
                      ),
                      title: Text(item['label'] as String),
                      onTap: () {
                        Navigator.pop(context);
                        showComingSoon();
                      },
                    ),
                  ),

                  const Divider(),

                  ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
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
              child: const Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      title: const Text(
        'Smart Career Hub',
        style: TextStyle(color: Colors.white),
      ),
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
      Icons.map_outlined,
      Icons.menu_book_outlined,
      Icons.bar_chart_rounded,
      Icons.person_outline_rounded,
    ];

    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: kPrimary,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });

        if (index != 0) {
          showComingSoon();
        }
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
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
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

            // ───────────────── Welcome ─────────────────

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimary, kPrimaryDark],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, $studentName 👋',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Track your progress and opportunities',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // ───────────────── Roadmaps ─────────────────

            _sectionHeader('My Roadmaps'),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: store.enrolledRoadmaps.isEmpty
                  ? _emptyState(
                      'No roadmaps enrolled yet',
                      Icons.map_outlined,
                    )
                  : Column(
                      children: store.enrolledRoadmaps.map((roadmap) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.map,
                                color: kPrimary,
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Text(
                                  roadmap['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),

            // ───────────────── Events ─────────────────

            _sectionHeader('My Events'),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: store.registeredEvents.isEmpty
                  ? _emptyState(
                      'No events registered yet',
                      Icons.event_outlined,
                    )
                  : Column(
                      children: store.registeredEvents.map((event) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.event,
                                color: kPrimary,
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Text(
                                  event['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),

            // ───────────────── Workshops ─────────────────

            _sectionHeader('My Workshops'),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: store.registeredWorkshops.isEmpty
                  ? _emptyState(
                      'No workshops registered yet',
                      Icons.handyman_outlined,
                    )
                  : Column(
                      children: store.registeredWorkshops.map((workshop) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.handyman,
                                color: kPrimary,
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Text(
                                  workshop['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomNav(),
    );
  }
}

