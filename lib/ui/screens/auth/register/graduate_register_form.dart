import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../../../data/repositories/Graduate auth repository.dart';
import '../../../screens/auth/otp/OTPVerificationScreen.dart';

class GraduateRegisterForm extends StatefulWidget {
  const GraduateRegisterForm({super.key});

  @override
  State<GraduateRegisterForm> createState() => _GraduateRegisterFormState();
}

class _GraduateRegisterFormState extends State<GraduateRegisterForm> {
  final _formKey = GlobalKey<FormState>();

  // Basic Info
  final _emailController            = TextEditingController();
  final _passwordController         = TextEditingController();
  final _firstNameController        = TextEditingController();
  final _lastNameController         = TextEditingController();

  // Location
  final _countryController          = TextEditingController();
  final _cityController             = TextEditingController();

  // Education
  final _majorController            = TextEditingController();
  final _universityController       = TextEditingController();
  final _graduationYearController   = TextEditingController();
  String? _selectedDegree;

  // Experience
  final _yearsOfExperienceController = TextEditingController();
  final _experienceSummaryController  = TextEditingController();

  // Optional
  final _githubController    = TextEditingController();
  final _linkedInController  = TextEditingController();
  final _portfolioController = TextEditingController();

  // Image
  File? _profileImage;
  bool _obscurePassword = true;
  bool _isLoading       = false;

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _profileImage = File(pickedFile.path));
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final repo = GraduateAuthRepository();
      final response = await repo.register(
        email:              _emailController.text.trim(),
        password:           _passwordController.text,
        firstName:          _firstNameController.text.trim(),
        lastName:           _lastNameController.text.trim(),
        university:         _universityController.text.trim(),
        degree:             _selectedDegree!,
        major:              _majorController.text.trim(),
        graduationYear:     int.parse(_graduationYearController.text.trim()),
        yearsOfExperience:  int.parse(_yearsOfExperienceController.text.trim()),
        experienceSummary:  _experienceSummaryController.text.trim(),
        city:               _cityController.text.trim(),
        country:            _countryController.text.trim(),
        linkedIn:           _linkedInController.text.trim(),
        gitHub:             _githubController.text.trim(),
        portfolio:          _portfolioController.text.trim(),
        profileImage:       _profileImage,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('Registration successful! Please verify your email.', Colors.green);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OTPVerificationScreen(
                email:    _emailController.text.trim(),
                userType: 'graduate',
              ),
            ),
          );
        }
      } else {
        final msg = response.data?['message']
            ?? response.data?['error']
            ?? response.data?['title']
            ?? 'Registration failed';
        _showSnackBar(msg.toString(), Colors.red);
      }
    } catch (e) {
      _showSnackBar('Registration failed: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _majorController.dispose();
    _universityController.dispose();
    _graduationYearController.dispose();
    _yearsOfExperienceController.dispose();
    _experienceSummaryController.dispose();
    _githubController.dispose();
    _linkedInController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Basic Information'),
            const SizedBox(height: 16),
            _buildTextField(
              controller:  _emailController,
              label:       'Email *',
              hint:        'your.email@example.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon:  Icons.email_outlined,
              validator:   (v) => v?.isEmpty ?? true ? 'Email is required' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _firstNameController,
              label:      'First Name *',
              hint:       'Enter your first name',
              prefixIcon: Icons.person_outline,
              validator:  (v) => v?.isEmpty ?? true ? 'First name is required' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _lastNameController,
              label:      'Last Name *',
              hint:       'Enter your last name',
              prefixIcon: Icons.person_outline,
              validator:  (v) => v?.isEmpty ?? true ? 'Last name is required' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller:   _passwordController,
              label:        'Password *',
              hint:         'At least 8 characters',
              obscureText:  _obscurePassword,
              prefixIcon:   Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) => (v?.length ?? 0) < 8
                  ? 'Password must be at least 8 characters'
                  : null,
            ),
            const SizedBox(height: 24),
            _sectionTitle('Location'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _countryController,
              label:      'Country *',
              hint:       'Enter your country',
              prefixIcon: Icons.public,
              validator:  (v) => v?.isEmpty ?? true ? 'Country is required' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _cityController,
              label:      'City *',
              hint:       'Enter your city',
              prefixIcon: Icons.location_city_outlined,
              validator:  (v) => v?.isEmpty ?? true ? 'City is required' : null,
            ),
            const SizedBox(height: 24),
            _sectionTitle('Education'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _majorController,
              label:      'Major *',
              hint:       'e.g., Computer Science',
              prefixIcon: Icons.school_outlined,
              validator:  (v) => v?.isEmpty ?? true ? 'Major is required' : null,
            ),
            const SizedBox(height: 12),
            _buildDropdown(
              label:     'Degree *',
              value:     _selectedDegree,
              items:     const ['Bachelor', 'Master', 'PhD'],
              onChanged: (v) => setState(() => _selectedDegree = v),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _universityController,
              label:      'University *',
              hint:       'Enter your university name',
              prefixIcon: Icons.account_balance_outlined,
              validator:  (v) => v?.isEmpty ?? true ? 'University is required' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller:  _graduationYearController,
              label:       'Graduation Year *',
              hint:        'YYYY',
              keyboardType: TextInputType.number,
              prefixIcon:  Icons.date_range_outlined,
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Graduation year is required';
                if (int.tryParse(v!) == null) return 'Enter a valid year';
                return null;
              },
            ),
            const SizedBox(height: 24),
            _sectionTitle('Experience'),
            const SizedBox(height: 16),
            _buildTextField(
              controller:  _yearsOfExperienceController,
              label:       'Years of Experience *',
              hint:        'e.g., 3',
              keyboardType: TextInputType.number,
              prefixIcon:  Icons.work_outline,
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Years of experience is required';
                if (int.tryParse(v!) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _experienceSummaryController,
              label:      'Experience Summary *',
              hint:       'Describe your professional experience',
              maxLines:   4,
              prefixIcon: Icons.description_outlined,
              validator:  (v) => v?.isEmpty ?? true ? 'Experience summary is required' : null,
            ),
            const SizedBox(height: 24),
            _sectionTitle('Optional Information'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _githubController,
              label:      'GitHub Profile',
              hint:       'https://github.com/username',
              prefixIcon: Icons.link,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _linkedInController,
              label:      'LinkedIn Profile',
              hint:       'https://linkedin.com/in/username',
              prefixIcon: Icons.link,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _portfolioController,
              label:      'Portfolio',
              hint:       'https://yourportfolio.com',
              prefixIcon: Icons.web_outlined,
            ),
            const SizedBox(height: 16),
            _buildImageUpload(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1676C4),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Text(
                  'REGISTER',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff1676C4)),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller:   controller,
          keyboardType: keyboardType,
          obscureText:  obscureText,
          maxLines:     maxLines,
          validator:    validator,
          decoration:   _inputDecoration(hint, prefixIcon, suffixIcon),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
          decoration: _inputDecoration(null, Icons.school_outlined, null),
          validator: (v) => v == null ? 'Please select a degree' : null,
        ),
      ],
    );
  }

  Widget _buildImageUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Profile Image',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xff1676C4), width: 2),
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xff1676C4).withOpacity(0.05),
            ),
            child: _profileImage != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(_profileImage!, fit: BoxFit.cover),
            )
                : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined, color: Color(0xff1676C4), size: 40),
                SizedBox(height: 8),
                Text('Tap to upload image',
                    style: TextStyle(color: Color(0xff1676C4), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String? hint, dynamic prefixIcon, Widget? suffixIcon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon is IconData ? Icon(prefixIcon, color: const Color(0xff1676C4)) : null,
      suffixIcon: suffixIcon,
      border:      OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xff1676C4), width: 2)),
      errorBorder:   OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}