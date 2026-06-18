import 'package:flutter/material.dart';
import '../../../../data/services/api_service.dart';

class JobInternshipTracker extends StatefulWidget {
  const JobInternshipTracker({super.key});
  @override
  State<JobInternshipTracker> createState() => _JobInternshipTrackerState();
}

class _JobInternshipTrackerState extends State<JobInternshipTracker>
    with SingleTickerProviderStateMixin {
  static const Color kPrimary = Color(0xff1676C4);
  static const Color kBg = Color(0xffF0F9FF);

  late TabController _tabs;
  List<dynamic> _jobs = [],
      _internships = [],
      _myJobApps = [],
      _myInternApps = [];
  bool _loading = true;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.get(
          '/Jobs/available?page=1&pageSize=20',
          userType: 'graduate',
        ),
        ApiService.get('/internships?page=1&pageSize=20', userType: 'graduate'),
        ApiService.get(
          '/graduate/jobs/my-applications',
          userType: 'graduate',
        ).catchError((_) => []),
        ApiService.get(
          '/graduate/jobs/my-internship-applications',
          userType: 'graduate',
        ).catchError((_) => []),
      ]);
      setState(() {
        _jobs =
            (results[0] is List ? results[0] : results[0]?['data'] ?? [])
                as List;
        _internships =
            (results[1] is List ? results[1] : results[1]?['data'] ?? [])
                as List;
        _myJobApps =
            (results[2] is List ? results[2] : results[2]?['data'] ?? [])
                as List;
        _myInternApps =
            (results[3] is List ? results[3] : results[3]?['data'] ?? [])
                as List;
      });
    } catch (_) {
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _applyJob(dynamic id) async {
    try {
      await ApiService.post('/Jobs/$id/apply', userType: 'graduate');
      _snack('✅ Applied to job!');
      _load();
    } catch (e) {
      _snack('❌ ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<void> _applyIntern(dynamic id) async {
    try {
      await ApiService.post('/internships/$id/apply', userType: 'graduate');
      _snack('✅ Applied to internship!');
      _load();
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
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Job & Internship Tracker',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: 'Browse (${_jobs.length + _internships.length})'),
            Tab(text: 'My Apps (${_myJobApps.length + _myInternApps.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : TabBarView(
              controller: _tabs,
              children: [_buildBrowse(), _buildMyApps()],
            ),
    );
  }

  Widget _buildBrowse() {
    final all = [
      ..._jobs.map((j) => {...(j as Map), '_type': 'Job'}),
      ...(_internships.map((i) => {...(i as Map), '_type': 'Internship'})),
    ];
    final filtered = _filter == 'All'
        ? all
        : all.where((i) => i['_type'] == _filter).toList();
    return Column(
      children: [
        Container(
          color: kPrimary,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Job', 'Internship']
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
                              color: _filter == f ? kPrimary : Colors.white,
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
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.work_outline,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No opportunities found',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                      TextButton(
                        onPressed: _load,
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final item = filtered[i];
                      final isJob = item['_type'] == 'Job';
                      return _card(item, isJob: isJob);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildMyApps() {
    final all = [
      ..._myJobApps.map((j) => {...(j as Map), '_type': 'Job'}),
      ...(_myInternApps.map((i) => {...(i as Map), '_type': 'Internship'})),
    ];
    if (all.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No applications yet',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: all.length,
        itemBuilder: (_, i) => _appCard(all[i]),
      ),
    );
  }

  Widget _card(Map item, {required bool isJob}) {
    final id = item['id'] ?? item['jobId'] ?? item['internshipId'];
    final status = item['status'] ?? item['applicationStatus'] ?? '';
    final applied = item['isApplied'] == true || item['applied'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (isJob ? kPrimary : Colors.purple).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isJob ? Icons.work_rounded : Icons.business_center_rounded,
                  color: isJob ? kPrimary : Colors.purple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      item['companyName'] ?? item['company'] ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (isJob ? kPrimary : Colors.purple).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item['_type'] as String,
                  style: TextStyle(
                    color: isJob ? kPrimary : Colors.purple,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if ((item['description'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item['description'].toString(),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            children: [
              // if ((item['locationType'] ?? item['type'] ?? '')
              //     .toString()
              //     .isNotEmpty)
              //   _chip(
              //     Icons.location_on_outlined,
              //     item['locationType'] ?? item['type'] ?? '',
              //   ),
              if ((item['location'] ?? '').toString().isNotEmpty)
                _chip(Icons.map_outlined, item['location']),
              if ((item['experienceLevel'] ?? '').toString().isNotEmpty)
                _chip(Icons.trending_up, item['experienceLevel']),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: applied
                      ? null
                      : () => isJob ? _applyJob(id) : _applyIntern(id),
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: Text(
                    applied ? 'Applied ✓' : 'Apply Now',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: applied ? Colors.grey[400] : kPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _appCard(Map app) {
    final status = app['status'] ?? app['applicationStatus'] ?? 'Applied';
    final statusColors = {
      'Applied': [const Color(0xffDDEEFF), kPrimary],
      'Interview Scheduled': [const Color(0xffD1FAE5), const Color(0xff065F46)],
      'Rejected': [const Color(0xffFEE2E2), const Color(0xff991B1B)],
      'Accepted': [const Color(0xffD1FAE5), const Color(0xff065F46)],
    };
    final sc =
        statusColors[status] ??
        [const Color(0xffF3F4F6), const Color(0xff6B7280)];
    final progress = app['matchPercentage'] ?? app['progressPercentage'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimary.withOpacity(0.8), const Color(0xff0d5fa3)],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app['title']?.toString() ??
                              app['jobTitle']?.toString() ??
                              'Position',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          app['companyName']?.toString() ??
                              app['company']?.toString() ??
                              '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          app['_type'] as String,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: sc[0],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: sc[1],
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Applied: ${(app['appliedAt'] ?? app['applicationDate'] ?? '').toString().split('T').first}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                if (progress > 0) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Match',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '$progress%',
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: Colors.grey),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ],
  );
}
