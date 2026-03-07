import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../data/models/company/CompanyInfoModel.dart';
import '../../../../../widgets/profilewidgets/custom_text_field.dart';
import '../../../../../widgets/profilewidgets/section_title.dart';

class EditCompanyProfileScreen extends StatefulWidget {
  final CompanyInfoModel companyInfo;
  final File? currentLogo;

  const EditCompanyProfileScreen({
    super.key,
    required this.companyInfo,
    this.currentLogo,
  });

  @override
  State<EditCompanyProfileScreen> createState() => _EditCompanyProfileScreenState();
}

class _EditCompanyProfileScreenState extends State<EditCompanyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  File? _companyLogo;
  late TextEditingController _nameController;
  late TextEditingController _industryController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;
  late TextEditingController _foundedController;
  late TextEditingController _sizeController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _companyLogo = widget.currentLogo;
    _nameController = TextEditingController(text: widget.companyInfo.name);
    _industryController = TextEditingController(text: widget.companyInfo.industry);
    _descriptionController = TextEditingController(text: widget.companyInfo.description);
    _locationController = TextEditingController(text: widget.companyInfo.location);
    _emailController = TextEditingController(text: widget.companyInfo.email);
    _phoneController = TextEditingController(text: widget.companyInfo.phone);
    _websiteController = TextEditingController(text: widget.companyInfo.website);
    _foundedController = TextEditingController(text: widget.companyInfo.founded);
    _sizeController = TextEditingController(text: widget.companyInfo.size);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _industryController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _foundedController.dispose();
    _sizeController.dispose();
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
              leading: const Icon(Icons.photo_library, color: Color(0xff1676C4)),
              title: const Text('اختر من المعرض'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xff1676C4)),
              title: const Text('التقط صورة'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            if (_companyLogo != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('إزالة الصورة'),
                onTap: () {
                  setState(() => _companyLogo = null);
                  Navigator.pop(context);
                },
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
          maxWidth: 1024,
          maxHeight: 1024,
        );
        if (image != null) {
          setState(() => _companyLogo = File(image.path));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم اختيار الصورة بنجاح'),
                backgroundColor: Color(0xff1676C4),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حصل خطأ: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      final updatedInfo = CompanyInfoModel(
        name: _nameController.text,
        industry: _industryController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        website: _websiteController.text,
        founded: _foundedController.text,
        size: _sizeController.text,
      );
      Navigator.pop(context, {'info': updatedInfo, 'logo': _companyLogo});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ التغييرات بنجاح'), backgroundColor: Colors.green),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F9FF),
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff1676C4), Color(0xff0d5fa3)], // ✅
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Edit Company Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Form ────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo Section
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: _companyLogo == null
                                      ? const LinearGradient(
                                    colors: [Color(0xff1676C4), Color(0xff0d5fa3)], // ✅
                                  )
                                      : null,
                                  border: Border.all(color: const Color(0xff1676C4), width: 3),
                                  image: _companyLogo != null
                                      ? DecorationImage(
                                    image: FileImage(_companyLogo!),
                                    fit: BoxFit.cover,
                                  )
                                      : null,
                                ),
                                child: _companyLogo == null
                                    ? Center(
                                  child: Text(
                                    _nameController.text.isNotEmpty
                                        ? _nameController.text.substring(0, 2).toUpperCase()
                                        : 'TC',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
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
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xff1676C4), Color(0xff0d5fa3)], // ✅
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Company Logo',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    SectionTitle(title: 'Basic Information'),
                    const SizedBox(height: 16),
                    CustomTextField(controller: _nameController, label: 'Company Name', icon: Icons.business,
                        validator: (v) => v == null || v.isEmpty ? 'Please enter company name' : null),
                    const SizedBox(height: 16),
                    CustomTextField(controller: _industryController, label: 'Industry', icon: Icons.category,
                        validator: (v) => v == null || v.isEmpty ? 'Please enter industry' : null),
                    const SizedBox(height: 16),
                    CustomTextField(controller: _descriptionController, label: 'Description', icon: Icons.description, maxLines: 4,
                        validator: (v) => v == null || v.isEmpty ? 'Please enter description' : null),

                    const SizedBox(height: 24),

                    SectionTitle(title: 'Contact Information'),
                    const SizedBox(height: 16),
                    CustomTextField(controller: _locationController, label: 'Location', icon: Icons.location_on,
                        validator: (v) => v == null || v.isEmpty ? 'Please enter location' : null),
                    const SizedBox(height: 16),
                    CustomTextField(controller: _emailController, label: 'Email', icon: Icons.email, keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please enter email';
                          if (!v.contains('@')) return 'Please enter valid email';
                          return null;
                        }),
                    const SizedBox(height: 16),
                    CustomTextField(controller: _phoneController, label: 'Phone', icon: Icons.phone, keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.isEmpty ? 'Please enter phone' : null),
                    const SizedBox(height: 16),
                    CustomTextField(controller: _websiteController, label: 'Website', icon: Icons.language, keyboardType: TextInputType.url),

                    const SizedBox(height: 24),

                    SectionTitle(title: 'Company Details'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(controller: _foundedController, label: 'Founded', icon: Icons.calendar_today,
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(controller: _sizeController, label: 'Company Size', icon: Icons.people,
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xff1676C4), Color(0xff0d5fa3)], // ✅
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff1676C4).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          height: 24, width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                            : const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Cancel Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xff1676C4)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1676C4)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}