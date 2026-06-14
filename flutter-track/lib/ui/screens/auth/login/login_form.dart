import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/repositories/Graduate auth repository.dart';
import '../../../../data/repositories/Student auth repository.dart';
import '../../../../data/repositories/Training center auth repository.dart';
import '../../../../data/repositories/University auth repository.dart';
import '../../../../data/repositories/company_auth_repository.dart';
import '../../users/company/pages/com-dashboard.dart';
import '../../users/university/pages/unidashboard.dart';
// TODO: استبدل بالـ dashboards الصح لما تعملهم
// import '../../users/graduate/pages/graduate_dashboard.dart';
// import '../../users/student/pages/student_dashboard.dart';
// import '../../users/training_center/pages/training_center_dashboard.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _rememberMe = false;
  String? _selectedAccountType;

  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading       = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

  Future<void> _login() async {
    if (_selectedAccountType == null) {
      _showSnackBar('Please select account type', Colors.red);
      return;
    }
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Please fill all fields', Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final String email    = _emailController.text.trim();
      final String password = _passwordController.text;
      final String userType = _selectedAccountType!.toLowerCase().replaceAll(' ', '_');

      switch (userType) {

      // ══════════════════════════════════════════
      // Company
      // ══════════════════════════════════════════
        case 'company':
          final repo     = CompanyAuthRepository();
          final response = await repo.login(email, password);

          if (response.statusCode == 200) {
            _showSnackBar('Company Login successful!', Colors.green);
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const comDashboard()),
              );
            }
          } else {
            final msg = response.data?['message']
                ?? response.data?['error']
                ?? response.data?['title']
                ?? 'Login failed';
            _showSnackBar(msg.toString(), Colors.red);
          }
          break;

      // ══════════════════════════════════════════
      // University
      // ══════════════════════════════════════════
        case 'university':
          final repo     = UniversityAuthRepository();
          final response = await repo.login(email, password);

          if (response.statusCode == 200) {
            try {
              final userProfile = response.data?['data']?['userProfile'];
              if (userProfile != null) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString(
                  'university_user_data',
                  jsonEncode({
                    'id':          userProfile['id']?.toString()     ?? '',
                    'name':        userProfile['name']                ?? '',
                    'email':       userProfile['email']               ?? '',
                    'phoneNumber': userProfile['phoneNumber']         ?? '',
                    'country':     userProfile['country']             ?? '',
                    'city':        userProfile['city']                ?? '',
                    'logoPath':    userProfile['organizationLogoUrl'] ?? '',
                  }),
                );
              }
            } catch (e) {
              debugPrint('⚠️ [LOGIN UNI] Failed to save userProfile: $e');
            }

            _showSnackBar('University Login successful!', Colors.green);
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const UniversityDashboard()),
              );
            }
          } else {
            final msg = response.data?['message']
                ?? response.data?['error']
                ?? response.data?['title']
                ?? 'Login failed';
            _showSnackBar(msg.toString(), Colors.red);
          }
          break;

      // ══════════════════════════════════════════
      // Graduate
      // ══════════════════════════════════════════
      //   case 'graduate':
      //     final repo     = GraduateAuthRepository();
      //     final response = await repo.login(email, password);
      //
      //     if (response.statusCode == 200) {
      //       _showSnackBar('Graduate Login successful!', Colors.green);
      //       if (mounted) {
      //         // TODO: استبدل بـ GraduateDashboard لما تعمله
      //          Navigator.pushReplacement(
      //            context,
      //            MaterialPageRoute(builder: (_) => const GraduateHomeScreen()),
      //          );
      //       }
      //     } else {
      //       final msg = response.data?['message']
      //           ?? response.data?['error']
      //           ?? response.data?['title']
      //           ?? 'Login failed';
      //       _showSnackBar(msg.toString(), Colors.red);
      //     }
      //     break;

      // ══════════════════════════════════════════
      // Student
      // ══════════════════════════════════════════
      //   case 'student':
      //     final repo     = StudentAuthRepository();
      //     final response = await repo.login(email, password);
      //
      //     if (response.statusCode == 200) {
      //       _showSnackBar('Student Login successful!', Colors.green);
      //       if (mounted) {
      //         // TODO: استبدل بـ StudentDashboard لما تعمله
      //          Navigator.pushReplacement(
      //            context,
      //            MaterialPageRoute(builder: (_) => const StudentHomeScreen()),
      //          );
      //       }
      //     } else {
      //       final msg = response.data?['message']
      //           ?? response.data?['error']
      //           ?? response.data?['title']
      //           ?? 'Login failed';
      //       _showSnackBar(msg.toString(), Colors.red);
      //     }
      //     break;

      // ══════════════════════════════════════════
      // Training Center
      // ══════════════════════════════════════════
      //   case 'training_center':
      //     final repo     = TrainingCenterAuthRepository();
      //     final response = await repo.login(email, password);
      //
      //     if (response.statusCode == 200) {
      //       _showSnackBar('Training Center Login successful!', Colors.green);
      //       if (mounted) {
      //         // TODO: استبدل بـ TrainingCenterDashboard لما تعمله
      //          Navigator.pushReplacement(
      //            context,
      //            MaterialPageRoute(builder: (_) => const TrainingHomeScreen()),
      //          );
      //       }
      //     } else {
      //       final msg = response.data?['message']
      //           ?? response.data?['error']
      //           ?? response.data?['title']
      //           ?? 'Login failed';
      //       _showSnackBar(msg.toString(), Colors.red);
      //     }
      //     break;

        default:
          _showSnackBar('Unknown account type', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          // ── Account Type ──────────────────────────
          DropdownButtonFormField<String>(
            value: _selectedAccountType,
            hint: const Text(
              'Select Account Type',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.manage_accounts_outlined, color: Color(0xff1676C4)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xff1676C4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xff1676C4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xff1676C4)),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(16),
            items: [
              _buildDropdownItem('Student',         Icons.school_outlined),
              _buildDropdownItem('Graduate',        Icons.workspace_premium_outlined),
              _buildDropdownItem('Company',         Icons.business_outlined),
              _buildDropdownItem('University',      Icons.account_balance_outlined),
              _buildDropdownItem('Training Center', Icons.model_training_outlined),
            ],
            onChanged: (value) => setState(() => _selectedAccountType = value),
          ),

          const SizedBox(height: 16),

          // ── Email ─────────────────────────────────
          TextField(
            controller:   _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText:   'Email',
              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xff1676C4)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xff1676C4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xff1676C4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Password ──────────────────────────────
          TextField(
            controller:  _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText:   'Password',
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xff1676C4)),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xff1676C4),
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xff1676C4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xff1676C4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Remember Me & Forgot Password ─────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value:    _rememberMe,
                    onChanged: (value) => setState(() => _rememberMe = value!),
                    activeColor: const Color(0xff1676C4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Remember Me', style: TextStyle(fontSize: 13, color: Colors.black87)),
              ]),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(fontSize: 13, color: Color(0xff1676C4), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // ── Login Button ──────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1676C4),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : const Text(
                'Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

DropdownMenuItem<String> _buildDropdownItem(String title, IconData icon) {
  return DropdownMenuItem<String>(
    value: title,
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xff1676C4).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xff1676C4), size: 18),
      ),
      const SizedBox(width: 12),
      Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
      ),
    ]),
  );
}