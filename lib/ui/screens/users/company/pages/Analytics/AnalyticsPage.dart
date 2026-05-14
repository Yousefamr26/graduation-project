// ignore_for_file: avoid_print
import 'package:flutter/material.dart';

import '../../../../../../data/repositories/Analytics repository.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  final AnalyticsRepository _repo = AnalyticsRepository();

  late TabController _tabController;

  bool _isLoading = true;
  String? _errorMessage;

  Map<String, dynamic> _overview      = {};
  Map<String, dynamic> _roadmaps      = {};
  Map<String, dynamic> _jobs          = {};
  Map<String, dynamic> _internships   = {};
  Map<String, dynamic> _workshops     = {};
  Map<String, dynamic> _events        = {};
  Map<String, dynamic> _interviews    = {};
  Map<String, dynamic> _interviewsOT  = {};
  Map<String, dynamic> _universities  = {};

  Map<String, dynamic> get _ov => _overview;

  final List<_TabItem> _tabs = const [
    _TabItem(icon: Icons.dashboard_outlined,      label: 'Overview'),
    _TabItem(icon: Icons.map_outlined,             label: 'Roadmaps'),
    _TabItem(icon: Icons.work_outline,             label: 'Jobs'),
    _TabItem(icon: Icons.school_outlined,          label: 'Internships'),
    _TabItem(icon: Icons.construction_outlined,    label: 'Workshops'),
    _TabItem(icon: Icons.event_outlined,           label: 'Events'),
    _TabItem(icon: Icons.videocam_outlined,        label: 'Interviews'),
    _TabItem(icon: Icons.account_balance_outlined, label: 'Universities'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final data = await _repo.fetchAllAnalytics();
      if (!mounted) return;
      setState(() {
        _overview     = data['overview']     ?? {};
        _roadmaps     = data['roadmaps']     ?? {};
        _jobs         = data['jobs']         ?? {};
        _internships  = data['internships']  ?? {};
        _workshops    = data['workshops']    ?? {};
        _events       = data['events']       ?? {};
        _interviews   = data['interviews']   ?? {};
        _interviewsOT = data['interviewsOT'] ?? {};
        _universities = data['universities'] ?? {};
        _isLoading    = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _errorMessage = e.toString(); _isLoading = false; });
    }
  }

  String _str(dynamic v, {String fallback = '—'}) =>
      v != null && v.toString().isNotEmpty && v.toString() != 'null'
          ? v.toString()
          : fallback;

  String _num(dynamic v, {String fallback = '0'}) {
    if (v == null) return fallback;
    if (v is Map) {
      final inner = v['value'];
      return _num(inner, fallback: fallback);
    }
    if (v is double) return v.toStringAsFixed(v == v.roundToDouble() ? 0 : 1);
    return v.toString();
  }

  dynamic _nested(Map<String, dynamic> root, List<String> keys) {
    dynamic cur = root;
    for (final k in keys) {
      if (cur is Map && cur.containsKey(k)) {
        cur = cur[k];
      } else {
        return null;
      }
    }
    return cur;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: const Color(0xff1676C4),
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff1676C4), Color(0xff1676C4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Analytics",
                                style: TextStyle(fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            SizedBox(height: 4),
                            Text("Track your performance",
                                style: TextStyle(fontSize: 13,
                                    color: Colors.white70)),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _loadAll,
                          icon: const Icon(Icons.refresh_rounded,
                              color: Colors.white, size: 26),
                          tooltip: 'Refresh',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                tabs: _tabs
                    .map((t) => Tab(icon: Icon(t.icon, size: 18), text: t.label))
                    .toList(),
              ),
            ),
          ),
        ],
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xff1676C4)))
            : _errorMessage != null
            ? _buildError()
            : TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildRoadmapsTab(),
            _buildJobsTab(),
            _buildInternshipsTab(),
            _buildWorkshopsTab(),
            _buildEventsTab(),
            _buildInterviewsTab(),
            _buildUniversitiesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Failed to load analytics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_errorMessage ?? '',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadAll,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff1676C4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return _scrollPad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Dashboard Overview'),
          if (_ov.isEmpty)
            _emptyState('No overview data available')
          else ...[
            _twoColGrid([
              _statCard(icon: Icons.map_outlined, label: 'Total Roadmaps', value: _num(_nested(_ov, ['roadmap', 'totalRoadmaps'])), color: const Color(0xff1676C4)),
              _statCard(icon: Icons.map_outlined, label: 'Active Roadmaps', value: _num(_nested(_ov, ['roadmap', 'activeRoadmaps'])), color: const Color(0xff0d55a0)),
              _statCard(icon: Icons.work_outline, label: 'Job Postings', value: _num(_nested(_ov, ['jobs', 'totalJobPostings'])), color: const Color(0xff2ecc71)),
              _statCard(icon: Icons.description_outlined, label: 'Applications', value: _num(_nested(_ov, ['jobs', 'totalApplications'])), color: const Color(0xff27ae60)),
              _statCard(icon: Icons.construction_outlined, label: 'Workshops', value: _num(_nested(_ov, ['workshops', 'totalWorkshops'])), color: const Color(0xffe67e22)),
              _statCard(icon: Icons.event_outlined, label: 'Events', value: _num(_nested(_ov, ['events', 'totalEvents'])), color: const Color(0xff9b59b6)),
              _statCard(icon: Icons.videocam_outlined, label: 'Interviews', value: _num(_nested(_ov, ['interviews', 'totalInterviews'])), color: const Color(0xffe74c3c)),
              _statCard(icon: Icons.school_outlined, label: 'Internship Programs', value: _num(_nested(_ov, ['internships', 'activePrograms'])), color: const Color(0xff1abc9c)),
            ]),
            const SizedBox(height: 16),
            _sectionTitle('Jobs Summary'),
            _twoColGrid([
              _statCard(icon: Icons.trending_up, label: 'Interview Rate', value: '${_num(_nested(_ov, ['jobs', 'interviewRate']))}%', color: const Color(0xff3498db)),
              _statCard(icon: Icons.how_to_reg_outlined, label: 'Hiring Rate', value: '${_num(_nested(_ov, ['jobs', 'hiringSuccessRate']))}%', color: const Color(0xff2ecc71)),
            ]),
            const SizedBox(height: 16),
            _sectionTitle('Internships Summary'),
            _twoColGrid([
              _statCard(icon: Icons.people_outline, label: 'Total Applicants', value: _num(_nested(_ov, ['internships', 'totalApplicants'])), color: const Color(0xff1abc9c)),
              _statCard(icon: Icons.percent_outlined, label: 'Acceptance Rate', value: '${_num(_nested(_ov, ['internships', 'acceptanceRate']))}%', color: const Color(0xff16a085)),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildRoadmapsTab() {
    return _scrollPad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Roadmaps Analytics'),
          if (_roadmaps.isEmpty)
            _emptyState('No roadmaps analytics available')
          else ...[
            _twoColGrid([
              _statCard(icon: Icons.map_outlined, label: 'Total Roadmaps', value: _num(_roadmaps['totalRoadmaps']), color: const Color(0xff1676C4)),
              _statCard(icon: Icons.check_circle_outline, label: 'Active Roadmaps', value: _num(_roadmaps['activeRoadmaps']), color: const Color(0xff2ecc71)),
              _statCard(icon: Icons.people_outline, label: 'Total Enrolled', value: _num(_roadmaps['totalEnrolled']), color: const Color(0xff9b59b6)),
              _statCard(icon: Icons.trending_up_outlined, label: 'Completion Rate', value: '${_num(_roadmaps['completionRate'])}%', color: const Color(0xff1abc9c)),
              _statCard(icon: Icons.show_chart, label: 'Avg Progress', value: '${_num(_roadmaps['avgProgress'])}%', color: const Color(0xffe67e22)),
            ]),
            const SizedBox(height: 16),
            if (_roadmaps['distributionByTargetRole'] is Map) ...[
              _sectionTitle('Distribution by Target Role'),
              _buildKeyValueCard(Map<String, dynamic>.from(_roadmaps['distributionByTargetRole'] as Map), color: const Color(0xff1676C4)),
            ],
            _buildRawDataCard('All Roadmap Fields', _roadmaps),
          ],
        ],
      ),
    );
  }

  Widget _buildJobsTab() {
    return _scrollPad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Jobs Analytics'),
          if (_jobs.isEmpty)
            _emptyState('No jobs analytics available')
          else ...[
            _twoColGrid([
              _statCard(icon: Icons.work_outline, label: 'Total Job Postings', value: _num(_jobs['totalJobPostings']), color: const Color(0xff1676C4)),
              _statCard(icon: Icons.description_outlined, label: 'Total Applications', value: _num(_jobs['totalApplications']), color: const Color(0xff2ecc71)),
              _statCard(icon: Icons.trending_up, label: 'Interview Rate', value: '${_num(_jobs['interviewRate'])}%', color: const Color(0xffe67e22)),
              _statCard(icon: Icons.how_to_reg_outlined, label: 'Hiring Success Rate', value: '${_num(_jobs['hiringSuccessRate'])}%', color: const Color(0xff9b59b6)),
            ]),
            const SizedBox(height: 16),
            if (_jobs['byTypeAndLevel'] is Map) ...[
              _sectionTitle('By Type & Level'),
              _buildKeyValueCard(Map<String, dynamic>.from(_jobs['byTypeAndLevel'] as Map), color: const Color(0xff2ecc71)),
            ],
            _buildRawDataCard('All Jobs Fields', _jobs),
          ],
        ],
      ),
    );
  }

  Widget _buildInternshipsTab() {
    return _scrollPad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Internships Analytics'),
          if (_internships.isEmpty)
            _emptyState('No internships analytics available')
          else ...[
            _twoColGrid([
              _statCard(icon: Icons.school_outlined, label: 'Active Programs', value: _num(_internships['activePrograms']), color: const Color(0xff1abc9c)),
              _statCard(icon: Icons.people_outline, label: 'Total Applicants', value: _num(_internships['totalApplicants']), color: const Color(0xff1676C4)),
              _statCard(icon: Icons.percent_outlined, label: 'Acceptance Rate', value: '${_num(_internships['acceptanceRate'])}%', color: const Color(0xff9b59b6)),
            ]),
            _buildRawDataCard('All Internship Fields', _internships),
          ],
        ],
      ),
    );
  }

  Widget _buildWorkshopsTab() {
    return _scrollPad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Workshops Analytics'),
          if (_workshops.isEmpty)
            _emptyState('No workshops analytics available')
          else ...[
            _twoColGrid([
              _statCard(icon: Icons.construction_outlined, label: 'Total Workshops', value: _num(_workshops['totalWorkshops']), color: const Color(0xffe67e22)),
              _statCard(icon: Icons.people_outline, label: 'Total Participants', value: _num(_workshops['totalParticipants']), color: const Color(0xff1676C4)),
              _statCard(icon: Icons.trending_up, label: 'Attendance Rate', value: '${_num(_workshops['attendanceRate'])}%', color: const Color(0xff2ecc71)),
            ]),
            const SizedBox(height: 16),
            if (_workshops['byType'] is Map) ...[
              _sectionTitle('By Type'),
              _buildKeyValueCard(Map<String, dynamic>.from(_workshops['byType'] as Map), color: const Color(0xffe67e22)),
            ],
            _buildRawDataCard('All Workshop Fields', _workshops),
          ],
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    return _scrollPad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Events Analytics'),
          if (_events.isEmpty)
            _emptyState('No events analytics available')
          else ...[
            _twoColGrid([
              _statCard(icon: Icons.event_outlined, label: 'Total Events', value: _num(_events['totalEvents']), color: const Color(0xff9b59b6)),
              _statCard(icon: Icons.app_registration_outlined, label: 'Total Registrations', value: _num(_events['totalRegistrations']), color: const Color(0xff1676C4)),
              _statCard(icon: Icons.trending_up, label: 'Attendance Rate', value: '${_num(_events['attendanceRate'])}%', color: const Color(0xffe67e22)),
            ]),
            const SizedBox(height: 16),
            if (_events['byMode'] is Map) ...[
              _sectionTitle('By Mode'),
              _buildKeyValueCard(Map<String, dynamic>.from(_events['byMode'] as Map), color: const Color(0xff9b59b6)),
            ],
            _buildRawDataCard('All Event Fields', _events),
          ],
        ],
      ),
    );
  }

  Widget _buildInterviewsTab() {
    return _scrollPad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Interviews Analytics'),
          if (_interviews.isEmpty)
            _emptyState('No interviews analytics available')
          else ...[
            _twoColGrid([
              _statCard(icon: Icons.videocam_outlined, label: 'Total Interviews', value: _num(_interviews['totalInterviews']), color: const Color(0xffe74c3c)),
              _statCard(icon: Icons.schedule_outlined, label: 'Scheduled', value: _num(_interviews['scheduledCount']), color: const Color(0xff1676C4)),
              _statCard(icon: Icons.check_circle_outline, label: 'Completed', value: _num(_interviews['completedCount']), color: const Color(0xff2ecc71)),
              _statCard(icon: Icons.people_outline, label: 'Attendance Rate', value: '${_num(_interviews['attendanceRate'])}%', color: const Color(0xffe67e22)),
              _statCard(icon: Icons.how_to_reg_outlined, label: 'Hiring Rate', value: '${_num(_interviews['hiringRate'])}%', color: const Color(0xff9b59b6)),
            ]),
            if (_interviewsOT.isNotEmpty) ...[
              const SizedBox(height: 16),
              _sectionTitle('Completion Rate Over Time'),
              _buildKeyValueCard(_interviewsOT, color: const Color(0xffe74c3c)),
            ],
            if (_interviews['completionRateOverTime'] is Map &&
                (_interviews['completionRateOverTime'] as Map).isNotEmpty) ...[
              const SizedBox(height: 16),
              _sectionTitle('Completion Rate Over Time'),
              _buildKeyValueCard(Map<String, dynamic>.from(_interviews['completionRateOverTime'] as Map), color: const Color(0xff1abc9c)),
            ],
            _buildRawDataCard('All Interview Fields', _interviews),
          ],
        ],
      ),
    );
  }

  Widget _buildUniversitiesTab() {
    return _scrollPad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Universities Analytics'),
          if (_universities.isEmpty)
            _emptyState('No universities analytics available')
          else ...[
            _twoColGrid([
              _statCard(icon: Icons.account_balance_outlined, label: 'Active Partners', value: _num(_universities['totalActivePartners']), color: const Color(0xff1abc9c)),
              _statCard(icon: Icons.handshake_outlined, label: 'New Partnerships', value: _num(_universities['newPartnerships']), color: const Color(0xff9b59b6)),
              _statCard(icon: Icons.star_outline, label: 'Most Active Campus', value: _str(_universities['mostActiveCampus']), color: const Color(0xfff39c12), small: true),
            ]),
            _buildRawDataCard('All University Fields', _universities),
          ],
        ],
      ),
    );
  }

  // ✅ التعديل هنا: أضفنا bottom: 40 في الـ padding
  Widget _scrollPad({required Widget child}) =>
      SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: child,
      );

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 4, height: 22,
            decoration: BoxDecoration(
                color: const Color(0xff1676C4),
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff1a1a2e))),
        ],
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.analytics_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(msg, style: TextStyle(color: Colors.grey[500], fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _twoColGrid(List<Widget> children) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12, mainAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: children,
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool small = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(fontSize: small ? 13 : 20, fontWeight: FontWeight.bold, color: const Color(0xff1a1a2e)),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyValueCard(Map<String, dynamic> data, {required Color color}) {
    final entries = data.entries
        .where((e) => e.value != null && e.value is! Map && e.value is! List)
        .toList();
    if (entries.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: entries.map((e) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Expanded(child: Text(e.key, style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
                Text(e.value.toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xff1a1a2e))),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRawDataCard(String title, Map<String, dynamic> data) {
    final filtered = Map.fromEntries(
        data.entries.where((e) => e.value != null && e.value is! List && e.value is! Map));
    if (filtered.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('All Fields'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: filtered.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: Text(_camelToLabel(e.key), style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500))),
                    Expanded(flex: 5, child: Text(e.value.toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xff1a1a2e)), textAlign: TextAlign.end)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _camelToLabel(String key) {
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[0]}')
        .replaceFirst(RegExp(r'^\s'), '')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }
}

// ─────────────────────────────────────────────────────────────
// TabBar Delegate
// ─────────────────────────────────────────────────────────────
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xff1676C4),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}