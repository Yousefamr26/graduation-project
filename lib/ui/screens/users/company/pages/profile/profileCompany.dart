import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../data/models/company/CompanyInfoModel.dart';
import 'EditCompanyProfileScreen.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  CompanyInfoModel? _companyInfo;
  bool _isLoading = true;
  File? _companyLogo;
  String _logoUrl = '';
  final ImagePicker _picker = ImagePicker();

  List<Map<String, String>> stats = [
    {'label': 'Active Jobs',      'value': '8'},
    {'label': 'Total Hires',      'value': '124'},
    {'label': 'Roadmaps Created', 'value': '12'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      Map<String, dynamic> savedData = {};
      final savedRaw = prefs.getString('company_user_data') ?? prefs.getString('user_data');
      if (savedRaw != null) {
        try {
          savedData = jsonDecode(savedRaw) as Map<String, dynamic>;
          debugPrint('📦 [COMPANY PROFILE] savedData: $savedData');
        } catch (e) {
          debugPrint('⚠️ [COMPANY PROFILE] parse error: $e');
        }
      }

      Map<String, dynamic> tokenData = {};
      final token = prefs.getString('company_token');
      if (token != null && token.isNotEmpty) {
        try {
          final parts = token.split('.');
          if (parts.length == 3) {
            final normalized = base64Url.normalize(parts[1]);
            final decoded    = utf8.decode(base64Url.decode(normalized));
            tokenData        = jsonDecode(decoded) as Map<String, dynamic>;
          }
        } catch (e) {
          debugPrint('⚠️ [COMPANY PROFILE] token decode error: $e');
        }
      }

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

      final firstName = get(['FirstName', 'firstName']);
      final lastName  = get(['LastName',  'lastName']);
      final fullName  = '$firstName $lastName'.trim();

      String name = get([
        'name', 'Name', 'organizationName', 'OrganizationName',
        'companyName', 'CompanyName',
        'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name',
      ]);
      if (name.isEmpty) name = fullName.isNotEmpty ? fullName : 'My Company';

      final email    = get(['email', 'Email',
        'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress']);
      final phone    = get(['phone', 'phoneNumber', 'PhoneNumber']);
      final city     = get(['city',  'City']);
      final country  = get(['country', 'Country']);
      final website  = get(['website', 'Website']);
      final industry = get(['industry', 'Industry', 'sector', 'Sector']);
      final desc     = get(['description', 'Description', 'about', 'About']);

      final logoRaw = get([
        'organizationLogoUrl', 'OrganizationLogoUrl',
        'logoUrl', 'LogoUrl',
        'organizationLogo', 'OrganizationLogo',
        'logo', 'Logo',
      ]);

      String fullLogoUrl = '';
      if (logoRaw.isNotEmpty) {
        fullLogoUrl = logoRaw.startsWith('http')
            ? logoRaw
            : 'http://smartcareerhub.runasp.net$logoRaw';
      }

      debugPrint('📋 [COMPANY PROFILE] name=$name | logo=$fullLogoUrl');

      if (mounted) {
        setState(() {
          _logoUrl     = fullLogoUrl;
          _companyInfo = CompanyInfoModel(
            name:        name,
            industry:    industry.isNotEmpty ? industry : 'Technology & Software',
            description: desc.isNotEmpty
                ? desc
                : 'Leading company focused on innovative solutions and talent development.',
            location:    [city, country].where((e) => e.isNotEmpty).join(', '),
            email:       email,
            phone:       phone,
            website:     website,
            founded:     get(['founded', 'Founded']),
            size:        get(['size', 'Size', 'employeeCount', 'EmployeeCount']),
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ [COMPANY PROFILE ERROR]: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _makeInitials(String name) {
    if (name.isEmpty) return 'CO';
    final words = name.trim().split(' ').where((w) => w.isNotEmpty).toList();
    if (words.length == 1) {
      return words[0].substring(0, words[0].length.clamp(0, 2)).toUpperCase();
    }
    return words.map((w) => w[0].toUpperCase()).take(2).join();
  }

  Future<void> _pickImage() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo_library, color: Color(0xff1676C4)),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Color(0xff1676C4)),
            title: const Text('Take a photo'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
        ]),
      ),
    );

    if (source != null) {
      try {
        final XFile? image =
        await _picker.pickImage(source: source, imageQuality: 85);
        if (image != null && mounted) {
          setState(() => _companyLogo = File(image.path));
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Logo updated successfully'),
            backgroundColor: Color(0xff1676C4),
          ));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  Widget _buildLogoWidget() {
    final decoration = BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4))
      ],
    );

    Widget logoChild;

    if (_companyLogo != null) {
      logoChild = ClipOval(
        child: Image.file(_companyLogo!, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initialsWidget()),
      );
    } else if (_logoUrl.isNotEmpty) {
      logoChild = ClipOval(
        child: Image.network(
          _logoUrl,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xff1676C4),
                strokeWidth: 2,
              ),
            );
          },
          errorBuilder: (_, error, ___) {
            debugPrint('❌ [LOGO] Failed to load: $_logoUrl | error: $error');
            return _initialsWidget();
          },
        ),
      );
    } else {
      logoChild = _initialsWidget();
    }

    return Stack(children: [
      Container(width: 88, height: 88, decoration: decoration, child: logoChild),
      Positioned(
        bottom: 0, right: 0,
        child: GestureDetector(
          onTap: _pickImage,
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xff1676C4), Color(0xff0d5fa3)]),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
          ),
        ),
      ),
    ]);
  }

  Widget _initialsWidget() {
    return Container(
      width: 88, height: 88,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [Color(0xff1676C4), Color(0xff0d5fa3)]),
      ),
      child: Center(
        child: Text(
          _makeInitials(_companyInfo?.name ?? ''),
          style: const TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: Color(0xff1676C4))));
    }

    if (_companyInfo == null) {
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
      backgroundColor: const Color(0xffF5F7FB),
      body: SingleChildScrollView(
        child: Column(children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildContactSection(),
          const SizedBox(height: 80),
        ]),
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
              const Spacer(),
              const Text('Company Profile',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditCompanyProfileScreen(
                        companyInfo: _companyInfo!,
                        currentLogo: _companyLogo,
                      ),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _companyInfo = result['info'];
                      if (result['logo'] != null) _companyLogo = result['logo'];
                    });
                  }
                },
              ),
            ]),
          ),
          const SizedBox(height: 8),
          _buildLogoWidget(),
          const SizedBox(height: 14),
          Text(
            _companyInfo!.name,
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          if (_companyInfo!.industry.isNotEmpty)
            Text(_companyInfo!.industry,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.85), fontSize: 14)),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _buildContactSection() {
    final rows = <Widget>[];
    void addRow(IconData icon, String text) {
      if (text.isEmpty) return;
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 12));
      rows.add(_contactRow(icon, text));
    }

    addRow(Icons.location_on,     _companyInfo!.location);
    addRow(Icons.email_outlined,  _companyInfo!.email);
    addRow(Icons.phone_outlined,  _companyInfo!.phone);
    addRow(Icons.language,        _companyInfo!.website);
    if (_companyInfo!.founded.isNotEmpty)
      addRow(Icons.calendar_today, 'Founded: ${_companyInfo!.founded}');
    if (_companyInfo!.size.isNotEmpty)
      addRow(Icons.people_outline, _companyInfo!.size);

    if (rows.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionTitle(Icons.info_outline, 'Contact Information'),
          const SizedBox(height: 16),
          ...rows,
        ]),
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xff1676C4).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xff1676C4), size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(
          child: Text(text,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]))),
    ]);
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2))
    ],
  );

  Widget _sectionTitle(IconData icon, String title) => Row(children: [
    Icon(icon, color: const Color(0xff1676C4), size: 22),
    const SizedBox(width: 8),
    Text(title,
        style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800])),
  ]);
}