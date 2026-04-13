import 'package:flutter/material.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../users/company/pages/com-dashboard.dart';


class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _rememberMe = false;
  String? _selectedAccountType;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, duration: const Duration(seconds: 3)),
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
      final authRepo = AuthRepository();
      final response = await authRepo.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        userType: _selectedAccountType!.toLowerCase().replaceAll(' ', '_'),
      );

      if (authRepo.isSuccessResponse(response)) {
        _showSnackBar('Login successful!', Colors.green);
        // Navigate to appropriate dashboard
        String userType = _selectedAccountType!.toLowerCase().replaceAll(' ', '_');
        if (userType == 'company') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const comDashboard()),
          );
        } else {
          // For other types, navigate to a placeholder or home
          // TODO: Add other dashboards
        }
      } else {
        final errorMessage = authRepo.getErrorMessage(response);
        _showSnackBar(errorMessage, Colors.red);
      }
    } catch (e) {
      _showSnackBar('Login failed: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          // Account Type
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
              _buildDropdownItem('Student', Icons.school_outlined),
              _buildDropdownItem('Graduate', Icons.workspace_premium_outlined),
              _buildDropdownItem('Company', Icons.business_outlined),
              _buildDropdownItem('University', Icons.account_balance_outlined),
              _buildDropdownItem('Training Center', Icons.model_training_outlined),
            ],
            onChanged: (value) {
              setState(() => _selectedAccountType = value);
            },
          ),

          const SizedBox(height: 16),

          // Email
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xff1676C4)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xff1676C4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xff1676C4)),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Password
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Password',
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
            ),
          ),

          const SizedBox(height: 10),

          // Remember Me & Forget Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Remember Me - أقصى الشمال
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() => _rememberMe = value!);
                      },
                      activeColor: const Color(0xff1676C4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Remember Me',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              // Forgot Password - أقصى اليمين
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xff1676C4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Login Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1676C4),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
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

          const SizedBox(height: 20),

          // Or Login With
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: Colors.grey.shade300,
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or login with',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: Colors.grey.shade300,
                  thickness: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Google & LinkedIn Buttons
          Row(
            children: [
              // Google
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://www.google.com/favicon.ico',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Google',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // LinkedIn
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/c/ca/LinkedIn_logo_initials.png',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'LinkedIn',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff0077B5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
DropdownMenuItem<String> _buildDropdownItem(String title, IconData icon) {
  return DropdownMenuItem<String>(
    value: title,
    child: Row(
      children: [
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    ),
  );
}