import 'package:SmartCareerHub/ui/screens/users/university/pages/partnerships/partnershipsscreen.dart';
import 'package:SmartCareerHub/ui/screens/users/university/pages/profile/universityprofilescreen.dart';
import 'package:flutter/material.dart';

import '../../../../../data/models/university/dashboardmodel.dart';
import '../../company/pages/Calendar/Calendar.dart';
import '../../company/pages/Event/eventscreen.dart';
import '../../company/pages/workshops/workshopsScreen.dart';
class UniversityDashboard extends StatefulWidget {
  const UniversityDashboard({super.key});

  @override
  State<UniversityDashboard> createState() => _UniversityDashboardState();
}

class _UniversityDashboardState extends State<UniversityDashboard> {
  int _selectedIndex = 0;

  final List<UniversityDashboardCardModel> dashboardCards = [
    UniversityDashboardCardModel(
      icon: Icons.event,
      title: 'Total Events',
      count: '12',
      subtitle: 'This semester',
    ),
    UniversityDashboardCardModel(
      icon: Icons.people,
      title: 'Participants',
      count: '456',
      subtitle: '+32 this week',
    ),
    UniversityDashboardCardModel(
      icon: Icons.handshake,
      title: 'Partnerships',
      count: '8',
      subtitle: 'Active companies',
    ),
    UniversityDashboardCardModel(
      icon: Icons.school,
      title: 'Students',
      count: '1,245',
      subtitle: 'Enrolled',
    ),
    UniversityDashboardCardModel(
      icon: Icons.trending_up,
      title: 'Engagement',
      count: '85%',
      subtitle: '↑ 5% this month',
    ),
    UniversityDashboardCardModel(
      icon: Icons.workspace_premium,
      title: 'Certificates',
      count: '234',
      subtitle: 'Issued total',
    ),
  ];

  final List<UpcomingEventModel> upcomingEvents = [
    UpcomingEventModel(
      name: 'AI & Ethics Workshop',
      type: 'Workshop',
      date: 'Nov 5, 2025',
      participants: 45,
    ),
    UpcomingEventModel(
      name: 'Career Fair 2025',
      type: 'Career Fair',
      date: 'Nov 12, 2025',
      participants: 230,
    ),
    UpcomingEventModel(
      name: 'Tech Talk: Cloud Computing',
      type: 'Seminar',
      date: 'Nov 18, 2025',
      participants: 78,
    ),
  ];

  final List<PartnershipModel> partnerships = [
    PartnershipModel(company: 'TechCorp Solutions', type: 'Technology', status: 'Active'),
    PartnershipModel(company: 'Microsoft', type: 'AI & Cloud', status: 'Active'),
    PartnershipModel(company: 'Orange Digital', type: 'Telecom', status: 'Pending'),
  ];

  final List<TopProgramModel> topPrograms = [
    TopProgramModel(name: 'Computer Science', students: 452, completion: 78),
    TopProgramModel(name: 'Business Administration', students: 389, completion: 82),
    TopProgramModel(name: 'Data Analytics', students: 312, completion: 75),
  ];

  final List<RecentWorkshopModel> recentWorkshops = [
    RecentWorkshopModel(
      name: 'Python for Beginners',
      instructor: 'Dr. Ahmed Hassan',
      date: 'Nov 8, 2025',
    ),
    RecentWorkshopModel(
      name: 'Digital Marketing Essentials',
      instructor: 'Prof. Sara Ibrahim',
      date: 'Nov 15, 2025',
    ),
    RecentWorkshopModel(
      name: 'UI/UX Design Fundamentals',
      instructor: 'Dr. Mariam Ali',
      date: 'Nov 22, 2025',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> _pages() {
    return [
      _buildHomePage(),
      // Placeholder pages - replace with actual screens
      WorkshopsScreen(),
      //EventsScreen(),
      UniversityProfileScreen(),
    ];
  }

  Widget _placeholderPage(String title) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title Page')),
    );
  }

  Widget _buildHomePage() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('University Dashboard'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'EELU - Egyptian E-Learning University\nManage your events, partnerships, and student engagement',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xff1676C4),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xff1676C4),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dashboardCards.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.07,
                      ),
                      itemBuilder: (context, index) {
                        return _universityDashboardCard(dashboardCards[index]);
                      },
                    ),

                    const SizedBox(height: 20),

                    // Upcoming Events
                    _buildSectionHeader('Upcoming Events', 'View All', () {}),
                    const SizedBox(height: 12),
                    _buildUpcomingEventsTable(),

                    const SizedBox(height: 20),

                    // Recent Partnerships
                    _buildSectionHeader('Recent Partnerships', 'View All', () {}),
                    const SizedBox(height: 12),
                    _buildPartnershipsTable(),

                    const SizedBox(height: 20),

                    // Top Programs
                    _buildSectionHeader('Top Programs', null, null),
                    const SizedBox(height: 12),
                    _buildTopProgramsTable(),

                    const SizedBox(height: 20),

                    // Recent Workshops
                    _buildSectionHeader('Recent Workshops', null, null),
                    const SizedBox(height: 12),
                    _buildRecentWorkshopsTable(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? actionLabel, VoidCallback? onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (actionLabel != null && onTap != null)
          GestureDetector(
            onTap: onTap,
            child: Text(
              actionLabel,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white70,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUpcomingEventsTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Header Row
          _tableHeaderRow(['Event Name', 'Date', 'Participants']),
          ...upcomingEvents.map((event) => _buildEventRow(event)),
        ],
      ),
    );
  }

  Widget _buildEventRow(UpcomingEventModel event) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff1676C4),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  event.type,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              event.date,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${event.participants}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnershipsTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _tableHeaderRow(['Company', 'Type', 'Status']),
          ...partnerships.map((p) => _buildPartnershipRow(p)),
        ],
      ),
    );
  }

  Widget _buildPartnershipRow(PartnershipModel p) {
    final isActive = p.status == 'Active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              p.company,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              p.type,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                p.status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.green[700] : Colors.orange[700],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProgramsTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _tableHeaderRow(['Program Name', 'Students', 'Completion']),
          ...topPrograms.map((p) => _buildProgramRow(p)),
        ],
      ),
    );
  }

  Widget _buildProgramRow(TopProgramModel p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              p.name,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${p.students}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${p.completion}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff1676C4),
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: p.completion / 100,
                    backgroundColor: Colors.grey[200],
                    color: Color(0xff1676C4),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentWorkshopsTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _tableHeaderRow(['Workshop Name', 'Instructor', 'Date']),
          ...recentWorkshops.map((w) => _buildWorkshopRow(w)),
        ],
      ),
    );
  }

  Widget _buildWorkshopRow(RecentWorkshopModel w) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              w.name,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              w.instructor,
              style: TextStyle(fontSize: 9, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              w.date,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeaderRow(List<String> headers) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xff1676C4).withOpacity(0.08),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: headers
            .asMap()
            .entries
            .map(
              (e) => Expanded(
            flex: e.key == 0 ? 3 : (e.key == 1 ? 2 : 1),
            child: Text(
              e.value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xff1676C4),
              ),
            ),
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      width: 220,
      child: Column(
        children: [
          // Header
          Container(
            height: 240,
            width: double.infinity,
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 50),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Smart Career',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1676C4),
                  ),
                ),
                const Text(
                  'Hub',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1676C4),
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xff1676C4),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  _drawerItem(
                    icon: Icons.calendar_today,
                    title: 'Partnerships',
                    onTap: () {
                       Navigator.push(context, MaterialPageRoute(builder: (_) => PartnershipsScreen()));
                    },
                  ),
                  _drawerItem(
                    icon: Icons.calendar_today,
                    title: 'Calendar',
                    onTap: () {

                       Navigator.push(context, MaterialPageRoute(builder: (_) => CalendarScreen()));
                    },
                  ),

                  _drawerItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigator.push(context, MaterialPageRoute(builder: (_) => Loginui()));
                    },
                  ),

                  const Spacer(),

                  // Logout
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: InkWell(
                      onTap: () {
                         //Navigator.push(context, MaterialPageRoute(builder: (_) => ChooseRoleScreen()));
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red, size: 24),
                          SizedBox(width: 16),
                          Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xff1676C4),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.construction), label: 'Workshops'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ==================== REUSABLE WIDGETS ====================

Widget _universityDashboardCard(UniversityDashboardCardModel model) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xff1676C4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(model.icon, color: const Color(0xff1676C4), size: 28),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  model.count,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          model.title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          model.subtitle,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    ),
  );
}

Widget _drawerItem({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}