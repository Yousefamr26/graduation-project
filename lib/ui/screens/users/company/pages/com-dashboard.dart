import 'package:SmartCareerHub/ui/screens/users/company/pages/profile/profileCompany.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../../../data/models/company/DashboardCardModel.dart';
import '../../university/pages/workshop/WorkshopsScreen.dart';
import '../../university/pages/workshop/crate_editWorkshopUni.dart';
import 'Analytics/AnalyticsPage.dart';
import 'Applications/Applications.dart';
import 'Calendar/Calendar.dart';
import 'Event/addnewevent.dart';
import 'Event/eventscreen.dart';
import 'Interviews/InterviewsScreen.dart';
import 'Roadmaps/Create_editRoadmap.dart';
import 'Roadmaps/roadmapscreen.dart';
import 'analyticsscreen/analyticsscreen.dart';
import 'internship/internshipscreen.dart';
import 'jobs/jobScreen.dart';

class comDashboard extends StatefulWidget {
  const comDashboard({super.key});

  @override
  State<comDashboard> createState() => _comDashboardState();
}

class _comDashboardState extends State<comDashboard> {
  int _selectedIndex = 0;
  String _companyName = 'TechCorp Solutions';

  final List<DashboardCardModel> dashboardCards = [
    DashboardCardModel(
      icon: Icons.school,
      title: 'Active Roadmaps',
      count: '5',
      subtitle: '1,234 student enrolled',
    ),
    DashboardCardModel(
      icon: Icons.people,
      title: 'Enrolled Students',
      count: '856',
      subtitle: '+45 this month',
    ),
    DashboardCardModel(
      icon: Icons.work,
      title: 'Workshops Created',
      count: '6',
      subtitle: 'This week',
    ),
    DashboardCardModel(
      icon: Icons.event,
      title: 'Upcoming Interviews',
      count: '12',
      subtitle: 'This week',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> _pages() {
    return [
      _buildHomePage(),
      MyRoadmapsScreen(),
      AnalyticsScreen(),
      CompanyProfileScreen(),
    ];
  }

  Widget _buildHomePage() {
    return Scaffold(
      backgroundColor: Color(0xffF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome back 👋",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              _companyName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.notifications_none, color: Color(0xff1676C4)),
            ),
          ),
        ],
        iconTheme: IconThemeData(color: Colors.black),
      ),

      drawer: Drawer(
        width: 220,
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(height: 50),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: IconButton(
                        icon: Icon(Icons.close, size: 28, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Smart Career Hub',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1676C4),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                color: Color(0xff1676C4),
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    _drawerItem(
                      icon: Icons.work_outline,
                      title: 'Jobs',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => JobsScreen())),
                    ),
                    _drawerItem(
                      icon: Icons.school,
                      title: 'Internships',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => InternshipsScreen())),
                    ),
                    _drawerItem(
                      icon: Icons.construction,
                      title: 'Workshops',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => WorkshopsScreen())),
                    ),
                    // _drawerItem(
                    //   icon: Icons.event,
                    //   title: 'Events',
                    //   onTap: () => Navigator.push(context,
                    //       MaterialPageRoute(builder: (_) => EventsScreen())),
                    // ),
                    _drawerItem(
                      icon: Icons.videocam_outlined,
                      title: 'Interviews',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => InterviewsScreen())),
                    ),
                    _drawerItem(
                      icon: Icons.description,
                      title: 'Applications',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => ApplicationsScreen())),
                    ),
                    _drawerItem(
                      icon: Icons.calendar_today,
                      title: 'Calendar',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => CalendarScreen())),
                    ),

                    Spacer(),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: InkWell(
                        //onTap: () => Navigator.push(context,
                          //  MaterialPageRoute(builder: (_) => ChooseRoleScreen())),
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red, size: 24),
                            SizedBox(width: 16),
                            Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Stats Grid
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: dashboardCards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                return modernCard(dashboardCards[index]);
              },
            ),

            SizedBox(height: 24),

            /// Quick Actions Title
            Text(
              "Quick Actions",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 12),

            /// Actions Row 1
            Row(
              children: [
                Expanded(
                  child: actionCard(
                    icon: Icons.add_road,
                    title: "Roadmap",
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => Create_editRoadmap())),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: actionCard(
                    icon: Icons.workspaces_outline,
                    title: "Workshop",
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => crate_editWorkshop())),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            /// Actions Row 2
            Row(
              children: [
                // Expanded(
                //   child: actionCard(
                //     icon: Icons.event_available,
                //     title: "Event",
                //     onTap: () => Navigator.push(context,
                //         MaterialPageRoute(builder: (_) => CreateEditEventScreen())),
                //   ),
                // ),
                SizedBox(width: 12),
                Expanded(
                  child: actionCard(
                    icon: Icons.calendar_today,
                    title: "Calendar",
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => CalendarScreen())),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      setState(() {
        _companyName = userData['name'] ?? 'TechCorp Solutions';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages(),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: Color(0xff1676C4),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Roadmaps'),
            BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

// ✅ Modern Stats Card
Widget modernCard(DashboardCardModel model) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xff1676C4).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(model.icon, color: Color(0xff1676C4), size: 22),
        ),
        Spacer(),
        Text(
          model.count,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          model.title,
          style: TextStyle(color: Colors.grey, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

// ✅ Action Card
Widget actionCard({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xff1676C4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Color(0xff1676C4), size: 20),
          ),
          SizedBox(width: 8),
          Flexible(                           // ✅ هنا الحل
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis, // ✅ لو النص طويل
              maxLines: 1,
            ),
          ),
          SizedBox(width: 4),
          Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
        ],
      ),
    ),
  );
}

// ✅ Drawer Item
Widget _drawerItem({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}