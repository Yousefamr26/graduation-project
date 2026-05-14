// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../../../data/repositories/Analytics repository.dart';
import '../../company/pages/Event/eventscreen.dart';
import '../../company/pages/workshops/workshopsScreen.dart';
import '../pages/profile/universityprofilescreen.dart';

class UniversityDashboard extends StatefulWidget {
  const UniversityDashboard({super.key});

  @override
  State<UniversityDashboard> createState() => _UniversityDashboardState();
}

class _UniversityDashboardState extends State<UniversityDashboard> {
  int _selectedIndex = 0;

  // ── User data ───────────────────────────────────────────────
  String _universityName = 'University';
  String _universityCity = '';
  String _universityCountry = '';

  // ── Analytics ───────────────────────────────────────────────
  final AnalyticsRepository _analyticsRepo = AnalyticsRepository();
  bool _overviewLoading = true;
  Map<String, dynamic> _overviewData = {};

  // ─────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────
  String _extract(String section, String key) {
    final sectionData = _overviewData[section];
    if (sectionData is Map) {
      final val = sectionData[key];
      if (val is Map && val['value'] != null) return val['value'].toString();
      return val?.toString() ?? '—';
    }
    return '—';
  }

  // ─────────────────────────────────────────────────────────────
  // Dashboard cards
  // ─────────────────────────────────────────────────────────────
  List<_CardModel> get _cards => [
    _CardModel(Icons.event_outlined, 'Total Events',
        _extract('events', 'totalEvents'), 'Organised events'),
    _CardModel(Icons.people_outline, 'Participants',
        _extract('events', 'totalRegistrations'), 'Event registrations'),
    _CardModel(Icons.construction_outlined, 'Workshops',
        _extract('workshops', 'totalWorkshops'), 'Total workshops'),
    _CardModel(
        Icons.workspace_premium_outlined,
        'Attendance',
        '${((_overviewData['events']?['attendanceRate'] ?? 0) * 100).toStringAsFixed(0)}%',
        'Event attendance rate'),
  ];

  // ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadOverview();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString('university_user_data') ??
        prefs.getString('user_data');
    if (rawData != null) {
      try {
        final data = jsonDecode(rawData) as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _universityName = data['name'] ?? data['Name'] ?? 'University';
            _universityCity = data['city'] ?? data['City'] ?? '';
            _universityCountry = data['country'] ?? data['Country'] ?? '';
          });
        }
      } catch (_) {}
    }
  }

  Future<void> _loadOverview() async {
    if (!mounted) return;
    setState(() => _overviewLoading = true);
    try {
      final data = await _analyticsRepo.getDashboardOverview();
      if (!mounted) return;
      setState(() {
        _overviewData = data;
        _overviewLoading = false;
      });
    } catch (e) {
      debugPrint('❌ [UNI HOME] Overview error: $e');
      if (!mounted) return;
      setState(() => _overviewLoading = false);
    }
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  // ─────────────────────────────────────────────────────────────
  // Pages
  // ─────────────────────────────────────────────────────────────
  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return WorkshopsScreen();
      case 2:
        return EventsScreen();
      case 3:
        return UniversityProfileScreen();
      default:
        return _buildHomePage();
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyedSubtree(
        key: ValueKey(_selectedIndex),
        child: _buildCurrentPage(),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10),
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
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.construction), label: 'Workshops'),
            BottomNavigationBarItem(
                icon: Icon(Icons.event), label: 'Events'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Home page
  // ─────────────────────────────────────────────────────────────
  Widget _buildHomePage() {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome back 👋',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text(
              _universityName,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadOverview,
        color: const Color(0xff1676C4),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Location chip ────────────────────────────
              if (_universityCity.isNotEmpty || _universityCountry.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(children: [
                    const Icon(Icons.location_on,
                        size: 14, color: Color(0xff1676C4)),
                    const SizedBox(width: 4),
                    Text(
                      [_universityCity, _universityCountry]
                          .where((s) => s.isNotEmpty)
                          .join(', '),
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xff1676C4)),
                    ),
                  ]),
                ),

              // ── Stats Grid ────────────────────────────────
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
                  children:
                  List.generate(4, (_) => _shimmerCard()),
                ),
              )
                  : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _cards.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (_, i) => _modernCard(_cards[i]),
              ),

              const SizedBox(height: 16),

              // ── Analytics banner ─────────────────────────
              if (!_overviewLoading && _overviewData.isNotEmpty)
                _buildAnalyticsBanner(),

              const SizedBox(height: 24),

              // ── Quick Actions ─────────────────────────────
              const Text('Quick Actions',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              Row(children: [
                Expanded(
                  child: _actionCard(
                    icon: Icons.event_outlined,
                    title: 'New Event',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => EventsScreen())),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _actionCard(
                    icon: Icons.construction_outlined,
                    title: 'Workshop',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => WorkshopsScreen())),
                  ),
                ),
              ]),

              const SizedBox(height: 12),



              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Analytics banner
  // ─────────────────────────────────────────────────────────────
  Widget _buildAnalyticsBanner() {
    return Container(
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
          child: const Icon(Icons.school_outlined,
              color: Colors.white, size: 28),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('University Overview',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(
                'Events · Workshops · Attendance',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios,
            color: Colors.white70, size: 16),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Small reusable widgets
  // ─────────────────────────────────────────────────────────────

  Widget _modernCard(_CardModel model) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xff1676C4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
            Icon(model.icon, color: const Color(0xff1676C4), size: 20),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(model.count,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 2),
          Text(model.title,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(model.subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _actionCard({
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
          const Icon(Icons.arrow_forward_ios,
              size: 12, color: Colors.grey),
        ]),
      ),
    );
  }

  Widget _shimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────
class _CardModel {
  final IconData icon;
  final String title;
  final String count;
  final String subtitle;
  const _CardModel(this.icon, this.title, this.count, this.subtitle);
}