import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentAuthRepository {
  static const String _baseUrl = 'http://smartcareerhub.runasp.net/api/StudentAuth/';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    headers: {'Accept': 'application/json'},
    validateStatus: (status) => status! < 500,
  ));

  // ════════════════════════════════════════════════════════════════
  // تسجيل حساب طالب جديد
  // ════════════════════════════════════════════════════════════════
  Future<Response> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String university,
    required String faculty,
    required String major,
    required String degree,
    required String expectedGraduation, // ISO 8601: "2026-06-01T00:00:00"
    required String city,
    required String country,
    String? linkedIn,   // null لو فاضي — مش string فاضي
    String? gitHub,     // null لو فاضي
    String? portfolio,  // null لو فاضي
    File? profileImage,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        'Email':              email,
        'Password':           password,
        'FirstName':          firstName,
        'LastName':           lastName,
        'University':         university,
        'Faculty':            faculty,
        'Major':              major,
        'Degree':             degree,
        'ExpectedGraduation': expectedGraduation,
        'City':               city,
        'Country':            country,
      };

      // ✅ بنضيف الـ optional fields بس لو مش null ومش فاضية
      if (linkedIn  != null && linkedIn.isNotEmpty)  dataMap['LinkedIn']  = linkedIn;
      if (gitHub    != null && gitHub.isNotEmpty)    dataMap['GitHub']    = gitHub;
      if (portfolio != null && portfolio.isNotEmpty) dataMap['Portfolio'] = portfolio;

      FormData formData = FormData.fromMap(dataMap);

      if (profileImage != null && profileImage.existsSync()) {
        final Uint8List? compressedBytes = await _compressImage(profileImage);
        if (compressedBytes != null) {
          formData.files.add(MapEntry(
            'ProfileImage',
            MultipartFile.fromBytes(
              compressedBytes,
              filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
              contentType: DioMediaType('image', 'jpeg'),
            ),
          ));
        }
      }

      final response = await _dio.post('register', data: formData);
      debugPrint("📡 Student Register STATUS: ${response.statusCode}");
      debugPrint("📡 Student Register BODY: ${response.data}");
      return response;
    } on DioException catch (e) {
      debugPrint("❌ Student Register Error: ${e.message}");
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // تسجيل دخول الطالب
  // ════════════════════════════════════════════════════════════════
  Future<Response> login(String email, String password) async {
    try {
      final response = await _dio.post('login', data: {
        'email':       email,
        'password':    password,
        'accountType': 'Student',
        'rememberMe':  true,
      });

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        final String? token =
            response.data['token'] ?? response.data['data']?['token'];

        if (token != null) {
          await prefs.setString('student_token', token);
          debugPrint("💾 Success: Student Token saved.");
        } else {
          debugPrint("⚠️ Warning: Login successful but no token found.");
        }

        final dynamic userProfile =
            response.data['data']?['userProfile'] ??
                response.data['data']              ??
                response.data['user']              ??
                response.data;

        debugPrint("📦 [STUDENT] userProfile raw: $userProfile");

        if (userProfile is Map) {
          final String profileImageUrl =
              userProfile['profileImageUrl']?.toString() ??
                  userProfile['ProfileImageUrl']?.toString() ??
                  userProfile['profileImage']?.toString()    ??
                  userProfile['ProfileImage']?.toString()    ??
                  '';

          final String name =
          '${userProfile['firstName'] ?? userProfile['FirstName'] ?? ''} '
              '${userProfile['lastName']  ?? userProfile['LastName']  ?? ''}'
              .trim();

          final Map<String, dynamic> userData = {
            'name':            name,
            'email':           userProfile['email']?.toString()      ?? userProfile['Email']?.toString()      ?? email,
            'city':            userProfile['city']?.toString()       ?? userProfile['City']?.toString()       ?? '',
            'country':         userProfile['country']?.toString()    ?? userProfile['Country']?.toString()    ?? '',
            'university':      userProfile['university']?.toString() ?? userProfile['University']?.toString() ?? '',
            'faculty':         userProfile['faculty']?.toString()    ?? userProfile['Faculty']?.toString()    ?? '',
            'major':           userProfile['major']?.toString()      ?? userProfile['Major']?.toString()      ?? '',
            'degree':          userProfile['degree']?.toString()     ?? userProfile['Degree']?.toString()     ?? '',
            'profileImageUrl': profileImageUrl,
            'id':              userProfile['id']?.toString()         ?? userProfile['Id']?.toString()         ?? '',
            'role':            'student',
          };

          await prefs.setString('student_user_data', jsonEncode(userData));
          debugPrint("💾 Success: Student user data saved → name: ${userData['name']}");
        }
      } else {
        debugPrint("🛑 Login Failed with status: ${response.statusCode}");
      }

      return response;
    } on DioException catch (e) {
      debugPrint("❌ Login Dio Error: ${e.message}");
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // تسجيل الخروج
  // ════════════════════════════════════════════════════════════════
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('student_token');
    await prefs.remove('student_user_data');
    await prefs.remove('user_data');
    debugPrint("🚪 Logged out: Student token & user data removed.");
  }

  // ════════════════════════════════════════════════════════════════
  // ضغط الصور
  // ════════════════════════════════════════════════════════════════
  Future<Uint8List?> _compressImage(File file) async {
    try {
      final result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: 25,
        format: CompressFormat.jpeg,
      );
      return result;
    } catch (e) {
      debugPrint("❌ Compression Error: $e");
      return null;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // التحقق من حالة التسجيل
  // ════════════════════════════════════════════════════════════════
  Future<bool> isStudentLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('student_token');
    return token != null && token.isNotEmpty;
  }
}