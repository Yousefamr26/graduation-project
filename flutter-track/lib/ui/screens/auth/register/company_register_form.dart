// ══════════════════════════════════════════════════════════════════════════════
// company_register_form.dart
// ══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../screens/auth/otp/OTPVerificationScreen.dart';

class CompanyRegisterForm extends StatefulWidget {
  const CompanyRegisterForm({super.key});

  @override
  State<CompanyRegisterForm> createState() => _CompanyRegisterFormState();
}

class _CompanyRegisterFormState extends State<CompanyRegisterForm> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _organizationNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();

  File? _organizationLogo;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile =
      await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _organizationLogo = File(pickedFile.path));
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
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
      final authRepo = AuthRepository();

      final response = await authRepo.registerCompany(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        organizationName: _organizationNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        country: _countryController.text.trim(),
        city: _cityController.text.trim(),
        organizationLogo: _organizationLogo,
      );

      if (authRepo.isSuccessResponse(response)) {
        _showSnackBar(
            'Registration successful! Please verify your email.', Colors.green);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OTPVerificationScreen(
                email: _emailController.text.trim(),
                userType: 'company',
              ),
            ),
          );
        }
      } else {
        final errorMessage = authRepo.getErrorMessage(response);
        _showSnackBar(errorMessage, Colors.red);
      }
    } catch (e) {
      _showSnackBar('Registration failed: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _organizationNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _countryController.dispose();
    _cityController.dispose();
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
            // ── Personal Info ──────────────────────────────────────────────
            const Text(
              'Personal Information',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1676C4)),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _firstNameController,
              label: 'First Name *',
              hint: 'Enter your first name',
              prefixIcon: Icons.person_outline,
              validator: (v) =>
              v?.isEmpty ?? true ? 'First name is required' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _lastNameController,
              label: 'Last Name *',
              hint: 'Enter your last name',
              prefixIcon: Icons.person_outline,
              validator: (v) =>
              v?.isEmpty ?? true ? 'Last name is required' : null,
            ),
            const SizedBox(height: 24),

            // ── Company Info ───────────────────────────────────────────────
            const Text(
              'Company Information',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1676C4)),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _organizationNameController,
              label: 'Organization Name *',
              hint: 'Enter your company name',
              prefixIcon: Icons.business_outlined,
              validator: (v) =>
              v?.isEmpty ?? true ? 'Organization name is required' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _emailController,
              label: 'Email *',
              hint: 'your.email@example.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (v) =>
              v?.isEmpty ?? true ? 'Email is required' : null,
            ),
            const SizedBox(height: 12),

            // ── Password Field (مع الـ validator الجديد) ───────────────────
            _buildTextField(
              controller: _passwordController,
              label: 'Password *',
              hint: 'At least 8 characters',
              obscureText: _obscurePassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 8) return 'Password must be at least 8 characters';
                if (!RegExp(r'[A-Z]').hasMatch(v))
                  return 'Must contain at least one uppercase letter';
                if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(v))
                  return 'Must contain at least one special character';
                if (!RegExp(r'[0-9]').hasMatch(v))
                  return 'Must contain at least one number';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // ── Location ───────────────────────────────────────────────────
            const Text(
              'Location',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1676C4)),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _countryController,
              label: 'Country *',
              hint: 'Enter your country',
              prefixIcon: Icons.public,
              validator: (v) =>
              v?.isEmpty ?? true ? 'Country is required' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _cityController,
              label: 'City *',
              hint: 'Enter your city',
              prefixIcon: Icons.location_city_outlined,
              validator: (v) =>
              v?.isEmpty ?? true ? 'City is required' : null,
            ),
            const SizedBox(height: 24),

            // ── Logo ───────────────────────────────────────────────────────
            const Text(
              'Company Logo',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1676C4)),
            ),
            const SizedBox(height: 16),
            _buildImageUpload(),
            const SizedBox(height: 32),

            // ── Submit ─────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1676C4),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
                    : const Text(
                  'REGISTER',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

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
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: const Color(0xff1676C4))
                : null,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: Color(0xff1676C4), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Logo',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                  color: const Color(0xff1676C4),
                  width: 2,
                  style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xff1676C4).withOpacity(0.05),
            ),
            child: _organizationLogo != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(_organizationLogo!, fit: BoxFit.cover),
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.image_outlined,
                    color: Color(0xff1676C4), size: 40),
                SizedBox(height: 8),
                Text(
                  'Tap to upload logo',
                  style: TextStyle(
                      color: Color(0xff1676C4),
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}