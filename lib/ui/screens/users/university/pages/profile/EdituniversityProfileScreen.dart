import 'package:flutter/material.dart';
import 'dart:io';

import '../../../../../../data/models/university/university-model.dart';
import '../../../../../../data/repositories/University auth repository.dart';

class UniversityEditProfileScreen extends StatefulWidget {
  final UniversityModel university;

  const UniversityEditProfileScreen({super.key, required this.university});

  @override
  State<UniversityEditProfileScreen> createState() =>
      _UniversityEditProfileScreenState();
}

class _UniversityEditProfileScreenState
    extends State<UniversityEditProfileScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _authRepo = UniversityAuthRepository();
  bool _isLoading = false;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _abbreviationController;
  late TextEditingController _locationController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;
  late TextEditingController _aboutController;
  late TextEditingController _establishedYearController;
  late TextEditingController _totalStudentsController;
  late TextEditingController _totalProgramsController;
  late TextEditingController _successRateController;
  late TextEditingController _totalPartnersController;

  // Specializations
  late List<String> _specializations;
  final TextEditingController _newSpecController = TextEditingController();

  // Social Media
  late Map<String, String> _socialMedia;
  final Map<String, TextEditingController> _socialControllers = {};

  final List<String> _socialPlatforms = ['facebook', 'twitter', 'linkedin', 'instagram'];

  final Map<String, IconData> _socialIcons = {
    'facebook':  Icons.facebook,
    'twitter':   Icons.flutter_dash,
    'linkedin':  Icons.business,
    'instagram': Icons.camera_alt,
  };

  final Map<String, Color> _socialColors = {
    'facebook':  Color(0xff1877F2),
    'twitter':   Color(0xff1DA1F2),
    'linkedin':  Color(0xff0A66C2),
    'instagram': Color(0xffE4405F),
  };

  @override
  void initState() {
    super.initState();
    final u = widget.university;

    _nameController             = TextEditingController(text: u.name);
    _abbreviationController     = TextEditingController(text: u.abbreviation);
    _locationController         = TextEditingController(text: u.location);
    _emailController            = TextEditingController(text: u.email);
    _phoneController            = TextEditingController(text: u.phone);
    _websiteController          = TextEditingController(text: u.website);
    _aboutController            = TextEditingController(text: u.about);
    _establishedYearController  = TextEditingController(text: u.establishedYear ?? '');
    _totalStudentsController    = TextEditingController(text: u.totalStudents.toString());
    _totalProgramsController    = TextEditingController(text: u.totalPrograms.toString());
    _successRateController      = TextEditingController(text: u.successRate.toString());
    _totalPartnersController    = TextEditingController(text: u.totalPartners.toString());

    _specializations = List<String>.from(u.specializations ?? []);
    _socialMedia     = Map<String, String>.from(u.socialMedia ?? {});

    for (final platform in _socialPlatforms) {
      _socialControllers[platform] =
          TextEditingController(text: _socialMedia[platform] ?? '');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _abbreviationController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _aboutController.dispose();
    _establishedYearController.dispose();
    _totalStudentsController.dispose();
    _totalProgramsController.dispose();
    _successRateController.dispose();
    _totalPartnersController.dispose();
    _newSpecController.dispose();
    for (final c in _socialControllers.values) c.dispose();
    super.dispose();
  }

  // ── Parse location into city/country ─────────────────────────
  Map<String, String> _parseLocation(String location) {
    final parts = location.split(',');
    if (parts.length >= 2) {
      return {
        'city':    parts[0].trim(),
        'country': parts.sublist(1).join(',').trim(),
      };
    }
    return {'city': location.trim(), 'country': ''};
  }

  // ── Save ──────────────────────────────────────────────────────
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // بناء الـ social media map من الـ controllers
      final updatedSocialMedia = <String, String>{};
      for (final platform in _socialPlatforms) {
        final val = _socialControllers[platform]!.text.trim();
        if (val.isNotEmpty) updatedSocialMedia[platform] = val;
      }

      // استخراج city/country من الـ location field
      final locationParts = _parseLocation(_locationController.text.trim());

      final response = await _authRepo.updateProfile(
        name:            _nameController.text.trim(),
        phoneNumber:     _phoneController.text.trim(),
        country:         locationParts['country']!,
        city:            locationParts['city']!,
        website:         _websiteController.text.trim(),
        about:           _aboutController.text.trim(),
        abbreviation:    _abbreviationController.text.trim(),
        establishedYear: _establishedYearController.text.trim(),
        totalStudents:   int.tryParse(_totalStudentsController.text) ?? 0,
        totalPrograms:   int.tryParse(_totalProgramsController.text) ?? 0,
        successRate:     double.tryParse(_successRateController.text) ?? 0.0,
        totalPartners:   int.tryParse(_totalPartnersController.text) ?? 0,
        specializations: _specializations,
        socialMedia:     updatedSocialMedia,
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Profile updated successfully!'),
          ]),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        Navigator.pop(context);
      } else {
        final msg = response.data?['message']
            ?? response.data?['error']
            ?? response.data?['title']
            ?? 'Update failed (${response.statusCode})';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(msg.toString())),
          ]),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ══════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        _buildHeader(),
        Expanded(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(children: [
                _buildLogoSection(),
                _buildBasicInfoSection(),
                _buildContactSection(),
                _buildAboutSection(),
                _buildStatisticsSection(),
                _buildSpecializationsSection(),
                _buildSocialMediaSection(),
                const SizedBox(height: 24),
                _buildSaveButton(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ),
      ]),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: _confirmDiscard,
            ),
            const Spacer(),
            const Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
            const Spacer(),
            _isLoading
                ? const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            )
                : IconButton(
              icon: const Icon(Icons.check, color: Colors.white),
              onPressed: _saveProfile,
            ),
          ]),
        ),
      ),
    );
  }

  void _confirmDiscard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 8),
          Text('Discard Changes?'),
        ]),
        content: const Text('Are you sure you want to go back? Any unsaved changes will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Keep Editing')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(children: [
        Stack(children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: const Color(0xff1676C4).withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xff1676C4).withOpacity(0.3), width: 2),
            ),
            child: widget.university.logoPath != null && widget.university.logoPath!.isNotEmpty
                ? ClipOval(
              child: widget.university.logoPath!.startsWith('http')
                  ? Image.network(widget.university.logoPath!, fit: BoxFit.cover)
                  : Image.file(File(widget.university.logoPath!), fit: BoxFit.cover),
            )
                : const Icon(Icons.school, color: Color(0xff1676C4), size: 44),
          ),
          Positioned(
            bottom: 0, right: 0,
            child: GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logo upload coming soon!'), behavior: SnackBarBehavior.floating)),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: const Color(0xff1676C4), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Text('Tap the camera icon to change logo', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ]),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      icon: Icons.business,
      title: 'Basic Information',
      children: [
        _buildTextField(controller: _nameController, label: 'University Full Name', icon: Icons.school, validator: (val) => val == null || val.isEmpty ? 'Name is required' : null),
        const SizedBox(height: 16),
        _buildTextField(controller: _abbreviationController, label: 'Abbreviation', icon: Icons.abc, validator: (val) => val == null || val.isEmpty ? 'Abbreviation is required' : null),
        const SizedBox(height: 16),
        _buildTextField(controller: _establishedYearController, label: 'Established Year', icon: Icons.calendar_today, keyboardType: TextInputType.number),
      ],
    );
  }

  Widget _buildContactSection() {
    return _buildSection(
      icon: Icons.contact_mail,
      title: 'Contact Information',
      children: [
        _buildTextField(controller: _locationController, label: 'Location (City, Country)', icon: Icons.location_on, validator: (val) => val == null || val.isEmpty ? 'Location is required' : null),
        const SizedBox(height: 16),
        _buildTextField(controller: _emailController, label: 'Email', icon: Icons.email, keyboardType: TextInputType.emailAddress,
            validator: (val) { if (val == null || val.isEmpty) return 'Email is required'; if (!val.contains('@')) return 'Enter a valid email'; return null; }),
        const SizedBox(height: 16),
        _buildTextField(controller: _phoneController, label: 'Phone', icon: Icons.phone, keyboardType: TextInputType.phone, validator: (val) => val == null || val.isEmpty ? 'Phone is required' : null),
        const SizedBox(height: 16),
        _buildTextField(controller: _websiteController, label: 'Website', icon: Icons.language, keyboardType: TextInputType.url),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      icon: Icons.description,
      title: 'About',
      children: [
        TextFormField(
          controller: _aboutController,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: 'About the University',
            alignLabelWithHint: true,
            border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xff1676C4), width: 2)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    return _buildSection(
      icon: Icons.analytics,
      title: 'Statistics',
      children: [
        Row(children: [
          Expanded(child: _buildTextField(controller: _totalStudentsController, label: 'Total Students', icon: Icons.people, keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(child: _buildTextField(controller: _totalProgramsController, label: 'Programs', icon: Icons.school, keyboardType: TextInputType.number)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _buildTextField(
            controller: _successRateController, label: 'Success Rate (%)', icon: Icons.trending_up,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (val) { if (val == null || val.isEmpty) return null; final d = double.tryParse(val); if (d == null || d < 0 || d > 100) return '0 - 100 only'; return null; },
          )),
          const SizedBox(width: 12),
          Expanded(child: _buildTextField(controller: _totalPartnersController, label: 'Partners', icon: Icons.business, keyboardType: TextInputType.number)),
        ]),
      ],
    );
  }

  Widget _buildSpecializationsSection() {
    return _buildSection(
      icon: Icons.class_,
      title: 'Specializations',
      children: [
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _specializations.map((spec) => Chip(
            label: Text(spec, style: const TextStyle(fontSize: 13, color: Color(0xff1676C4), fontWeight: FontWeight.w500)),
            backgroundColor: const Color(0xff1676C4).withOpacity(0.1),
            side: BorderSide(color: const Color(0xff1676C4).withOpacity(0.3)),
            deleteIcon: const Icon(Icons.close, size: 16, color: Color(0xff1676C4)),
            onDeleted: () => setState(() => _specializations.remove(spec)),
          )).toList(),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: _newSpecController,
              decoration: InputDecoration(
                hintText: 'Add new specialization',
                border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xff1676C4), width: 2)),
                filled: true, fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff1676C4), foregroundColor: Colors.white, padding: const EdgeInsets.all(14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              final val = _newSpecController.text.trim();
              if (val.isNotEmpty && !_specializations.contains(val)) {
                setState(() { _specializations.add(val); _newSpecController.clear(); });
              }
            },
            child: const Icon(Icons.add),
          ),
        ]),
      ],
    );
  }

  Widget _buildSocialMediaSection() {
    return _buildSection(
      icon: Icons.share,
      title: 'Social Media',
      children: _socialPlatforms.map((platform) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: _socialControllers[platform],
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            labelText: '${platform[0].toUpperCase()}${platform.substring(1)} URL',
            prefixIcon: Padding(padding: const EdgeInsets.all(12), child: Icon(_socialIcons[platform] ?? Icons.link, color: _socialColors[platform] ?? Colors.grey, size: 22)),
            border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _socialColors[platform] ?? const Color(0xff1676C4), width: 2)),
            filled: true, fillColor: Colors.grey[50],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity, height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff1676C4),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 2,
          ),
          onPressed: _isLoading ? null : _saveProfile,
          child: _isLoading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.save),
            SizedBox(width: 8),
            Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────
  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
  );

  Widget _buildSection({required IconData icon, required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: const Color(0xff1676C4), size: 24),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
        ]),
        const SizedBox(height: 16),
        ...children,
      ]),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xff1676C4), size: 20),
        border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xff1676C4), width: 2)),
        errorBorder:   OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1)),
        filled: true, fillColor: Colors.grey[50],
      ),
    );
  }
}