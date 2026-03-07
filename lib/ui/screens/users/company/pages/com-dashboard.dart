import 'package:SmartCareerHub/ui/screens/users/company/pages/profile/profileCompany.dart';
import 'package:flutter/material.dart';

import '../../../../../data/models/company/DashboardCardModel.dart';
import '../../chooseUser.dart';
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
      title: 'UpcomingInterviews',
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
      _buildHomePage(), // Home
      MyRoadmapsScreen(), // Roadmaps
      AnalyticsScreen(), // Analytics
      CompanyProfileScreen(), // Profile
    ];
  }

  // صفحة الـ Home
  Widget _buildHomePage() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Company Dashboard'),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications),
          )
        ],
      ),
      drawer: Drawer(
        width: 220,
        child: Column(
          children: [
            Container(
              height: 240,
              width: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(height: 50),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: IconButton(
                        icon: Icon(Icons.close, size: 30),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                   'Smart Career',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1676C4),
                    ),
                  ),
                  Text(
                    'Hub',
                    style: TextStyle(
                      fontSize: 28,
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
                      onTap: () {
                       Navigator.push(context,
                           MaterialPageRoute(builder: (BuildContext context){
                             return JobsScreen();
                           })
                       );
                      },
                    ),
                    _drawerItem(
                      icon: Icons.school,
                      title: 'Internships',
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context){
                              return InternshipsScreen();
                            })
                        );
                      },
                    ),
                    _drawerItem(
                      icon: Icons.construction,
                      title: 'Workshops',
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context){
                              return WorkshopsScreen();
                            })
                        );
                      },
                    ),
                    _drawerItem(
                      icon: Icons.event,
                      title: 'Events',
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context){
                              return EventsScreen();
                            })
                        );
                      },
                    ),
                    _drawerItem(
                      icon: Icons.videocam_outlined,
                      title: 'Interviews',
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context){
                              return InterviewsScreen();
                            })
                        );
                      },
                    ),
                    _drawerItem(
                      icon: Icons.description,
                      title: 'Applications',
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context){
                              return ApplicationsScreen();
                            })
                        );
                      },
                    ),
                    _drawerItem(
                      icon: Icons.calendar_today,
                      title: 'Calendar',
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context){
                              return CalendarScreen();
                            })
                        );
                      },
                    ),

                    Spacer(),

                    // زر Logout
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ChooseRoleScreen()));
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout,
                              color: Colors.red,
                              size: 24,
                            ),
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
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'TechCorp Solutions - Manage your roadmaps,\nworkshops, and student engagement',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xff1676C4),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xff1676C4),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: dashboardCards.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.07,
                      ),
                      itemBuilder: (context, index) {
                        return dashboardCard(dashboardCards[index]);
                      },
                    ),

                    SizedBox(height: 16),

                    SizedBox(
                      width: 220,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context){
                                return Create_editRoadmap();
                              }));
                        },
                        icon: Icon(
                          Icons.add_road,
                          color: Color(0xff1676C4),
                        ),
                        label: Text(
                          'Add Roadmap',
                          style: TextStyle(
                            color: Color(0xff1676C4),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 8),

                    SizedBox(
                      width: 220,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context){
                                return crate_editWorkshop();
                              }));
                        },
                        icon: Icon(
                          Icons.workspaces_outline,
                          color: Color(0xff1676C4),
                        ),
                        label: Text(
                          'Create Workshop',
                          style: TextStyle(
                            color: Color(0xff1676C4),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 8),

                    SizedBox(
                      width: 220,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context){
                                return CreateEditEventScreen();
                              }));
                        },
                        icon: Icon(
                          Icons.event_available,
                          color: Color(0xff1676C4),
                        ),
                        label: Text(
                          'Create Event',
                          style: TextStyle(
                            color: Color(0xff1676C4),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xff1676C4),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Roadmaps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

Widget dashboardCard(DashboardCardModel model) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xff1676C4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(model.icon, color: Color(0xff1676C4), size: 28),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 34),
                child: Text(
                  model.count,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Text(
          model.title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          model.subtitle,
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    ),
  );
}
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
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
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