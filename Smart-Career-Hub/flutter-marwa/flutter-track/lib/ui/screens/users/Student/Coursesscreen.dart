import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/services/api_service.dart';
import '../../../../core/Constants/apiConstants.dart';
import '../../../../data/services/RoadmapService.dart';
import '../../../../data/services/CatalogService.dart';
import '../../../../data/models/Student/student-roadmap-model.dart';
import 'cubit/roadmap/roadmap_cubit.dart';
import 'cubit/roadmap/roadmap_state.dart';
import 'cubit/catalog/catalog_cubit.dart';
import 'cubit/catalog/catalog_state.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});
  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen>
    with SingleTickerProviderStateMixin {
  static const Color kPrimary = Color(0xff1676C4);
  static const Color kBg = Color(0xffF0F9FF);

  late TabController _tabs;
  String _search = '', _level = 'All Levels';
  String? _userType;
  String _userRole = 'student';
  RoadmapCubit? _roadmapCubit;
  CatalogCubit? _catalogCubit;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.getString('student_token') != null) {
        _userType = 'student';
        _userRole = 'student';
      } else if (prefs.getString('graduate_token') != null) {
        _userType = 'graduate';
        _userRole = 'graduate';
      }
    });
  }

  Future<void> _enroll(BuildContext context, dynamic id) async {
    try {
      final prefix = _userRole == 'graduate' ? '/graduate' : '/student';
      await ApiService.post(
        '$prefix/roadmaps/enroll',
        data: {'roadmapId': id},
        userType: _userType,
      );
      _snack('✅ Enrolled successfully!');
      if (context.mounted) {
        context.read<RoadmapCubit>().loadRoadmaps();
        context.read<CatalogCubit>().loadCatalog();
      }
    } catch (e) {
      _snack('❌ ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<void> _unenroll(BuildContext context, dynamic id) async {
    try {
      final prefix = _userRole == 'graduate' ? '/graduate' : '/student';
      await ApiService.delete(
        '$prefix/roadmaps/$id/unenroll',
        userType: _userType,
      );
      _snack('✅ Unenrolled successfully!');
      if (context.mounted) {
        context.read<RoadmapCubit>().loadRoadmaps();
        context.read<CatalogCubit>().loadCatalog();
      }
    } catch (e) {
      _snack('❌ ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(m),
      backgroundColor: kPrimary,
      behavior: SnackBarBehavior.floating,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final parentRoadmapCubit = () {
      try {
        return BlocProvider.of<RoadmapCubit>(context);
      } catch (_) {
        return null;
      }
    }();

    final parentCatalogCubit = () {
      try {
        return BlocProvider.of<CatalogCubit>(context);
      } catch (_) {
        return null;
      }
    }();

    if (parentRoadmapCubit != null) _roadmapCubit = parentRoadmapCubit;
    if (parentCatalogCubit != null) _catalogCubit = parentCatalogCubit;

    return MultiBlocProvider(
      providers: [
        if (parentRoadmapCubit != null)
          BlocProvider<RoadmapCubit>.value(value: parentRoadmapCubit)
        else
          BlocProvider<RoadmapCubit>(
            create: (c) {
              _roadmapCubit = RoadmapCubit(RoadmapService())..loadRoadmaps();
              return _roadmapCubit!;
            },
          ),
        if (parentCatalogCubit != null)
          BlocProvider<CatalogCubit>.value(value: parentCatalogCubit)
        else
          BlocProvider<CatalogCubit>(
            create: (c) {
              _catalogCubit = CatalogCubit(CatalogService())..loadCatalog();
              return _catalogCubit!;
            },
          ),
      ],
      child: Scaffold(
        backgroundColor: kBg,
        appBar: AppBar(
          backgroundColor: kPrimary,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Courses',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            controller: _tabs,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              BlocBuilder<CatalogCubit, CatalogState>(
                builder: (context, state) {
                  int count = 0;
                  if (state is CatalogSuccess)
                    count = state.catalogRoadmaps.length;
                  return Tab(text: 'All Courses ($count)');
                },
              ),
              BlocBuilder<RoadmapCubit, RoadmapState>(
                builder: (context, state) {
                  int count = 0;
                  if (state is RoadmapSuccess) count = state.myRoadmaps.length;
                  return Tab(text: 'My Courses ($count)');
                },
              ),
            ],
          ),
        ),
        body: Builder(
          builder: (context) {
            return TabBarView(
              controller: _tabs,
              children: [_buildAll(context), _buildMy(context)],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAll(BuildContext context) {
    return BlocBuilder<CatalogCubit, CatalogState>(
      builder: (context, state) {
        if (state is CatalogLoading) {
          return const Center(
            child: CircularProgressIndicator(color: kPrimary),
          );
        }
        if (state is CatalogError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text(
                  'Error loading catalog: ${state.message}',
                  style: TextStyle(color: Colors.grey[500]),
                ),
                TextButton(
                  onPressed: () => context.read<CatalogCubit>().loadCatalog(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        List<StudentRoadmap> catalog = [];
        if (state is CatalogSuccess) {
          catalog = state.catalogRoadmaps;
        }

        final filteredCatalog = catalog.where((c) {
          final t = c.title.toLowerCase();
          final p = c.company.toLowerCase();
          final l = c.level;

          final matchesSearch =
              _search.isEmpty ||
              t.contains(_search.toLowerCase()) ||
              p.contains(_search.toLowerCase());
          final matchesLevel = _level == 'All Levels' || l == _level;

          return matchesSearch && matchesLevel;
        }).toList();

        return Column(
          children: [
            Container(
              color: kPrimary,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.school_rounded,
                          color: Colors.white70,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${catalog.length} courses to enroll',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextField(
                    onChanged: (v) => setState(() => _search = v),
                    decoration: InputDecoration(
                      hintText: 'Search courses...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          ['All Levels', 'Beginner', 'Intermediate', 'Advanced']
                              .map(
                                (l) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () => setState(() => _level = l),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _level == l
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        l,
                                        style: TextStyle(
                                          color: _level == l
                                              ? kPrimary
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredCatalog.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No courses found',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.read<CatalogCubit>().loadCatalog(),
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () =>
                          context.read<CatalogCubit>().loadCatalog(),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          top: 16,
                          left: 16,
                          right: 16,
                          bottom: 80,
                        ),
                        itemCount: filteredCatalog.length,
                        itemBuilder: (_, i) => _courseCard(
                          context,
                          filteredCatalog[i],
                          enrolled: false,
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMy(BuildContext context) {
    return BlocBuilder<RoadmapCubit, RoadmapState>(
      builder: (context, state) {
        if (state is RoadmapLoading) {
          return const Center(
            child: CircularProgressIndicator(color: kPrimary),
          );
        }
        if (state is RoadmapError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text(
                  'Error loading my courses: ${state.message}',
                  style: TextStyle(color: Colors.grey[500]),
                ),
                TextButton(
                  onPressed: () => context.read<RoadmapCubit>().loadRoadmaps(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        List<StudentRoadmap> my = [];
        if (state is RoadmapSuccess) {
          my = state.myRoadmaps;
        }

        if (my.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text(
                  'No enrolled courses yet',
                  style: TextStyle(color: Colors.grey[500]),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _tabs.animateTo(0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Browse Courses'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<RoadmapCubit>().loadRoadmaps(),
          child: ListView.builder(
            padding: const EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: 80,
            ),
            itemCount: my.length,
            itemBuilder: (_, i) => _courseCard(context, my[i], enrolled: true),
          ),
        );
      },
    );
  }

  Widget _courseCard(
    BuildContext context,
    StudentRoadmap c, {
    required bool enrolled,
  }) {
    final id = c.id;
    final level = c.level.isNotEmpty ? c.level : 'Beginner';
    final levelColor = level == 'Advanced'
        ? const Color(0xffDC2626)
        : level == 'Intermediate'
        ? const Color(0xffD97706)
        : const Color(0xff16A34A);
    final progress = c.progress;

    final imageUrl = c.imageUrl ?? '';
    final hasImage = imageUrl.toString().isNotEmpty;
    final fullImageUrl = hasImage
        ? ApiConstants.getImageUrl(imageUrl.toString())
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimary.withOpacity(0.9), const Color(0xff0d5fa3)],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: (fullImageUrl.isNotEmpty)
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      fullImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.menu_book_rounded,
                            color: Colors.white.withOpacity(0.5),
                            size: 50,
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white.withOpacity(0.5),
                      size: 50,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.title.isNotEmpty ? c.title : 'Course',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  c.company,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (enrolled && progress > 0) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '${progress.toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: kPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 7,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation(kPrimary),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (level.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: levelColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          level,
                          style: TextStyle(
                            fontSize: 11,
                            color: levelColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (c.duration != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${c.duration} weeks',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => enrolled
                        ? _unenroll(context, id)
                        : _enroll(context, id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: enrolled
                          ? Colors.red.shade400
                          : kPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      enrolled ? 'Unenroll' : 'Enroll Now',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
