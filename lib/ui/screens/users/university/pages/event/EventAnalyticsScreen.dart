import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../data/models/company/event-model.dart';
import '../../../../../widgets/common/timeline_row_widget.dart';

class EventAnalyticsScreen extends StatelessWidget {
  final EventModel event;

  const EventAnalyticsScreen({required this.event, super.key});

  String _calculateDuration() {
    if (event.startDate.isEmpty || event.endDate.isEmpty) {
      return 'Not set';
    }

    try {
      DateTime start = DateFormat('yyyy-MM-dd').parse(event.startDate);
      DateTime end = DateFormat('yyyy-MM-dd').parse(event.endDate);
      int days = end.difference(start).inDays + 1;

      if (days == 1) {
        return '1 day';
      } else if (days < 7) {
        return '$days days';
      } else if (days < 30) {
        int weeks = (days / 7).ceil();
        return '$weeks ${weeks == 1 ? "week" : "weeks"}';
      } else {
        int months = (days / 30).ceil();
        return '$months ${months == 1 ? "month" : "months"}';
      }
    } catch (e) {
      return 'Invalid dates';
    }
  }

  String _calculateTimeRange() {
    if (event.startTime.isEmpty || event.endTime.isEmpty) {
      return 'Not set';
    }
    return '${event.startTime} - ${event.endTime}';
  }

  int _calculateAvailableSeats() {
    // Assuming you'll add registeredCount to EventModel
    // For now returning capacity
    return event.capacity;
  }

  double _calculateOccupancyRate() {
    // This will be calculated when you have actual registration data
    // registeredCount / capacity * 100
    return 0.0;
  }

  int _safeToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final duration = _calculateDuration();
    final timeRange = _calculateTimeRange();
    final availableSeats = _calculateAvailableSeats();
    final occupancyRate = _calculateOccupancyRate();

    // These values should come from your backend/database
    final registeredCount = 0; // TODO: Get from database
    final attendedCount = 0; // TODO: Get from database
    final checkedInCount = 0; // TODO: Get from database

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Analytics",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Color(0xff1676C4),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff1676C4), Color(0xff0d7ce8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  Icon(Icons.event, size: 48, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    event.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.status,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Cards
                  _buildSectionTitle("Overview", Icons.dashboard),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOverviewCard(
                          "Capacity",
                          event.capacity.toString(),
                          Icons.people,
                          Color(0xff1676C4),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildOverviewCard(
                          "Duration",
                          duration,
                          Icons.schedule,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOverviewCard(
                          "Min Points",
                          event.minPoints.round().toString(),
                          Icons.stars,
                          Colors.amber,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildOverviewCard(
                          "Occupancy",
                          "${occupancyRate.toStringAsFixed(0)}%",
                          Icons.trending_up,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Registration Statistics
                  _buildSectionTitle("Registration Statistics", Icons.app_registration),
                  SizedBox(height: 12),
                  _buildStatCard(
                    title: "Total Registered",
                    value: registeredCount,
                    icon: Icons.how_to_reg,
                    color: Color(0xff1676C4),
                  ),
                  _buildStatCard(
                    title: "Checked In",
                    value: checkedInCount,
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                  _buildStatCard(
                    title: "Attended",
                    value: attendedCount,
                    icon: Icons.person,
                    color: Colors.purple,
                  ),
                  _buildStatCard(
                    title: "Available Seats",
                    value: availableSeats,
                    icon: Icons.event_seat,
                    color: Colors.orange,
                  ),

                  SizedBox(height: 24),

                  // Event Details
                  _buildSectionTitle("Event Details", Icons.info_outline),
                  SizedBox(height: 12),
                  _buildDetailCard(
                    items: [
                      _DetailItem("Type", event.type ?? 'N/A', Icons.category),
                      _DetailItem("Mode", event.mode ?? 'N/A', Icons.computer),
                      _DetailItem("Location", event.location.isNotEmpty ? event.location : 'N/A', Icons.place),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Timeline
                  _buildSectionTitle("Timeline", Icons.calendar_today),
                  SizedBox(height: 12),
                  _buildTimelineCard(timeRange),

                  SizedBox(height: 24),

                  // Attendance Breakdown (if you have the data)
                  _buildSectionTitle("Attendance Breakdown", Icons.bar_chart),
                  SizedBox(height: 12),
                  _buildBreakdownCard(
                    items: [
                      _BreakdownItem(
                        "Registered",
                        registeredCount,
                        Color(0xff1676C4),
                      ),
                      _BreakdownItem(
                        "Attended",
                        attendedCount,
                        Colors.green,
                      ),
                      _BreakdownItem(
                        "Absent",
                        registeredCount - attendedCount,
                        Colors.red,
                      ),
                    ],
                    total: registeredCount > 0 ? registeredCount : 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color:Color(0xff1676C4), size: 24),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({required List<_DetailItem> items}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: EdgeInsets.only(bottom: items.last == item ? 0 : 12),
            child: Row(
              children: [
                Icon(item.icon, color: Color(0xff1676C4), size: 20),
                SizedBox(width: 12),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Spacer(),
                Flexible(
                  child: Text(
                    item.value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBreakdownCard({
    required List<_BreakdownItem> items,
    required int total,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items.map((item) {
          double percentage = total > 0 ? (item.count / total) * 100 : 0;
          return Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      "${item.count} (${percentage.toStringAsFixed(0)}%)",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: item.color,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(item.color),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimelineCard(String timeRange) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TimelineRowWidget(
            label: "Start Date",
            value: event.startDate.isNotEmpty ? event.startDate : 'Not set',
            icon: Icons.play_arrow,
            color: Colors.green,
          ),

          SizedBox(height: 12),
          TimelineRowWidget(
            label:  "End Date",
            value:  event.endDate.isNotEmpty ? event.endDate : 'Not set',
            icon:   Icons.flag,
            color:  Colors.red,
          ),
          SizedBox(height: 12),
          TimelineRowWidget(
            label: "Time",
            value:  timeRange,
            icon: Icons.access_time,
            color:Color(0xff1676C4),
          ),
        ],
      ),
    );
  }


}

class _BreakdownItem {
  final String label;
  final int count;
  final Color color;

  _BreakdownItem(this.label, this.count, this.color);
}

class _DetailItem {
  final String label;
  final String value;
  final IconData icon;

  _DetailItem(this.label, this.value, this.icon);
}