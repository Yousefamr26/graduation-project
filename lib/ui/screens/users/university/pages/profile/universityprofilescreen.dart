import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../data/models/university/university-model.dart';
import '../../../../auth/login/login_screen.dart';
import 'EdituniversityProfileScreen.dart';

class UniversityProfileScreen extends StatefulWidget {
  const UniversityProfileScreen({super.key});

  @override
  State<UniversityProfileScreen> createState() =>
      _UniversityProfileScreenState();
}

class _UniversityProfileScreenState extends State<UniversityProfileScreen> {
  UniversityModel? _university;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // ── المصدر 1: university_user_data ──────────────────────
      Map<String, dynamic> savedData = {};
      final savedRaw = prefs.getString('university_user_data');
      if (savedRaw != null && savedRaw.isNotEmpty) {
        try {
          savedData = jsonDecode(savedRaw) as Map<String, dynamic>;
          debugPrint('📦 [UNI PROFILE] university_user_data: $savedData');
        } catch (e) {
          debugPrint('⚠️ [UNI PROFILE] parse error: $e');
        }
      }

      // ── المصدر 2: JWT token ──────────────────────────────────
      Map<String, dynamic> tokenData = {};
      final token = prefs.getString('university_token');
      if (token != null && token.isNotEmpty) {
        try {
          final parts = token.split('.');
          if (parts.length == 3) {
            final normalized = base64Url.normalize(parts[1]);
            final decoded    = utf8.decode(base64Url.decode(normalized));
            tokenData        = jsonDecode(decoded) as Map<String, dynamic>;
            debugPrint('🔑 [UNI PROFILE] Token keys: ${tokenData.keys.toList()}');
          }
        } catch (e) {
          debugPrint('⚠️ [UNI PROFILE] token decode error: $e');
        }
      }

      // ── Helper ────────────────────────────────────────────────
      String get(List<String> keys) {
        for (final k in keys) {
          final v = savedData[k]?.toString() ?? '';
          if (v.isNotEmpty) return v;
        }
        for (final k in keys) {
          final v = tokenData[k]?.toString() ?? '';
          if (v.isNotEmpty) return v;
        }
        return '';
      }

      final name    = get(['name', 'Name', 'UniversityName',
        'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name']);
      final email   = get(['email', 'Email',
        'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress']);
      final phone   = get(['phoneNumber', 'PhoneNumber', 'phone']);
      final city    = get(['city',    'City']);
      final country = get(['country', 'Country']);
      final about   = get(['about',   'About']);
      final website = get(['website', 'Website']);
      final abbr    = get(['abbreviation', 'Abbreviation']);
      final id      = get(['id', 'Id', 'UniversityId',
        'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier']);

      // ✅ الـ logo — نجيبه من savedData وهو بالفعل full URL
      final logoRaw = get([
        'logoPath', 'LogoPath',
        'organizationLogoUrl', 'OrganizationLogoUrl',
        'logoUrl', 'LogoUrl',
        'organizationLogo', 'OrganizationLogo',
      ]);

      // ✅ نبني الـ full URL لو لسه relative (ضمان مضاعف)
      String fullLogoUrl = '';
      if (logoRaw.isNotEmpty) {
        fullLogoUrl = logoRaw.startsWith('http')
            ? logoRaw
            : 'http://smartcareerhub.runasp.net$logoRaw';
      }

      debugPrint('🖼️ [UNI PROFILE] logo raw: $logoRaw');
      debugPrint('🖼️ [UNI PROFILE] logo full: $fullLogoUrl');

      // ── Specializations ──────────────────────────────────────
      List<String>? specializations;
      final specRaw = savedData['specializations'] ?? tokenData['Specializations'];
      if (specRaw is List) {
        specializations = specRaw.map((e) => e.toString()).toList();
      }

      // ── Stats ────────────────────────────────────────────────
      final totalStudents = int.tryParse(get(['totalStudents', 'TotalStudents'])) ?? 0;
      final totalPrograms = int.tryParse(get(['totalPrograms', 'TotalPrograms'])) ?? 0;
      final successRate   = double.tryParse(get(['successRate',  'SuccessRate']))  ?? 0.0;
      final totalPartners = int.tryParse(get(['totalPartners', 'TotalPartners'])) ?? 0;

      if (mounted) {
        setState(() {
          _university = UniversityModel(
            id:              id,
            name:            name,
            abbreviation:    abbr.isNotEmpty ? abbr : _makeAbbreviation(name),
            location:        [city, country].where((e) => e.isNotEmpty).join(', '),
            email:           email,
            phone:           phone,
            website:         website,
            about:           about,
            totalStudents:   totalStudents,
            totalPrograms:   totalPrograms,
            successRate:     successRate,
            totalPartners:   totalPartners,
            logoPath:        fullLogoUrl.isNotEmpty ? fullLogoUrl : null,
            specializations: specializations,
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ [UNI LOAD PROFILE ERROR]: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _makeAbbreviation(String name) {
    if (name.isEmpty) return '';
    final words = name.trim().split(' ').where((w) => w.isNotEmpty).toList();
    if (words.length == 1) {
      return words[0].substring(0, words[0].length.clamp(0, 4)).toUpperCase();
    }
    return words.map((w) => w[0].toUpperCase()).take(5).join();
  }

  // ✅ Logout Function
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('university_user_data');
      await prefs.remove('university_token');

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      }
    }
  }

  // ✅ Logo Widget — نفس منطق الـ company بالظبط
  Widget _buildLogoWidget() {
    final logoPath = _university?.logoPath;

    final decoration = BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4))
      ],
    );

    // ✅ حالة 1: URL من الـ API
    if (logoPath != null && logoPath.startsWith('http')) {
      return Container(
        width: 80, height: 80,
        decoration: decoration,
        child: ClipOval(
          child: Image.network(
            logoPath,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return const Center(
                child: CircularProgressIndicator(
                    color: Color(0xff1676C4), strokeWidth: 2),
              );
            },
            errorBuilder: (_, error, ___) {
              debugPrint('❌ [UNI LOGO] Failed to load: $logoPath | $error');
              return const Icon(Icons.school,
                  color: Color(0xff1676C4), size: 40);
            },
          ),
        ),
      );
    }

    // ✅ حالة 2: ملف محلي
    if (logoPath != null && logoPath.isNotEmpty) {
      final file = File(logoPath);
      if (file.existsSync()) {
        return Container(
          width: 80, height: 80,
          decoration: decoration,
          child: ClipOval(
            child: Image.file(file,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.school, color: Color(0xff1676C4), size: 40)),
          ),
        );
      }
    }

    // ✅ حالة 3: fallback — أيقونة
    return Container(
      width: 80, height: 80,
      decoration: decoration,
      child: const Icon(Icons.school, color: Color(0xff1676C4), size: 40),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: Color(0xff1676C4))),
      );
    }

    if (_university == null) {
      return Scaffold(
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Could not load profile',
                style: TextStyle(fontSize: 18, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('Please login again',
                style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          ]),
        ),
      );
    }

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
                  if (_university!.about.isNotEmpty) _buildAboutSection(),
                  if (_university!.totalStudents > 0 ||
                      _university!.totalPrograms > 0 ||
                      _university!.successRate > 0 ||
                      _university!.totalPartners > 0)
                    _buildStatistics(),
                  if (_university!.specializations != null &&
                      _university!.specializations!.isNotEmpty)
                    _buildSpecializations(),
                  if (_university!.socialMedia != null &&
                      _university!.socialMedia!.isNotEmpty)
                    _buildSocialMedia(),
                  const SizedBox(height: 24),
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff1676C4), Color(0xff0d5fa3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              const Text('University Profile',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              // ✅ زرار Edit
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () async {
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                        builder: (_) => UniversityEditProfileScreen(
                            university: _university!)),
                  );
                  if (updated == true && mounted) _loadProfile();
                },
              ),
              // ✅ زرار Logout
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.red),
                tooltip: 'Logout',
                onPressed: _logout,
              ),
            ]),
          ),
          const SizedBox(height: 16),
          _buildLogoWidget(),
          const SizedBox(height: 16),
          Text(
            _university!.abbreviation.isNotEmpty
                ? _university!.abbreviation
                : _university!.name,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          if (_university!.abbreviation.isNotEmpty &&
              _university!.name.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _university!.name,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.9), fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _buildContactInformation() {
    final rows = <Widget>[];

    void addRow(IconData icon, String text) {
      if (text.isEmpty) return;
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 12));
      rows.add(_buildContactRow(icon, text));
    }

    addRow(Icons.location_on, _university!.location);
    addRow(Icons.email,       _university!.email);
    addRow(Icons.phone,       _university!.phone);
    addRow(Icons.language,    _university!.website);

    if (rows.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.info_outline, color: Color(0xff1676C4), size: 24),
            const SizedBox(width: 8),
            Text('Contact Information',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800])),
          ]),
          const SizedBox(height: 16),
          ...rows,
        ]),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: const Color(0xff1676C4).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: const Color(0xff1676C4), size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(
          child: Text(text,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]))),
    ]);
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.description, color: Color(0xff1676C4), size: 24),
            const SizedBox(width: 8),
            Text('About',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800])),
          ]),
          const SizedBox(height: 12),
          Text(_university!.about,
              style: TextStyle(
                  fontSize: 14, color: Colors.grey[700], height: 1.5)),
          if (_university!.establishedYear != null) ...[
            const SizedBox(height: 16),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: const Color(0xff1676C4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.calendar_today,
                    color: Color(0xff1676C4), size: 16),
                const SizedBox(width: 8),
                Text('Established: ${_university!.establishedYear}',
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xff1676C4),
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _buildStatistics() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.analytics, color: Color(0xff1676C4), size: 24),
            const SizedBox(width: 8),
            Text('Statistics',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800])),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _buildStatCard(
                '${_university!.totalStudents}+', 'Students',
                Icons.people, Colors.blue)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(
                '${_university!.totalPrograms}+', 'Programs',
                Icons.school, Colors.green)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _buildStatCard(
                '${_university!.successRate.toInt()}%', 'Success Rate',
                Icons.trending_up, Colors.orange)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(
                '${_university!.totalPartners}+', 'Partners',
                Icons.business, Colors.purple)),
          ]),
        ]),
      ),
    );
  }

  Widget _buildStatCard(
      String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildSpecializations() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.class_, color: Color(0xff1676C4), size: 24),
            const SizedBox(width: 8),
            Text('Specializations',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800])),
          ]),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _university!.specializations!
                .map((spec) => Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xff1676C4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color:
                    const Color(0xff1676C4).withOpacity(0.3)),
              ),
              child: Text(spec,
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xff1676C4),
                      fontWeight: FontWeight.w500)),
            ))
                .toList(),
          ),
        ]),
      ),
    );
  }

  Widget _buildSocialMedia() {
    final socialIcons = {
      'facebook':  Icons.facebook,
      'twitter':   Icons.flutter_dash,
      'linkedin':  Icons.business,
      'instagram': Icons.camera_alt,
    };
    final socialColors = {
      'facebook':  const Color(0xff1877F2),
      'twitter':   const Color(0xff1DA1F2),
      'linkedin':  const Color(0xff0A66C2),
      'instagram': const Color(0xffE4405F),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.share, color: Color(0xff1676C4), size: 24),
            const SizedBox(width: 8),
            Text('Social Media',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800])),
          ]),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _university!.socialMedia!.entries
                .map((entry) => InkWell(
              onTap: () =>
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                          Text('Opening ${entry.key}...'))),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (socialColors[entry.key] ??
                      Colors.grey[600])!
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: (socialColors[entry.key] ??
                          Colors.grey[300])!
                          .withOpacity(0.3)),
                ),
                child: Icon(
                    socialIcons[entry.key] ?? Icons.link,
                    color: socialColors[entry.key] ??
                        Colors.grey[600],
                    size: 24),
              ),
            ))
                .toList(),
          ),
        ]),
      ),
    );
  }
}