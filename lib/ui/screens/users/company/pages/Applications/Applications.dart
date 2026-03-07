import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../data/models/company/application-model.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  final List<ApplicationModel> applications = [
    ApplicationModel(
      id: '1',
      applicantName: 'Sarah Ahmed',
      email: 'sarah.ahmed@student.edu',
      university: 'Cairo University',
      major: 'Computer Science',
      year: '3rd Year',
      position: 'Software Engineering Intern',
      points: 3250,
      skills: ['Python', 'Java', 'C++'],
      appliedDate: '2026-01-28',
      status: 'Under Review',
      applicationType: 'Internship',
      degreeLevel: 'Under Graduate',
    ),
    ApplicationModel(
      id: '2',
      applicantName: 'Mohamed Hassan',
      email: 'mohamed.hassan@student.edu',
      university: 'Ain Shams University',
      major: 'Software Engineering',
      year: '4th Year',
      position: 'Frontend Development Intern',
      points: 2980,
      skills: ['React', 'TypeScript', 'CSS'],
      appliedDate: '2026-01-27',
      status: 'Under Review',
      applicationType: 'Internship',
      degreeLevel: 'Under Graduate',
    ),
    ApplicationModel(
      id: '3',
      applicantName: 'Nour Khaled',
      email: 'nour.khaled@student.edu',
      university: 'American University in Cairo',
      major: 'Data Science',
      year: '3rd Year',
      position: 'Data Science Intern',
      points: 3500,
      skills: ['Python', 'SQL', 'Pandas'],
      appliedDate: '2026-01-26',
      status: 'Shortlisted',
      applicationType: 'Internship',
      degreeLevel: 'Under Graduate',
    ),
    ApplicationModel(
      id: '4',
      applicantName: 'Ahmed Mahmoud',
      email: 'ahmed.mahmoud@student.edu',
      university: 'Alexandria University',
      major: 'Information Systems',
      year: '2nd Year',
      position: 'UX/UI Design Intern',
      points: 2650,
      skills: ['Figma', 'Adobe XD', 'Sketch'],
      appliedDate: '2026-01-25',
      status: 'Under Review',
      applicationType: 'Internship',
      degreeLevel: 'Under Graduate',
    ),
    ApplicationModel(
      id: '5',
      applicantName: 'Layla Ibrahim',
      email: 'layla.ibrahim@student.edu',
      university: 'Cairo University',
      major: 'Computer Science',
      year: '4th Year',
      position: 'Mobile App Development Intern',
      points: 3100,
      skills: ['Flutter', 'React Native', 'Dart'],
      appliedDate: '2026-01-24',
      status: 'Interview Scheduled',
      applicationType: 'Internship',
      degreeLevel: 'Under Graduate',
    ),
    ApplicationModel(
      id: '6',
      applicantName: 'Omar Youssef',
      email: 'omar.youssef@student.edu',
      university: 'German University in Cairo',
      major: 'Computer Engineering',
      year: '3rd Year',
      position: 'DevOps Engineering Intern',
      points: 2800,
      skills: ['Docker', 'Kubernetes', 'Jenkins'],
      appliedDate: '2026-01-23',
      status: 'Under Review',
      applicationType: 'Internship',
      degreeLevel: 'Under Graduate',
    ),
    // Graduate Job Applications
    ApplicationModel(
      id: '7',
      applicantName: 'Yara Mohamed',
      email: 'yara.mohamed@grad.edu',
      university: 'Cairo University',
      major: 'Computer Science',
      year: 'Graduate',
      position: 'Senior React Developer',
      points: 4200,
      skills: ['React', 'Node.js', 'MongoDB'],
      appliedDate: '2026-01-28',
      status: 'Shortlisted',
      applicationType: 'Job',
      degreeLevel: 'Graduate',
    ),
    ApplicationModel(
      id: '8',
      applicantName: 'Khaled Ali',
      email: 'khaled.ali@grad.edu',
      university: 'Ain Shams University',
      major: 'Software Engineering',
      year: 'Graduate',
      position: 'Full Stack Developer',
      points: 3900,
      skills: ['JavaScript', 'Python', 'AWS'],
      appliedDate: '2026-01-27',
      status: 'Under Review',
      applicationType: 'Job',
      degreeLevel: 'Graduate',
    ),
    ApplicationModel(
      id: '9',
      applicantName: 'Dina Samir',
      email: 'dina.samir@grad.edu',
      university: 'American University in Cairo',
      major: 'Data Science',
      year: 'Graduate',
      position: 'Data Analyst',
      points: 4500,
      skills: ['Python', 'R', 'Tableau'],
      appliedDate: '2026-01-26',
      status: 'Interview Scheduled',
      applicationType: 'Job',
      degreeLevel: 'Graduate',
    ),
    ApplicationModel(
      id: '10',
      applicantName: 'Hossam Fathy',
      email: 'hossam.fathy@grad.edu',
      university: 'Alexandria University',
      major: 'Information Technology',
      year: 'Graduate',
      position: 'DevOps Engineer',
      points: 4100,
      skills: ['Docker', 'Kubernetes', 'Terraform'],
      appliedDate: '2026-01-25',
      status: 'Under Review',
      applicationType: 'Job',
      degreeLevel: 'Graduate',
    ),
    ApplicationModel(
      id: '11',
      applicantName: 'Rana Waleed',
      email: 'rana.waleed@grad.edu',
      university: 'Cairo University',
      major: 'Computer Engineering',
      year: 'Graduate',
      position: 'Machine Learning Engineer',
      points: 4800,
      skills: ['Python', 'TensorFlow', 'PyTorch'],
      appliedDate: '2026-01-24',
      status: 'Shortlisted',
      applicationType: 'Job',
      degreeLevel: 'Graduate',
    ),
    ApplicationModel(
      id: '12',
      applicantName: 'Tarek Hassan',
      email: 'tarek.hassan@grad.edu',
      university: 'German University in Cairo',
      major: 'Software Engineering',
      year: 'Graduate',
      position: 'Backend Developer',
      points: 3700,
      skills: ['Java', 'Spring Boot', 'PostgreSQL'],
      appliedDate: '2026-01-23',
      status: 'Under Review',
      applicationType: 'Job',
      degreeLevel: 'Graduate',
    ),
  ];

  String searchText = "";
  String selectedTab = "Internship"; // Internship or Job
  List<ApplicationModel> filteredApplications = [];

  @override
  void initState() {
    super.initState();
    applyFilters();
  }

  void applyFilters() {
    setState(() {
      filteredApplications = applications.where((app) {
        bool matchesTab = app.applicationType == selectedTab;

        if (searchText.isEmpty) return matchesTab;

        final searchLower = searchText.toLowerCase();
        return matchesTab &&
            (app.applicantName.toLowerCase().contains(searchLower) ||
                app.email.toLowerCase().contains(searchLower) ||
                app.university.toLowerCase().contains(searchLower) ||
                app.position.toLowerCase().contains(searchLower));
      }).toList();
    });
  }

  int get underGradCount =>
      applications.where((a) => a.degreeLevel == "Under Graduate").length;
  int get gradCount =>
      applications.where((a) => a.degreeLevel == "Graduate").length;
  int get shortlistedCount =>
      applications.where((a) => a.status == "Shortlisted").length;
  int get interviewScheduledCount =>
      applications.where((a) => a.status == "Interview Scheduled").length;

  void _viewProfile(ApplicationModel application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xff1676C4),
              radius: 24,
              child: Text(
                application.applicantName[0],
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(application.applicantName, style: TextStyle(fontSize: 16)),
                  Text(
                    application.degreeLevel,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
              _buildProfileRow(Icons.email, 'Email', application.email),
              SizedBox(height: 12),
              _buildProfileRow(Icons.school, 'University', application.university),
              SizedBox(height: 12),
              _buildProfileRow(
                  Icons.book, 'Major', '${application.major} - ${application.year}'),
              SizedBox(height: 12),
              _buildProfileRow(Icons.work, 'Position', application.position),
              SizedBox(height: 12),
              _buildProfileRow(
                  Icons.stars, 'Total Points', application.points.toString()),
              SizedBox(height: 12),
              _buildProfileRow(
                  Icons.calendar_today, 'Applied Date', application.appliedDate),
              Divider(height: 24),
              Text(
                'Skills',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: application.skills.map((skill) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xff1676C4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Color(0xff1676C4).withOpacity(0.3)),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xff1676C4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              Divider(height: 24),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(application.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getStatusColor(application.status)),
                ),
                child: Row(
                  children: [
                    Icon(_getStatusIcon(application.status),
                        color: _getStatusColor(application.status), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Status: ${application.status}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(application.status),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showStatusChangeDialog(application);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff1676C4),
              foregroundColor: Colors.white,
            ),
            child: Text('Update Status'),
          ),
        ],
      ),
    );
  }

  void _showStatusChangeDialog(ApplicationModel application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Update Application Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusOption(application, 'Under Review'),
            _buildStatusOption(application, 'Shortlisted'),
            _buildStatusOption(application, 'Interview Scheduled'),
            _buildStatusOption(application, 'Accepted'),
            _buildStatusOption(application, 'Rejected'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(ApplicationModel application, String status) {
    return ListTile(
      leading: Icon(
        _getStatusIcon(status),
        color: _getStatusColor(status),
      ),
      title: Text(status),
      onTap: () {
        setState(() {
          final index = applications.indexWhere((a) => a.id == application.id);
          if (index != -1) {
            applications[index] = application.copyWith(status: status);
            applyFilters();
          }
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to $status'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Under Review':
        return Colors.orange;
      case 'Shortlisted':
        return Colors.blue;
      case 'Interview Scheduled':
        return Colors.purple;
      case 'Accepted':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Under Review':
        return Icons.rate_review;
      case 'Shortlisted':
        return Icons.star;
      case 'Interview Scheduled':
        return Icons.event_available;
      case 'Accepted':
        return Icons.check_circle;
      case 'Rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Color(0xff1676C4)),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAppBar(),
            _buildStatsCards(),
            _buildTabBar(),
            _buildSearchBar(),
            _buildApplicationsTable(),
          ],
        ),
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
                  "Applications",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "View and manage job and internship applications",
                  style: TextStyle(
                    fontSize: 11,
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
              underGradCount.toString(),
              "Under Graduate\nApplications",
              Icons.school,
              Colors.blue,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              gradCount.toString(),
              "Graduate\nApplications",
              Icons.workspace_premium,
              Colors.purple,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              shortlistedCount.toString(),
              "Shortlisted",
              Icons.star,
              Colors.orange,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              interviewScheduledCount.toString(),
              "Interviews\nScheduled",
              Icons.event_available,
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
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
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedTab = "Internship";
                  applyFilters();
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedTab == "Internship"
                      ? Color(0xff1676C4)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selectedTab == "Internship"
                        ? Color(0xff1676C4)
                        : Colors.grey,
                  ),
                ),
                child: Text(
                  'Internships\n(UnderGraduates & Graduates) (${applications.where((a) => a.applicationType == "Internship").length})',
                  style: TextStyle(
                    color: selectedTab == "Internship" ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedTab = "Job";
                  applyFilters();
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedTab == "Job" ? Color(0xff1676C4) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selectedTab == "Job" ? Color(0xff1676C4) : Colors.grey,
                  ),
                ),
                child: Text(
                  'Jobs\nGraduates Only (${applications.where((a) => a.applicationType == "Job").length})',
                  style: TextStyle(
                    color: selectedTab == "Job" ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search applications...",
          prefixIcon: const Icon(Icons.search, color: Color(0xff1676C4)),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xff1676C4), width: 2),
          ),
        ),
        onChanged: (value) {
          setState(() {
            searchText = value;
            applyFilters();
          });
        },
      ),
    );
  }

  Widget _buildApplicationsTable() {
    return Expanded(
      child: filteredApplications.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined,
                size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              "No applications found",
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(
                Color(0xff1676C4).withOpacity(0.1)),
            columns: [
              const DataColumn(
                  label: Text('Applicant Name',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(
                  label: Text('Email',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(
                  label: Text('University',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(
                  label: Text('Major / Year',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text(
                      selectedTab == "Internship"
                          ? 'Internship Position'
                          : 'Job Position',
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(
                  label: Text('Points',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(
                  label: Text('Skills',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(
                  label: Text('Applied Date',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(
                  label: Text('Status',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(
                  label: Text('Profile',
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: filteredApplications.map((app) {
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color(0xff1676C4),
                          radius: 16,
                          child: Text(
                            app.applicantName[0],
                            style: TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          app.applicantName,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                      Text(app.email, style: TextStyle(fontSize: 13))),
                  DataCell(Text(app.university,
                      style: TextStyle(fontSize: 13))),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(app.major,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        Text(app.year,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xff1676C4).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        app.position,
                        style: TextStyle(
                            fontSize: 12, color: Color(0xff1676C4)),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        Icon(Icons.stars, size: 16, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          app.points.toString(),
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        ...app.skills.take(2).map((skill) {
                          return Container(
                            margin: EdgeInsets.only(right: 4),
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                              Color(0xff1676C4).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              skill,
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xff1676C4),
                              ),
                            ),
                          );
                        }).toList(),
                        if (app.skills.length > 2)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '+${app.skills.length - 2}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  DataCell(Text(app.appliedDate,
                      style: TextStyle(fontSize: 13))),
                  DataCell(
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                        _getStatusColor(app.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        app.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(app.status),
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    ElevatedButton(
                      onPressed: () => _viewProfile(app),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff1676C4),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text('View', style: TextStyle(fontSize: 12)),
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