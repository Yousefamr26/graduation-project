import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:dio/io.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class AuthRepository {
  static const String _baseUrl = 'http://smartcareerhub.runasp.net/api/';
  String _toAccountType(String userType) {
    switch (userType.toLowerCase()) {
      case 'student':          return 'Student';
      case 'graduate':         return 'Graduate';
      case 'company':          return 'Company';
      case 'university':       return 'University';
      case 'training_center':  return 'TrainingCenter';
      case 'instructor':       return 'Instructor';
      default:                 return userType;
    }
  }

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      receiveDataWhenStatusError: true,
      followRedirects: true,
      maxRedirects: 5,
      headers: {'Accept': 'application/json'},
    ),
  )..httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    },
  );

  // ════════════════════════════════════════════════════════════════
  // Helper: auth prefix per user type
  // e.g. 'company' → 'CompanyAuth'
  // ════════════════════════════════════════════════════════════════
  String _prefix(String userType) {
    switch (userType.toLowerCase()) {
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

  // ════════════════════════════════════════════════════════════════
  // LOGIN  →  POST /api/{prefix}/login
  // ════════════════════════════════════════════════════════════════
  Future<Response> login({
    required String email,
    required String password,
    required String userType,
  }) async {
    final endpoint = '${_prefix(userType)}/login';
    debugPrint('📤 LOGIN → $endpoint');

    try {
      final response = await _dio.post(
        endpoint,
        data: {
          'email': email,
          'password': password,
          'accountType': _toAccountType(userType),
          'rememberMe': true,
        },
        options: Options(
          validateStatus: (_) => true,
          contentType: 'application/json',
        ),
      );

      debugPrint('📥 LOGIN STATUS: ${response.statusCode}');
      debugPrint('📥 LOGIN RAW RESPONSE: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        String? token;
        Map<String, dynamic>? user;

        if (data is Map) {
          token = data['token'] ??
              data['data']?['token'] ??
              data['accessToken'];

          user = data['user'] ?? data['data']?['user'];
        }

        debugPrint('🔑 EXTRACTED TOKEN: $token');

        if (token != null) {
          await _saveToken(token);
          debugPrint('✅ TOKEN SAVED SUCCESSFULLY');
        } else {
          debugPrint('❌ TOKEN IS NULL - CHECK BACKEND RESPONSE');
        }

        if (user != null) {
          await _saveUserData(user);
          debugPrint('✅ USER SAVED SUCCESSFULLY');
        }
      }

      return response;
    } catch (e) {
      debugPrint('❌ LOGIN ERROR: $e');
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // VERIFY EMAIL  →  POST /api/{prefix}/verify-email
  // ════════════════════════════════════════════════════════════════
  Future<Response> verifyEmail({
    required String email,
    required String otp,
    required String userType,
  }) async {
    final endpoint = '${_prefix(userType)}/verify-email';
    debugPrint('📤 VERIFY EMAIL → $endpoint');

    try {
      final response = await _dio.post(
        endpoint,
        data: {'email': email, 'otp': otp},
        options: Options(
          validateStatus: (_) => true,
          contentType: 'application/json',
        ),
      );

      debugPrint('📥 VERIFY EMAIL ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('❌ Verify Email Error: $e');
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // RESEND OTP  →  POST /api/{prefix}/resend-otp
  // ════════════════════════════════════════════════════════════════
  Future<Response> resendOtp({
    required String email,
    required String userType,
  }) async {
    final endpoint = '${_prefix(userType)}/resend-otp';
    debugPrint('📤 RESEND OTP → $endpoint');

    try {
      final response = await _dio.post(
        endpoint,
        data: {'email': email},
        options: Options(
          validateStatus: (_) => true,
          contentType: 'application/json',
        ),
      );

      debugPrint('📥 RESEND OTP ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('❌ Resend OTP Error: $e');
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // COMPANY REGISTER  →  POST /api/CompanyAuth/register
  // ════════════════════════════════════════════════════════════════
  Future<Response> registerCompany({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String organizationName,
    required String country,
    required String city,
    File? organizationLogo,
  }) async {
    const endpoint = 'CompanyAuth/register';
    debugPrint('📤 COMPANY REGISTER → $endpoint');

    try {
      final map = <String, dynamic>{
        'Email': email,
        'Password': password,
        'FirstName': firstName,
        'LastName': lastName,
        'OrganizationName': organizationName,
        'Country': country,
        'City': city,
      };

      if (organizationLogo != null) {
        final bytes = await _compressImage(organizationLogo);
        map['OrganizationLogo'] = MultipartFile.fromBytes(
          bytes,
          filename: organizationLogo.path.split('/').last,
          contentType: DioMediaType('image', 'jpeg'),
        );
      }

      final response = await _dio.post(
        endpoint,
        data: FormData.fromMap(map),
        options: Options(validateStatus: (_) => true),
      );

      debugPrint('📥 COMPANY REGISTER ${response.statusCode}');
      debugPrint('📥 Data: ${response.data}');
      return response;
    } catch (e) {
      debugPrint('❌ Company Register Error: $e');
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // GRADUATE REGISTER  →  POST /api/GraduateAuth/register
  // ════════════════════════════════════════════════════════════════
  Future<Response> registerGraduate({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String country,
    required String city,
    required String major,
    required String degree,
    required String university,
    required int graduationYear,
    required int yearsOfExperience,
    required String experienceSummary,
    String? github,
    String? linkedIn,
    File? profileImage,
  }) async {
    const endpoint = 'GraduateAuth/register';
    debugPrint('📤 GRADUATE REGISTER → $endpoint');

    try {
      final map = <String, dynamic>{
        'Email': email,
        'Password': password,
        'FirstName': firstName,
        'LastName': lastName,
        'Country': country,
        'City': city,
        'Major': major,
        'Degree': degree,
        'University': university,
        'GraduationYear': graduationYear,
        'YearsOfExperience': yearsOfExperience,
        'ExperienceSummary': experienceSummary,
        if (github?.isNotEmpty ?? false) 'GitHub': github,
        if (linkedIn?.isNotEmpty ?? false) 'LinkedIn': linkedIn,
      };

      if (profileImage != null) {
        map['ProfileImage'] = await MultipartFile.fromFile(
          profileImage.path,
          filename: profileImage.path.split('/').last,
        );
      }

      final response = await _dio.post(
        endpoint,
        data: FormData.fromMap(map),
        options: Options(validateStatus: (_) => true),
      );

      debugPrint('📥 GRADUATE REGISTER ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('❌ Graduate Register Error: $e');
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // STUDENT REGISTER  →  POST /api/StudentAuth/register
  // ════════════════════════════════════════════════════════════════
  Future<Response> registerStudent({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String country,
    required String city,
    required String major,
    required String degree,
    required String university,
    required String faculty,
    required String expectedGraduation,
    String? github,
    String? linkedIn,
    File? profileImage,
  }) async {
    const endpoint = 'StudentAuth/register';
    debugPrint('📤 STUDENT REGISTER → $endpoint');

    try {
      final map = <String, dynamic>{
        'Email': email,
        'Password': password,
        'FirstName': firstName,
        'LastName': lastName,
        'Country': country,
        'City': city,
        'Major': major,
        'Degree': degree,
        'University': university,
        'Faculty': faculty,
        'ExpectedGraduation': expectedGraduation,
        if (github?.isNotEmpty ?? false) 'GitHub': github,
        if (linkedIn?.isNotEmpty ?? false) 'LinkedIn': linkedIn,
      };

      if (profileImage != null) {
        map['ProfileImage'] = await MultipartFile.fromFile(
          profileImage.path,
          filename: profileImage.path.split('/').last,
        );
      }

      final response = await _dio.post(
        endpoint,
        data: FormData.fromMap(map),
        options: Options(validateStatus: (_) => true),
      );

      debugPrint('📥 STUDENT REGISTER ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('❌ Student Register Error: $e');
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // TRAINING CENTER REGISTER  →  POST /api/TrainingCenterAuth/register
  // ════════════════════════════════════════════════════════════════
  Future<Response> registerTrainingCenter({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
    required String country,
    required String city,
    File? organizationLogo,
  }) async {
    const endpoint = 'TrainingCenterAuth/register';
    debugPrint('📤 TRAINING CENTER REGISTER → $endpoint');

    try {
      final map = <String, dynamic>{
        'Name': name,
        'Email': email,
        'Password': password,
        'ConfirmPassword': confirmPassword,
        'PhoneNumber': phoneNumber,
        'Country': country,
        'City': city,
      };

      if (organizationLogo != null) {
        final bytes = await _compressImage(organizationLogo);
        map['OrganizationLogo'] = MultipartFile.fromBytes(
          bytes,
          filename: organizationLogo.path.split('/').last,
          contentType: DioMediaType('image', 'jpeg'),
        );
      }

      final response = await _dio.post(
        endpoint,
        data: FormData.fromMap(map),
        options: Options(validateStatus: (_) => true),
      );

      debugPrint('📥 TRAINING CENTER REGISTER ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('❌ Training Center Register Error: $e');
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // UNIVERSITY REGISTER  →  POST /api/UniversityAuth/register
  // ════════════════════════════════════════════════════════════════
  Future<Response> registerUniversity({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
    required String country,
    required String city,
    File? organizationLogo,
  }) async {
    const endpoint = 'UniversityAuth/register';
    debugPrint('📤 UNIVERSITY REGISTER → $endpoint');

    try {
      final map = <String, dynamic>{
        'Name': name,
        'Email': email,
        'Password': password,
        'ConfirmPassword': confirmPassword,
        'PhoneNumber': phoneNumber,
        'Country': country,
        'City': city,
      };

      if (organizationLogo != null) {
        final bytes = await _compressImage(organizationLogo);
        map['OrganizationLogo'] = MultipartFile.fromBytes(
          bytes,
          filename: organizationLogo.path.split('/').last,
          contentType: DioMediaType('image', 'jpeg'),
        );
      }

      final response = await _dio.post(
        endpoint,
        data: FormData.fromMap(map),
        options: Options(validateStatus: (_) => true),
      );

      debugPrint('📥 UNIVERSITY REGISTER ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('❌ University Register Error: $e');
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // IMAGE COMPRESSION
  // ════════════════════════════════════════════════════════════════
  Future<Uint8List> _compressImage(File file) async {
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 25,
      minWidth: 500,
      minHeight: 500,
      format: CompressFormat.jpeg,
    );
    if (result == null) throw Exception('Image compression failed');
    debugPrint('🗜️ Compressed: ${result.length} bytes');
    return result;
  }

  // ════════════════════════════════════════════════════════════════
  // TOKEN & USER DATA
  // ════════════════════════════════════════════════════════════════
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
    await prefs.remove('user_data');
  }

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user_data');
    return raw != null ? jsonDecode(raw) : null;
  }

  // ════════════════════════════════════════════════════════════════
  // RESPONSE HELPERS
  // ════════════════════════════════════════════════════════════════
  bool isSuccessResponse(Response response) {
    return response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300;
  }

  String getErrorMessage(Response response) {
    if (response.data is Map) {
      return response.data['message'] ??
          response.data['error'] ??
          response.data['title'] ??
          'An error occurred';
    }
    return response.statusMessage ?? 'An error occurred';
  }
}