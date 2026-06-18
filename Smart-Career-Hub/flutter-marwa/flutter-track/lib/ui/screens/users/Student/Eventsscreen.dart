import 'dart:developer';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/services/api_service.dart';
import '../../../../data/services/ProfileService.dart';
import '../../../../core/Constants/apiConstants.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});
  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with SingleTickerProviderStateMixin {
  static const Color kPrimary = Color(0xff1676C4);
  static const Color kBg = Color(0xffF0F9FF);

  late TabController _tabs;
  List<dynamic> _all = [], _my = [];
  bool _loading = true;
  String? _userType;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('student_token') != null) {
      _userType = 'student';
    } else if (prefs.getString('graduate_token') != null)
      _userType = 'graduate';
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.get('/Events', userType: _userType),
        ApiService.get(
          '/events/my-events',
          userType: _userType,
        ).catchError((_) => []),
      ]);
      final allData = results[0];
      final myData = results[1];

      final rawAll = (allData is List
              ? allData
              : allData?['data'] ?? allData?['items'] ?? [])
          as List;
      final rawMy = (myData is List ? myData : myData?['data'] ?? []) as List;

      List<dynamic> fullMy = [];
      if (rawMy.isNotEmpty) {
        final fetchFutures = rawMy.map((enr) {
          final eventId = enr['eventId'] ?? enr['id'];
          if (eventId != null) {
            return ApiService.get('/events/$eventId', userType: _userType)
                .catchError((_) => null);
          }
          return Future.value(null);
        }).toList();

        final fetchedResults = await Future.wait(fetchFutures);
        fullMy = fetchedResults
            .where((item) => item != null)
            .map((item) {
              if (item is Map && item['data'] != null) {
                return item['data'];
              }
              return item;
            })
            .toList();
      }

      setState(() {
        _all = rawAll;
        _my = fullMy;
      });
    } catch (_) {
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _enroll(dynamic id) async {
    try {
      final profile = await ProfileService().getProfileSummary(
        userType: _userType,
      );
      final basicInfo = (profile['basicInfo'] ?? {}) as Map;
      final email = basicInfo['email']?.toString() ?? '';
      final phone = basicInfo['phoneNumber']?.toString() ?? '';
      final eventId = int.tryParse(id.toString()) ?? 0;

      await ApiService.post(
        '/events/$id/enroll',
        data: {
          'eventId': eventId,
          'Email': email,
          'PhoneNumber': phone == "N/A" ? "01000000000" : phone,
        },
        userType: _userType,
      );
      _showSnack('✅ Registered successfully!');
      _load();
    } catch (e) {
      log(e.toString());
      _showSnack('❌ ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<void> _unenroll(dynamic id) async {
    try {
      await ApiService.delete('/events/$id/enroll', userType: _userType);
      _showSnack('✅ Cancelled successfully');
      _load();
    } catch (e) {
      _showSnack('❌ ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: kPrimary,
      behavior: SnackBarBehavior.floating,
    ),
  );

  @override
  Widget build(BuildContext context) {
    // Filter out enrolled events from the "available" list.
    // An event is considered enrolled if its ID matches any ID in the _my list.
    final enrolledIds = _my.map((e) {
      final eventMap = (e['event'] is Map)
          ? e['event'] as Map
          : (e['Event'] is Map)
              ? e['Event'] as Map
              : e;
      final id = eventMap['id'] ??
          eventMap['eventId'] ??
          eventMap['Id'] ??
          eventMap['EventId'] ??
          e['id'] ??
          e['eventId'] ??
          e['Id'] ??
          e['EventId'];
      return id?.toString();
    }).whereType<String>().toSet();

    final availableEvents = _all.where((e) {
      final eventMap = (e['event'] is Map)
          ? e['event'] as Map
          : (e['Event'] is Map)
              ? e['Event'] as Map
              : e;
      final id = eventMap['id'] ??
          eventMap['eventId'] ??
          eventMap['Id'] ??
          eventMap['EventId'] ??
          e['id'] ??
          e['eventId'] ??
          e['Id'] ??
          e['EventId'];
      return id == null || !enrolledIds.contains(id.toString());
    }).toList();

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
          'Events',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Available'),
            Tab(text: 'My Events'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : TabBarView(
              controller: _tabs,
              children: [
                _buildList(availableEvents, isMyTab: false),
                _buildList(_my, isMyTab: true),
              ],
            ),
    );
  }

  Widget _buildList(List data, {required bool isMyTab}) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              isMyTab ? 'No registered events yet' : 'No events available',
              style: TextStyle(color: Colors.grey[500]),
            ),
            if (!isMyTab) ...[
              const SizedBox(height: 8),
              TextButton(onPressed: _load, child: const Text('Refresh')),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: data.length,
        itemBuilder: (_, i) => _eventCard(data[i], isMyTab: isMyTab),
      ),
    );
  }

  Widget _eventCard(Map e, {required bool isMyTab}) {
    final eventMap = (e['event'] is Map)
        ? e['event'] as Map
        : (e['Event'] is Map)
            ? e['Event'] as Map
            : e;

    final id = eventMap['id'] ?? eventMap['eventId'] ?? eventMap['Id'] ?? eventMap['EventId'] ?? e['id'] ?? e['eventId'] ?? e['Id'] ?? e['EventId'];
    final enrolled =
        eventMap['isEnrolled'] == true || eventMap['enrolled'] == true || 
        eventMap['IsEnrolled'] == true || eventMap['Enrolled'] == true ||
        e['isEnrolled'] == true || e['enrolled'] == true || 
        e['IsEnrolled'] == true || e['Enrolled'] == true || isMyTab;
    final type = eventMap['locationType'] ?? eventMap['type'] ?? eventMap['LocationType'] ?? eventMap['Type'] ?? '';
    final typeColor = type == 'Online'
        ? const Color(0xff10B981)
        : type == 'Hybrid'
        ? const Color(0xff8B5CF6)
        : kPrimary;

    final organizerName =
        eventMap['organizerName'] ?? eventMap['organizer'] ?? eventMap['company'] ?? 
        eventMap['OrganizerName'] ?? eventMap['Organizer'] ?? eventMap['Company'] ?? 'Organizer';
    final dateStr = eventMap['startDate'] ?? eventMap['date'] ?? eventMap['StartDate'] ?? eventMap['Date'] ?? '';
    final formattedDate = _formatDate(dateStr.toString());
    final startTime = _formatTime((eventMap['startTime'] ?? eventMap['StartTime'])?.toString());
    final endTime = _formatTime((eventMap['endTime'] ?? eventMap['EndTime'])?.toString());
    final location = eventMap['location'] ?? eventMap['Location'] ?? '';
    final seats = eventMap['availableSeats'] ?? eventMap['seats'] ?? eventMap['AvailableSeats'] ?? eventMap['Seats'];

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
            // Card Banner Section
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _buildRobustImage(
                      eventMap['bannerUrl'] ?? eventMap['BannerUrl'] ?? 
                      eventMap['imageUrl'] ?? eventMap['ImageUrl'] ?? 
                      eventMap['image'] ?? eventMap['Image'] ?? 
                      e['bannerUrl'] ?? e['BannerUrl'] ?? 
                      e['imageUrl'] ?? e['ImageUrl'] ?? 
                      e['image'] ?? e['Image'],
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  _buildFloatingCalendarBadge(dateStr.toString()),
                  if (type.toString().isNotEmpty)
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
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
                              size: 11,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              type.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (enrolled)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xff10B981),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
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
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Enrolled',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventMap['title'] ?? 'Event Title',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Color(0xFF0F172A),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: kPrimary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.business_rounded,
                          size: 12,
                          color: kPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          organizerName.toString(),
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
                  Row(
                    children: [
                      Expanded(
                        child: _infoItem(
                          Icons.calendar_today_rounded,
                          'DATE',
                          formattedDate.isNotEmpty ? formattedDate : 'TBD',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _infoItem(
                          Icons.access_time_rounded,
                          'TIME',
                          startTime.toString().isNotEmpty
                              ? '$startTime - $endTime'
                              : 'TBD',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _infoItem(
                          Icons.location_on_rounded,
                          'LOCATION',
                          location.toString().isNotEmpty
                              ? location.toString()
                              : 'Online / TBD',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _infoItem(
                          Icons.people_alt_rounded,
                          'SEATS',
                          seats != null
                              ? '$seats seats left'
                              : 'Open Registration',
                          valueColor:
                              seats != null &&
                                  int.tryParse(seats.toString()) != null &&
                                  int.parse(seats.toString()) < 10
                              ? const Color(0xffEF4444)
                              : const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (enrolled)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _unenroll(id),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xffEF4444),
                            width: 1.5,
                          ),
                          foregroundColor: const Color(0xffEF4444),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cancel_outlined, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Cancel Registration',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _enroll(id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: kPrimary.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_turned_in_rounded, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Register Now',
                              style: TextStyle(
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
      top: 14,
      left: 14,
      child: Container(
        width: 48,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 18,
              decoration: const BoxDecoration(
                color: Color(0xffEF4444),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              alignment: Alignment.center,
              child: Text(
                month,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
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
                    fontSize: 18,
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

  Widget _buildRobustImage(String? imageStr) {
    if (imageStr == null || imageStr.trim().isEmpty) {
      return _buildBannerFallback();
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
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => _buildBannerFallback(),
        );
      } catch (_) {}
    }

    try {
      final fullUrl = ApiConstants.getImageUrl(cleanStr);
      return Image.network(
        fullUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildBannerFallback(),
      );
    } catch (_) {
      return _buildBannerFallback();
    }
  }

  Widget _buildBannerFallback() {
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
          Icons.event_rounded,
          color: Colors.white.withOpacity(0.25),
          size: 48,
        ),
      ),
    );
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return '';
    final cleanStr = timeStr.trim();

    // If it's a full DateTime ISO string
    final parsedDate = DateTime.tryParse(cleanStr);
    if (parsedDate != null) {
      final hour = parsedDate.hour.toString().padLeft(2, '0');
      final minute = parsedDate.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    // If it's a time-only string like "09:00:00" or "09:00"
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
}
