import 'package:flutter/material.dart';
import '../../../../../../data/models/company/application-model.dart';
import '../../../../../../data/repositories/Applications repository.dart';
import '../../../../../../data/repositories/Profile repository.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  final _repo        = ApplicationsRepository();
  final _profileRepo = ProfileRepository();

  List<ApplicationModel> _all      = [];
  List<ApplicationModel> _filtered = [];
  bool   _isLoading   = true;
  String _error       = '';
  String _searchText  = '';
  String _selectedTab = 'Job';
  bool   _isUpdating  = false;

  int get _jobCount        => _all.where((a) => a.applicationType == 'Job').length;
  int get _internshipCount => _all.where((a) => a.applicationType == 'Internship').length;

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = ''; });
    try {
      final data = await _repo.getMyApplications();
      if (!mounted) return;
      setState(() { _all = data; _isLoading = false; });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  void _applyFilters() {
    setState(() {
      _filtered = _all.where((app) {
        if (_selectedTab == 'Internship' && app.applicationType != 'Internship') return false;
        if (_selectedTab == 'Job' && app.applicationType != 'Job') return false;
        if (_searchText.isEmpty) return true;
        final q = _searchText.toLowerCase();
        return app.applicantName.toLowerCase().contains(q) ||
            app.position.toLowerCase().contains(q);
      }).toList();
    });
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Under Review':        return Colors.orange;
      case 'Shortlisted':         return Colors.blue;
      case 'Interview Scheduled': return Colors.purple;
      case 'Accepted':            return Colors.green;
      case 'Rejected':            return Colors.red;
      default:                    return Colors.grey;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'Under Review':        return Icons.rate_review;
      case 'Shortlisted':         return Icons.star;
      case 'Interview Scheduled': return Icons.event_available;
      case 'Accepted':            return Icons.check_circle;
      case 'Rejected':            return Icons.cancel;
      default:                    return Icons.help;
    }
  }

  Future<void> _updateStatus(ApplicationModel app, String newStatus) async {
    setState(() => _isUpdating = true);

    final isInternship = app.applicationType == 'Internship';
    final id           = isInternship ? (app.internshipId ?? 0) : (app.jobId ?? 0);

    final ok = await _repo.updateApplicationStatus(
      id,
      app.id,
      newStatus,
      isInternship: isInternship,
    );

    if (!mounted) return;
    final idx = _all.indexWhere((a) => a.id == app.id);
    if (idx != -1) {
      setState(() {
        _all[idx] = app.copyWith(status: newStatus);
        _isUpdating = false;
      });
      _applyFilters();
    } else {
      setState(() => _isUpdating = false);
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Status updated to $newStatus' : 'Updated locally (network issue)'),
      backgroundColor: ok ? Colors.green : Colors.orange,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _showProfileDialog(ApplicationModel app) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(color: Color(0xff1676C4)),
              SizedBox(height: 16),
              Text('Loading profile...'),
            ]),
          ),
        ),
      ),
    );

    final userId = app.userId;
    Map<String, dynamic>? profile;

    if (userId != null && userId.isNotEmpty) {
      profile = await _profileRepo.getProfileSummary(userId);
    }

    if (!mounted) return;
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (_) => _ProfileDialog(
        app: app,
        profile: profile,
        statusColor: _statusColor,
        statusIcon: _statusIcon,
        onUpdateStatus: () => _showStatusDialog(app),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(children: [
        Column(children: [
          _buildAppBar(),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xff1676C4))))
          else if (_error.isNotEmpty)
            Expanded(child: _buildError())
          else
            Expanded(child: _buildContent()),
        ]),
        if (_isUpdating)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(child: Card(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: Color(0xff1676C4))))),
          ),
      ]),
    );
  }

  Widget _buildAppBar() => Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      color: Color(0xff1676C4),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
    ),
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 80,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Applications', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500)),
              SizedBox(height: 4),
              Text('View and manage job & internship applications', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w300)),
            ],
          ),
          actions: [
            IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _fetchApplications, tooltip: 'Refresh'),
          ],
        ),
      ),
    ),
  );

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.wifi_off_rounded, size: 80, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text('Failed to load applications', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _fetchApplications,
          icon: const Icon(Icons.refresh),
          label: const Text('Try Again'),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff1676C4), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ]),
    ),
  );

  Widget _buildContent() => SingleChildScrollView(
    child: Column(children: [
      _buildTabBar(),
      _buildSearchBar(),
      _all.isEmpty ? _buildEmptyState() : _filtered.isEmpty ? _buildNoResults() : _buildTable(),
      const SizedBox(height: 24),
    ]),
  );

  Widget _buildTabBar() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: Row(children: [
      _tab('Job', 'Jobs ($_jobCount)'),
      const SizedBox(width: 12),
      _tab('Internship', 'Internships ($_internshipCount)'),
    ]),
  );

  Widget _tab(String value, String label) => Expanded(
    child: GestureDetector(
      onTap: () { setState(() => _selectedTab = value); _applyFilters(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: _selectedTab == value ? const Color(0xff1676C4) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _selectedTab == value ? const Color(0xff1676C4) : Colors.grey[300]!, width: _selectedTab == value ? 2 : 1),
          boxShadow: _selectedTab == value ? [BoxShadow(color: const Color(0xff1676C4).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : [],
        ),
        child: Text(label, style: TextStyle(color: _selectedTab == value ? Colors.white : Colors.grey[700], fontWeight: FontWeight.w600, fontSize: 13), textAlign: TextAlign.center),
      ),
    ),
  );

  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.all(16),
    child: TextField(
      decoration: InputDecoration(
        hintText: 'Search by name or position…',
        prefixIcon: const Icon(Icons.search, color: Color(0xff1676C4)),
        suffixIcon: _searchText.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { setState(() => _searchText = ''); _applyFilters(); }) : null,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xff1676C4), width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      onChanged: (v) { setState(() => _searchText = v); _applyFilters(); },
    ),
  );

  Widget _buildEmptyState() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 60),
    child: Column(children: [
      Icon(Icons.description_outlined, size: 80, color: Colors.grey[300]),
      const SizedBox(height: 16),
      Text('No applications yet', style: TextStyle(fontSize: 18, color: Colors.grey[500])),
    ]),
  );

  Widget _buildNoResults() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 60),
    child: Column(children: [
      Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
      const SizedBox(height: 12),
      Text('No results for "$_searchText"', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
    ]),
  );

  // ════════════════════════════════════════════════════════════════
  // TABLE — columns & rows change based on selected tab
  // ════════════════════════════════════════════════════════════════
  Widget _buildTable() {
    final isInternship = _selectedTab == 'Internship';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 52,
              dataRowMinHeight: 64,
              dataRowMaxHeight: 80,
              dividerThickness: 0.5,
              headingRowColor: MaterialStateProperty.all(const Color(0xff1676C4).withOpacity(0.08)),
              columns: [
                _col('Applicant'),
                _col(isInternship ? 'Internship' : 'Job'),
                if (isInternship) _col('Duration'),
                _col('Applied'),
                _col('Status'),
                _col('Actions'),
              ],
              rows: _filtered.map((app) => _buildRow(app, isInternship)).toList(),
            ),
          ),
        ),
      ),
    );
  }

  DataColumn _col(String label) => DataColumn(
    label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff1676C4))),
  );

  DataRow _buildRow(ApplicationModel app, bool isInternship) => DataRow(
    color: MaterialStateProperty.resolveWith(
            (states) => states.contains(MaterialState.hovered) ? Colors.grey[50] : null),
    cells: [
      // ── Applicant ──
      DataCell(Row(children: [
        CircleAvatar(
          backgroundColor: const Color(0xff1676C4),
          radius: 18,
          child: Text(
            app.applicantName.isNotEmpty ? app.applicantName[0] : '?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(app.applicantName,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text(
              app.degreeLevel != 'N/A' ? app.degreeLevel : 'Applicant',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
      ])),

      // ── Position (Job title or Internship title + company) ──
      DataCell(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xff1676C4).withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              app.position,
              style: const TextStyle(fontSize: 12, color: Color(0xff1676C4)),
            ),
          ),
          if (isInternship &&
              app.companyName != null &&
              app.companyName!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                app.companyName!,
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ),
        ],
      )),

      // ── Duration (Internship tab only) ──
      if (isInternship)
        DataCell(Row(children: [
          Icon(Icons.schedule_outlined, size: 13, color: Colors.grey[400]),
          const SizedBox(width: 4),
          Text(
            app.year?.isNotEmpty == true ? app.year! : '—',
            style: const TextStyle(fontSize: 12),
          ),
        ])),

      // ── Applied Date ──
      DataCell(Text(
        app.appliedDate.isEmpty ? '—' : app.appliedDate,
        style: const TextStyle(fontSize: 12),
      )),

      // ── Status ──
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: _statusColor(app.status).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _statusColor(app.status).withOpacity(0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(_statusIcon(app.status), size: 12, color: _statusColor(app.status)),
          const SizedBox(width: 4),
          Text(
            app.status,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _statusColor(app.status)),
          ),
        ]),
      )),

      // ── Actions ──
      DataCell(Row(children: [
        _actionBtn(
            icon: Icons.person_outline,
            tooltip: 'View Profile',
            color: const Color(0xff1676C4),
            onTap: () => _showProfileDialog(app)),
        const SizedBox(width: 6),
        _actionBtn(
            icon: Icons.edit_note,
            tooltip: 'Update Status',
            color: Colors.orange,
            onTap: () => _showStatusDialog(app)),
      ])),
    ],
  );

  Widget _actionBtn({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onTap,
  }) =>
      Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      );

  void _showStatusDialog(ApplicationModel app) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Update Status', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(app.applicantName, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Under Review', 'Shortlisted', 'Interview Scheduled', 'Accepted', 'Rejected']
              .map((s) => _statusOption(app, s))
              .toList(),
        ),
      ),
    );
  }

  Widget _statusOption(ApplicationModel app, String status) {
    final isSelected = app.status == status;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? _statusColor(status).withOpacity(0.08) : null,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: _statusColor(status).withOpacity(0.3)) : null,
      ),
      child: ListTile(
        dense: true,
        leading: Icon(_statusIcon(status), color: _statusColor(status), size: 22),
        title: Text(status,
            style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        trailing: isSelected ? Icon(Icons.check, color: _statusColor(status)) : null,
        onTap: () { Navigator.pop(context); _updateStatus(app, status); },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// PROFILE DIALOG WIDGET
// ══════════════════════════════════════════════════════════════════
class _ProfileDialog extends StatelessWidget {
  final ApplicationModel app;
  final Map<String, dynamic>? profile;
  final Color Function(String) statusColor;
  final IconData Function(String) statusIcon;
  final VoidCallback onUpdateStatus;

  const _ProfileDialog({
    required this.app,
    required this.profile,
    required this.statusColor,
    required this.statusIcon,
    required this.onUpdateStatus,
  });

  String _s(Map<String, dynamic>? m, String k, [String fallback = '']) =>
      m?[k]?.toString() ?? fallback;

  int _i(Map<String, dynamic>? m, String k, [int fallback = 0]) =>
      int.tryParse((m?[k] ?? fallback).toString()) ?? fallback;

  double _d(Map<String, dynamic>? m, String k, [double fallback = 0]) =>
      double.tryParse((m?[k] ?? fallback).toString()) ?? fallback;

  @override
  Widget build(BuildContext context) {
    final raw = profile ?? {};

    final basic = (raw['basicInfo'] as Map<String, dynamic>?)     ?? raw;
    final stats = (raw['stats']     as Map<String, dynamic>?)     ?? (raw['statistics'] as Map<String, dynamic>?);
    final skills       = (raw['skills']           as List?) ?? (raw['userSkills'] as List?);
    final achievements = (raw['achievements']     as List?) ?? (raw['badges']     as List?);
    final roadmaps     = (raw['roadmapsProgress'] as List?) ?? (raw['roadmaps']   as List?);
    final experiences  = (raw['experiences']      as List?) ?? (raw['workExperience'] as List?);
    final educations   = (raw['educations']       as List?) ?? (raw['education']  as List?);

    final name       = _s(basic, 'fullName',   app.applicantName);
    final email      = _s(basic, 'email',      app.email);
    final phone      = _s(basic, 'phoneNumber', app.phoneNumber ?? '');
    final country    = _s(basic, 'country');
    final city       = _s(basic, 'city');
    final major      = _s(basic, 'major');
    final degree     = _s(basic, 'degree',     _s(basic, 'degreeLevel', app.degreeLevel));
    final university = _s(basic, 'university', _s(basic, 'universityName', app.university ?? ''));
    final github     = _s(basic, 'gitHub',     _s(basic, 'github'));
    final linkedin   = _s(basic, 'linkedIn',   _s(basic, 'linkedin', app.linkedIn ?? ''));
    final portfolio  = _s(basic, 'portfolio',  app.portfolio ?? '');
    final summary    = _s(basic, 'experienceSummary', _s(basic, 'bio'));
    final rawPhoto = _s(basic, 'profileImage', _s(basic, 'profilePicture'));
    final photoUrl = rawPhoto.startsWith('http')
        ? rawPhoto
        : rawPhoto.isNotEmpty
        ? 'http://smartcareerhub.runasp.net$rawPhoto'
        : '';
    final cvUrl      = _s(basic, 'cvUrl',      app.cvUrl ?? '');

    final totalPoints       = _i(stats, 'totalPoints',          _i(stats, 'points'));
    final level             = _i(stats, 'level');
    final readiness         = _i(stats, 'careerReadinessScore', _i(stats, 'readinessScore'));
    final totalRoadmaps     = _i(stats, 'totalRoadmaps');
    final completedRoadmaps = _i(stats, 'completedRoadmaps');

    final location = [city, country].where((e) => e.isNotEmpty).join(', ');
    final degreeDisplay = [degree, major].where((e) => e.isNotEmpty && e != 'N/A').join(' · ');

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 40, offset: const Offset(0, 12))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff1676C4), Color(0xff0A4F9F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _Avatar(photoUrl: photoUrl, name: name, size: 68),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.2)),
                    const SizedBox(height: 4),
                    if (degreeDisplay.isNotEmpty)
                      Text(degreeDisplay, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
                    if (university.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(children: [
                          Icon(Icons.school_outlined, size: 12, color: Colors.white.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Expanded(child: Text(university, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11), overflow: TextOverflow.ellipsis)),
                        ]),
                      ),
                    if (location.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(children: [
                          Icon(Icons.location_on_outlined, size: 12, color: Colors.white.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Text(location, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                        ]),
                      ),
                  ])),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ]),

                if (stats != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      _MiniStat(value: '$totalPoints', label: 'Points', icon: Icons.bolt),
                      _StatDivider(),
                      _MiniStat(value: 'Lv.$level', label: 'Level', icon: Icons.military_tech_outlined),
                      _StatDivider(),
                      _MiniStat(value: '$readiness%', label: 'Readiness', icon: Icons.track_changes),
                      _StatDivider(),
                      _MiniStat(value: '$completedRoadmaps/$totalRoadmaps', label: 'Roadmaps', icon: Icons.map_outlined),
                    ]),
                  ),
                ],

                const SizedBox(height: 10),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(statusIcon(app.status), size: 13, color: Colors.white),
                      const SizedBox(width: 5),
                      Text('Status: ${app.status}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  if (app.position.isNotEmpty)
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.work_outline, size: 12, color: Colors.white),
                          const SizedBox(width: 5),
                          Flexible(child: Text(app.position, style: const TextStyle(color: Colors.white, fontSize: 11), overflow: TextOverflow.ellipsis)),
                        ]),
                      ),
                    ),
                ]),
              ]),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  if (profile == null) ...[
                    _NoProfileCard(app: app),
                  ] else ...[

                    _SectionHeader(title: 'Contact Information'),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      if (email.isNotEmpty)     _InfoChip(icon: Icons.email_outlined,       text: email),
                      if (phone.isNotEmpty)     _InfoChip(icon: Icons.phone_outlined,       text: phone),
                      if (location.isNotEmpty)  _InfoChip(icon: Icons.location_on_outlined, text: location),
                      if (github.isNotEmpty)    _InfoChip(icon: Icons.code,                text: 'GitHub',    url: github),
                      if (linkedin.isNotEmpty)  _InfoChip(icon: Icons.link,                text: 'LinkedIn',  url: linkedin),
                      if (portfolio.isNotEmpty) _InfoChip(icon: Icons.web,                 text: 'Portfolio', url: portfolio),
                      if (cvUrl.isNotEmpty)     _InfoChip(icon: Icons.picture_as_pdf,      text: 'View CV',   url: cvUrl, highlight: true),
                    ]),

                    if (summary.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _SectionHeader(title: 'About'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                        child: Text(summary, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.6)),
                      ),
                    ],

                    if (educations != null && educations.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _SectionHeader(title: 'Education'),
                      const SizedBox(height: 8),
                      ...educations.take(3).map((e) {
                        final edu = e as Map<String, dynamic>;
                        final inst   = edu['institution'] ?? edu['university']  ?? edu['school'] ?? '';
                        final deg    = edu['degree']      ?? edu['degreeLevel'] ?? '';
                        final field  = edu['field']       ?? edu['major']       ?? '';
                        final period = edu['period']      ?? edu['years']       ?? edu['graduationYear'] ?? '';
                        return _TimelineCard(
                          icon: Icons.school_outlined,
                          title: [deg, field].where((e) => e.isNotEmpty).join(' in '),
                          subtitle: inst,
                          trailing: period.toString(),
                          color: Colors.blue,
                        );
                      }),
                    ],

                    if (experiences != null && experiences.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _SectionHeader(title: 'Work Experience'),
                      const SizedBox(height: 8),
                      ...experiences.take(3).map((e) {
                        final exp    = e as Map<String, dynamic>;
                        final title  = exp['title']    ?? exp['position']    ?? exp['jobTitle'] ?? '';
                        final comp   = exp['company']  ?? exp['companyName'] ?? exp['employer'] ?? '';
                        final period = exp['period']   ?? exp['duration']    ?? exp['years']    ?? '';
                        final desc   = exp['description'] ?? exp['summary']  ?? '';
                        return _TimelineCard(
                          icon: Icons.work_outline,
                          title: title,
                          subtitle: comp,
                          trailing: period.toString(),
                          description: desc,
                          color: Colors.teal,
                        );
                      }),
                    ],

                    if (skills != null && skills.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _SectionHeader(title: 'Skills'),
                      const SizedBox(height: 8),
                      ...skills.take(6).map((s) {
                        final skill = s as Map<String, dynamic>;
                        final sName  = skill['skillName'] ?? skill['name']  ?? '';
                        final sLevel = skill['level']     ?? skill['proficiency'] ?? '';
                        final pct    = double.tryParse((skill['progressPercent'] ?? skill['progress'] ?? 0).toString()) ?? 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text(sName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xff1676C4).withOpacity(0.08), borderRadius: BorderRadius.circular(4)),
                                child: Text(sLevel, style: const TextStyle(fontSize: 10, color: Color(0xff1676C4), fontWeight: FontWeight.w600)),
                              ),
                            ]),
                            const SizedBox(height: 5),
                            Stack(children: [
                              Container(height: 7, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
                              FractionallySizedBox(
                                widthFactor: (pct / 100).clamp(0, 1),
                                child: Container(
                                  height: 7,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [Color(0xff1676C4), Color(0xff42A5F5)]),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ]),
                          ]),
                        );
                      }),
                    ],

                    if (roadmaps != null && roadmaps.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _SectionHeader(title: 'Learning Roadmaps'),
                      const SizedBox(height: 8),
                      ...roadmaps.take(3).map((r) {
                        final rd       = r as Map<String, dynamic>;
                        final rdTitle  = rd['title']           ?? rd['roadmapTitle']     ?? '';
                        final rdRole   = rd['targetRole']      ?? rd['role']             ?? '';
                        final rdStatus = rd['status']          ?? rd['completionStatus'] ?? '';
                        final rdPct    = double.tryParse((rd['progressPercent'] ?? rd['progress'] ?? 0).toString()) ?? 0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Expanded(child: Text(rdTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                              if (rdStatus.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: rdStatus.toLowerCase().contains('complet') ? Colors.green.withOpacity(0.1) : const Color(0xff1676C4).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(rdStatus, style: TextStyle(fontSize: 10, color: rdStatus.toLowerCase().contains('complet') ? Colors.green : const Color(0xff1676C4), fontWeight: FontWeight.w600)),
                                ),
                            ]),
                            if (rdRole.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(rdRole, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                            ],
                            const SizedBox(height: 8),
                            Row(children: [
                              Expanded(
                                child: Stack(children: [
                                  Container(height: 6, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
                                  FractionallySizedBox(
                                    widthFactor: (rdPct / 100).clamp(0, 1),
                                    child: Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [Color(0xff1676C4), Color(0xff42A5F5)]),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ]),
                              ),
                              const SizedBox(width: 10),
                              Text('${rdPct.toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff1676C4))),
                            ]),
                          ]),
                        );
                      }),
                    ],

                    if (achievements != null && achievements.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _SectionHeader(title: 'Achievements'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: achievements.take(9).map((a) {
                          final ach = a as Map<String, dynamic>;
                          final icon  = ach['icon']  ?? ach['emoji'] ?? '🏆';
                          final title = ach['title'] ?? ach['name']  ?? ach['achievementName'] ?? '';
                          final desc  = ach['description'] ?? '';
                          return Tooltip(
                            message: desc,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.amber.withOpacity(0.35)),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Text(icon.toString(), style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 5),
                                Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                              ]),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],

                  const SizedBox(height: 8),
                ]),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(color: Colors.grey[50], border: Border(top: BorderSide(color: Colors.grey[200]!))),
              child: Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () { Navigator.pop(context); onUpdateStatus(); },
                    icon: const Icon(Icons.edit_note, size: 18),
                    label: const Text('Update Status'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: const Color(0xff1676C4),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String photoUrl;
  final String name;
  final double size;
  const _Avatar({required this.photoUrl, required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.5), color: Colors.white.withOpacity(0.2)),
      child: ClipOval(
        child: photoUrl.isNotEmpty
            ? Image.network(photoUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback())
            : _fallback(),
      ),
    );
  }

  Widget _fallback() => Container(
    color: Colors.white.withOpacity(0.2),
    child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: TextStyle(color: Colors.white, fontSize: size * 0.38, fontWeight: FontWeight.bold))),
  );
}

class _MiniStat extends StatelessWidget {
  final String value; final String label; final IconData icon;
  const _MiniStat({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Icon(icon, size: 14, color: Colors.white.withOpacity(0.8)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 9)),
    ]),
  );
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 30, color: Colors.white.withOpacity(0.25), margin: const EdgeInsets.symmetric(horizontal: 4));
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 3, height: 16, decoration: BoxDecoration(color: const Color(0xff1676C4), borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xff1676C4))),
  ]);
}

class _InfoChip extends StatelessWidget {
  final IconData icon; final String text; final String? url; final bool highlight;
  const _InfoChip({required this.icon, required this.text, this.url, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final color = highlight ? Colors.green : const Color(0xff1676C4);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.25))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: highlight ? FontWeight.w600 : FontWeight.normal), overflow: TextOverflow.ellipsis),
        ),
      ]),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final IconData icon; final String title; final String subtitle;
  final String trailing; final String? description; final Color color;
  const _TimelineCard({required this.icon, required this.title, required this.subtitle, required this.trailing, required this.color, this.description});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 16, color: color)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
          if (trailing.isNotEmpty) Text(trailing, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        ]),
        if (subtitle.isNotEmpty) ...[const SizedBox(height: 2), Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600]))],
        if (description != null && description!.isNotEmpty) ...[const SizedBox(height: 4), Text(description!, style: TextStyle(fontSize: 11, color: Colors.grey[500], height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis)],
      ])),
    ]),
  );
}

class _NoProfileCard extends StatelessWidget {
  final ApplicationModel app;
  const _NoProfileCard({required this.app});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.withOpacity(0.3))),
      child: Row(children: [
        Icon(Icons.info_outline, color: Colors.orange[700], size: 22),
        const SizedBox(width: 10),
        Expanded(child: Text('Full profile not available for this applicant.', style: TextStyle(color: Colors.orange[800], fontSize: 13))),
      ]),
    ),
    const SizedBox(height: 16),
    if (app.email.isNotEmpty || app.phoneNumber != null) ...[
      const _SectionHeader(title: 'Available Information'),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        if (app.email.isNotEmpty)               _InfoChip(icon: Icons.email_outlined,   text: app.email),
        if (app.phoneNumber?.isNotEmpty == true) _InfoChip(icon: Icons.phone_outlined,   text: app.phoneNumber!),
        if (app.university?.isNotEmpty == true)  _InfoChip(icon: Icons.school_outlined,  text: app.university!),
        if (app.major?.isNotEmpty == true)       _InfoChip(icon: Icons.book_outlined,    text: app.major!),
        if (app.linkedIn?.isNotEmpty == true)    _InfoChip(icon: Icons.link,             text: 'LinkedIn', url: app.linkedIn),
        if (app.cvUrl?.isNotEmpty == true)       _InfoChip(icon: Icons.picture_as_pdf,   text: 'View CV',  url: app.cvUrl, highlight: true),
      ]),
    ],
  ]);
}

