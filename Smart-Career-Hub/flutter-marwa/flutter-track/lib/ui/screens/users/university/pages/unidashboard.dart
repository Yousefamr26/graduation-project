// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_career_hub/ui/screens/users/university/pages/workshop/WorkshopsScreen.dart';
import 'dart:convert';

import '../../../../../data/repositories/Analytics repository.dart';
import '../pages/profile/universityprofilescreen.dart';
import 'event/EventsScreen.dart';

class UniversityDashboard extends StatefulWidget {
  const UniversityDashboard({super.key});

  @override
  State<UniversityDashboard> createState() => _UniversityDashboardState();
}

class _UniversityDashboardState extends State<UniversityDashboard> {
  int _selectedIndex = 0;

  String _universityName = 'University';
  String _universityCity = '';
  String _universityCountry = '';
  String _logoUrl = '';

  final AnalyticsRepository _analyticsRepo = AnalyticsRepository();
  bool _overviewLoading = true;
  Map<String, dynamic> _overviewData = {};

  static const _primary   = Color(0xff1676C4);
  static const _primaryDk = Color(0xff0d55a0);
  static const _bg        = Color(0xffF0F4F9);

  String _extract(String section, String key) {
    final sectionData = _overviewData[section];
    if (sectionData is Map) {
      final val = sectionData[key];
      if (val is Map && val['value'] != null) return val['value'].toString();
      return val?.toString() ?? '—';
    }
    return '—';
  }

  String _attendanceRate() {
    final raw = _overviewData['events']?['attendanceRate'];
    if (raw == null) return '—';
    final rate = raw is Map ? (raw['value'] ?? 0) : raw;
    return '${((rate as num) * 100).toStringAsFixed(0)}%';
  }

  List<_CardModel> get _cards => [
    _CardModel(Icons.event_rounded,       'Total Events',  _extract('events', 'totalEvents'),         'Organised'),
    _CardModel(Icons.people_alt_rounded,  'Participants',  _extract('events', 'totalRegistrations'),  'Registered'),
    _CardModel(Icons.construction_rounded,'Workshops',     _extract('workshops', 'totalWorkshops'),   'Total'),
    _CardModel(Icons.workspace_premium,   'Attendance',    _attendanceRate(),                         'Rate'),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadOverview();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString('university_user_data') ?? prefs.getString('user_data');
    if (rawData != null) {
      try {
        final data = jsonDecode(rawData) as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _universityName = data['name'] ?? data['Name'] ?? 'University';
            _universityCity = data['city'] ?? data['City'] ?? '';
            _universityCountry = data['country'] ?? data['Country'] ?? '';
            _logoUrl = data['organizationLogoUrl'] ?? data['logoUrl'] ?? '';
            if (_logoUrl.isNotEmpty && !_logoUrl.startsWith('http')) {
              _logoUrl = 'http://smartcareerhub.runasp.net$_logoUrl';
            }
          });
        }
      } catch (_) {}
    }
  }

  Future<void> _loadOverview() async {
    if (!mounted) return;
    setState(() => _overviewLoading = true);
    try {
      final data = await _analyticsRepo.getUniversityDashboardOverview();
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

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:  return _buildHomePage();
      case 1:  return WorkshopsUniScreen();
      case 2:  return EventsUniScreen();
      case 3:  return UniversityProfileScreen();
      default: return _buildHomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyedSubtree(
        key: ValueKey(_selectedIndex),
        child: _buildCurrentPage(),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: _primary,
        unselectedItemColor: Colors.grey.shade400,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded),         label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.construction_rounded), label: 'Workshops'),
          BottomNavigationBarItem(icon: Icon(Icons.event_rounded),        label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded),       label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return Scaffold(
      backgroundColor: _bg,
      body: RefreshIndicator(
        onRefresh: _loadOverview,
        color: _primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              sliver: _overviewLoading
                  ? SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildBuilderDelegate(
                      (_, __) => _shimmerCard(),
                  childCount: 4,
                ),
              )
                  : SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildBuilderDelegate(
                      (_, i) => _statCard(_cards[i]),
                  childCount: _cards.length,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    _actionTile(
                      icon: Icons.event_rounded,
                      color: const Color(0xff3B82F6),
                      title: 'New Event',
                      subtitle: 'Create & manage events',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => EventsUniScreen())),
                    ),
                    const SizedBox(height: 10),
                    _actionTile(
                      icon: Icons.construction_rounded,
                      color: const Color(0xff8B5CF6),
                      title: 'New Workshop',
                      subtitle: 'Add workshop content',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => WorkshopsUniScreen())),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final initials = _universityName.isNotEmpty
        ? _universityName.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : 'U';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary, _primaryDk],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                ),
                child: ClipOval(
                  child: _logoUrl.isNotEmpty
                      ? Image.network(
                    _logoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(initials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ),
                  )
                      : Center(
                    child: Text(initials,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back 👋',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _universityName,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_universityCity.isNotEmpty || _universityCountry.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.location_on_rounded,
                            size: 12, color: Colors.white60),
                        const SizedBox(width: 3),
                        Text(
                          [_universityCity, _universityCountry]
                              .where((s) => s.isNotEmpty)
                              .join(', '),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white60),
                        ),
                      ]),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(_CardModel model) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(model.icon, color: _primary, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  model.count,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                model.title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                model.subtitle,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.black87)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: Colors.grey.shade400),
        ]),
      ),
    );
  }

  Widget _shimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _CardModel {
  final IconData icon;
  final String title;
  final String count;
  final String subtitle;
  const _CardModel(this.icon, this.title, this.count, this.subtitle);
}