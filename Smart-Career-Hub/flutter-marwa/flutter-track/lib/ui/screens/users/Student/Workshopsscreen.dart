import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/services/api_service.dart';

class WorkshopsScreen extends StatefulWidget {
  const WorkshopsScreen({super.key});
  @override
  State<WorkshopsScreen> createState() => _WorkshopsScreenState();
}

class _WorkshopsScreenState extends State<WorkshopsScreen>
    with SingleTickerProviderStateMixin {
  static const Color kPrimary = Color(0xff1676C4);
  static const Color kBg = Color(0xffF0F9FF);
  static const String _baseUrl = 'http://smartcareerhub.runasp.net';

  late TabController _tabs;

  // _all = flat list from /Workshops
  // _my = list from /WorkshopEnrollment/my-workshops (each item has enrollmentId + workshop data)
  List<dynamic> _all = [], _my = [];
  bool _loading = true;
  String _search = '', _filterType = 'All Types';
  String? _userType;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _init();
  }

  @override
  void dispose() {
    _tabs.dispose();
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

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        // Public endpoint — full list of available workshops
        ApiService.get('/Workshops', userType: _userType),
        // Auth-required — my enrollment list (contains workshopId per item)
        ApiService.get('/WorkshopEnrollment/my-workshops', userType: _userType)
            .catchError((_) => <dynamic>[]),
      ]);

      final allData = results[0];
      final rawMyData = _toList(results[1]);

      // For each enrollment, fetch full workshop details via GET /Workshops/{id}
      List<dynamic> fullMyData = [];
      if (rawMyData.isNotEmpty) {
        final fetchFutures = rawMyData.map((enrollment) {
          // Extract the workshop id from the enrollment object
          final wId = enrollment['workshopId'] ??
              enrollment['WorkshopId'] ??
              (enrollment['workshop'] is Map
                  ? (enrollment['workshop']['id'] ?? enrollment['workshop']['Id'])
                  : null) ??
              enrollment['id'] ??
              enrollment['Id'];

          if (wId != null) {
            return ApiService.get('/Workshops/$wId', userType: _userType)
                .then((detail) {
                  // Merge enrollment metadata (for unenroll) with full workshop details
                  if (detail is Map) {
                    return {
                      ...Map<String, dynamic>.from(detail),
                      '_enrollmentId': enrollment['enrollmentId'] ??
                          enrollment['EnrollmentId'] ??
                          enrollment['id'] ??
                          enrollment['Id'],
                    };
                  }
                  return enrollment;
                })
                .catchError((_) => enrollment);
          }
          return Future<dynamic>.value(enrollment);
        }).toList();

        final fetched = await Future.wait(fetchFutures);
        fullMyData = fetched.whereType<Map>().toList();
      }

      if (!mounted) return;
      setState(() {
        _all = _toList(allData);
        _my = fullMyData;
      });
    } catch (e) {
      if (mounted) _snack('❌ Failed to load workshops');
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

  /// Extract the flat workshop map from an item.
  /// After enrichment, _my items are flat /Workshops/{id} responses with
  /// an extra '_enrollmentId' key injected. No nesting needed.
  Map _workshopMap(dynamic raw) {
    if (raw is! Map) return {};
    // If the item has a nested 'workshop' or 'Workshop' key (pre-enrichment fallback)
    if (raw['workshop'] is Map) return raw['workshop'] as Map;
    if (raw['Workshop'] is Map) return raw['Workshop'] as Map;
    // For enriched items (flat /Workshops/{id} response), use the map directly
    return raw;
  }

  /// Get the enrollment ID for unenroll call.
  /// We inject '_enrollmentId' during enrichment in _load().
  dynamic _enrollmentId(dynamic raw) {
    if (raw is! Map) return null;
    return raw['_enrollmentId'] ??
        raw['enrollmentId'] ??
        raw['EnrollmentId'] ??
        raw['id'] ??
        raw['Id'];
  }

  /// Get the workshop ID
  dynamic _workshopId(dynamic raw) {
    final w = _workshopMap(raw);
    return w['id'] ??
        w['Id'] ??
        w['workshopId'] ??
        w['WorkshopId'] ??
        (raw is Map
            ? (raw['workshopId'] ?? raw['WorkshopId'] ?? raw['id'] ?? raw['Id'])
            : null);
  }

  Set<String> get _enrolledWorkshopIds => _my
      .map((item) => _workshopId(item)?.toString())
      .whereType<String>()
      .toSet();

  List<dynamic> get _filteredAll {
    final enrolled = _enrolledWorkshopIds;
    return _all.where((raw) {
      final id = _workshopId(raw)?.toString();
      if (id != null && enrolled.contains(id)) return false;

      final w = _workshopMap(raw);
      final title = (w['title'] ?? w['Title'] ?? '').toString().toLowerCase();
      final company = (w['companyName'] ??
              w['company'] ??
              w['organizer'] ??
              w['CompanyName'] ??
              '')
          .toString()
          .toLowerCase();
      final wType =
          (w['workshopType'] ?? w['type'] ?? w['WorkshopType'] ?? '')
              .toString();

      final matchSearch = _search.isEmpty ||
          title.contains(_search.toLowerCase()) ||
          company.contains(_search.toLowerCase());
      final matchType = _filterType == 'All Types' || wType == _filterType;
      return matchSearch && matchType;
    }).toList();
  }

  Future<void> _enroll(dynamic workshopId) async {
    try {
      await ApiService.post(
        '/WorkshopEnrollment/enroll',
        data: {'workshopId': workshopId},
        userType: _userType,
      );
      _snack('✅ Enrolled successfully!');
      _load();
    } catch (e) {
      _snack('❌ ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<void> _unenroll(dynamic raw) async {
    // Try using enrollmentId first, then workshopId as fallback
    final enrollId = _enrollmentId(raw);
    final wId = _workshopId(raw);
    try {
      if (enrollId != null) {
        await ApiService.delete(
          '/WorkshopEnrollment/$enrollId',
          userType: _userType,
        );
      } else {
        await ApiService.delete(
          '/WorkshopEnrollment/$wId',
          userType: _userType,
        );
      }
      _snack('✅ Unenrolled successfully');
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
          'Workshops',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Available'),
            Tab(text: 'My Workshops'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : TabBarView(
              controller: _tabs,
              children: [
                _buildAvailable(),
                _buildMyList(),
              ],
            ),
    );
  }

  // ──────────────────── Available Tab ────────────────────

  Widget _buildAvailable() {
    final list = _filteredAll;
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: list.isEmpty
              ? _emptyState(
                  Icons.handyman_outlined, 'No workshops found')
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: list.length,
                    itemBuilder: (_, i) =>
                        _workshopCard(list[i], isMyTab: false),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Search workshops...',
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
              children: ['All Types', 'Online', 'On-site', 'Hybrid']
                  .map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _filterType = t),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                _filterType == t ? kPrimary : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _filterType == t
                                  ? kPrimary
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            t,
                            style: TextStyle(
                              color: _filterType == t
                                  ? Colors.white
                                  : Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
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

  // ──────────────────── My Workshops Tab ────────────────────

  Widget _buildMyList() {
    if (_my.isEmpty) {
      return _emptyState(
          Icons.handyman_outlined, 'No enrolled workshops yet');
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _my.length,
        itemBuilder: (_, i) => _workshopCard(_my[i], isMyTab: true),
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
          Text(label, style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  // ──────────────────── Workshop Card ────────────────────

  Widget _workshopCard(dynamic raw, {required bool isMyTab}) {
    final w = _workshopMap(raw);
    final wId = _workshopId(raw);

    // Field extraction using actual API field names
    final title = w['title'] ?? w['Title'] ?? 'Workshop';
    final company = w['companyName'] ??
        w['company'] ??
        w['organizer'] ??
        w['universityName'] ??
        w['CompanyName'] ??
        w['UniversityName'] ??
        'Organizer';
    final wType =
        w['workshopType'] ?? w['type'] ?? w['WorkshopType'] ?? w['Type'] ?? '';
    final totalPoints =
        w['totalPoints'] ?? w['points'] ?? w['TotalPoints'] ?? w['Points'];
    final maxCapacity =
        w['maxCapacity'] ?? w['seats'] ?? w['MaxCapacity'] ?? w['Seats'];
    final location = w['location'] ?? w['Location'] ?? '';
    final bannerUrl = w['bannerUrl'] ?? w['BannerUrl'] ?? w['imageUrl'] ?? w['ImageUrl'];
    final startDateStr = w['startDate'] ?? w['date'] ?? w['StartDate'] ?? w['Date'] ?? '';

    final typeColor = wType == 'Online'
        ? const Color(0xff10B981)
        : wType == 'Hybrid'
            ? const Color(0xff8B5CF6)
            : kPrimary;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff0F172A).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: kPrimary.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Banner ───
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildBannerImage(bannerUrl),
                  // Dark gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.35),
                          Colors.transparent,
                          Colors.black.withOpacity(0.2),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Type badge
                  if (wType.toString().isNotEmpty)
                    Positioned(
                      top: 14,
                      right: 14,
                      child: _badge(
                        wType.toString(),
                        typeColor,
                        icon: wType == 'Online'
                            ? Icons.videocam_rounded
                            : wType == 'Hybrid'
                                ? Icons.devices_other_rounded
                                : Icons.location_on_rounded,
                      ),
                    ),
                  // Points badge
                  if (totalPoints != null)
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xffFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Color(0xffD97706), size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '+$totalPoints Pts',
                              style: const TextStyle(
                                color: Color(0xffD97706),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Enrolled badge
                  if (isMyTab)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: _badge(
                        'Enrolled',
                        const Color(0xff10B981),
                        icon: Icons.check_circle_rounded,
                      ),
                    ),
                ],
              ),
            ),

            // ─── Info ───
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title.toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Color(0xFF0F172A),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Company
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: kPrimary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.business_rounded,
                            size: 12, color: kPrimary),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          company.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 16),
                  // Details row
                  Row(
                    children: [
                      Expanded(
                        child: _infoItem(
                          Icons.location_on_rounded,
                          'LOCATION',
                          location.toString().isNotEmpty
                              ? location.toString()
                              : 'Online',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _infoItem(
                          Icons.people_alt_rounded,
                          'CAPACITY',
                          maxCapacity != null
                              ? '$maxCapacity seats'
                              : 'Open',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _infoItem(
                          Icons.star_rounded,
                          'POINTS',
                          totalPoints != null
                              ? '$totalPoints Points'
                              : '0 Points',
                          valueColor: const Color(0xffD97706),
                        ),
                      ),
                      if (startDateStr.toString().isNotEmpty) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          child: _infoItem(
                            Icons.calendar_today_rounded,
                            'DATE',
                            _formatDate(startDateStr.toString()),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          isMyTab ? _unenroll(raw) : _enroll(wId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isMyTab
                            ? const Color(0xffEF4444)
                            : kPrimary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: (isMyTab
                                ? const Color(0xffEF4444)
                                : kPrimary)
                            .withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isMyTab
                                ? Icons.cancel_outlined
                                : Icons.assignment_turned_in_rounded,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isMyTab ? 'Unenroll' : 'Register Now',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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

  // ──────────────────── Banner Image ────────────────────

  Widget _buildBannerImage(dynamic bannerUrl) {
    if (bannerUrl == null || bannerUrl.toString().trim().isEmpty) {
      return _bannerFallback();
    }

    final raw = bannerUrl.toString().trim();

    // Check if it's a relative path from the API
    String url = raw;
    if (raw.startsWith('/')) {
      url = '$_baseUrl$raw';
    }

    // Check if it's base64
    final isBase64 = raw.startsWith('data:image') ||
        raw.startsWith('/9j/') ||
        raw.startsWith('iVBORw0KG') ||
        (!raw.contains('/') && !raw.contains('.') && raw.length > 100);

    if (isBase64) {
      try {
        String b64 = raw.contains(',') ? raw.split(',')[1] : raw;
        b64 = b64.replaceAll(RegExp(r'\s+'), '');
        b64 = b64.padRight(b64.length + (4 - b64.length % 4) % 4, '=');
        final bytes = base64Decode(b64);
        return Image.memory(bytes,
            fit: BoxFit.cover, errorBuilder: (_, __, ___) => _bannerFallback());
      } catch (_) {
        return _bannerFallback();
      }
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _bannerFallback(),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return _bannerFallback();
      },
    );
  }

  Widget _bannerFallback() {
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
          color: Colors.white.withOpacity(0.15),
          size: 72,
        ),
      ),
    );
  }

  // ──────────────────── Helpers ────────────────────

  Widget _badge(String label, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
                color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: const Color(0xFF64748B)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
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

  String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    final d = DateTime.tryParse(raw);
    if (d == null) return raw;
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}
