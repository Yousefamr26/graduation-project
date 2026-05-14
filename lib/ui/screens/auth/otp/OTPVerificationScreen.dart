import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import '../../../../data/repositories/auth_repository.dart';
import '../login/login_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final String userType;

  const OTPVerificationScreen({
    super.key,
    required this.email,
    required this.userType,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _canResend = false;
  int _remainingSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  // ─── Timer ────────────────────────────────────────────────────────────────
  void _startTimer() {
    setState(() {
      _canResend = false;
      _remainingSeconds = 60;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  String get _otp => _otpControllers.map((c) => c.text).join();

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

  void _clearFields() {
    for (final c in _otpControllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
  }

  // ─── Verify OTP ──────────────────────────────────────────────────────────
  Future<void> _verifyOTP() async {
    final otp = _otp;

    if (otp.length != 6) {
      _showSnackBar('Please enter all 6 digits', Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authRepo = AuthRepository();
      final response = await authRepo.verifyEmail(
        email: widget.email,
        otp: otp,
        userType: widget.userType,
      );

      if (authRepo.isSuccessResponse(response)) {
        _showSnackBar('Email verified successfully!', Colors.green);
        if (mounted) {
          // ✅ FIXED: go to login screen specifically, not just popUntil(isFirst)
          // because the first route might be RegisterScreen, not LoginScreen.
          // Using pushNamedAndRemoveUntil assumes you have a named route '/login'.
          // If you use a different routing approach, replace accordingly.
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
          );
        }
      } else {
        _showSnackBar(authRepo.getErrorMessage(response), Colors.red);
      }
    } catch (e) {
      _showSnackBar('Verification failed: $e', Colors.red);
    } finally {
      // ✅ FIXED: mounted check before setState
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Resend OTP ───────────────────────────────────────────────────────────
  // ✅ FIXED: was using a fake Future.delayed — now calls real API
  Future<void> _resendOTP() async {
    setState(() => _isLoading = true);
    try {
      final authRepo = AuthRepository();
      final response = await authRepo.resendOtp(
        email: widget.email,
        userType: widget.userType,
      );

      if (authRepo.isSuccessResponse(response)) {
        _showSnackBar('OTP sent successfully!', Colors.green);
        if (mounted) {
          _clearFields();
          _startTimer();
        }
      } else {
        _showSnackBar(authRepo.getErrorMessage(response), Colors.red);
      }
    } catch (e) {
      _showSnackBar('Failed to resend OTP: $e', Colors.red);
    } finally {
      // ✅ FIXED: mounted check before setState
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xff1676C4)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 40),

              // Email icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xff1676C4).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mail_lock,
                  size: 60,
                  color: Color(0xff1676C4),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1676C4),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a verification code to',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xff1676C4),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // OTP card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xff1676C4),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff1676C4).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Enter Verification Code',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // OTP fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, _buildOTPField),
                    ),
                    const SizedBox(height: 24),

                    // Verify button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xff1676C4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xff1676C4)),
                          ),
                        )
                            : const Text(
                          'Verify',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Resend / timer
                    _canResend
                        ? TextButton(
                      onPressed: _isLoading ? null : _resendOTP,
                      child: const Text(
                        'Resend Code',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                        : Text(
                      'Resend code in $_remainingSeconds seconds',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Info box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Color(0xff1676C4), size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Check your spam folder if you don\'t see the email',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xff1676C4)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── OTP single field ──────────────────────────────────────────────────────
  Widget _buildOTPField(int index) {
    return Container(
      width: 35,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xff1676C4),
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
              // ✅ Auto-submit when last digit is entered
              _verifyOTP();
            }
          } else {
            // Backspace → go to previous field
            if (index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          }
        },
      ),
    );
  }
}