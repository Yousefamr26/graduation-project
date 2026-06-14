import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/dio_helper.dart';

class AuthService {
  // ─── Login ───────────────────────────────────────────────────────────────────
  // ✅ FIXED: Added "accountType" to body — required by API per Postman
  // Postman: { "email", "password", "accountType": "Student"|"Graduate"|... }
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String userType,
  }) async {
    String authType = _getAuthType(userType);
    String accountType = _getAccountType(userType);

    final response = await DioHelper.post(
      url: '$authType/login',
      data: {
        'email': email,
        'password': password,
        'accountType': accountType, // ✅ was missing before
      },
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final token = data['token'];
      if (token != null) {
        await _saveToken(token as String);
      }
      return data;
    } else {
      throw Exception('Login failed: ${response.statusCode}');
    }
  }

  // ─── Register ────────────────────────────────────────────────────────────────
  // ✅ FIXED: image key differs by userType:
  //   - student / graduate  → "ProfileImage"
  //   - company / university / training_center → "OrganizationLogo"
  Future<Map<String, dynamic>> register({
    required String userType,
    required Map<String, dynamic> formData,
    String? imagePath,
  }) async {
    String authType = _getAuthType(userType);
    String imageFieldKey = _getImageFieldKey(userType);

    FormData data = FormData.fromMap(formData);

    if (imagePath != null) {
      data.files.add(MapEntry(
        imageFieldKey, // ✅ correct field name per Postman
        await MultipartFile.fromFile(imagePath, filename: imagePath.split('/').last),
      ));
    }

    final response = await DioHelper.postFormData(
      url: '$authType/register',
      data: data,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception('Registration failed: ${response.statusCode}');
    }
  }

  // ─── Verify Email ─────────────────────────────────────────────────────────────
  // ✅ FIXED: Postman sends JSON body { "email", "otp" } — not formdata
  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String otp,
    required String userType,
  }) async {
    String authType = _getAuthType(userType);

    final response = await DioHelper.post(
      url: '$authType/verify-email',
      data: {
        'email': email,
        'otp': otp,
      },
    );

    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception('Verification failed: ${response.statusCode}');
    }
  }

  // ─── Resend OTP ───────────────────────────────────────────────────────────────
  // Postman body: { "email" } — JSON
  Future<Map<String, dynamic>> resendOtp({
    required String email,
    required String userType,
  }) async {
    String authType = _getAuthType(userType);

    final response = await DioHelper.post(
      url: '$authType/resend-otp',
      data: {'email': email},
    );

    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception('Resend OTP failed: ${response.statusCode}');
    }
  }

  // ─── Helper: Auth route prefix ────────────────────────────────────────────────
  String _getAuthType(String userType) {
    switch (userType) {
      case 'student':
        return 'StudentAuth';
      case 'graduate':
        return 'GraduateAuth';
      case 'company':
        return 'CompanyAuth';
      case 'university':
        return 'UniversityAuth';
      case 'instructor':
        return 'InstructorAuth';
      case 'training_center':
        return 'TrainingCenterAuth';
      default:
        return 'StudentAuth';
    }
  }

  // ─── Helper: accountType string for login ─────────────────────────────────────
  String _getAccountType(String userType) {
    switch (userType) {
      case 'student':
        return 'Student';
      case 'graduate':
        return 'Graduate';
      case 'company':
        return 'Company';
      case 'university':
        return 'University';
      case 'instructor':
        return 'Instructor';
      case 'training_center':
        return 'TrainingCenter';
      default:
        return 'Student';
    }
  }

  // ─── Helper: correct image field name per user type ───────────────────────────
  // student/graduate → ProfileImage
  // company/university/training_center → OrganizationLogo
  String _getImageFieldKey(String userType) {
    switch (userType) {
      case 'student':
      case 'graduate':
        return 'ProfileImage';
      case 'company':
      case 'university':
      case 'training_center':
        return 'OrganizationLogo';
      default:
        return 'ProfileImage';
    }
  }

  // ─── Token Management ─────────────────────────────────────────────────────────
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}