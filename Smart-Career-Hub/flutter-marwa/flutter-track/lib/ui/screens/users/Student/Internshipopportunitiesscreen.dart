import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/services/api_service.dart';

class InternshipOpportunitiesScreen extends StatefulWidget {
  const InternshipOpportunitiesScreen({super.key});
  @override
  State<InternshipOpportunitiesScreen> createState() =>
      _InternshipOpportunitiesScreenState();
}

class _InternshipOpportunitiesScreenState
    extends State<InternshipOpportunitiesScreen> {
  static const Color kPrimary = Color(0xff1676C4);
  static const Color kBg = Color(0xffF0F9FF);
  static const String _base = 'http://smartcareerhub.runasp.net';

  List<dynamic> _all = [];
  bool _loading = true;
  String _search = '', _filterType = 'All';
  String? _userType;

  // ─── Type helpers ──────────────────────────────────────────────
  static String _typeLabel(dynamic t) {
    switch (t?.toString()) {
      case '0':
        return 'On-site';
      case '1':
        return 'Remote';
      case '2':
        return 'Hybrid';
      default:
        return t?.toString() ?? '';
    }
  }

  static Color _typeColor(dynamic t) {
    switch (t?.toString()) {
      case '1':
        return const Color(0xff10B981);
      case '2':
        return const Color(0xff8B5CF6);
      default:
        return kPrimary;
    }
  }

  static String _statusLabel(dynamic s) {
    switch (s?.toString().toLowerCase()) {
      case '0':
      case 'pending':
        return 'Pending';
      case '1':
      case 'accepted':
        return 'Accepted';
      case '2':
      case 'rejected':
        return 'Rejected';
      case '3':
      case 'withdrawn':
        return 'Withdrawn';
      default:
        return s?.toString() ?? 'Pending';
    }
  }

  static Color _statusColor(dynamic s) {
    switch (s?.toString().toLowerCase()) {
      case '1':
      case 'accepted':
        return const Color(0xff059669);
      case '2':
      case 'rejected':
        return const Color(0xffEF4444);
      case '3':
      case 'withdrawn':
        return const Color(0xFF94A3B8);
      default:
        return const Color(0xffD97706); // pending
    }
  }

  static IconData _statusIcon(dynamic s) {
    switch (s?.toString().toLowerCase()) {
      case '1':
      case 'accepted':
        return Icons.check_circle_rounded;
      case '2':
      case 'rejected':
        return Icons.cancel_rounded;
      case '3':
      case 'withdrawn':
        return Icons.remove_circle_rounded;
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  // ─── Lifecycle ────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('student_token') != null) {
      _userType = 'student';
    } else if (prefs.getString('graduate_token') != null) {
      _userType = 'graduate';
    }
    await _load();
  }

  // ─── Data loading ─────────────────────────────────────────────

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final res = await ApiService.get('/internships', userType: _userType);
      final allList = _toList(res);

      if (!mounted) return;
      setState(() {
        _all = allList;
      });
    } catch (e) {
      if (mounted) _snack('❌ Failed to load internships');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<dynamic> _toList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      if (data['data'] is List) return data['data'] as List;
      if (data['items'] is List) return data['items'] as List;
    }
    return [];
  }

  /// Fetch full detail for an internship
  Future<Map<String, dynamic>?> _fetchDetail(dynamic id) async {
    try {
      final res = await ApiService.get('/internships/$id', userType: _userType);
      if (res is Map) return Map<String, dynamic>.from(res);
    } catch (_) {}
    return null;
  }

  Future<void> _apply(dynamic internshipId) async {
    try {
      await ApiService.post(
        '/internships/$internshipId/apply',
        userType: _userType,
      );
      _snack('✅ Applied successfully!');
      _load();
    } catch (e) {
      _snack('❌ ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<void> _withdraw(dynamic applicationId) async {
    try {
      await ApiService.delete(
        '/internships/applications/$applicationId/withdraw',
        userType: _userType,
      );
      _snack('✅ Application withdrawn');
      _load();
    } catch (e) {
      _snack('❌ ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m),
        backgroundColor: kPrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── Filtered available list ──────────────────────────────────

  List<dynamic> get _filteredAll {
    return _all.where((i) {
      final t = (i['title'] ?? '').toString().toLowerCase();
      final c = (i['companyName'] ?? '').toString().toLowerCase();
      final tp = _typeLabel(i['type']);
      return (_search.isEmpty ||
              t.contains(_search.toLowerCase()) ||
              c.contains(_search.toLowerCase())) &&
          (_filterType == 'All' || tp == _filterType);
    }).toList();
  }

  // ─── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Internships',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : _buildAvailable(),
    );
  }

  // ─── Available Tab ────────────────────────────────────────────

  Widget _buildAvailable() {
    final list = _filteredAll;
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: list.isEmpty
              ? _emptyState(Icons.work_outline, 'No internships found')
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _availableCard(list[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: kPrimary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Search by title or company...',
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
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'On-site', 'Remote', 'Hybrid']
                  .map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _filterType = t),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: _filterType == t
                                ? Colors.white
                                : Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            t,
                            style: TextStyle(
                              color: _filterType == t ? kPrimary : Colors.white,
                              fontWeight: FontWeight.w700,
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
    );
  }
  // ─── Available Card ───────────────────────────────────────────

  Widget _availableCard(dynamic raw) {
    final item = raw is Map ? raw : <String, dynamic>{};
    final id = item['id'];
    final title = item['title'] ?? 'Internship';
    final company = item['companyName'] ?? 'Company';
    final location = item['location'] ?? '';
    final typeInt = item['type'];
    final typeLabel = _typeLabel(typeInt);
    final typeColor = _typeColor(typeInt);
    final isPaid = item['isPaid'] == true;
    final duration = item['durationInMonths'];

    return GestureDetector(
      onTap: () => _showDetailSheet(id: id, rawItem: item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff0F172A).withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colored top bar
              Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [typeColor, typeColor.withOpacity(0.55)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _companyAvatar(null),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title.toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                company.toString(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: kPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (typeLabel.isNotEmpty)
                          _tag(typeLabel, typeColor, Icons.device_hub_rounded),
                        if (location.toString().isNotEmpty)
                          _tag(
                            location.toString(),
                            const Color(0xFF64748B),
                            Icons.location_on_rounded,
                          ),
                        _tag(
                          isPaid ? 'Paid' : 'Unpaid',
                          isPaid
                              ? const Color(0xff059669)
                              : const Color(0xffEF4444),
                          isPaid
                              ? Icons.attach_money_rounded
                              : Icons.money_off_rounded,
                        ),
                        if (duration != null)
                          _tag(
                            '$duration month${duration == 1 ? '' : 's'}',
                            const Color(0xFF64748B),
                            Icons.schedule_rounded,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _apply(id),
                        icon: const Icon(Icons.send_rounded, size: 16),
                        label: const Text(
                          'Apply Now',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: kPrimary.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(IconData icon, String label) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 15)),
        ],
      ),
    );
  }

  // ─── Shared helpers ───────────────────────────────────────────

  Widget _companyAvatar(String? logoUrl) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: logoUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                logoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.business_center_rounded,
                  color: kPrimary,
                  size: 24,
                ),
              ),
            )
          : const Icon(
              Icons.business_center_rounded,
              color: kPrimary,
              size: 24,
            ),
    );
  }

  Widget _tag(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Detail bottom sheet ──────────────────────────────────────

  Future<void> _showDetailSheet({
    required dynamic id,
    required Map rawItem,
  }) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(
        id: id,
        initialData: Map<String, dynamic>.from(rawItem),
        userType: _userType,
        baseUrl: _base,
        onApply: () {
          Navigator.pop(context);
          _apply(id);
        },
        fetchDetail: _fetchDetail,
        typeLabel: _typeLabel,
        typeColor: _typeColor,
        statusLabel: _statusLabel,
        statusColor: _statusColor,
        statusIcon: _statusIcon,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _DetailSheet extends StatefulWidget {
  final dynamic id;
  final Map<String, dynamic> initialData;
  final String? userType;
  final String baseUrl;
  final VoidCallback onApply;
  final Future<Map<String, dynamic>?> Function(dynamic) fetchDetail;
  final String Function(dynamic) typeLabel;
  final Color Function(dynamic) typeColor;
  final String Function(dynamic) statusLabel;
  final Color Function(dynamic) statusColor;
  final IconData Function(dynamic) statusIcon;

  const _DetailSheet({
    super.key,
    required this.id,
    required this.initialData,
    required this.userType,
    required this.baseUrl,
    required this.onApply,
    required this.fetchDetail,
    required this.typeLabel,
    required this.typeColor,
    required this.statusLabel,
    required this.statusColor,
    required this.statusIcon,
  });

  @override
  State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet> {
  static const Color kPrimary = Color(0xff1676C4);
  Map<String, dynamic>? _detail;
  bool _fetching = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final d = await widget.fetchDetail(widget.id);
    if (mounted) {
      setState(() {
        _detail = d;
        _fetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _detail ?? widget.initialData;
    final title = data['title'] ?? 'Internship';
    final typeInt = widget.initialData['type'] ?? data['type'];
    final tLabel = widget.typeLabel(typeInt);
    final tColor = widget.typeColor(typeInt);
    final isPaid = data['isPaid'] == true;
    final isApplied =
        data['isApplied'] == true || widget.initialData['isApplied'] == true;
    final canApply = data['canApply'] != false && !isApplied;
    final status = data['status'] ?? widget.initialData['status'];
    final sLabel = widget.statusLabel(status);
    final sColor = widget.statusColor(status);
    final sIcon = widget.statusIcon(status);

    // Company info
    final company = data['company'] is Map
        ? data['company']
        : <String, dynamic>{'name': widget.initialData['companyName'] ?? ''};
    final companyName =
        company['name'] ?? widget.initialData['companyName'] ?? '';
    final logoPath = company['logo']?.toString();
    final logoUrl = logoPath != null && logoPath.isNotEmpty
        ? (logoPath.startsWith('/') ? '${widget.baseUrl}$logoPath' : logoPath)
        : null;

    final desc = data['description'] ?? widget.initialData['description'] ?? '';
    final skills =
        (data['requiredSkills'] ?? widget.initialData['requiredSkills'] ?? [])
            as List;
    final reqs = (data['requirements'] ?? []) as List;
    final duration =
        data['durationInMonths'] ?? widget.initialData['durationInMonths'];
    final location = data['location'] ?? widget.initialData['location'] ?? '';
    final deadlineRaw = data['applicationDeadline']?.toString() ?? '';
    final deadline = _fmtDate(deadlineRaw);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: _fetching && _detail == null
                  ? const Center(
                      child: CircularProgressIndicator(color: kPrimary),
                    )
                  : ListView(
                      controller: controller,
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      children: [
                        // Header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: kPrimary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: logoUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.network(
                                        logoUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                              Icons.business_center_rounded,
                                              color: kPrimary,
                                              size: 28,
                                            ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.business_center_rounded,
                                      color: kPrimary,
                                      size: 28,
                                    ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    companyName.toString(),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: kPrimary,
                                    ),
                                  ),
                                  Text(
                                    title.toString(),
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Status banner for my applications
                        // if (isMyTab) ...[
                        //   Container(
                        //     padding: const EdgeInsets.symmetric(
                        //       horizontal: 16,
                        //       vertical: 12,
                        //     ),
                        //     decoration: BoxDecoration(
                        //       color: sColor.withOpacity(0.08),
                        //       borderRadius: BorderRadius.circular(14),
                        //       border: Border.all(
                        //         color: sColor.withOpacity(0.25),
                        //       ),
                        //     ),
                        //     child: Row(
                        //       children: [
                        //         Icon(sIcon, color: sColor, size: 20),
                        //         const SizedBox(width: 10),
                        //         Column(
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           children: [
                        //             Text(
                        //               'Application Status',
                        //               style: TextStyle(
                        //                 fontSize: 11,
                        //                 color: sColor.withOpacity(0.7),
                        //                 fontWeight: FontWeight.w600,
                        //               ),
                        //             ),
                        //             Text(
                        //               sLabel,
                        //               style: TextStyle(
                        //                 fontSize: 15,
                        //                 color: sColor,
                        //                 fontWeight: FontWeight.w800,
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        //   const SizedBox(height: 16),
                        // ],

                        // Tags
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (tLabel.isNotEmpty)
                              _dtag(tLabel, tColor, Icons.device_hub_rounded),
                            if (location.toString().isNotEmpty)
                              _dtag(
                                location.toString(),
                                const Color(0xFF64748B),
                                Icons.location_on_rounded,
                              ),
                            _dtag(
                              isPaid ? 'Paid' : 'Unpaid',
                              isPaid
                                  ? const Color(0xff059669)
                                  : const Color(0xffEF4444),
                              isPaid
                                  ? Icons.attach_money_rounded
                                  : Icons.money_off_rounded,
                            ),
                            if (duration != null)
                              _dtag(
                                '$duration month${duration == 1 ? '' : 's'}',
                                const Color(0xFF64748B),
                                Icons.schedule_rounded,
                              ),
                            if (deadline.isNotEmpty)
                              _dtag(
                                'Deadline: $deadline',
                                const Color(0xffD97706),
                                Icons.event_rounded,
                              ),
                          ],
                        ),
                        const SizedBox(height: 22),

                        if (desc.toString().isNotEmpty) ...[
                          _sec('About the Role'),
                          const SizedBox(height: 8),
                          Text(
                            desc.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF475569),
                              height: 1.65,
                            ),
                          ),
                          const SizedBox(height: 22),
                        ],

                        if (reqs.isNotEmpty) ...[
                          _sec('Requirements'),
                          const SizedBox(height: 10),
                          ...reqs.map(
                            (r) => Padding(
                              padding: const EdgeInsets.only(bottom: 7),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: Icon(
                                      Icons.circle,
                                      size: 6,
                                      color: kPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      r.toString(),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF475569),
                                        height: 1.55,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                        ],

                        if (skills.isNotEmpty) ...[
                          _sec('Required Skills'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: skills
                                .map(
                                  (s) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: kPrimary.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: kPrimary.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Text(
                                      s.toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: kPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 22),
                        ],

                        const SizedBox(height: 8),

                        // Action button
                        SizedBox(
                          width: double.infinity,
                          child: isApplied
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  decoration: BoxDecoration(
                                    color: sColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: sColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(sIcon, size: 18, color: sColor),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Application $sLabel',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: sColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ElevatedButton.icon(
                                  onPressed: canApply ? widget.onApply : null,
                                  icon: const Icon(
                                    Icons.send_rounded,
                                    size: 18,
                                  ),
                                  label: Text(
                                    canApply
                                        ? 'Apply Now'
                                        : 'Applications Closed',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: canApply
                                        ? kPrimary
                                        : Colors.grey[400],
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shadowColor: kPrimary.withOpacity(0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
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
  }

  Widget _sec(String t) => Text(
    t,
    style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w800,
      color: Color(0xFF0F172A),
    ),
  );

  Widget _dtag(String label, Color color, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  String _fmtDate(String raw) {
    if (raw.isEmpty) return '';
    final d = DateTime.tryParse(raw);
    if (d == null) return raw;
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
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}
