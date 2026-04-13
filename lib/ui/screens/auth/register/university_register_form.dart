import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../screens/auth/otp/OTPVerificationScreen.dart';
import '../../../../data/repositories/auth_repository.dart';

class UniversityRegisterForm extends StatefulWidget {
  const UniversityRegisterForm({super.key});

  @override
  State<UniversityRegisterForm> createState() => _UniversityRegisterFormState();
}

class _UniversityRegisterFormState extends State<UniversityRegisterForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();

  File? _organizationLogo;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
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

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match', Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authRepo = AuthRepository();
      final response = await authRepo.registerUniversity(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        phoneNumber: _phoneController.text.trim(),
        country: _countryController.text.trim(),
        city: _cityController.text.trim(),
        organizationLogo: _organizationLogo,
      );

      if (authRepo.isSuccessResponse(response)) {
        _showSnackBar(
            'Registration successful! Please verify your email.', Colors.green);
        // ✅ FIXED: mounted check before navigation
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OTPVerificationScreen(
                email: _emailController.text.trim(),
                userType: 'university',
              ),
            ),
          );
        }
      } else {
        _showSnackBar(authRepo.getErrorMessage(response), Colors.red);
      }
    } catch (e) {
      _showSnackBar('Registration failed: $e', Colors.red);
    } finally {
      // ✅ FIXED: mounted check before setState in finally
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
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
            _sectionTitle('University Information'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'University Name *',
              hint: 'Enter your university name',
              prefixIcon: Icons.account_balance_outlined,
              validator: (v) =>
              v?.isEmpty ?? true ? 'University name is required' : null,
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
            _buildTextField(
              controller: _passwordController,
              label: 'Password *',
              hint: 'At least 8 characters',
              obscureText: _obscurePassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) => (v?.length ?? 0) < 8
                  ? 'Password must be at least 8 characters'
                  : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password *',
              hint: 'Re-enter your password',
              obscureText: _obscureConfirmPassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () => setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
              validator: (v) => (v?.length ?? 0) < 8
                  ? 'Password must be at least 8 characters'
                  : null,
            ),
            const SizedBox(height: 24),
            _sectionTitle('Contact Information'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number *',
              hint: '+1 (555) 000-0000',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: (v) =>
              v?.isEmpty ?? true ? 'Phone number is required' : null,
            ),
            const SizedBox(height: 12),
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
            _sectionTitle('University Logo'),
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

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xff1676C4)),
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
          decoration: _inputDecoration(hint, prefixIcon, suffixIcon),
        ),
      ],
    );
  }

  Widget _buildImageUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Logo *',
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
                : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined,
                    color: Color(0xff1676C4), size: 40),
                SizedBox(height: 8),
                Text('Tap to upload logo',
                    style: TextStyle(
                        color: Color(0xff1676C4),
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
      String? hint, IconData? prefixIcon, Widget? suffixIcon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: const Color(0xff1676C4))
          : null,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xff1676C4), width: 2)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2)),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}