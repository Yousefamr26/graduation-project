import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../data/models/company/candidate-model.dart';

class InterviewsScreen extends StatefulWidget {
  const InterviewsScreen({super.key});

  @override
  State<InterviewsScreen> createState() => _InterviewsScreenState();
}

class _InterviewsScreenState extends State<InterviewsScreen> {
  String? selectedStatus;
  final List<CandidateModel> candidates = [
    CandidateModel(
      id: '1',
      name: 'Sarah Doe',
      email: 'sarah.doe@email.com',
      profileImagePath: '',
      degreeLevel: 'Under Graduate',
      skillMatchPercentage: 85,
      totalPoints: 3250,
      roadmap: 'Data Analysis',
      isAIPick: true,
      status: 'Scheduled',
      interviewDate: '2026-02-15',
      interviewTime: '10:00 AM',
    ),
    CandidateModel(
      id: '2',
      name: 'John Smith',
      email: 'john.smith@email.com',
      profileImagePath: '',
      degreeLevel: 'Graduate',
      skillMatchPercentage: 78,
      totalPoints: 2800,
      roadmap: 'Web Development',
      isAIPick: true,
      status: 'Scheduled',
      interviewDate: '2026-02-16',
      interviewTime: '02:00 PM',
    ),
    CandidateModel(
      id: '3',
      name: 'Mona Hassan',
      email: 'mona.hassan@email.com',
      profileImagePath: '',
      degreeLevel: 'Under Graduate',
      skillMatchPercentage: 82,
      totalPoints: 3100,
      roadmap: 'UI/UX Design',
      isAIPick: false,
      status: 'Scheduled',
      interviewDate: '2026-02-11',
      interviewTime: '03:00 PM',
    ),
    CandidateModel(
      id: '4',
      name: 'Ahmed Khalil',
      email: 'ahmed.k@email.com',
      profileImagePath: '',
      degreeLevel: 'Graduate',
      skillMatchPercentage: 90,
      totalPoints: 3500,
      roadmap: 'Machine Learning',
      isAIPick: true,
      status: 'Pending',
    ),
    CandidateModel(
      id: '5',
      name: 'Layla Mohamed',
      email: 'layla.m@email.com',
      profileImagePath: '',
      degreeLevel: 'Under Graduate',
      skillMatchPercentage: 75,
      totalPoints: 2650,
      roadmap: 'Mobile Development',
      isAIPick: false,
      status: 'Pending',
    ),
    CandidateModel(
      id: '6',
      name: 'Omar Sayed',
      email: 'omar.sayed@email.com',
      profileImagePath: '',
      degreeLevel: 'Graduate',
      skillMatchPercentage: 88,
      totalPoints: 3350,
      roadmap: 'Cloud Computing',
      isAIPick: true,
      status: 'Pending',
    ),
  ];

  String searchText = "";
  String selectedFilter = "All";
  List<CandidateModel> filteredCandidates = [];

  @override
  void initState() {
    super.initState();
    filteredCandidates = candidates;
  }

  void applyFilters() {
    setState(() {
      filteredCandidates = candidates.where((candidate) {
        bool matchesFilter = true;

        if (selectedFilter == "Scheduled") {
          matchesFilter = candidate.status == "Scheduled";
        } else if (selectedFilter == "Pending") {
          matchesFilter = candidate.status == "Pending";
        }

        if (searchText.isEmpty) return matchesFilter;

        final searchLower = searchText.toLowerCase();
        return matchesFilter && (
            candidate.name.toLowerCase().contains(searchLower) ||
                candidate.email.toLowerCase().contains(searchLower) ||
                candidate.roadmap.toLowerCase().contains(searchLower)
        );
      }).toList();
    });
  }

  int get totalCandidates => candidates.length;
  int get scheduledCount => candidates.where((c) => c.status == "Scheduled").length;
  int get todayCount => candidates.where((c) {
    if (c.interviewDate == null) return false;
    try {
      DateTime interviewDate = DateFormat('yyyy-MM-dd').parse(c.interviewDate!);
      DateTime today = DateTime.now();
      return interviewDate.year == today.year &&
          interviewDate.month == today.month &&
          interviewDate.day == today.day;
    } catch (e) {
      return false;
    }
  }).length;

  void _scheduleInterview(CandidateModel candidate) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff1676C4),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xff1676C4),
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (selectedTime != null) {
        setState(() {
          final index = candidates.indexWhere((c) => c.id == candidate.id);
          if (index != -1) {
            candidates[index] = candidate.copyWith(
              status: 'Scheduled',
              interviewDate: DateFormat('yyyy-MM-dd').format(selectedDate),
              interviewTime: selectedTime.format(context),
            );
            applyFilters();
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Interview scheduled successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildAppBar(),
          _buildStatsCards(),
          _buildCandidatesTable(),
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
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Interview Scheduling",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Manage candidate interviews",
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

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              totalCandidates.toString(),
              "Total Candidates",
              Icons.people,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              scheduledCount.toString(),
              "Scheduled",
              Icons.event_available,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              todayCount.toString(),
              "Today",
              Icons.today,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCandidatesTable() {
    return Expanded(
      child: filteredCandidates.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No candidates found",
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(const Color(0xff1676C4).withOpacity(0.1)),
            columns: const [
              DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Skill Match %', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Total Points', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Roadmap', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Profile', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: filteredCandidates.map((candidate) {
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xff1676C4),
                          radius: 16,
                          child: Text(
                            candidate.name[0],
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(
                                  candidate.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            Text(
                              candidate.degreeLevel,
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text(candidate.email, style: const TextStyle(fontSize: 13))),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: candidate.skillMatchPercentage >= 80
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${candidate.skillMatchPercentage}%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: candidate.skillMatchPercentage >= 80 ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        const Icon(Icons.stars, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          candidate.totalPoints.toString(),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xff1676C4).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        candidate.roadmap,
                        style: const TextStyle(fontSize: 12, color: Color(0xff1676C4)),
                      ),
                    ),
                  ),
                  DataCell(
                    ElevatedButton(
                      onPressed: (){
                        // Navigator.push(context,
                        //     // MaterialPageRoute(builder: (BuildContext context){
                        //     //   // return const ProfileStudent();
                        //     // })
                        // );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xff1676C4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: const BorderSide(color: Color(0xff1676C4)),
                        ),
                      ),
                      child: const Text('View', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  DataCell(
                    ElevatedButton(
                      onPressed: candidate.status == "Scheduled"
                          ? null
                          : () => _scheduleInterview(candidate),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: candidate.status == "Scheduled"
                            ? Colors.grey
                            : const Color(0xff1676C4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        candidate.status == "Scheduled" ? 'Scheduled' : 'Schedule',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}