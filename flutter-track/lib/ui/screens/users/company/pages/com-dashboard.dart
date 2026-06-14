// ignore_for_file: avoid_print
import 'package:smart_career_hub/ui/screens/users/company/pages/profile/profileCompany.dart';
import 'package:smart_career_hub/ui/screens/users/company/pages/workshops/editworkshop.dart';
import 'package:smart_career_hub/ui/screens/users/company/pages/workshops/workshopsScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../../../data/models/company/DashboardCardModel.dart';
import '../../../../../data/repositories/Analytics repository.dart';
import '../../../auth/login/login_screen.dart';
import 'Analytics/AnalyticsPage.dart';
import 'Applications/Applications.dart';
import 'Chat/Chat rooms screen.dart';
import 'Cv/cvScreen.dart';
import 'Event/eventscreen.dart';
import 'Interviews/Calendar screen.dart';
import 'Interviews/InterviewsScreen.dart';
import 'Roadmaps/create_edit_roadmap.dart';
import 'Roadmaps/roadmapscreen.dart';
import 'internship/internshipscreen.dart';
import 'jobs/jobScreen.dart';
import '../../university/pages/workshop/crate_editWorkshopUni.dart';


class comDashboard extends StatefulWidget {
  const comDashboard({super.key});

  @override
  State<comDashboard> createState() => _comDashboardState();
}

class _comDashboardState extends State<comDashboard> {
  int _selectedIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _companyName    = 'My Company';
  String _companyCity    = '';
  String _companyCountry = '';

  final AnalyticsRepository _analyticsRepo = AnalyticsRepository();
  bool _overviewLoading = true;
  Map<String, dynamic> _overviewData = {};

  String _extract(String section, String key) {
    final sectionData = _overviewData[section];
    if (sectionData is Map) {
      final val = sectionData[key];
      if (val is Map && val['value'] != null) return val['value'].toString();
      return val?.toString() ?? '—';
    }
    return '—';
  }

  List<DashboardCardModel> get dashboardCards => [
    DashboardCardModel(
      icon:     Icons.school,
      title:    'Active Roadmaps',
      count:    _extract('roadmap', 'activeRoadmaps'),
      subtitle: 'Total created roadmaps',
    ),
    DashboardCardModel(
      icon:     Icons.people,
      title:    'Enrolled Students',
      count:    _extract('roadmap', 'totalEnrolled'),
      subtitle: 'Across all roadmaps',
    ),
    DashboardCardModel(
      icon:     Icons.work,
      title:    'Total Jobs',
      count:    _extract('jobs', 'totalJobPostings'),
      subtitle: 'Posted jobs',
    ),
    DashboardCardModel(
      icon:     Icons.videocam_outlined,
      title:    'Total Interviews',
      count:    _extract('interviews', 'totalInterviews'),
      subtitle: 'Scheduled interviews',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadOverview();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final token = prefs.getString('company_token');
      if (token != null && token.isNotEmpty) {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload    = parts[1];
          final normalized = base64Url.normalize(payload);
          final decoded    = utf8.decode(base64Url.decode(normalized));
          final data       = json.decode(decoded) as Map<String, dynamic>;

          final name = data['OrganizationName'] ??
              data['organizationName']           ??
              data['CompanyName']                ??
              data['companyName']                ??
              data['Name']                       ??
              data['name']                       ??
              data['unique_name']                ??
              '${data['FirstName'] ?? data['firstName'] ?? ''} ${data['LastName'] ?? data['lastName'] ?? ''}'.trim();

          final city    = data['City']    ?? data['city']    ?? '';
          final country = data['Country'] ?? data['country'] ?? '';

          if (name.toString().isNotEmpty && mounted) {
            setState(() {
              _companyName    = name.toString();
              _companyCity    = city.toString();
              _companyCountry = country.toString();
            });
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ [DASHBOARD] Token parse failed: $e');
    }

    try {
      final raw = prefs.getString('company_user_data') ?? prefs.getString('user_data');
      if (raw != null) {
        final data = json.decode(raw) as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _companyName    = data['name']    ?? data['organizationName'] ?? 'My Company';
            _companyCity    = data['city']    ?? '';
            _companyCountry = data['country'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('❌ [DASHBOARD] user_data parse failed: $e');
    }
  }

  Future<void> _loadOverview() async {
    if (!mounted) return;
    setState(() => _overviewLoading = true);
    try {
      final data = await _analyticsRepo.getDashboardOverview();
      if (!mounted) return;
      setState(() { _overviewData = data; _overviewLoading = false; });
    } catch (e) {
      debugPrint("❌ [HOME] Overview load error: $e");
      if (!mounted) return;
      setState(() => _overviewLoading = false);
    }
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:  return _buildHomePage();
      case 1:  return const MyRoadmapsScreen();
      case 2:  return const AnalyticsScreen();
      case 3:  return const CompanyProfileScreen();
      default: return _buildHomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          _buildCurrentPage(),

          // ── BottomNav ─────────────────────────────────────────
          Positioned(
            left: 12, right: 12, bottom: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10)
                ],
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex,
                selectedItemColor: const Color(0xff1676C4),
                unselectedItemColor: Colors.grey,
                onTap: _onItemTapped,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home),      label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.map),       label: 'Roadmaps'),
                  BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
                  BottomNavigationBarItem(icon: Icon(Icons.person),    label: 'Profile'),
                ],
              ),
            ),
          ),

          // ✅ Chat FAB
          if (_selectedIndex == 0)
            Positioned(
              right: 20,
              bottom: 120 + MediaQuery.of(context).padding.bottom,
              child: _FloatingChatButton(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatRoomsScreen()),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Home Page
  // ─────────────────────────────────────────────────────────────
  Widget _buildHomePage() {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Welcome back 👋",
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text(_companyName,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            if (_companyCity.isNotEmpty || _companyCountry.isNotEmpty)
              Row(children: [
                const Icon(Icons.location_on,
                    size: 12, color: Color(0xff1676C4)),
                const SizedBox(width: 3),
                Text(
                  [_companyCity, _companyCountry]
                      .where((s) => s.isNotEmpty)
                      .join(', '),
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xff1676C4)),
                ),
              ]),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadOverview,
        color: const Color(0xff1676C4),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _overviewLoading
                  ? SizedBox(
                height: 200,
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: List.generate(4, (_) => _shimmerCard()),
                ),
              )
                  : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dashboardCards.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (_, i) => modernCard(dashboardCards[i]),
              ),

              const SizedBox(height: 16),

              if (!_overviewLoading && _overviewData.isNotEmpty)
                _buildAnalyticsPreviewBanner(),

              const SizedBox(height: 24),

              const Text("Quick Actions",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              Row(children: [
                Expanded(
                  child: actionCard(
                    icon:  Icons.add_road,
                    title: "Roadmap",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => Create_editRoadmap())),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: actionCard(
                    icon:  Icons.workspaces_outline,
                    title: "Workshop",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => CreateEditWorkshopScreen())),
                  ),
                ),
              ]),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsPreviewBanner() {
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = 2),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff1676C4), Color(0xff0d55a0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff1676C4).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.analytics_outlined,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('View Full Analytics',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Roadmaps · Jobs · Workshops · Interviews',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              color: Colors.white70, size: 16),
        ]),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      width: 220,
      child: Column(children: [
        Container(
          height: 200,
          width: double.infinity,
          color: Colors.white,
          child: Column(children: [
            const SizedBox(height: 50),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: IconButton(
                  icon: const Icon(Icons.close, size: 28, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Smart Career Hub',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1676C4))),
          ]),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            color: const Color(0xff1676C4),
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(children: [
              _drawerItem(Icons.work_outline, 'Jobs', () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => JobsScreen()));
              }),
              _drawerItem(Icons.school, 'Internships', () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => InternshipsScreen()));
              }),
              _drawerItem(Icons.construction, 'Workshops', () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => WorkshopsScreen()));
              }),
              _drawerItem(Icons.event_outlined, 'Events', () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => EventsScreen()));
              }),
              _drawerItem(Icons.videocam_outlined, 'Interviews', () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => InterviewsScreen()));
              }),
              _drawerItem(Icons.description, 'Applications', () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ApplicationsScreen()));
              }),
              _drawerItem(Icons.calendar_today, 'Calendar', () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => CalendarScreen()));
              }),
              _drawerItem(Icons.file_copy_outlined, 'CV', () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => CvTemplatesScreen()));
              }),

              SizedBox(height: 30,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => LoginScreen()));
                  },
                  child: const Row(children: [
                    Icon(Icons.logout, color: Colors.red, size: 24),
                    SizedBox(width: 16),
                    Text('Logout',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.w500)),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _shimmerCard() => Container(
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(20),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
// ✅ Floating Chat Button — animated
// ─────────────────────────────────────────────────────────────────
class _FloatingChatButton extends StatefulWidget {
  final VoidCallback onTap;
  const _FloatingChatButton({required this.onTap});

  @override
  State<_FloatingChatButton> createState() => _FloatingChatButtonState();
}

class _FloatingChatButtonState extends State<_FloatingChatButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => _controller.forward(),
      onTapUp:     (_) { _controller.reverse(); widget.onTap(); },
      onTapCancel: ()  => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xff1676C4), Color(0xff0d5fa3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff1676C4).withOpacity(0.45),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.chat_bubble_rounded,
              color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Standalone helpers
// ─────────────────────────────────────────────────────────────────
Widget modernCard(DashboardCardModel model) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xff1676C4).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(model.icon, color: const Color(0xff1676C4), size: 22),
      ),
      const Spacer(),
      Text(model.count,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(model.title,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
    ]),
  );
}

Widget actionCard({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xff1676C4).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xff1676C4), size: 20),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13),
              overflow: TextOverflow.ellipsis,
              maxLines: 1),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
      ]),
    ),
  );
}

Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: InkWell(
      onTap: onTap,
      child: Row(children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(width: 16),
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500)),
      ]),
    ),
  );
}