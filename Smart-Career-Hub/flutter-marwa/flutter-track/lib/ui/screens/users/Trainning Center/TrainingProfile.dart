import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../data/services/api_service.dart';

class TrainingProfile extends StatefulWidget {
  const TrainingProfile({super.key});
  @override
  State<TrainingProfile> createState() => _TrainingProfileState();
}

class _TrainingProfileState extends State<TrainingProfile> {
  static const Color kPrimary = Color(0xff1676C4);
  static const Color kBg = Color(0xffF0F9FF);
  bool _editing = false, _loading = true, _saving = false;

  Map<String, dynamic> _profile = {};

  final _nameCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _specsCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _accredCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final local = prefs.getString('training_center_user_data');
      if (local != null) {
        final d = json.decode(local) as Map<String, dynamic>;
        _profile = d;
      }
      final res = await ApiService.get(
        '/trainingcenter/profile',
        userType: 'training_center',
      );
      final data = (res is Map
          ? res as Map<String, dynamic>
          : res?['data'] ?? {});
      if (data.isNotEmpty) _profile = {..._profile, ...data};
      _fillControllers();
    } catch (_) {
      _fillControllers();
    } finally {
      setState(() => _loading = false);
    }
  }

  void _fillControllers() {
    _nameCtrl.text =
        _profile['name'] ??
        _profile['centerName'] ??
        _profile['trainingCenterName'] ??
        '';
    _tagCtrl.text = _profile['tagline'] ?? _profile['description'] ?? '';
    _emailCtrl.text = _profile['email'] ?? '';
    _phoneCtrl.text = _profile['phone'] ?? _profile['phoneNumber'] ?? '';
    _websiteCtrl.text = _profile['website'] ?? _profile['websiteUrl'] ?? '';
    _cityCtrl.text = _profile['city'] ?? '';
    _addressCtrl.text = _profile['address'] ?? _profile['fullAddress'] ?? '';
    _aboutCtrl.text = _profile['about'] ?? _profile['bio'] ?? '';
    _typeCtrl.text = _profile['type'] ?? _profile['trainingCenterType'] ?? '';
    _specsCtrl.text =
        _profile['specializations'] ?? _profile['primarySpecializations'] ?? '';
    _yearCtrl.text =
        (_profile['establishedYear'] ?? _profile['foundedYear'] ?? '')
            .toString();
    _capacityCtrl.text =
        (_profile['totalCapacity'] ?? _profile['capacity'] ?? '').toString();
    _accredCtrl.text =
        _profile['accreditations'] ?? _profile['certifications'] ?? '';
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ApiService.put(
        '/trainingcenter/profile',
        data: {
          'centerName': _nameCtrl.text,
          'tagline': _tagCtrl.text,
          'email': _emailCtrl.text,
          'phone': _phoneCtrl.text,
          'website': _websiteCtrl.text,
          'city': _cityCtrl.text,
          'address': _addressCtrl.text,
          'about': _aboutCtrl.text,
          'type': _typeCtrl.text,
          'specializations': _specsCtrl.text,
          'establishedYear': int.tryParse(_yearCtrl.text),
          'totalCapacity': int.tryParse(_capacityCtrl.text),
          'accreditations': _accredCtrl.text,
        },
        userType: 'training_center',
      );
      setState(() => _editing = false);
      _snack('✅ Profile updated!');
    } catch (e) {
      _snack('❌ ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      setState(() => _saving = false);
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(m),
      backgroundColor: kPrimary,
      behavior: SnackBarBehavior.floating,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          _editing ? 'Edit Training Center Profile' : 'Training Center Profile',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _editing ? Icons.close : Icons.edit_outlined,
              color: Colors.white,
            ),
            onPressed: () => setState(() {
              _editing = !_editing;
              if (!_editing) _fillControllers();
            }),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Avatar
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundColor: kPrimary.withOpacity(0.1),
                          backgroundImage:
                              (_profile['logoUrl'] ??
                                      _profile['profileImageUrl'] ??
                                      '')
                                  .isNotEmpty
                              ? NetworkImage(
                                  _profile['logoUrl'] ??
                                      _profile['profileImageUrl'],
                                )
                              : null,
                          child:
                              (_profile['logoUrl'] ??
                                      _profile['profileImageUrl'] ??
                                      '')
                                  .isEmpty
                              ? const Icon(
                                  Icons.business_rounded,
                                  size: 52,
                                  color: kPrimary,
                                )
                              : null,
                        ),
                        if (_editing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: kPrimary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (!_editing) ...[
                    Text(
                      _nameCtrl.text.isEmpty
                          ? 'Training Center'
                          : _nameCtrl.text,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_tagCtrl.text.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _tagCtrl.text,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 20),
                    _viewCard([
                      _viewRow(Icons.email_outlined, _emailCtrl.text),
                      _viewRow(Icons.phone_outlined, _phoneCtrl.text),
                      _viewRow(Icons.language_outlined, _websiteCtrl.text),
                      _viewRow(Icons.location_on_outlined, _cityCtrl.text),
                      _viewRow(Icons.home_outlined, _addressCtrl.text),
                    ]),
                    const SizedBox(height: 14),
                    if (_aboutCtrl.text.isNotEmpty)
                      _viewCard([
                        _viewRow(Icons.info_outline, _aboutCtrl.text),
                      ]),
                    const SizedBox(height: 14),
                    _viewCard([
                      _viewRow(Icons.business_center_outlined, _typeCtrl.text),
                      _viewRow(Icons.verified_outlined, _accredCtrl.text),
                      _viewRow(Icons.category_outlined, _specsCtrl.text),
                      _viewRow(
                        Icons.calendar_today_outlined,
                        _yearCtrl.text.isNotEmpty
                            ? 'Established ${_yearCtrl.text}'
                            : '',
                      ),
                      _viewRow(
                        Icons.group_outlined,
                        _capacityCtrl.text.isNotEmpty
                            ? 'Capacity: ${_capacityCtrl.text} trainees'
                            : '',
                      ),
                    ]),
                  ] else ...[
                    const SizedBox(height: 12),
                    _field('Training Center Name', _nameCtrl),
                    _field('Tagline', _tagCtrl),
                    _field(
                      'Email',
                      _emailCtrl,
                      type: TextInputType.emailAddress,
                    ),
                    _field('Phone', _phoneCtrl, type: TextInputType.phone),
                    _field('Website', _websiteCtrl),
                    _field('City', _cityCtrl),
                    _field('Full Address', _addressCtrl),
                    _field('Training Center Type', _typeCtrl),
                    _field('About', _aboutCtrl, maxLines: 4),
                    _field(
                      'Accreditations & Certifications',
                      _accredCtrl,
                      maxLines: 2,
                    ),
                    _field('Primary Specializations', _specsCtrl, maxLines: 2),
                    _field(
                      'Established Year',
                      _yearCtrl,
                      type: TextInputType.number,
                    ),
                    _field(
                      'Total Capacity',
                      _capacityCtrl,
                      type: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saving ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() {
                              _editing = false;
                              _fillControllers();
                            }),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _viewCard(List<Widget> children) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
      ],
    ),
    child: Column(children: children),
  );

  Widget _viewRow(IconData icon, String text) => text.isEmpty
      ? const SizedBox()
      : Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: kPrimary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
            ],
          ),
        );

  Widget _field(
    String label,
    TextEditingController ctrl, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xffDDEEFF),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kPrimary),
            ),
          ),
        ),
      ],
    ),
  );
}
