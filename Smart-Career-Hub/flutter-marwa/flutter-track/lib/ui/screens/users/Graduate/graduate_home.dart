import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../ui/screens/auth/login/login_screen.dart';

// ── Cubits (shared with Student) ──
import '../Student/cubit/profile/profile_cubit.dart';
import '../Student/cubit/profile/profile_state.dart';
import '../Student/cubit/roadmap/roadmap_cubit.dart';
import '../Student/cubit/event/event_cubit.dart';
import '../Student/cubit/workshop/workshop_cubit.dart';
import '../Student/cubit/catalog/catalog_cubit.dart';

// ── Services ──
import '../../../../data/services/ProfileService.dart';
import '../../../../data/services/RoadmapService.dart';
import '../../../../data/services/EventService.dart';
import '../../../../data/services/WorkshopService.dart';
import '../../../../data/services/CatalogService.dart';

// ── Screens ──
import '../Student/RoadmapExplorerScreen.dart';
import '../Student/Eventsscreen.dart';
import '../Student/Workshopsscreen.dart';
import '../Student/Settings screen.dart';
import '../Student/Message hr screen.dart';
import '../Student/Careertipsscreen.dart';
import 'my_profile.dart';
import 'job_internship_tracker.dart';
import 'interview_invitations.dart';
import 'build_career_profile.dart';

class GraduateHome extends StatefulWidget {
  const GraduateHome({super.key});
  @override
  State<GraduateHome> createState() => _GraduateHomeState();
}

class _GraduateHomeState extends State<GraduateHome> {
  int _selectedIndex = 0;
  static const Color kPrimary = Color(0xff1676C4);
  static const Color kPrimaryDark = Color(0xff0d5fa3);
  static const Color kBg = Color(0xffF0F9FF);

  // ── Cubits ──
  late final ProfileCubit _profileCubit;
  late final RoadmapCubit _roadmapCubit;
  late final CatalogCubit _catalogCubit;
  late final EventCubit _eventCubit;
  late final WorkshopCubit _workshopCubit;

  @override
  void initState() {
    super.initState();
    _profileCubit = ProfileCubit(ProfileService())..loadProfile();
    _roadmapCubit = RoadmapCubit(RoadmapService())..loadRoadmaps();
    _catalogCubit = CatalogCubit(CatalogService())..loadCatalog();
    _eventCubit = EventCubit(EventService())..loadEvents();
    _workshopCubit = WorkshopCubit(WorkshopService())..loadWorkshops();
  }

  @override
  void dispose() {
    _profileCubit.close();
    _roadmapCubit.close();
    _catalogCubit.close();
    _eventCubit.close();
    _workshopCubit.close();
    super.dispose();
  }

  void _pushScreen(Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(icon: const Icon(Icons.close, color: Colors.black54), onPressed: () => Navigator.pop(context)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [kPrimary, kPrimaryDark]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.hub_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Text('Smart Career\nHub', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kPrimary, height: 1.25)),
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(padding: const EdgeInsets.symmetric(vertical: 8), children: [
              _tile(Icons.calendar_today_outlined, 'Calendar', () => _pushScreen(const GraduateCalendarScreen())),
              _tile(Icons.event_outlined, 'Events', () => _pushScreen(const EventsScreen())),
              _tile(Icons.handyman_outlined, 'Workshops', () => _pushScreen(const WorkshopsScreen())),
              _tile(Icons.work_outline, 'Job & Internship Tracker', () { Navigator.pop(context); setState(() => _selectedIndex = 2); }),
              _tile(Icons.videocam_outlined, 'Interview Invitations', () => _pushScreen(const InterviewInvitations())),
              _tile(Icons.build_circle_outlined, 'Build Career Profile', () => _pushScreen(const BuildCareerProfile())),
              _tile(Icons.lightbulb_outline, 'Career Tips', () => _pushScreen(const CareerTipsScreen())),
              _tile(Icons.settings_outlined, 'Settings', () => _pushScreen(const SettingsScreen())),
              _tile(Icons.message_outlined, 'Message HR', () => _pushScreen(const MessageHRScreen())),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.red, size: 22),
                title: const Text('Logout', style: TextStyle(color: Colors.red, fontSize: 14)),
                horizontalTitleGap: 8,
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('student_token');
                  await prefs.remove('graduate_token');
                  await prefs.remove('auth_token');
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (r) => false,
                    );
                  }
                },
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  ListTile _tile(IconData icon, String label, VoidCallback onTap) =>
      ListTile(leading: Icon(icon, color: kPrimary, size: 22), title: Text(label, style: const TextStyle(fontSize: 14)), horizontalTitleGap: 8, onTap: onTap);

  PreferredSizeWidget _appBar(BuildContext ctx) => AppBar(
    backgroundColor: kPrimary, elevation: 0,
    leading: Builder(builder: (c) => GestureDetector(
      onTap: () => Scaffold.of(c).openDrawer(),
      child: Padding(padding: const EdgeInsets.all(10), child: CircleAvatar(backgroundColor: Colors.white.withOpacity(0.25), child: const Icon(Icons.person, color: Colors.white, size: 20))),
    )),
    title: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.hub_rounded, color: Colors.white, size: 16), SizedBox(width: 4),
        Text('Smart Career Hub', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    ),
    actions: [IconButton(icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 26), onPressed: () {})],
  );

  Widget _bottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.map_outlined, 'label': 'Roadmaps'},
      {'icon': Icons.work_outline, 'label': 'Jobs'},
      {'icon': Icons.person_outline_rounded, 'label': 'Profile'},
    ];
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -3))]),
      child: SafeArea(top: false, child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: List.generate(items.length, (i) {
          final sel = _selectedIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: sel ? kPrimary.withOpacity(0.12) : Colors.transparent, borderRadius: BorderRadius.circular(20)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(items[i]['icon'] as IconData, color: sel ? kPrimary : Colors.grey, size: 24),
                if (sel) ...[const SizedBox(height: 2), Text(items[i]['label'] as String, style: const TextStyle(fontSize: 10, color: kPrimary, fontWeight: FontWeight.w600))],
              ]),
            ),
          );
        })),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileCubit>.value(value: _profileCubit),
        BlocProvider<RoadmapCubit>.value(value: _roadmapCubit),
        BlocProvider<CatalogCubit>.value(value: _catalogCubit),
        BlocProvider<EventCubit>.value(value: _eventCubit),
        BlocProvider<WorkshopCubit>.value(value: _workshopCubit),
      ],
      child: Builder(
        builder: (context) {
          final pages = [
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                String graduateName = 'Graduate';
                if (state is ProfileSuccess) {
                  final basicInfo = (state.profileData['basicInfo'] ?? {}) as Map;
                  graduateName = basicInfo['fullName']?.toString() ?? 'Graduate';
                }
                return _GraduateHomeBody(name: graduateName, onNav: (i) => setState(() => _selectedIndex = i));
              },
            ),
            const RoadmapExplorerScreen(showBackButton: false),
            const JobInternshipTracker(),
            const MyProfile(showBackButton: false),
          ];
          return Scaffold(
            backgroundColor: kBg,
            appBar: _selectedIndex == 0 ? _appBar(context) : null,
            drawer: _selectedIndex == 0 ? _buildDrawer() : null,
            body: IndexedStack(index: _selectedIndex, children: pages),
            bottomNavigationBar: _bottomNav(),
          );
        },
      ),
    );
  }
}

// ── Home Body ──
class _GraduateHomeBody extends StatelessWidget {
  final String name;
  final void Function(int) onNav;
  const _GraduateHomeBody({required this.name, required this.onNav});
  static const Color kPrimary = Color(0xff1676C4);
  static const Color kPrimaryDark = Color(0xff0d5fa3);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [kPrimary, kPrimaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.3))),
            child: const Row(children: [
              Icon(Icons.smart_toy_outlined, color: Colors.white, size: 18), SizedBox(width: 8),
              Expanded(child: Text("Career Feedback: You're 80% ready for a Data Analyst position!", style: TextStyle(color: Colors.white, fontSize: 12))),
            ]),
          ),
          const SizedBox(height: 16),
          Text('Welcome, $name 👋', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          Row(children: [_chip('3,258','Points'), const SizedBox(width:8), _chip('12','Applications'), const SizedBox(width:8), _chip('3','Completed'), const SizedBox(width:8), _chip('2','Interviews')]),
        ]),
      ),
      _section('Recommended Jobs & Internships', 'View All', () => onNav(2)),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Column(children: [
        _jobCard('Data Analyst', 'Microsoft · Full-time', 0.80),
        _jobCard('Business Intelligence Analyst', 'Google · Full-time', 0.75),
        _jobCard('Data Science Intern', 'Amazon · Internship', 0.67),
      ])),
      _section('Completed Roadmaps', 'View All', () => onNav(1)),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
        child: Column(children: [
          _roadmapRow('Full Stack Web Development', 'Google'),
          const Divider(height:1, indent:16, endIndent:16),
          _roadmapRow('Data Analysis Fundamentals', 'Microsoft'),
          const Divider(height:1, indent:16, endIndent:16),
          _roadmapRow('Python for Data Science', 'IBM'),
        ]),
      )),
      _section('Upcoming Interviews', 'View All', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InterviewInvitations()))),
      Padding(padding: const EdgeInsets.fromLTRB(16,0,16,24), child: Row(children: [
        Expanded(child: _interviewMini('Data Analyst', 'Microsoft', 'Nov 3')),
        const SizedBox(width:10),
        Expanded(child: _interviewMini('Business Analyst', 'Orange', 'Nov 5')),
      ])),
    ]));
  }

  Widget _chip(String v, String l) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical:8),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
    child: Column(children: [
      Text(v, style: const TextStyle(color:Colors.white, fontWeight:FontWeight.bold, fontSize:13)),
      Text(l, style: const TextStyle(color:Colors.white70, fontSize:9)),
    ]),
  ));

  Widget _section(String t, String a, VoidCallback fn) => Padding(
    padding: const EdgeInsets.fromLTRB(16,16,16,10),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(t, style: const TextStyle(fontSize:15, fontWeight:FontWeight.bold)),
      TextButton(onPressed: fn, child: Text(a, style: const TextStyle(color:kPrimary, fontWeight:FontWeight.w600, fontSize:12))),
    ]),
  );

  Widget _jobCard(String title, String sub, double match) => Container(
    margin: const EdgeInsets.only(bottom:10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color:Colors.white, borderRadius:BorderRadius.circular(14), boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.05), blurRadius:6)]),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment:CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight:FontWeight.w700, fontSize:13)),
        const SizedBox(height:2),
        Text(sub, style: const TextStyle(fontSize:11, color:Colors.grey)),
        const SizedBox(height:6),
        LinearProgressIndicator(value:match, backgroundColor:Colors.grey[200], valueColor: const AlwaysStoppedAnimation(kPrimary), minHeight:4, borderRadius:BorderRadius.circular(4)),
        const SizedBox(height:3),
        Text('${(match*100).toInt()}% match', style: const TextStyle(fontSize:10, color:kPrimary, fontWeight:FontWeight.w600)),
      ])),
      const SizedBox(width:12),
      ElevatedButton(onPressed:(){}, style:ElevatedButton.styleFrom(backgroundColor:kPrimary, padding: const EdgeInsets.symmetric(horizontal:14, vertical:8), shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)), minimumSize:Size.zero), child: const Text('Apply', style:TextStyle(fontSize:12, color:Colors.white))),
    ]),
  );

  Widget _roadmapRow(String t, String c) => Padding(
    padding: const EdgeInsets.symmetric(horizontal:16, vertical:12),
    child: Row(children: [
      const Icon(Icons.check_circle_rounded, color:Color(0xff22C55E), size:20),
      const SizedBox(width:12),
      Expanded(child: Column(crossAxisAlignment:CrossAxisAlignment.start, children: [
        Text(t, style: const TextStyle(fontWeight:FontWeight.w600, fontSize:13)),
        Text(c, style: const TextStyle(fontSize:11, color:Colors.grey)),
      ])),
      OutlinedButton(onPressed:(){}, style:OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal:10, vertical:4), side: const BorderSide(color:kPrimary), shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(8)), minimumSize:Size.zero),
        child: const Text('View Certificate', style:TextStyle(fontSize:10, color:kPrimary))),
    ]),
  );

  Widget _interviewMini(String title, String co, String date) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color:Colors.white, borderRadius:BorderRadius.circular(14), boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.05), blurRadius:6)]),
    child: Column(crossAxisAlignment:CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight:FontWeight.bold, fontSize:12)),
      const SizedBox(height:4),
      Text(co, style: const TextStyle(fontSize:11, color:Colors.grey)),
      const SizedBox(height:6),
      Row(children:[const Icon(Icons.calendar_today, size:11, color:Colors.grey), const SizedBox(width:4), Text(date, style: const TextStyle(fontSize:11, color:Colors.grey))]),
      const SizedBox(height:8),
      SizedBox(width:double.infinity, child:ElevatedButton(onPressed:(){}, style:ElevatedButton.styleFrom(backgroundColor:kPrimary, padding: const EdgeInsets.symmetric(vertical:6), shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(8)), minimumSize:Size.zero), child: const Text('Details', style:TextStyle(fontSize:11, color:Colors.white)))),
    ]),
  );
}

// ── Graduate Calendar ──
class GraduateCalendarScreen extends StatelessWidget {
  const GraduateCalendarScreen({super.key});
  static const Color kPrimary = Color(0xff1676C4);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final firstWeekday = DateTime(now.year, now.month, 1).weekday % 7;
    final monthName = ['January','February','March','April','May','June','July','August','September','October','November','December'][now.month-1];
    final events = [
      {'day':3,'title':'Microsoft Interview','color':const Color(0xff22C55E)},
      {'day':8,'title':'Data Analyst Interview','color':kPrimary},
      {'day':15,'title':'Career Fair','color':const Color(0xffF59E0B)},
      {'day':22,'title':'Flutter Workshop','color':Colors.purple},
    ];
    return Scaffold(
      backgroundColor: const Color(0xffF0F9FF),
      appBar: AppBar(backgroundColor:kPrimary, elevation:0, leading:IconButton(icon: const Icon(Icons.arrow_back, color:Colors.white), onPressed:()=>Navigator.pop(context)), title: const Text('Calendar', style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold))),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children:[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(gradient: const LinearGradient(colors:[kPrimary,Color(0xff0d5fa3)]), borderRadius:BorderRadius.circular(16)),
          child: Column(children:[
            Text('$monthName ${now.year}', style: const TextStyle(color:Colors.white, fontSize:18, fontWeight:FontWeight.bold)),
            const SizedBox(height:12),
            Row(children:['Sun','Mon','Tue','Wed','Thu','Fri','Sat'].map((d)=>Expanded(child:Center(child:Text(d, style: const TextStyle(color:Colors.white70, fontSize:11))))).toList()),
            const SizedBox(height:8),
            GridView.builder(
              shrinkWrap:true, physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:7, mainAxisSpacing:4, crossAxisSpacing:4),
              itemCount:firstWeekday+daysInMonth,
              itemBuilder:(_, i){
                if(i<firstWeekday) return const SizedBox();
                final day=i-firstWeekday+1;
                final isToday=day==now.day;
                final hasEvent=events.any((e)=>e['day']==day);
                return Container(
                  decoration:BoxDecoration(color:isToday?Colors.white:(hasEvent?Colors.white.withOpacity(0.2):Colors.transparent), borderRadius:BorderRadius.circular(8)),
                  child:Column(mainAxisAlignment:MainAxisAlignment.center, children:[
                    Text('$day', style:TextStyle(color:isToday?kPrimary:Colors.white, fontWeight:isToday?FontWeight.bold:FontWeight.normal, fontSize:12)),
                    if(hasEvent) Container(width:4, height:4, decoration: const BoxDecoration(color:Color(0xffFCD34D), shape:BoxShape.circle)),
                  ]),
                );
              },
            ),
          ]),
        ),
        const SizedBox(height:16),
        const Align(alignment:Alignment.centerLeft, child:Text('Upcoming Events', style:TextStyle(fontWeight:FontWeight.bold, fontSize:16))),
        const SizedBox(height:12),
        ...events.map((e)=>Container(
          margin: const EdgeInsets.only(bottom:10),
          padding: const EdgeInsets.all(14),
          decoration:BoxDecoration(color:Colors.white, borderRadius:BorderRadius.circular(14), boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.05), blurRadius:6)], border:Border(left:BorderSide(color:e['color'] as Color, width:4))),
          child:Row(children:[
            Container(width:40, height:40, decoration:BoxDecoration(color:(e['color'] as Color).withOpacity(0.1), borderRadius:BorderRadius.circular(10)), child:Center(child:Text('${e['day']}', style:TextStyle(color:e['color'] as Color, fontWeight:FontWeight.bold, fontSize:16)))),
            const SizedBox(width:12),
            Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
              Text(e['title'] as String, style: const TextStyle(fontWeight:FontWeight.w600, fontSize:13)),
              Text('$monthName ${e['day']}, ${now.year}', style: const TextStyle(fontSize:11, color:Colors.grey)),
            ])),
          ]),
        )),
      ])),
    );
  }
}
