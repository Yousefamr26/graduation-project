import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/Constants/apiConstants.dart';
import '../../../../data/services/api_service.dart';
import '../../../../data/services/RoadmapService.dart';
import '../../../../data/services/CatalogService.dart';
import '../../../../data/models/Student/student-roadmap-model.dart';
import 'cubit/roadmap/roadmap_cubit.dart';
import 'cubit/roadmap/roadmap_state.dart';
import 'cubit/catalog/catalog_cubit.dart';
import 'cubit/catalog/catalog_state.dart';

class RoadmapExplorerScreen extends StatefulWidget {
  final bool showBackButton;
  final int initialTab;
  const RoadmapExplorerScreen({
    super.key,
    this.showBackButton = true,
    this.initialTab = 0,
  });

  @override
  State<RoadmapExplorerScreen> createState() => _RoadmapExplorerScreenState();
}

class _RoadmapExplorerScreenState extends State<RoadmapExplorerScreen>
    with SingleTickerProviderStateMixin {
  static const Color kPrimary = Color(0xff1676C4);
  static const Color kBg = Color(0xffF0F9FF);

  late TabController _tabs;
  String _search = '', _filter = 'ALL';
  String? _userType;
  String _userRole = 'student';
  RoadmapCubit? _roadmapCubit;
  CatalogCubit? _catalogCubit;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
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
      _snack('✅ Unenrolled');
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

    if (parentRoadmapCubit != null) {
      _roadmapCubit = parentRoadmapCubit;
    }
    if (parentCatalogCubit != null) {
      _catalogCubit = parentCatalogCubit;
    }

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
          leading: widget.showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
          title: const Text(
            'Roadmap Explorer',
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
                  if (state is CatalogSuccess) {
                    count = state.catalogRoadmaps.length;
                  }
                  return Tab(text: 'Catalog ($count)');
                },
              ),
              BlocBuilder<RoadmapCubit, RoadmapState>(
                builder: (context, state) {
                  int count = 0;
                  if (state is RoadmapSuccess) {
                    count = state.myRoadmaps.length;
                  }
                  return Tab(text: 'My Roadmaps ($count)');
                },
              ),
            ],
          ),
        ),
        body: Builder(
          builder: (context) {
            return TabBarView(
              controller: _tabs,
              children: [_buildCatalog(context), _buildMyRoadmaps(context)],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCatalog(BuildContext context) {
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
                Icon(Icons.map_outlined, size: 64, color: Colors.grey[300]),
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

        final filteredCatalog = catalog.where((r) {
          final t = r.title.toLowerCase();
          final d = r.description.toLowerCase();
          final categoryFieldRole = '${r.category} ${r.field} ${r.targetRole}'
              .toLowerCase();
          final skillsCombined = r.skills.join(' ').toLowerCase();

          final textToSearch = '$t $d $categoryFieldRole $skillsCombined';

          // Search filtering
          final matchesSearch =
              _search.isEmpty ||
              t.contains(_search.toLowerCase()) ||
              d.contains(_search.toLowerCase()) ||
              skillsCombined.contains(_search.toLowerCase());

          // Filter tag mapping
          bool matchesFilter = false;
          if (_filter == 'ALL') {
            matchesFilter = true;
          } else if (_filter == 'AI') {
            matchesFilter =
                textToSearch.contains('ai') ||
                textToSearch.contains('data science') ||
                textToSearch.contains('python') ||
                textToSearch.contains('machine learning');
          } else if (_filter == 'WEB') {
            matchesFilter =
                textToSearch.contains('web') ||
                textToSearch.contains('frontend') ||
                textToSearch.contains('html') ||
                textToSearch.contains('css') ||
                textToSearch.contains('react') ||
                textToSearch.contains('devops') ||
                textToSearch.contains('software');
          } else if (_filter == 'DATA') {
            matchesFilter =
                textToSearch.contains('data') ||
                textToSearch.contains('database') ||
                textToSearch.contains('sql') ||
                textToSearch.contains('python');
          } else if (_filter == 'MOBILE') {
            matchesFilter =
                textToSearch.contains('mobile') ||
                textToSearch.contains('flutter') ||
                textToSearch.contains('android') ||
                textToSearch.contains('ios');
          }

          return matchesSearch && matchesFilter;
        }).toList();

        return Column(
          children: [
            Container(
              color: kPrimary,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI Recommendation: Based on your skills, we suggest starting with available roadmaps that match your profile',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextField(
                    onChanged: (v) => setState(() => _search = v),
                    decoration: InputDecoration(
                      hintText: 'Search roadmaps by title or field...',
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
                      children: ['ALL', 'AI', 'WEB', 'DATA', 'MOBILE']
                          .map(
                            (f) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setState(() => _filter = f),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _filter == f
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    f,
                                    style: TextStyle(
                                      color: _filter == f
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
                            Icons.map_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No roadmaps found',
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
                        padding: EdgeInsets.fromLTRB(
                          16,
                          16,
                          16,
                          widget.showBackButton ? 16 : 100,
                        ),
                        itemCount: filteredCatalog.length,
                        itemBuilder: (_, i) => _roadmapCard(
                          context,
                          filteredCatalog[i],
                          isMyTab: false,
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMyRoadmaps(BuildContext context) {
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
                Icon(Icons.map_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text(
                  'Error loading my roadmaps: ${state.message}',
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
                Icon(Icons.map_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text(
                  'No enrolled roadmaps yet',
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
                  child: const Text('Browse Catalog'),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => context.read<RoadmapCubit>().loadRoadmaps(),
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              widget.showBackButton ? 16 : 100,
            ),
            itemCount: my.length,
            itemBuilder: (_, i) => _roadmapCard(context, my[i], isMyTab: true),
          ),
        );
      },
    );
  }

  Widget _roadmapCard(
    BuildContext context,
    StudentRoadmap r, {
    required bool isMyTab,
  }) {
    final id = r.id;
    final progress = r.progress;
    final level = r.level;
    final duration = r.duration;

    final imageUrl = r.imageUrl ?? '';
    final hasImage = imageUrl.toString().isNotEmpty;
    final fullImageUrl = hasImage
        ? ApiConstants.getImageUrl(imageUrl.toString())
        : '';

    final skills = r.skills;

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
        children: [
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimary.withOpacity(0.85), const Color(0xff0d5fa3)],
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
                        log(fullImageUrl);
                        return Center(
                          child: Icon(
                            Icons.route_rounded,
                            color: Colors.white.withOpacity(0.5),
                            size: 50,
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.route_rounded,
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        r.title.isNotEmpty ? r.title : 'Roadmap',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  r.company.isNotEmpty ? r.company : '',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 6),
                if (r.description.isNotEmpty)
                  Text(
                    r.description,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 10),
                if (isMyTab) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation(kPrimary),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (level.isNotEmpty)
                      _tag(level, const Color(0xffDDEEFF), kPrimary),
                    if (duration != null)
                      _tag(
                        '$duration weeks',
                        const Color(0xffF3F4F6),
                        Colors.grey[700]!,
                      ),
                    if (isMyTab)
                      ...skills.map(
                        (s) => _tag(
                          s,
                          Colors.green.withOpacity(0.1),
                          Colors.green[700]!,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        isMyTab ? _unenroll(context, id) : _enroll(context, id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isMyTab ? Colors.red.shade400 : kPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      isMyTab ? 'Unenroll' : 'Join Roadmap',
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

  Widget _tag(String t, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      t,
      style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600),
    ),
  );
}
