import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../ui/screens/auth/login/login_screen.dart';
import '../../../../data/services/api_service.dart';
import '../../../../core/Constants/apiConstants.dart';
import '../../../../data/services/RoadmapService.dart';
import '../../../../data/models/Student/student-roadmap-model.dart';
import '../../../../data/models/Student/student-event-model.dart';
import '../../../../data/models/Student/student-workshop-model.dart';
import 'RoadmapQuizScreen.dart';
import 'cubit/roadmap/roadmap_cubit.dart';
import 'cubit/roadmap/roadmap_state.dart';
import 'cubit/profile/profile_cubit.dart';
import 'cubit/profile/profile_state.dart';
import 'cubit/event/event_cubit.dart';
import 'cubit/event/event_state.dart';
import 'cubit/workshop/workshop_cubit.dart';
import 'cubit/workshop/workshop_state.dart';
import '../../../../data/services/ProfileService.dart';
import '../../../../data/services/EventService.dart';
import '../../../../data/services/WorkshopService.dart';

// ── استبدلي المسارات دي بالمسارات الصح ──────────────────────────────────────
import 'RoadmapExplorerScreen.dart';
import 'Eventsscreen.dart';
import 'Settings screen.dart';
import 'Message hr screen.dart';
import '../Graduate/graduate_home.dart';
import 'Workshopsscreen.dart';
import 'Internshipopportunitiesscreen.dart';
import 'Careertipsscreen.dart';
import 'Studentprofilescreen.dart';
import 'CareerAdvisorScreen.dart';
import 'Coursesscreen.dart';
// ─────────────────────────────────────────────────────────────────────────────

/// Navigation wrapper for Student screens
class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  static const Color kPrimary = Color(0xff1676C4);
  int _selectedBottomNavIndex = 0;
  late final RoadmapCubit _roadmapCubit;
  late final ProfileCubit _profileCubit;
  late final EventCubit _eventCubit;
  late final WorkshopCubit _workshopCubit;

  @override
  void initState() {
    super.initState();
    _roadmapCubit = RoadmapCubit(RoadmapService())..loadRoadmaps();
    _profileCubit = ProfileCubit(ProfileService())..loadProfile();
    _eventCubit = EventCubit(EventService())..loadEvents();
    _workshopCubit = WorkshopCubit(WorkshopService())..loadWorkshops();
  }

  @override
  void dispose() {
    _roadmapCubit.close();
    _profileCubit.close();
    _eventCubit.close();
    _workshopCubit.close();
    super.dispose();
  }

  late final List<Widget> _bottomNavPages = [
    const StudentHomeScreenWithNav(),
    const RoadmapExplorerScreen(showBackButton: false),
    const CoursesScreen(),
    const StudentProfileScreen(showBackButton: false),
  ];

  // ── Navigate to any screen from drawer or other sources ──
  void _navigateTo(Widget screen, String screenName) {
    debugPrint("🔄 Navigating to: $screenName");
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RoadmapCubit>.value(value: _roadmapCubit),
        BlocProvider<ProfileCubit>.value(value: _profileCubit),
        BlocProvider<EventCubit>.value(value: _eventCubit),
        BlocProvider<WorkshopCubit>.value(value: _workshopCubit),
      ],
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: _selectedBottomNavIndex,
          children: _bottomNavPages,
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  // ── Bottom Navigation Bar ──
  Widget _buildBottomNav() {
    final navItems = [
      {'icon': Icons.home_rounded, 'label': 'Home', 'index': 0},
      {'icon': Icons.alt_route_rounded, 'label': 'Roadmap', 'index': 1},
      {'icon': Icons.menu_book_rounded, 'label': 'Courses', 'index': 2},
      {'icon': Icons.person_rounded, 'label': 'Profile', 'index': 3},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: navItems.map((item) {
          final isSelected = _selectedBottomNavIndex == item['index'];
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() => _selectedBottomNavIndex = item['index'] as int);
              debugPrint("Bottom Nav: ${item['label']}");
            },
            child: _BottomNavItem(
              icon: item['icon'] as IconData,
              label: item['label'] as String,
              isSelected: isSelected,
              activeColor: kPrimary,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color activeColor;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? activeColor.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: isSelected ? 1.0 : 1.15,
              end: isSelected ? 1.15 : 1.0,
            ),
            duration: const Duration(milliseconds: 250),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Icon(
                  icon,
                  color: isSelected ? activeColor : Colors.grey.shade500,
                  size: 24,
                ),
              );
            },
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            child: Row(
              children: [
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: activeColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Extended StudentHomeScreen with Drawer Navigation
// ─────────────────────────────────────────────────────────────────────────────

class StudentHomeScreenWithNav extends StatefulWidget {
  const StudentHomeScreenWithNav({super.key});

  @override
  State<StudentHomeScreenWithNav> createState() =>
      _StudentHomeScreenWithNavState();
}

class _StudentHomeScreenWithNavState extends State<StudentHomeScreenWithNav> {
  static const Color kPrimary = Color(0xff1676C4);
  static const Color kPrimaryDark = Color(0xff0d5fa3);
  static const Color kBg = Color(0xffF0F9FF);

  // ── Navigation helper ──
  void _navigateTo(Widget screen, String screenName) {
    Navigator.pop(context); // اغلق الـ drawer أولاً
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    debugPrint("🔄 Navigating to: $screenName");
  }

  // ── Drawer ──
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
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
            // Logo
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
                  'Smart Career',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kPrimary,
                  ),
                ),
                const Text(
                  'Hub',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 8),
            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Calendar
                  ListTile(
                    leading: const Icon(
                      Icons.calendar_today_outlined,
                      color: kPrimary,
                      size: 22,
                    ),
                    title: const Text(
                      'Calendar',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GraduateCalendarScreen(),
                        ),
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // Events
                  ListTile(
                    leading: const Icon(
                      Icons.event_outlined,
                      color: kPrimary,
                      size: 22,
                    ),
                    title: const Text(
                      'Events',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () => _navigateTo(const EventsScreen(), 'Events'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // Workshops
                  ListTile(
                    leading: const Icon(
                      Icons.handyman_outlined,
                      color: kPrimary,
                      size: 22,
                    ),
                    title: const Text(
                      'Workshops',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () =>
                        _navigateTo(const WorkshopsScreen(), 'Workshops'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // Internship
                  ListTile(
                    leading: const Icon(
                      Icons.work_outline,
                      color: kPrimary,
                      size: 22,
                    ),
                    title: const Text(
                      'Internship',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () => _navigateTo(
                      const InternshipOpportunitiesScreen(),
                      'Internship Opportunities',
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // Settings
                  ListTile(
                    leading: const Icon(
                      Icons.settings_outlined,
                      color: kPrimary,
                      size: 22,
                    ),
                    title: const Text(
                      'Setting',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // Career Tips
                  ListTile(
                    leading: const Icon(
                      Icons.lightbulb_outline,
                      color: kPrimary,
                      size: 22,
                    ),
                    title: const Text(
                      'Career Tips',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () =>
                        _navigateTo(const CareerTipsScreen(), 'Career Tips'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // Message HR
                  ListTile(
                    leading: const Icon(
                      Icons.message_outlined,
                      color: kPrimary,
                      size: 22,
                    ),
                    title: const Text(
                      'Message HR',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MessageHRScreen(),
                        ),
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const Divider(height: 24),
                  // Logout
                  ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.red,
                      size: 22,
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () async {
                      // Clear all stored tokens
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── AppBar ──
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
              child: const Icon(Icons.person, color: Colors.white, size: 20),
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
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
            size: 26,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        String studentName = 'John Doe';
        if (state is ProfileSuccess) {
          final basicInfo = (state.profileData['basicInfo'] ?? {}) as Map;
          studentName = basicInfo['fullName']?.toString() ?? 'John Doe';
        }

        return Scaffold(
          backgroundColor: kBg,
          appBar: _buildAppBar(context),
          drawer: _buildDrawer(),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
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
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                // Quick Actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      _quickActionButton(
                        icon: Icons.smart_toy_outlined,
                        label: 'Career AI',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CareerAdvisorScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _quickActionButton(
                        icon: Icons.work_outline,
                        label: 'Internships',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const InternshipOpportunitiesScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _quickActionButton(
                        icon: Icons.lightbulb_outline,
                        label: 'Career Tips',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CareerTipsScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Placeholder for My Roadmaps (static for now)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Roadmaps',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<RoadmapCubit>(),
                              child: const RoadmapExplorerScreen(initialTab: 1),
                            ),
                          ),
                        ),
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            color: kPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                BlocBuilder<RoadmapCubit, RoadmapState>(
                  builder: (context, state) {
                    if (state is RoadmapLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(color: kPrimary),
                        ),
                      );
                    }
                    if (state is RoadmapError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Failed to load roadmaps: ${state.message}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }
                    List<StudentRoadmap> my = [];
                    if (state is RoadmapSuccess) {
                      my = state.myRoadmaps;
                    }
                    if (my.isEmpty) {
                      return _emptyState(
                        'No roadmaps enrolled yet',
                        Icons.map_outlined,
                      );
                    }
                    return SizedBox(
                      height: 265,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: my.length,
                        itemBuilder: (context, index) {
                          final r = my[index];
                          final imageUrl = r.imageUrl ?? '';
                          final hasImage = imageUrl.toString().isNotEmpty;
                          final fullImageUrl = hasImage
                              ? ApiConstants.getImageUrl(imageUrl.toString())
                              : '';
                          return Container(
                            width: 240,
                            margin: const EdgeInsets.only(
                              right: 14,
                              bottom: 8,
                              top: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider.value(
                                          value: context.read<RoadmapCubit>(),
                                          child: const RoadmapExplorerScreen(
                                            initialTab: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 85,
                                          width: double.infinity,
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [kPrimary, kPrimaryDark],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                          child: fullImageUrl.isNotEmpty
                                              ? Image.network(
                                                  fullImageUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => const Icon(
                                                        Icons.route_rounded,
                                                        color: Colors.white70,
                                                        size: 28,
                                                      ),
                                                )
                                              : const Icon(
                                                  Icons.route_rounded,
                                                  color: Colors.white70,
                                                  size: 28,
                                                ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            12,
                                            12,
                                            12,
                                            0,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                r.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Color(0xFF1E293B),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Progress: ${r.progress.toInt()}%',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 3,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFF10B981,
                                                      ).withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      'Enrolled',
                                                      style: TextStyle(
                                                        color: Color(
                                                          0xFF10B981,
                                                        ),
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                                child: LinearProgressIndicator(
                                                  value: r.progress / 100,
                                                  minHeight: 5,
                                                  backgroundColor:
                                                      Colors.grey[100],
                                                  valueColor:
                                                      const AlwaysStoppedAnimation(
                                                        kPrimary,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      10,
                                      12,
                                      12,
                                    ),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 32,
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: kPrimary,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding: EdgeInsets.zero,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      RoadmapQuizScreen(
                                                        roadmapId: r.id,
                                                        roadmapTitle: r.title,
                                                      ),
                                                ),
                                              );
                                            },

                                            child: const Text(
                                              'Attempt Quiz Now',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 8),
                                        SizedBox(
                                          height: 32,
                                          width: double.infinity,
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              foregroundColor: Colors.redAccent,
                                              side: const BorderSide(
                                                color: Colors.redAccent,
                                                width: 1,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: const Text(
                                                    'Unenroll Roadmap',
                                                  ),
                                                  content: Text(
                                                    'Are you sure you want to unenroll from "${r.title}"?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            ctx,
                                                            false,
                                                          ),
                                                      child: const Text(
                                                        'Cancel',
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            ctx,
                                                            true,
                                                          ),
                                                      style:
                                                          TextButton.styleFrom(
                                                            foregroundColor:
                                                                Colors.red,
                                                          ),
                                                      child: const Text(
                                                        'Unenroll',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirm == true &&
                                                  context.mounted) {
                                                try {
                                                  await context
                                                      .read<RoadmapCubit>()
                                                      .unenroll(r.id);
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Unenrolled successfully!',
                                                        ),
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                      ),
                                                    );
                                                  }
                                                } catch (e) {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Error: $e',
                                                        ),
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                      ),
                                                    );
                                                  }
                                                }
                                              }
                                            },
                                            child: const Text(
                                              'Unenroll',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                // My Events
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Events',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EventsScreen(),
                              ),
                            ).then((_) {
                              if (context.mounted) {
                                context.read<EventCubit>().loadEvents();
                              }
                            }),
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            color: kPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                BlocBuilder<EventCubit, EventState>(
                  builder: (context, state) {
                    if (state is EventLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(color: kPrimary),
                        ),
                      );
                    }
                    if (state is EventError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Failed to load events: ${state.message}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }
                    List<StudentEvent> myEvents = [];
                    if (state is EventSuccess) {
                      myEvents = state.myEvents;
                    }
                    if (myEvents.isEmpty) {
                      return _emptyState(
                        'No events registered yet',
                        Icons.event_outlined,
                      );
                    }
                    return SizedBox(
                      height: 345,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: myEvents.length,
                        itemBuilder: (context, index) {
                          return _eventCard(myEvents[index]);
                        },
                      ),
                    );
                  },
                ),

                // My Workshops
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Workshops',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WorkshopsScreen(),
                              ),
                            ).then((_) {
                              if (context.mounted) {
                                context.read<WorkshopCubit>().loadWorkshops();
                              }
                            }),
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            color: kPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                BlocBuilder<WorkshopCubit, WorkshopState>(
                  builder: (context, state) {
                    if (state is WorkshopLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(color: kPrimary),
                        ),
                      );
                    }
                    if (state is WorkshopError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Failed to load workshops: ${state.message}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }
                    List<StudentWorkshop> myWorkshops = [];
                    if (state is WorkshopSuccess) {
                      myWorkshops = state.myWorkshops;
                    }
                    if (myWorkshops.isEmpty) {
                      return _emptyState(
                        'No workshops registered yet',
                        Icons.handyman_outlined,
                      );
                    }
                    return SizedBox(
                      height: 345,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: myWorkshops.length,
                        itemBuilder: (context, index) {
                          return _workshopCard(myWorkshops[index]);
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: kPrimary, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(String message, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
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
      ),
    );
  }

  DateTime? _tryParseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    final parsed = DateTime.tryParse(dateStr);
    if (parsed != null) return parsed;

    try {
      final regex = RegExp(r'(\d{4})[-/](\d{1,2})[-/](\d{1,2})');
      final match = regex.firstMatch(dateStr);
      if (match != null) {
        final y = int.parse(match.group(1)!);
        final m = int.parse(match.group(2)!);
        final d = int.parse(match.group(3)!);
        return DateTime(y, m, d);
      }
    } catch (_) {}
    return null;
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    final parsed = _tryParseDate(dateStr);
    if (parsed == null) return dateStr;

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = parsed.month >= 1 && parsed.month <= 12
        ? months[parsed.month - 1]
        : '';
    return '$month ${parsed.day}, ${parsed.year}';
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return '';
    final cleanStr = timeStr.trim();

    final parsedDate = DateTime.tryParse(cleanStr);
    if (parsedDate != null) {
      final hour = parsedDate.hour.toString().padLeft(2, '0');
      final minute = parsedDate.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    try {
      final parts = cleanStr.split(':');
      if (parts.isNotEmpty) {
        final hourInt = int.tryParse(parts[0]);
        if (hourInt != null) {
          final hour = hourInt.toString().padLeft(2, '0');
          final minute = parts.length > 1
              ? (int.tryParse(parts[1])?.toString().padLeft(2, '0') ?? '00')
              : '00';
          return '$hour:$minute';
        }
      }
    } catch (_) {}

    return cleanStr;
  }

  Widget _buildFloatingCalendarBadge(String dateStr) {
    final parsedDate = _tryParseDate(dateStr);
    if (parsedDate == null) return const SizedBox.shrink();

    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    final month = parsedDate.month >= 1 && parsedDate.month <= 12
        ? months[parsedDate.month - 1]
        : '';
    final day = parsedDate.day.toString();

    return Positioned(
      top: 10,
      left: 10,
      child: Container(
        width: 38,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 14,
              decoration: const BoxDecoration(
                color: Color(0xffEF4444),
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              alignment: Alignment.center,
              child: Text(
                month,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 7.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 11, color: const Color(0xFF64748B)),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _unenroll(dynamic id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userType;
      if (prefs.getString('student_token') != null) {
        userType = 'student';
      } else if (prefs.getString('graduate_token') != null) {
        userType = 'graduate';
      }

      await ApiService.delete('/events/$id/enroll', userType: userType);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Cancelled successfully'),
            backgroundColor: kPrimary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.read<EventCubit>().loadEvents();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: kPrimary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _eventCard(StudentEvent e) {
    final type = e.type;
    final typeColor = type == 'Online'
        ? const Color(0xff10B981)
        : type == 'Hybrid'
        ? const Color(0xff8B5CF6)
        : kPrimary;

    final formattedDate = _formatDate(e.date);
    final startTime = _formatTime(e.startTime);
    final endTime = _formatTime(e.endTime);
    final location = e.location;
    final seats = e.availableSeats;

    return Container(
      width: 290,
      margin: const EdgeInsets.only(right: 14, bottom: 10, top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff0F172A).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: kPrimary.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _buildRobustImage(e.bannerUrl, height: 120),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.35),
                            Colors.transparent,
                            Colors.black.withOpacity(0.35),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  _buildFloatingCalendarBadge(e.date),
                  if (type.isNotEmpty)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              type == 'Online'
                                  ? Icons.videocam_rounded
                                  : type == 'Hybrid'
                                  ? Icons.devices_other_rounded
                                  : Icons.location_on_rounded,
                              size: 9,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              type,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff10B981),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 9,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'Enrolled',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: kPrimary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.business_rounded,
                          size: 9,
                          color: kPrimary,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          e.organizer,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _infoItem(
                          Icons.calendar_today_rounded,
                          'DATE',
                          formattedDate.isNotEmpty ? formattedDate : 'TBD',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _infoItem(
                          Icons.access_time_rounded,
                          'TIME',
                          startTime.isNotEmpty
                              ? '$startTime - $endTime'
                              : 'TBD',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _infoItem(
                          Icons.location_on_rounded,
                          'LOCATION',
                          location.isNotEmpty ? location : 'Online / TBD',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _infoItem(
                          Icons.people_alt_rounded,
                          'SEATS',
                          seats != null
                              ? '$seats seats left'
                              : 'Open Registration',
                          valueColor: seats != null && seats < 10
                              ? const Color(0xffEF4444)
                              : const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _unenroll(e.id),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xffEF4444),
                          width: 1.2,
                        ),
                        foregroundColor: const Color(0xffEF4444),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cancel_outlined, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Cancel Registration',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _unenrollWorkshop(dynamic id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userType;
      if (prefs.getString('student_token') != null) {
        userType = 'student';
      } else if (prefs.getString('graduate_token') != null) {
        userType = 'graduate';
      }

      await ApiService.delete('/WorkshopEnrollment/$id', userType: userType);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Cancelled successfully'),
            backgroundColor: kPrimary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.read<WorkshopCubit>().loadWorkshops();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: kPrimary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _workshopCard(StudentWorkshop w) {
    final type = w.type;
    final typeColor = type == 'Online'
        ? const Color(0xff10B981)
        : type == 'Hybrid'
        ? const Color(0xff8B5CF6)
        : kPrimary;

    final formattedDate = _formatDate(w.date);
    final startTime = _formatTime(w.startTime);
    final endTime = _formatTime(w.endTime);
    final seats = w.availableSeats;
    final points = w.points;

    return Container(
      width: 290,
      margin: const EdgeInsets.only(right: 14, bottom: 10, top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff0F172A).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: kPrimary.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildWorkshopBanner(w.bannerUrl),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.2),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  _buildFloatingCalendarBadge(w.date),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (points != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xffFEF3C7),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xffD97706),
                                  size: 10,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '+$points Pts',
                                  style: const TextStyle(
                                    color: Color(0xffD97706),
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (type.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: typeColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  type == 'Online'
                                      ? Icons.videocam_rounded
                                      : type == 'Hybrid'
                                      ? Icons.devices_other_rounded
                                      : Icons.location_on_rounded,
                                  size: 9,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  type,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff10B981),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 9,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'Enrolled',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    w.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: kPrimary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.business_rounded,
                          size: 9,
                          color: kPrimary,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          w.organizer,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _infoItem(
                          Icons.calendar_today_rounded,
                          'DATE',
                          formattedDate.isNotEmpty ? formattedDate : 'TBD',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _infoItem(
                          Icons.access_time_rounded,
                          'TIME',
                          startTime.isNotEmpty
                              ? '$startTime - $endTime'
                              : 'TBD',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _infoItem(
                          Icons.people_alt_rounded,
                          'SEATS',
                          seats != null
                              ? '$seats seats left'
                              : 'Open Registration',
                          valueColor: seats != null && seats < 10
                              ? const Color(0xffEF4444)
                              : const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _infoItem(
                          Icons.star_rounded,
                          'POINTS REWARD',
                          points != null ? '$points Points' : '0 Points',
                          valueColor: const Color(0xffD97706),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _unenrollWorkshop(
                        w.enrollmentId.isNotEmpty ? w.enrollmentId : w.id,
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xffEF4444),
                          width: 1.2,
                        ),
                        foregroundColor: const Color(0xffEF4444),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cancel_outlined, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Cancel Registration',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkshopBanner(String? bannerUrl) {
    const baseUrl = 'http://smartcareerhub.runasp.net';
    if (bannerUrl == null || bannerUrl.trim().isEmpty) {
      return _workshopBannerFallback();
    }
    final raw = bannerUrl.trim();
    final url = raw.startsWith('/') ? '$baseUrl$raw' : raw;
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => _workshopBannerFallback(),
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : _workshopBannerFallback(),
    );
  }

  Widget _workshopBannerFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimary.withOpacity(0.85), const Color(0xff0d5fa3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.school_rounded,
          color: Colors.white.withOpacity(0.12),
          size: 64,
        ),
      ),
    );
  }

  Widget _buildRobustImage(String? imageStr, {double? height}) {
    if (imageStr == null || imageStr.trim().isEmpty) {
      return _buildBannerFallback(height: height);
    }

    final cleanStr = imageStr.trim();

    final isBase64 =
        cleanStr.startsWith('data:image') ||
        cleanStr.startsWith('/9j/') ||
        cleanStr.startsWith('iVBORw0KG') ||
        cleanStr.startsWith('R0lGOD') ||
        cleanStr.startsWith('UklGR') ||
        (!cleanStr.contains('/') &&
            !cleanStr.contains('.') &&
            cleanStr.length > 100);

    if (isBase64) {
      try {
        String cleanBase64 = cleanStr;
        if (cleanBase64.contains(',')) {
          cleanBase64 = cleanBase64.split(',')[1];
        }
        cleanBase64 = cleanBase64.replaceAll(RegExp(r'\s+'), '');
        final padded = cleanBase64.padRight(
          cleanBase64.length + (4 - cleanBase64.length % 4) % 4,
          '=',
        );
        final decoded = base64Decode(padded);
        return Image.memory(
          decoded,
          fit: BoxFit.cover,
          width: double.infinity,
          height: height,
          errorBuilder: (context, error, stackTrace) =>
              _buildBannerFallback(height: height),
        );
      } catch (_) {}
    }

    try {
      final fullUrl = ApiConstants.getImageUrl(cleanStr);
      return Image.network(
        fullUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
        errorBuilder: (context, error, stackTrace) =>
            _buildBannerFallback(height: height),
      );
    } catch (_) {
      return _buildBannerFallback(height: height);
    }
  }

  Widget _buildBannerFallback({double? height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimary.withOpacity(0.85), kPrimary.withOpacity(0.95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.event_rounded,
          color: Colors.white.withOpacity(0.25),
          size: 24,
        ),
      ),
    );
  }
}
