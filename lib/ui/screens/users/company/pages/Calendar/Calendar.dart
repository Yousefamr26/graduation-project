import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../../../data/models/company/calendar-event-model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<CalendarEventModel>> _events = {
    DateTime(2025, 11, 6): [
      CalendarEventModel(
        id: '1',
        title: 'Interview: Sarah Doe',
        type: 'Interview',
        date: DateTime(2025, 11, 6),
        time: '10:00 AM',
        location: 'Meeting Room A',
        description: 'Technical interview for Software Engineering position',
        attendees: ['Sarah Doe', 'HR Manager', 'Tech Lead'],
      ),
    ],
    DateTime(2025, 11, 11): [
      CalendarEventModel(
        id: '2',
        title: 'React Workshop',
        type: 'Workshop',
        date: DateTime(2025, 11, 11),
        time: '2:00 PM',
        location: 'Training Hall',
        description: 'Advanced React patterns and best practices',
      ),
    ],
    DateTime(2025, 11, 13): [
      CalendarEventModel(
        id: '3',
        title: 'Interview: Ahmed Khalil',
        type: 'Interview',
        date: DateTime(2025, 11, 13),
        time: '11:00 AM',
        location: 'Meeting Room B',
        description: 'Final round interview for Machine Learning Engineer',
        attendees: ['Ahmed Khalil', 'CTO', 'ML Team Lead'],
      ),
    ],
    DateTime(2025, 11, 16): [
      CalendarEventModel(
        id: '4',
        title: 'Career Fair Event',
        type: 'Event',
        date: DateTime(2025, 11, 16),
        time: '9:00 AM',
        location: 'Cairo Convention Center',
        description: 'Annual career fair for recruiting top talent',
      ),
    ],
    DateTime(2025, 11, 19): [
      CalendarEventModel(
        id: '5',
        title: 'UI/UX Design Workshop',
        type: 'Workshop',
        date: DateTime(2025, 11, 19),
        time: '3:00 PM',
        location: 'Design Studio',
        description: 'User-centered design principles workshop',
      ),
    ],
    DateTime(2025, 11, 21): [
      CalendarEventModel(
        id: '6',
        title: 'Job Posting Deadline',
        type: 'Deadline',
        date: DateTime(2025, 11, 21),
        time: '11:59 PM',
        description: 'Last day to submit Senior Developer job posting',
      ),
    ],
    DateTime(2025, 11, 23): [
      CalendarEventModel(
        id: '7',
        title: 'Team Meeting',
        type: 'Meeting',
        date: DateTime(2025, 11, 23),
        time: '10:00 AM',
        location: 'Conference Room',
        description: 'Monthly team sync and planning',
        attendees: ['All Team Members'],
      ),
    ],
    DateTime(2025, 11, 26): [
      CalendarEventModel(
        id: '8',
        title: 'Interview: Omar Sayed',
        type: 'Interview',
        date: DateTime(2025, 11, 26),
        time: '2:30 PM',
        location: 'Meeting Room A',
        description: 'Technical screening for Cloud Engineer position',
        attendees: ['Omar Sayed', 'DevOps Lead'],
      ),
    ],
    DateTime(2025, 11, 29): [
      CalendarEventModel(
        id: '9',
        title: 'Data Science Workshop',
        type: 'Workshop',
        date: DateTime(2025, 11, 29),
        time: '1:00 PM',
        location: 'Lab 3',
        description: 'Introduction to Machine Learning and AI',
      ),
    ],
  };

  List<CalendarEventModel> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  List<CalendarEventModel> get _upcomingEvents {
    final now = DateTime.now();
    final allEvents = _events.entries
        .expand((entry) => entry.value)
        .where((event) => event.date.isAfter(now))
        .toList();
    allEvents.sort((a, b) => a.date.compareTo(b.date));
    return allEvents.take(5).toList();
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'Interview':
        return Colors.blue;
      case 'Workshop':
        return Colors.green;
      case 'Event':
        return Colors.orange;
      case 'Meeting':
        return Colors.purple;
      case 'Deadline':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'Interview':
        return Icons.person;
      case 'Workshop':
        return Icons.school;
      case 'Event':
        return Icons.event;
      case 'Meeting':
        return Icons.people;
      case 'Deadline':
        return Icons.alarm;
      default:
        return Icons.circle;
    }
  }

  void _showEventDetails(CalendarEventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getEventColor(event.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getEventIcon(event.type),
                color: _getEventColor(event.type),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: TextStyle(fontSize: 16)),
                  Text(
                    event.type,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getEventColor(event.type),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
              _buildDetailRow(
                Icons.calendar_today,
                'Date',
                DateFormat('EEEE, MMMM dd, yyyy').format(event.date),
              ),
              if (event.time != null) ...[
                SizedBox(height: 12),
                _buildDetailRow(Icons.access_time, 'Time', event.time!),
              ],
              if (event.location != null) ...[
                SizedBox(height: 12),
                _buildDetailRow(Icons.place, 'Location', event.location!),
              ],
              if (event.description != null) ...[
                SizedBox(height: 12),
                _buildDetailRow(
                    Icons.description, 'Description', event.description!),
              ],
              if (event.attendees != null && event.attendees!.isNotEmpty) ...[
                Divider(height: 24),
                Text(
                  'Attendees',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                ...event.attendees!.map((attendee) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Color(0xff1676C4),
                          child: Text(
                            attendee[0],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          attendee,
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Color(0xff1676C4)),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCalendar(),
                  _buildLegend(),
                  _buildUpcomingSchedule(),
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
                Text(
                  "Company Calendar",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  DateFormat('MMMM yyyy').format(_focusedDay),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.today, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime.now();
                    _selectedDay = DateTime.now();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        eventLoader: _getEventsForDay,
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });

          final events = _getEventsForDay(selectedDay);
          if (events.isNotEmpty) {
            _showEventDetails(events.first);
          }
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Color(0xff1676C4).withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Color(0xff1676C4),
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 1,
          outsideDaysVisible: false,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xff1676C4),
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xff1676C4)),
          rightChevronIcon:
          Icon(Icons.chevron_right, color: Color(0xff1676C4)),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isEmpty) return null;

            final event = events.first as CalendarEventModel;
            return Positioned(
              bottom: 1,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _getEventColor(event.type),
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
    final eventTypes = [
      {'type': 'Interview', 'color': Colors.blue},
      {'type': 'Workshop', 'color': Colors.green},
      {'type': 'Event', 'color': Colors.orange},
      {'type': 'Meeting', 'color': Colors.purple},
      {'type': 'Deadline', 'color': Colors.red},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: eventTypes.map((type) {
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
              SizedBox(width: 6),
              Text(
                type['type'] as String,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUpcomingSchedule() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: Color(0xff1676C4), size: 24),
              SizedBox(width: 8),
              Text(
                'Upcoming Schedule',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (_upcomingEvents.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No upcoming events',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ..._upcomingEvents.map((event) {
              return InkWell(
                onTap: () => _showEventDetails(event),
                child: Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getEventColor(event.type).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getEventColor(event.type).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getEventColor(event.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getEventIcon(event.type),
                          color: _getEventColor(event.type),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 12, color: Colors.grey[600]),
                                SizedBox(width: 4),
                                Text(
                                  DateFormat('MMM dd, yyyy').format(event.date),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (event.time != null) ...[
                                  SizedBox(width: 8),
                                  Icon(Icons.access_time,
                                      size: 12, color: Colors.grey[600]),
                                  SizedBox(width: 4),
                                  Text(
                                    event.time!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
                      ),
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