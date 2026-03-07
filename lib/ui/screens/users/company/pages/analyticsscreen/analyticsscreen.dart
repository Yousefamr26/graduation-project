import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../../data/models/company/analytics-model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String selectedCategory = "Roadmaps";

  final List<String> categories = [
    "Roadmaps",
    "Jobs",
    "Internships",
    "Workshops",
    "Events",
    "Interviews",
    "Universities",
  ];

  // Data using AnalyticsModel
  late final Map<String, AnalyticsModel> analyticsData;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    analyticsData = {
      "Roadmaps": AnalyticsModel(
        category: "Roadmaps",
        metrics: [
          MetricModel(
            title: "Total Enrolled",
            value: "856",
            change: "↑ 15% this month",
            isPositive: true,
            icon: Icons.people,
            color: Colors.blue,
          ),
          MetricModel(
            title: "Completion Rate",
            value: "67%",
            change: "↑ 5% vs last month",
            isPositive: true,
            icon: Icons.check_circle,
            color: Colors.green,
          ),
          MetricModel(
            title: "Avg. Progress",
            value: "73%",
            change: "↑ 8% improvement",
            isPositive: true,
            icon: Icons.trending_up,
            color: Colors.orange,
          ),
          MetricModel(
            title: "Active Roadmaps",
            value: "5",
            change: "Stable",
            isPositive: true,
            icon: Icons.route,
            color: Colors.purple,
          ),
        ],
        lineChartData: {
          "Jan": 120,
          "Feb": 150,
          "Mar": 180,
          "Apr": 210,
          "May": 250,
          "Jun": 280,
        },
        pieChartData: {
          "Completed": 45.0,
          "In Progress": 35.0,
          "Not Started": 20.0,
        },
        pieChartTitle: "Roadmap Completion Stats",
        lineChartTitle: "Under Graduate Performance Over Time",
      ),
      "Jobs": AnalyticsModel(
        category: "Jobs",
        metrics: [
          MetricModel(
            title: "Total Job Postings",
            value: "128",
            change: "Active",
            isPositive: true,
            icon: Icons.work,
            color: Colors.blue,
          ),
          MetricModel(
            title: "Total Applications",
            value: "2,492",
            change: "↑ 18% this month",
            isPositive: true,
            icon: Icons.description,
            color: Colors.green,
          ),
          MetricModel(
            title: "Interview Rate",
            value: "18%",
            change: "↑ 3% improvement",
            isPositive: true,
            icon: Icons.event_available,
            color: Colors.orange,
          ),
          MetricModel(
            title: "Hiring Success Rate",
            value: "32%",
            change: "↑ 5% vs last quarter",
            isPositive: true,
            icon: Icons.check_circle,
            color: Colors.purple,
          ),
        ],
        lineChartData: {
          "Jan": 180,
          "Feb": 220,
          "Mar": 280,
          "Apr": 340,
          "May": 420,
          "Jun": 480,
        },
        pieChartData: {
          "Software Dev": 35.0,
          "Data Science": 25.0,
          "Design": 20.0,
          "Marketing": 12.0,
          "Other": 8.0,
        },
        pieChartTitle: "Applications by Category",
        lineChartTitle: "Job Applications Over Time",
        barChartData: {
          "Posted": 128,
          "Screening": 85,
          "Interview": 45,
          "Offer": 28,
          "Hired": 18,
        },
        barChartTitle: "Job Pipeline Summary",
      ),
      "Internships": AnalyticsModel(
        category: "Internships",
        metrics: [
          MetricModel(
            title: "Active Programs",
            value: "75",
            change: "↑ 8% this semester",
            isPositive: true,
            icon: Icons.school,
            color: Colors.blue,
          ),
          MetricModel(
            title: "Total Applicants",
            value: "1,383",
            change: "↑ 22% increase",
            isPositive: true,
            icon: Icons.people,
            color: Colors.green,
          ),
          MetricModel(
            title: "Acceptance Rate",
            value: "23%",
            change: "Stable",
            isPositive: true,
            icon: Icons.check,
            color: Colors.orange,
          ),
          MetricModel(
            title: "Completion Rate",
            value: "89%",
            change: "↑ 4% improvement",
            isPositive: true,
            icon: Icons.emoji_events,
            color: Colors.purple,
          ),
        ],
        lineChartData: {
          "Jan": 150,
          "Feb": 190,
          "Mar": 240,
          "Apr": 280,
          "May": 320,
          "Jun": 360,
        },
        pieChartData: {
          "Engineering": 40.0,
          "Business": 25.0,
          "Design": 15.0,
          "Data": 12.0,
          "Other": 8.0,
        },
        pieChartTitle: "Internships by Department",
        lineChartTitle: "Internship Trends",
      ),
      "Workshops": AnalyticsModel(
        category: "Workshops",
        metrics: [
          MetricModel(
            title: "Total Workshops",
            value: "24",
            change: "This semester",
            isPositive: true,
            icon: Icons.construction,
            color: Colors.blue,
          ),
          MetricModel(
            title: "Avg. Satisfaction",
            value: "4.7/5",
            change: "Excellent rating",
            isPositive: true,
            icon: Icons.star,
            color: Colors.amber,
          ),
          MetricModel(
            title: "Total Participants",
            value: "590",
            change: "↑ 15% growth",
            isPositive: true,
            icon: Icons.groups,
            color: Colors.green,
          ),
          MetricModel(
            title: "Attendance Rate",
            value: "92%",
            change: "Consistent",
            isPositive: true,
            icon: Icons.check_circle,
            color: Colors.purple,
          ),
        ],
        lineChartData: {
          "Jan": 45,
          "Feb": 68,
          "Mar": 85,
          "Apr": 102,
          "May": 118,
          "Jun": 135,
        },
        pieChartData: {
          "Technical": 45.0,
          "Soft Skills": 30.0,
          "Career Dev": 15.0,
          "Leadership": 10.0,
        },
        pieChartTitle: "Workshop Engagement Distribution",
        lineChartTitle: "Session Statistics",
      ),
      "Events": AnalyticsModel(
        category: "Events",
        metrics: [
          MetricModel(
            title: "Total Events",
            value: "18",
            change: "This quarter",
            isPositive: true,
            icon: Icons.event,
            color: Colors.blue,
          ),
          MetricModel(
            title: "Total Registrations",
            value: "732",
            change: "↑ 20% increase",
            isPositive: true,
            icon: Icons.app_registration,
            color: Colors.green,
          ),
          MetricModel(
            title: "Attendance Rate",
            value: "95%",
            change: "Excellent turnout",
            isPositive: true,
            icon: Icons.check_circle,
            color: Colors.purple,
          ),
          MetricModel(
            title: "Avg. Rating",
            value: "4.8/5",
            change: "Outstanding",
            isPositive: true,
            icon: Icons.star,
            color: Colors.amber,
          ),
        ],
        lineChartData: {
          "Jan": 60,
          "Feb": 85,
          "Mar": 110,
          "Apr": 135,
          "May": 165,
          "Jun": 190,
        },
        pieChartData: {
          "Career Fair": 35.0,
          "Tech Talk": 25.0,
          "Networking": 20.0,
          "Workshop": 12.0,
          "Other": 8.0,
        },
        pieChartTitle: "Event Categories Distribution",
        lineChartTitle: "Event Participation Trends",
      ),
      "Interviews": AnalyticsModel(
        category: "Interviews",
        metrics: [
          MetricModel(
            title: "Total Interviews",
            value: "367",
            change: "↑ 12% this quarter",
            isPositive: true,
            icon: Icons.person,
            color: Colors.blue,
          ),
          MetricModel(
            title: "Attendance Rate",
            value: "96%",
            change: "Exceptional engagement",
            isPositive: true,
            icon: Icons.check_circle,
            color: Colors.green,
          ),
          MetricModel(
            title: "Hiring Rate",
            value: "71%",
            change: "↑ 5% improvement",
            isPositive: true,
            icon: Icons.work,
            color: Colors.purple,
          ),
          MetricModel(
            title: "Avg. Duration",
            value: "45 min",
            change: "Optimal time",
            isPositive: true,
            icon: Icons.schedule,
            color: Colors.orange,
          ),
        ],
        lineChartData: {
          "Jan": 40,
          "Feb": 52,
          "Mar": 65,
          "Apr": 78,
          "May": 88,
          "Jun": 98,
        },
        pieChartData: {
          "Completed": 71.0,
          "Scheduled": 18.0,
          "No Show": 4.0,
          "Cancelled": 7.0,
        },
        pieChartTitle: "Interview Success Pipeline",
        lineChartTitle: "Monthly Interview Trends",
      ),
      "Universities": AnalyticsModel(
        category: "Universities",
        metrics: [
          MetricModel(
            title: "Partner Universities",
            value: "12",
            change: "Active partnerships",
            isPositive: true,
            icon: Icons.school,
            color: Colors.blue,
          ),
          MetricModel(
            title: "Total Students",
            value: "2,456",
            change: "Across all unis",
            isPositive: true,
            icon: Icons.people,
            color: Colors.green,
          ),
          MetricModel(
            title: "Placement Rate",
            value: "68%",
            change: "↑ 7% increase",
            isPositive: true,
            icon: Icons.work,
            color: Colors.purple,
          ),
          MetricModel(
            title: "Avg. Performance",
            value: "4.3/5",
            change: "Strong results",
            isPositive: true,
            icon: Icons.star,
            color: Colors.amber,
          ),
        ],
        lineChartData: {
          "Jan": 320,
          "Feb": 380,
          "Mar": 450,
          "Apr": 520,
          "May": 590,
          "Jun": 650,
        },
        pieChartData: {
          "Cairo Uni": 28.0,
          "Ain Shams": 22.0,
          "AUC": 18.0,
          "Alexandria": 15.0,
          "Other": 17.0,
        },
        pieChartTitle: "Students by University",
        lineChartTitle: "University Engagement Over Time",
      ),
    };
  }

  AnalyticsModel get currentData => analyticsData[selectedCategory]!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildAppBar(),
          _buildCategoryTabs(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetricsCards(),
                  SizedBox(height: 24),
                  if (currentData.barChartData != null)
                    Column(
                      children: [
                        _buildBarChart(),
                        SizedBox(height: 24),
                      ],
                    ),
                  _buildPerformanceChart(),
                  SizedBox(height: 24),
                  _buildCompletionStats(),
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
            toolbarHeight: 100,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Analytics & Reports",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Detailed insights about your programs and \n under graduate engagement",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 12),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xff1676C4) : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? Color(0xff1676C4) : Colors.grey[300]!,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: Color(0xff1676C4).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
                    : [],
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.dashboard, color: Color(0xff1676C4), size: 24),
            SizedBox(width: 8),
            Text(
              "Key Performance Metrics",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: currentData.metrics.length,
          itemBuilder: (context, index) {
            return _buildMetricCard(currentData.metrics[index]);
          },
        ),
      ],
    );
  }

  Widget _buildMetricCard(MetricModel metric) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: metric.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(metric.icon, color: metric.color, size: 20),
              ),
              Text(
                metric.value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            metric.title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: metric.isPositive
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              metric.change,
              style: TextStyle(
                fontSize: 10,
                color: metric.isPositive ? Colors.green[700] : Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final barData = currentData.barChartData;
    if (barData == null) return SizedBox.shrink();

    return Container(
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
              Icon(Icons.bar_chart, color: Color(0xff1676C4), size: 24),
              SizedBox(width: 8),
              Text(
                currentData.barChartTitle ?? "Pipeline Summary",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: barData.values.reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final keys = barData.keys.toList();
                        if (value.toInt() >= 0 && value.toInt() < keys.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              keys[value.toInt()],
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200],
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                    left: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                barGroups: barData.entries.toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final colors = [
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                    Colors.red,
                  ];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data.value.toDouble(),
                        color: colors[index % colors.length],
                        width: 20,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Container(
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
              Icon(Icons.show_chart, color: Color(0xff1676C4), size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  currentData.lineChartTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: currentData.lineChartData.values.reduce((a, b) => a > b ? a : b) / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200],
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final months = currentData.lineChartData.keys.toList();
                        if (value.toInt() >= 0 && value.toInt() < months.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              months[value.toInt()],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                    left: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                minX: 0,
                maxX: (currentData.lineChartData.length - 1).toDouble(),
                minY: 0,
                maxY: currentData.lineChartData.values.reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: currentData.lineChartData.entries
                        .toList()
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.value.toDouble()))
                        .toList(),
                    isCurved: true,
                    color: Color(0xff1676C4),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: Color(0xff1676C4),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Color(0xff1676C4).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionStats() {
    return Container(
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
              Icon(Icons.pie_chart, color: Color(0xff1676C4), size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  currentData.pieChartTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: _getPieChartSections(),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildLegend(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getPieChartSections() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
    ];

    return currentData.pieChartData.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: item.value,
        title: '${item.value.toInt()}%',
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<Widget> _buildLegend() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
    ];

    return currentData.pieChartData.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.key,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${item.value.toInt()}%',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}