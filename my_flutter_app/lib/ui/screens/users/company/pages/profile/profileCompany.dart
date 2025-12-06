import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// استورد الـ Models والـ Widgets
import '../../../../../../data/models/CompanyActivity.dart';
import '../../../../../../data/models/CompanyInfoModel.dart';
import '../../../../../../data/models/CompanyMember.dart';
import '../../../../../widgets/about_tab.dart';
import '../../../../../widgets/activity_tab.dart';
import '../../../../../widgets/benefits_tab.dart';
import '../../../../../widgets/team_tab.dart';
import 'EditCompanyProfileScreen.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen>
    with SingleTickerProviderStateMixin {
  File? _companyLogo;
  final ImagePicker _picker = ImagePicker();
  late TabController _tabController;

  late CompanyInfoModel companyInfo;

  List<Map<String, String>> stats = [
    {'label': 'Active Jobs', 'value': '8'},
    {'label': 'Total Hires', 'value': '124'},
    {'label': 'Roadmaps Created', 'value': '12'},
  ];

  List<CompanyMember> teamMembers = [
    CompanyMember(name: "Sarah Johnson", role: "HR Manager", email: "sarah@techcorp.com"),
    CompanyMember(name: "Mike Chen", role: "Tech Recruiter", email: "mike@techcorp.com"),
    CompanyMember(name: "Emily Brown", role: "Talent Acquisition", email: "emily@techcorp.com"),
  ];

  List<CompanyActivity> recentActivity = [
    CompanyActivity(action: "Posted new job", detail: "Frontend Developer", date: "2 days ago"),
    CompanyActivity(action: "Created roadmap", detail: "Full Stack Development", date: "1 week ago"),
    CompanyActivity(action: "Hired candidate", detail: "Jane Doe - UI Designer", date: "2 weeks ago"),
  ];

  List<String> benefits = [
    'Health Insurance',
    'Remote Work',
    '401(k) Matching',
    'Learning Budget',
    'Flexible Hours',
    'Stock Options',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    companyInfo = CompanyInfoModel(
      name: 'TechCorp',
      industry: 'Technology & Software',
      description: 'Leading technology company focused on innovative solutions and talent development.',
      location: 'San Francisco, CA',
      email: 'careers@techcorp.com',
      phone: '+1 (555) 123-4567',
      website: 'www.techcorp.com',
      founded: '2015',
      size: '500-1000 employees',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xff3B82F6)),
              title: const Text('اختر من المعرض'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xff3B82F6)),
              title: const Text('التقط صورة'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      try {
        final XFile? image = await _picker.pickImage(
          source: source,
          imageQuality: 85,
        );

        if (image != null) {
          setState(() {
            _companyLogo = File(image.path);
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم اختيار الصورة بنجاح'),
                backgroundColor: Color(0xff3B82F6),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حصل خطأ: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F9FF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with gradient
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xff3B82F6), Color(0xff06B6D4)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        toolbarHeight: 100,
                        // في CompanyProfileScreen
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 24, color: Colors.white),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditCompanyProfileScreen(
                                    companyInfo: companyInfo,
                                    currentLogo: _companyLogo,
                                  ),
                                ),
                              );

                              if (result != null) {
                                setState(() {
                                  companyInfo = result['info'];
                                  if (result['logo'] != null) {
                                    _companyLogo = result['logo'];
                                  }
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // White card with company info
                Positioned(
                  top: 100,
                  left: 24,
                  right: 24,
                  child: Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Company Logo with Camera Icon
                          Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: _companyLogo == null
                                      ? const LinearGradient(
                                    colors: [Color(0xff3B82F6), Color(0xff06B6D4)],
                                  )
                                      : null,
                                  border: Border.all(color: const Color(0xff3B82F6), width: 3),
                                  image: _companyLogo != null
                                      ? DecorationImage(
                                    image: FileImage(_companyLogo!),
                                    fit: BoxFit.cover,
                                  )
                                      : null,
                                ),
                                child: _companyLogo == null
                                    ? const Center(
                                  child: Text(
                                    'TC',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xff3B82F6), Color(0xff06B6D4)],
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Company Name
                          Text(
                            companyInfo.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            companyInfo.industry,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Stats
                          Row(
                            children: stats.map((stat) {
                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xff3B82F6).withOpacity(0.1),
                                        const Color(0xff06B6D4).withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          stat['value']!,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          stat['label']!,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 340),

            // Tabs
            Container(
              height: 55,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff3B82F6), Color(0xff06B6D4)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'About'),
                  Tab(text: 'Team'),
                  Tab(text: 'Activity'),
                  Tab(text: 'Benefits'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // TabBarView
            SizedBox(
              height: 550,
              child: TabBarView(
                controller: _tabController,
                children: [
                  AboutTab(companyInfo: companyInfo),
                  TeamTab(teamMembers: teamMembers),
                  ActivityTab(recentActivity: recentActivity),
                  BenefitsTab(benefits: benefits),
                ],
              ),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.only(right: 24, left: 24),
              child: Column(
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back to Dashboard',
                      style: TextStyle(
                        color: Color(0xff3B82F6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }
}