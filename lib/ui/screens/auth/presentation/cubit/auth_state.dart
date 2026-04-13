// ══════════════════════════════════════════════════════════════════════════════
// auth_state.dart
// ══════════════════════════════════════════════════════════════════════════════

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

// ✅ FIXED: token is nullable — API might not return it on every 200 response
class AuthSuccess extends AuthState {
  final String? token;
  final Map<String, dynamic>? data;

  AuthSuccess({this.token, this.data});
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}