import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../../data/repositories/Calendarrepository.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final calendarRepo = CalendarRepository();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay  = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    debugPrint("🗓️ [CALENDAR SCREEN] initState called");
    _fetchAndBuildEvents();
  }

  Future<void> _fetchAndBuildEvents() async {
    debugPrint("🗓️ [CALENDAR] _fetchAndBuildEvents started");
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final events = await calendarRepo.getAllEvents();

      debugPrint("🗓️ [CALENDAR] Total events fetched: ${events.length}");
      if (events.isNotEmpty) {
        debugPrint("🗓️ [CALENDAR] First event keys: ${events.first.keys.toList()}");
        debugPrint("🗓️ [CALENDAR] First event: ${events.first}");
      }

      if (!mounted) return;

      final Map<DateTime, List<Map<String, dynamic>>> eventsMap = {};

      for (final event in events) {
        // ✅ جرب كل أسماء الـ date field المحتملة
        final dateStr = _findDateString(event);

        if (dateStr == null || dateStr.isEmpty) {
          debugPrint("⚠️ [CALENDAR] No date field in event: ${event.keys.toList()}");
          debugPrint("⚠️ [CALENDAR] Full event: $event");
          continue;
        }

        try {
          final date   = _parseDate(dateStr);
          if (date == null) {
            debugPrint("⚠️ [CALENDAR] Could not parse date: $dateStr");
            continue;
          }

          final dayKey = DateTime(date.year, date.month, date.day);

          eventsMap.putIfAbsent(dayKey, () => []);
          eventsMap[dayKey]!.add({
            ...event,
            '_parsedDate': date,
          });

          debugPrint("✅ [CALENDAR] Event added on $dayKey: ${_getTitle(event)}");
        } catch (e) {
          debugPrint("⚠️ [CALENDAR] Error parsing date '$dateStr': $e");
          continue;
        }
      }

      debugPrint("🗓️ [CALENDAR] Total days with events: ${eventsMap.length}");

      setState(() {
        _events   = eventsMap;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ [CALENDAR] Fetch error: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load calendar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// ✅ ابحث عن أي date field في الـ event
  String? _findDateString(Map<String, dynamic> event) {
    const dateKeys = [
      'date', 'Date',
      'scheduledDate', 'ScheduledDate',
      'eventDate', 'EventDate',
      'startDate', 'StartDate',
      'interviewDate', 'InterviewDate',
      'scheduled_date', 'start_date',
    ];
    for (final key in dateKeys) {
      final val = event[key];
      if (val != null && val.toString().trim().isNotEmpty) {
        return val.toString().trim();
      }
    }
    return null;
  }

  /// ✅ parse تنسيقات مختلفة من التواريخ
  DateTime? _parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr).toLocal();
    } catch (_) {}

    // جرب تنسيقات تانية لو DateTime.parse فشل
    final formats = [
      'yyyy-MM-ddTHH:mm:ss',
      'yyyy-MM-dd HH:mm:ss',
      'yyyy-MM-dd',
      'MM/dd/yyyy HH:mm:ss',
      'MM/dd/yyyy',
      'dd/MM/yyyy',
    ];

    for (final fmt in formats) {
      try {
        return DateFormat(fmt).parse(dateStr).toLocal();
      } catch (_) {}
    }

    return null;
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  List<Map<String, dynamic>> get _upcomingEvents {
    final now = DateTime.now();
    final future = <Map<String, dynamic>>[];
    final past   = <Map<String, dynamic>>[];

    for (final e in _events.entries.expand((entry) => entry.value)) {
      final d = e['_parsedDate'] as DateTime?;
      if (d == null) continue;
      if (d.isAfter(now)) {
        future.add(e);
      } else {
        past.add(e);
      }
    }

    future.sort((a, b) => (a['_parsedDate'] as DateTime).compareTo(b['_parsedDate'] as DateTime));
    past.sort((a, b) => (b['_parsedDate'] as DateTime).compareTo(a['_parsedDate'] as DateTime));

    return [...future, ...past].take(10).toList();
  }

  String _getTitle(Map<String, dynamic> event) {
    return (event['title'] ?? event['Title'] ?? event['name'] ?? event['eventName'] ??
        event['studentName'] ?? event['StudentName'] ?? 'Event').toString();
  }

  String _getType(Map<String, dynamic> event) {
    return (event['type'] ?? event['Type'] ?? event['eventType'] ??
        event['interviewType'] ?? event['InterviewType'] ?? 'Event').toString();
  }

  String _getLocation(Map<String, dynamic> event) {
    return (event['location'] ?? event['Location'] ?? event['place'] ?? '').toString();
  }

  String _getDescription(Map<String, dynamic> event) {
    return (event['description'] ?? event['Description'] ?? event['notes'] ?? '').toString();
  }

  Color _getEventColor(String type, {String? apiColor}) {
    // ✅ لو الـ API بعت color خاص، استخدمه
    if (apiColor != null) {
      switch (apiColor.toLowerCase()) {
        case 'red':    return Colors.red;
        case 'purple': return Colors.purple;
        case 'green':  return Colors.green;
        case 'orange': return Colors.orange;
        case 'blue':   return const Color(0xff1676C4);
        case 'yellow': return Colors.amber[700]!;
      }
    }
    switch (type.toLowerCase()) {
      case 'interview':  return Colors.purple;
      case 'job':        return Colors.red;
      case 'workshop':   return Colors.green;
      case 'event':      return Colors.orange;
      case 'meeting':    return Colors.teal;
      case 'deadline':   return Colors.red;
      case 'online':     return Colors.green;
      case 'on-site':    return Colors.orange;
      case 'phone':      return Colors.purple;
      default:           return const Color(0xff1676C4);
    }
  }

  IconData _getEventIcon(String type) {
    switch (type.toLowerCase()) {
      case 'interview':  return Icons.people_outlined;
      case 'job':        return Icons.work_outline;
      case 'workshop':   return Icons.school_outlined;
      case 'event':      return Icons.event_outlined;
      case 'meeting':    return Icons.groups_outlined;
      case 'deadline':   return Icons.alarm_outlined;
      case 'online':     return Icons.video_call_outlined;
      case 'on-site':    return Icons.business_outlined;
      case 'phone':      return Icons.phone_outlined;
      default:           return Icons.event_available;
    }
  }

  void _showEventDetails(Map<String, dynamic> event) {
    final parsedDate  = event['_parsedDate'] as DateTime?;
    final title       = _getTitle(event);
    final type        = _getType(event);
    final location    = _getLocation(event);
    final description = _getDescription(event);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getEventColor(type, apiColor: event['color']?.toString()).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_getEventIcon(type), color: _getEventColor(type, apiColor: event['color']?.toString())),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis),
                  Text(type,
                      style: TextStyle(
                          fontSize: 12,
                          color: _getEventColor(type, apiColor: event['color']?.toString()),
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (parsedDate != null) ...[
                _buildDetailRow(
                  Icons.calendar_today,
                  'Date',
                  DateFormat('EEEE, MMMM dd, yyyy').format(parsedDate),
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.access_time,
                  'Time',
                  DateFormat('hh:mm a').format(parsedDate),
                ),
              ],
              if (location.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow(Icons.place_outlined, 'Location', location),
              ],
              if (description.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow(Icons.notes_outlined, 'Description', description),
              ],
              ...event.entries
                  .where((e) =>
              !['_parsedDate', '_type', 'date', 'eventDate',
                'scheduledDate', 'ScheduledDate', 'startDate',
                'title', 'type', 'location', 'description',
                'name', 'eventName', 'eventType', 'Title', 'Type',
                'Location', 'Description', 'Date',
                'studentName', 'StudentName', 'interviewType',
                'InterviewType',
                // ✅ fields مخفية — مش مفيدة للمستخدم
                'id', 'color', 'status', 'result', 'isAIPick',
                'companyName', 'createdAt', 'roadmapId',
                'roadmapName', 'additionalNotes', 'interviewerName',
                'studentUserId', 'userId',
              ].contains(e.key) &&
                  e.value != null &&
                  e.value.toString().isNotEmpty)
                  .map((e) {
                final label = e.key
                    .replaceAllMapped(RegExp(r'([A-Z])'),
                        (m) => ' ${m.group(0)}')
                    .trim();
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _buildDetailRow(
                      Icons.info_outline,
                      label[0].toUpperCase() + label.substring(1),
                      e.value.toString()),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xff1676C4)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(fontSize: 14, color: Colors.grey[800])),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              child: Column(
                children: [
                  _buildCalendar(),
                  _buildLegend(),
                  _buildUpcomingSchedule(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Company Calendar",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMMM yyyy').format(_focusedDay),
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w300),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _fetchAndBuildEvents,
                tooltip: 'Refresh',
              ),
              IconButton(
                icon: const Icon(Icons.today, color: Colors.white),
                onPressed: () => setState(() {
                  _focusedDay  = DateTime.now();
                  _selectedDay = DateTime.now();
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar<Map<String, dynamic>>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: _getEventsForDay,
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay  = focusedDay;
          });
          final events = _getEventsForDay(selectedDay);
          if (events.isNotEmpty) _showEventDetails(events.first);
        },
        onFormatChanged: (format) =>
            setState(() => _calendarFormat = format),
        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: const Color(0xff1676C4).withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: Color(0xff1676C4),
            shape: BoxShape.circle,
          ),
          markersMaxCount: 1,
          outsideDaysVisible: false,
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xff1676C4),
          ),
          leftChevronIcon:
          Icon(Icons.chevron_left, color: Color(0xff1676C4)),
          rightChevronIcon:
          Icon(Icons.chevron_right, color: Color(0xff1676C4)),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isEmpty) return null;
            final type = _getType(events.first);
            final color = events.first['color']?.toString();
            return Positioned(
              bottom: 1,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _getEventColor(type, apiColor: color),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          {'label': 'Interview', 'color': const Color(0xff1676C4)},
          {'label': 'Workshop',  'color': Colors.green},
          {'label': 'Event',     'color': Colors.orange},
          {'label': 'Meeting',   'color': Colors.purple},
          {'label': 'Deadline',  'color': Colors.red},
        ].map((type) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: type['color'] as Color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(type['label'] as String,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700])),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUpcomingSchedule() {
    final upcoming = _upcomingEvents;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, color: Color(0xff1676C4), size: 24),
              const SizedBox(width: 8),
              Text(
                'Schedule',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (upcoming.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'No events this month',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            ...upcoming.map((event) {
              final parsedDate = event['_parsedDate'] as DateTime?;
              final title      = _getTitle(event);
              final type       = _getType(event);

              return InkWell(
                onTap: () => _showEventDetails(event),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getEventColor(type, apiColor: event['color']?.toString()).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getEventColor(type, apiColor: event['color']?.toString()).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getEventColor(type, apiColor: event['color']?.toString()).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getEventIcon(type),
                          color: _getEventColor(type, apiColor: event['color']?.toString()),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 12, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  parsedDate != null
                                      ? DateFormat('MMM dd, yyyy')
                                      .format(parsedDate)
                                      : 'N/A',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                                if (parsedDate != null) ...[
                                  const SizedBox(width: 8),
                                  Icon(Icons.access_time,
                                      size: 12, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('hh:mm a').format(parsedDate),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600]),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getEventColor(type, apiColor: event['color']?.toString()).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                type,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: _getEventColor(type, apiColor: event['color']?.toString()),
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey[400]),
                    ],
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}