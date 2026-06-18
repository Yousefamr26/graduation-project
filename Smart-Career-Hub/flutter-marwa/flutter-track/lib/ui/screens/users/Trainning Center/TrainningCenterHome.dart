import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../data/services/api_service.dart';
import '../../../../core/Constants/apiConstants.dart';
import '../../auth/login/login_screen.dart';
import 'TrainingCourseManagement.dart';
import 'TrainingCommunication.dart';
import 'TrainingTraineeProfiles.dart';
import 'TrainingReports.dart';
import 'TrainingProfile.dart';
import '../Student/Settings screen.dart';

class TrainingHomeScreen extends StatefulWidget {
  const TrainingHomeScreen({super.key});
  @override
  State<TrainingHomeScreen> createState() => _TrainingHomeScreenState();
}

class _TrainingHomeScreenState extends State<TrainingHomeScreen> {
  static const Color kPrimary = Color(0xff1676C4);
  static const Color kPrimaryDark = Color(0xff0d5fa3);
  static const Color kBg = Color(0xffF0F9FF);

  int _selectedIndex = 0;

  final List<Map<String, dynamic>> courses = [
    {'name': 'Flutter Development', 'progress': 0.85, 'rate': 4.8},
    {'name': 'UI/UX Design', 'progress': 0.60, 'rate': 4.5},
    {'name': 'Data Science', 'progress': 0.40, 'rate': 4.2},
    {'name': 'Cybersecurity', 'progress': 0.75, 'rate': 4.7},
  ];

  List<Map<String, dynamic>> _recentCandidates = [];
  bool _loadingCandidates = true;
  
  Map<String, dynamic> _profile = {};
  String _academyName = 'SkillBoost Academy'; // default

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadCandidates();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final local = prefs.getString('training_center_user_data');
      if (local != null) {
        final d = json.decode(local) as Map<String, dynamic>;
        _profile = d;
        _updateName();
      }
      final res = await ApiService.get(
        '/trainingcenter/profile',
        userType: 'training_center',
      );
      final data = (res is Map
          ? res as Map<String, dynamic>
          : res?['data'] ?? {});
      if (data.isNotEmpty) {
        _profile = {..._profile, ...data};
        _updateName();
      }
    } catch (_) {}
  }

  void _updateName() {
    if (mounted) {
      setState(() {
        _academyName = _profile['name'] ??
            _profile['centerName'] ??
            _profile['trainingCenterName'] ??
            'SkillBoost Academy';
      });
    }
  }

  Future<void> _loadCandidates() async {
    try {
      final res = await ApiService.get('/Candidates', userType: 'training_center');
      final raw = (res is List ? res : res?['data'] ?? res?['items'] ?? []) as List;

      // Group by userId (same user may appear for multiple roadmaps)
      final Map<String, Map<String, dynamic>> grouped = {};
      for (final item in raw) {
        final map = Map<String, dynamic>.from(item as Map);
        final uid = map['userId']?.toString() ?? '';
        if (uid.isEmpty) continue;

        if (!grouped.containsKey(uid)) {
          grouped[uid] = {
            'userId': uid,
            'fullName': map['fullName'] ?? '',
            'email': map['email'] ?? '',
            'userType': map['userType'] ?? '',
            'profileImage': map['profileImage'] ?? '',
            'totalPoints': map['totalPoints'] ?? 0,
            'roadmapName': map['roadmapName'] ?? '',
            'roadmapCount': 1,
          };
        } else {
          grouped[uid]!['roadmapCount'] = (grouped[uid]!['roadmapCount'] as int) + 1;
          final existing = grouped[uid]!['totalPoints'] as int;
          final incoming = (map['totalPoints'] ?? 0) as int;
          if (incoming > existing) grouped[uid]!['totalPoints'] = incoming;
          if ((map['profileImage'] ?? '').toString().isNotEmpty) {
            grouped[uid]!['profileImage'] = map['profileImage'];
          }
        }
      }
      if (mounted) setState(() => _recentCandidates = grouped.values.toList());
    } catch (_) {}
    if (mounted) setState(() => _loadingCandidates = false);
  }

  void _pushScreen(Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Student':
        return const Color(0xff22C55E);
      case 'Graduate':
        return kPrimary;
      default:
        return const Color(0xffF59E0B);
    }
  }

  Widget _buildDrawer() {
    final items = [
      {
        'icon': Icons.dashboard_outlined,
        'label': 'Dashboard',
        'action': () {
          Navigator.pop(context);
          setState(() => _selectedIndex = 0);
        },
      },
      {
        'icon': Icons.menu_book_outlined,
        'label': 'Course Management',
        'action': () {
          Navigator.pop(context);
          setState(() => _selectedIndex = 1);
        },
      },
      {
        'icon': Icons.chat_bubble_outline_rounded,
        'label': 'Communication',
        'action': () {
          Navigator.pop(context);
          setState(() => _selectedIndex = 2);
        },
      },
      {
        'icon': Icons.people_outline_rounded,
          'label': 'Reports',
        'action': () {
          Navigator.pop(context);
          setState(() => _selectedIndex = 3);
        },
      },
      {
        'icon': Icons.bar_chart_rounded,'label': 'Trainee Profiles',
      
        'action': () {
          Navigator.pop(context);
          setState(() => _selectedIndex = 4);
        },
      },
      {
        'icon': Icons.person_outline_rounded,
        'label': 'Profile',
        'action': () {
          Navigator.pop(context);
          setState(() => _selectedIndex = 5);
        },
      },
      {
        'icon': Icons.settings_outlined,
        'label': 'Settings',
        'action': () => _pushScreen(const SettingsScreen()),
      },
    ];

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black54),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [kPrimary, kPrimaryDark],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.hub_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Smart Career\nHub',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: kPrimary,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  ...items.map(
                    (item) => ListTile(
                      leading: Icon(
                        item['icon'] as IconData,
                        color: kPrimary,
                        size: 22,
                      ),
                      title: Text(
                        item['label'] as String,
                        style: const TextStyle(fontSize: 14),
                      ),
                      horizontalTitleGap: 8,
                      onTap: item['action'] as VoidCallback,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.logout_rounded,
                      color: Colors.red,
                      size: 22,
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                    horizontalTitleGap: 8,
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('student_token');
                      await prefs.remove('graduate_token');
                      await prefs.remove('auth_token');
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (r) => false,
                        );
                      }
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
              child: const Icon(Icons.business, color: Colors.white, size: 18),
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.hub_rounded, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'Smart Career Hub',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.menu_book_outlined, 'label': 'Courses'},
      {'icon': Icons.chat_bubble_outline_rounded, 'label': 'Chat'},
      {'icon': Icons.bar_chart_rounded, 'label': 'Reports'},
      {'icon': Icons.people_outline_rounded, 'label': 'Trainees'},
      {'icon': Icons.person_outline_rounded, 'label': 'Profile'},
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final sel = _selectedIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: sel
                        ? kPrimary.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i]['icon'] as IconData,
                        color: sel ? kPrimary : Colors.grey,
                        size: 22,
                      ),
                      if (sel) ...[
                        const SizedBox(height: 2),
                        Text(
                          items[i]['label'] as String,
                          style: const TextStyle(
                            fontSize: 9,
                            color: kPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required String value,
    required String label,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _courseRow(Map<String, dynamic> course) {
    final double p = course['progress'] as double;
    final Color pc = p >= 0.75
        ? const Color(0xff22C55E)
        : p >= 0.5
        ? const Color(0xffF59E0B)
        : const Color(0xffEF4444);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              course['name'],
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: p,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(pc),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${(p * 100).toInt()}%',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xffF59E0B),
                size: 13,
              ),
              const SizedBox(width: 2),
              Text(
                course['rate'].toString(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _traineeRow(Map<String, dynamic> t) {
    final name = t['fullName']?.toString() ?? 'Candidate';
    final roadmap = t['roadmapName']?.toString() ?? '';
    final userType = t['userType']?.toString() ?? '';
    final profileImage = t['profileImage']?.toString() ?? '';
    final totalPoints = t['totalPoints'] ?? 0;
    final roadmapCount = t['roadmapCount'] ?? 1;
    final fullImageUrl = profileImage.isNotEmpty ? ApiConstants.getImageUrl(profileImage) : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: kPrimary.withOpacity(0.1),
            backgroundImage: fullImageUrl.isNotEmpty ? NetworkImage(fullImageUrl) : null,
            child: fullImageUrl.isEmpty
              ? Text(
                  name[0].toUpperCase(),
                  style: const TextStyle(
                    color: kPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  roadmapCount > 1 ? '$roadmap +${roadmapCount - 1} more' : roadmap,
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (totalPoints > 0)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xffFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$totalPoints pts',
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xffD97706)),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _typeColor(userType).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              userType,
              style: TextStyle(
                fontSize: 10,
                color: _typeColor(userType),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required String title,
    required String action,
    required VoidCallback onAction,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  action,
                  style: const TextStyle(color: kPrimary, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blue Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimary, kPrimaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        color: Color(0xffFCD34D),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome,',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        Text(
                          _academyName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _statCard(
                      value: '18',
                      label: 'Total Courses',
                      icon: Icons.menu_book_rounded,
                      iconBg: Colors.white.withOpacity(0.2),
                      iconColor: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    _statCard(
                      value: '342',
                      label: 'Active Trainees',
                      icon: Icons.people_rounded,
                      iconBg: Colors.white.withOpacity(0.2),
                      iconColor: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _statCard(
                      value: '465',
                      label: 'Pending Requests',
                      icon: Icons.pending_actions_rounded,
                      iconBg: const Color(0xffFEF3C7),
                      iconColor: const Color(0xffD97706),
                    ),
                    const SizedBox(width: 12),
                    _statCard(
                      value: '287',
                      label: 'Certificates Issued',
                      icon: Icons.workspace_premium_rounded,
                      iconBg: const Color(0xffFEF3C7),
                      iconColor: const Color(0xffF59E0B),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _statCard(
                      value: '90%',
                      label: 'Completion Rate',
                      icon: Icons.check_circle_rounded,
                      iconBg: const Color(0xffDCFCE7),
                      iconColor: const Color(0xff16A34A),
                    ),
                    const SizedBox(width: 12),
                    _statCard(
                      value: '6',
                      label: 'Active Entities',
                      icon: Icons.business_center_rounded,
                      iconBg: Colors.white.withOpacity(0.2),
                      iconColor: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _card(
            title: 'Course Performance',
            action: 'See All',
            onAction: () => setState(() => _selectedIndex = 1),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Expanded(
                        flex: 4,
                        child: Text(
                          'Course Name',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Text(
                        'Rate',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ...courses.map(_courseRow),
              ],
            ),
          ),
          _card(
            title: 'Recent Trainees',
            action: 'View All',
            onAction: () => setState(() => _selectedIndex = 4),
            child: _loadingCandidates
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2)),
                )
              : _recentCandidates.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('No candidates yet', style: TextStyle(color: Colors.grey, fontSize: 12))),
                  )
                : Column(children: _recentCandidates.take(5).map(_traineeRow).toList()),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _selectedIndex = 1),
                icon: const Icon(Icons.add_rounded, color: kPrimary),
                label: const Text(
                  'Add Course',
                  style: TextStyle(
                    color: kPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: kPrimary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomePage(),
      const TrainingCourseManagement(),
      const TrainingCommunication(),
      const TrainingReports(),
      const TrainingTraineeProfiles(),
      const TrainingProfile(),
    ];
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
}
