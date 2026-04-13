import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:dio/io.dart';


class AuthRepository {
  static const String _baseUrl = 'http://smartcareerhub.runasp.net/api';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      receiveDataWhenStatusError: true,
      followRedirects: true,
      maxRedirects: 5,
      headers: {
        'Accept': 'application/json',
      },
    ),
  )..httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    },
  );

  // ─── Login ──────────────────────────────────────────────────────────────────
  Future<Response> login({
    required String email,
    required String password,
    required String userType,
  }) async {
    try {
      String authType = _getAuthType(userType);
      String accountType = _getAccountType(userType);

      debugPrint('📤 Logging in to: /$authType/login');
      final response = await _dio.post(
        '$authType/login',
        data: {
          'email': email,
          'password': password,
          'accountType': accountType,
        },
        options: Options(
          validateStatus: (status) => true,
          contentType: 'application/json',
        ),
      );

      debugPrint('📥 Login Response: ${response.statusCode}');
      if (response.statusCode == 200 && response.data != null) {
        final token = response.data['token'];
        if (token != null) {
          await _saveToken(token);
        }
        final user = response.data['user'];
        if (user != null) {
          await _saveUserData(user);
        }
      }
      return response;
    } catch (e) {
      debugPrint('❌ Login Error: $e');
      rethrow;
    }
  }

  // ─── Verify Email ────────────────────────────────────────────────────────────
  Future<Response> verifyEmail({
    required String email,
    required String otp,
    required String userType,
  }) async {
    try {
      String authType = _getAuthType(userType);
      debugPrint('📤 Verifying email to: /$authType/verify-email');
      final response = await _dio.post(
        '$authType/verify-email',
        data: {
          'email': email,
          'otp': otp,
        },
        options: Options(
          validateStatus: (status) => true,
          contentType: 'application/json',
        ),
      );

      debugPrint('📥 Verify Email Response: ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('❌ Verify Email Error: $e');
      rethrow;
    }
  }

  // ─── Resend OTP ───────────────────────────────────────────────────────────────
  Future<Response> resendOtp({
    required String email,
    required String userType,
  }) async {
    try {
      String authType = _getAuthType(userType);
      debugPrint('📤 Resending OTP to: /$authType/resend-otp');
      final response = await _dio.post(
        '$authType/resend-otp',
        data: {'email': email},
        options: Options(
          validateStatus: (status) => true,
          contentType: 'application/json',
        ),
      );

      debugPrint('📥 Resend OTP Response: ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('❌ Resend OTP Error: $e');
      rethrow;
    }
  }

  // ─── Graduate Registration ───────────────────────────────────────────────────
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

      FormData formData = FormData.fromMap(map);

      debugPrint('📤 Registering Graduate to: /GraduateAuth/register');
      final response = await _dio.post(
        'GraduateAuth/register',
        data: formData,
        options: Options(validateStatus: (status) => true),
      );

      debugPrint('📥 Graduate Registration Response: ${response.statusCode}');
      debugPrint('📥 Response Data: ${response.data}');
      return response;
    } catch (e) {
      debugPrint('❌ Graduate Registration Error: $e');
      rethrow;
    }
  }

  // ─── Student Registration ─────────────────────────────────────────────────────
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

      FormData formData = FormData.fromMap(map);

      debugPrint('📤 Registering Student to: /StudentAuth/register');
      final response = await _dio.post(
        'StudentAuth/register',
        data: formData,
        options: Options(validateStatus: (status) => true),
      );

      debugPrint('📥 Student Registration Response: ${response.statusCode}');
      debugPrint('📥 Response Data: ${response.data}');
      return response;
    } catch (e) {
      debugPrint('❌ Student Registration Error: $e');
      rethrow;
    }
  }

  // ─── Training Center Registration ─────────────────────────────────────────────
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
        map['OrganizationLogo'] = await MultipartFile.fromFile(
          organizationLogo.path,
          filename: organizationLogo.path.split('/').last,
        );
      }

      FormData formData = FormData.fromMap(map);

      debugPrint('📤 Registering Training Center to: /trainingcenterauth/register');
      final response = await _dio.post(
        'trainingcenterauth/register',
        data: formData,
        options: Options(validateStatus: (status) => true),
      );

      debugPrint('📥 Training Center Registration Response: ${response.statusCode}');
      debugPrint('📥 Response Data: ${response.data}');
      return response;
    } catch (e) {
      debugPrint('❌ Training Center Registration Error: $e');
      rethrow;
    }
  }

  // ─── University Registration ──────────────────────────────────────────────────
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
        map['OrganizationLogo'] = await MultipartFile.fromFile(
          organizationLogo.path,
          filename: organizationLogo.path.split('/').last,
        );
      }

      FormData formData = FormData.fromMap(map);

      debugPrint('📤 Registering University to: /UniversityAuth/register');
      final response = await _dio.post(
        'UniversityAuth/register',
        data: formData,
        options: Options(validateStatus: (status) => true),
      );

      debugPrint('📥 University Registration Response: ${response.statusCode}');
      debugPrint('📥 Response Data: ${response.data}');
      return response;
    } catch (e) {
      debugPrint('❌ University Registration Error: $e');
      rethrow;
    }
  }

  // ─── Company Registration ─────────────────────────────────────────────────────
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

      // ✅ 1. Log map fields before FormData
      debugPrint("══════════════════════════════");
      debugPrint("🚀 COMPANY REGISTER REQUEST");
      debugPrint("══════════════════════════════");
      map.forEach((key, value) {
        debugPrint("🔹 $key : $value");
      });

      if (organizationLogo != null) {
        debugPrint("🖼️ ORIGINAL IMAGE:");
        debugPrint("path: ${organizationLogo.path}");
        debugPrint("size: ${organizationLogo.lengthSync()} bytes");

        // ✅ Compress using dart:ui — no external package needed
        final Uint8List compressedBytes = await _compressImage(organizationLogo);
        debugPrint("✅ COMPRESSED size: ${compressedBytes.length} bytes");

        map['OrganizationLogo'] = MultipartFile.fromBytes(
          compressedBytes,
          filename: organizationLogo.path.split('/').last,
        );
      }

      FormData formData = FormData.fromMap(map);

      // ✅ 3. Log FormData fields and files
      debugPrint("════════ FORM DATA ════════");
      formData.fields.forEach((f) {
        debugPrint("🔹 ${f.key} : ${f.value}");
      });
      debugPrint("📎 FILES:");
      for (var file in formData.files) {
        debugPrint("🔹 ${file.key} -> ${file.value.filename}");
      }

      // ✅ 4. Log before sending request
      debugPrint("📤 SENDING REQUEST NOW...");
      Response response = await _dio.post(
        'CompanyAuth/register',
        data: formData,
        options: Options(
          validateStatus: (status) => true,
          followRedirects: false,
        ),
      );

      // ✅ Handle 307 redirect manually to preserve POST body
      if (response.statusCode == 307 || response.statusCode == 301 || response.statusCode == 302) {
        final redirectUrl = response.headers.value('location');
        debugPrint("↪️ Redirecting to: $redirectUrl");
        if (redirectUrl != null) {
          // rebuild FormData because it can only be sent once
          final newMap = <String, dynamic>{
            'Email': email,
            'Password': password,
            'FirstName': firstName,
            'LastName': lastName,
            'OrganizationName': organizationName,
            'Country': country,
            'City': city,
          };
          if (organizationLogo != null) {
            final Uint8List bytes = await _compressImage(organizationLogo);
            newMap['OrganizationLogo'] = MultipartFile.fromBytes(
              bytes,
              filename: organizationLogo.path.split('/').last,
            );
          }
          response = await _dio.post(
            redirectUrl,
            data: FormData.fromMap(newMap),
            options: Options(validateStatus: (status) => true),
          );
          debugPrint("📥 After redirect Response: ${response.statusCode}");
        }
      }

      debugPrint('📥 Company Registration Response: ${response.statusCode}');
      debugPrint('📥 Response Data: ${response.data}');
      return response;
    } catch (e) {
      // ✅ 5. Detailed error logging
      debugPrint("══════════════════════════════");
      debugPrint("❌ ERROR OCCURRED");
      debugPrint("══════════════════════════════");
      debugPrint(e.toString());
      if (e is DioException) {
        debugPrint("📡 TYPE: ${e.type}");
        debugPrint("📡 MESSAGE: ${e.message}");
        debugPrint("📡 STATUS: ${e.response?.statusCode}");
        debugPrint("📡 RESPONSE: ${e.response?.data}");
      }
      rethrow;
    }
  }

  // ─── Image Compression (no external package) ─────────────────────────────────
  Future<Uint8List> _compressImage(File imageFile) async {
    final Uint8List originalBytes = await imageFile.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(
      originalBytes,
      targetWidth: 800,  // max width
      targetHeight: 800, // max height
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? byteData = await frameInfo.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData!.buffer.asUint8List();
  }

  // ─── Helper: Get auth route prefix ───────────────────────────────────────────
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

  // ─── Helper: Get accountType string for login body ────────────────────────────
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
    await prefs.remove('user_data');
  }

  // ─── User Data Management ─────────────────────────────────────────────────────
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }

  // ─── Response Helpers ─────────────────────────────────────────────────────────
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