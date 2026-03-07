import 'package:flutter/material.dart';
import 'dart:io';

import '../../../../../../data/models/university/university-model.dart';
import 'EdituniversityProfileScreen.dart';

class UniversityProfileScreen extends StatefulWidget {
  const UniversityProfileScreen({super.key});

  @override
  State<UniversityProfileScreen> createState() => _UniversityProfileScreenState();
}

class _UniversityProfileScreenState extends State<UniversityProfileScreen> {
  // Sample data - Replace with API data
  final UniversityModel university = UniversityModel(
    id: '1',
    name: 'Egyptian E-Learning University',
    abbreviation: 'EELU',
    location: 'Giza, Egypt',
    email: 'info@eelu.edu.eg',
    phone: '+20 2 3854 0888',
    website: 'www.eelu.edu.eg',
    about:
    'The Egyptian E-Learning University (EELU) is a leading institution in providing quality education through modern e-learning platforms. We offer a wide range of programs designed to prepare students for successful careers in their chosen fields.',
    totalStudents: 12500,
    totalPrograms: 45,
    successRate: 85.0,
    totalPartners: 200,
    establishedYear: '2008',
    specializations: [
      'Computer Science',
      'Business Administration',
      'Information Technology',
      'Mass Communication',
      'Commerce',
    ],
    socialMedia: {
      'facebook': 'https://facebook.com/eelu',
      'twitter': 'https://twitter.com/eelu',
      'linkedin': 'https://linkedin.com/school/eelu',
      'instagram': 'https://instagram.com/eelu',
    },
  );

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.edit, color: Color(0xff1676C4)),
            SizedBox(width: 8),
            Text('Edit Profile'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('University profile editing feature coming soon!'),
            SizedBox(height: 16),
            Text(
              'You will be able to update university information, contact details, and statistics.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
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

  Widget _buildLogoWidget() {
    if (university.logoPath == null || university.logoPath!.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.school,
          color: Color(0xff1676C4),
          size: 40,
        ),
      );
    }

    if (university.logoPath!.startsWith("http")) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.network(
            university.logoPath!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.broken_image, size: 40);
            },
          ),
        ),
      );
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.file(
          File(university.logoPath!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.broken_image, size: 40);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContactInformation(),
                  _buildAboutSection(),
                  _buildStatistics(),
                  if (university.specializations != null &&
                      university.specializations!.isNotEmpty)
                    _buildSpecializations(),
                  if (university.socialMedia != null &&
                      university.socialMedia!.isNotEmpty)
                    SizedBox(height: 20),
                    _buildSocialMedia(),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff1676C4), Color(0xff0d5fa3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Spacer(),
                  Text(
                    'University Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UniversityEditProfileScreen(university: university),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Logo and Name
            _buildLogoWidget(),
            SizedBox(height: 16),
            Text(
              university.abbreviation,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              university.name,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInformation() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: EdgeInsets.all(20),
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
                Icon(Icons.info_outline, color: Color(0xff1676C4), size: 24),
                SizedBox(width: 8),
                Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildContactRow(Icons.location_on, university.location),
            SizedBox(height: 12),
            _buildContactRow(Icons.email, university.email),
            SizedBox(height: 12),
            _buildContactRow(Icons.phone, university.phone),
            SizedBox(height: 12),
            _buildContactRow(Icons.language, university.website),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xff1676C4).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Color(0xff1676C4), size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: EdgeInsets.all(20),
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
                Icon(Icons.description, color: Color(0xff1676C4), size: 24),
                SizedBox(width: 8),
                Text(
                  'About',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              university.about,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            if (university.establishedYear != null) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Color(0xff1676C4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today,
                        color: Color(0xff1676C4), size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Established: ${university.establishedYear}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xff1676C4),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: EdgeInsets.all(20),
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
                Icon(Icons.analytics, color: Color(0xff1676C4), size: 24),
                SizedBox(width: 8),
                Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
              children: [
                _buildStatCard(
                  '${university.totalStudents}+',
                  'Students',
                  Icons.people,
                  Colors.blue,
                ),
                _buildStatCard(
                  '${university.totalPrograms}+',
                  'Programs',
                  Icons.school,
                  Colors.green,
                ),
                _buildStatCard(
                  '${university.successRate.toInt()}%',
                  'Success Rate',
                  Icons.trending_up,
                  Colors.orange,
                ),
                _buildStatCard(
                  '${university.totalPartners}+',
                  'Partners',
                  Icons.business,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String value, String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecializations() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: EdgeInsets.all(20),
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
                Icon(Icons.class_, color: Color(0xff1676C4), size: 24),
                SizedBox(width: 8),
                Text(
                  'Specializations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: university.specializations!.map((spec) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xff1676C4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Color(0xff1676C4).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    spec,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xff1676C4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMedia() {
    final socialIcons = {
      'facebook': Icons.facebook,
      'twitter': Icons.flutter_dash, // Twitter icon alternative
      'linkedin': Icons.business,
      'instagram': Icons.camera_alt,
    };

    final socialColors = {
      'facebook': Color(0xff1877F2),
      'twitter': Color(0xff1DA1F2),
      'linkedin': Color(0xff0A66C2),
      'instagram': Color(0xffE4405F),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: EdgeInsets.all(20),
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
                Icon(Icons.share, color: Color(0xff1676C4), size: 24),
                SizedBox(width: 8),
                Text(
                  'Social Media',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: university.socialMedia!.entries.map((entry) {
                return InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening ${entry.key}...')),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: socialColors[entry.key]?.withOpacity(0.1) ??
                          Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: socialColors[entry.key]?.withOpacity(0.3) ??
                            Colors.grey[300]!,
                      ),
                    ),
                    child: Icon(
                      socialIcons[entry.key] ?? Icons.link,
                      color: socialColors[entry.key] ?? Colors.grey[600],
                      size: 24,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}