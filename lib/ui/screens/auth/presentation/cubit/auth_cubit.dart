// ══════════════════════════════════════════════════════════════════════════════
// auth_cubit.dart
// ══════════════════════════════════════════════════════════════════════════════

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../data/services/AuthService.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService authService;

  AuthCubit(this.authService) : super(AuthInitial());

  // ─── Login ────────────────────────────────────────────────────────────────────
  Future<void> login(String email, String password, String userType) async {
    emit(AuthLoading());
    try {
      final result = await authService.login(
        email: email,
        password: password,
        userType: userType,
      );

      // ✅ FIXED: token can be null (e.g. unverified account returns 200 + message)
      final token = result['token'] as String?;
      emit(AuthSuccess(token: token, data: result));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ─── Register ─────────────────────────────────────────────────────────────────
  Future<void> register({
    required String userType,
    required Map<String, dynamic> formData,
    String? imagePath,
  }) async {
    emit(AuthLoading());
    try {
      final result = await authService.register(
        userType: userType,
        formData: formData,
        imagePath: imagePath,
      );
      emit(AuthSuccess(data: result));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ─── Verify Email ─────────────────────────────────────────────────────────────
  Future<void> verifyEmail({
    required String email,
    required String otp,
    required String userType,
  }) async {
    emit(AuthLoading());
    try {
      final result = await authService.verifyEmail(
        email: email,
        otp: otp,
        userType: userType,
      );
      emit(AuthSuccess(data: result));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ─── Resend OTP ───────────────────────────────────────────────────────────────
  Future<void> resendOtp({
    required String email,
    required String userType,
  })
  async {
    emit(AuthLoading());
    try {
      final result = await authService.resendOtp(
        email: email,
        userType: userType,
      );
      emit(AuthSuccess(data: result));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

}