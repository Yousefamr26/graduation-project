import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GraduateAuthRepository {
  static const String _baseUrl = 'http://smartcareerhub.runasp.net/api/GraduateAuth/';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    headers: {'Accept': 'application/json'},
    validateStatus: (status) => status! < 500,
  ));

  // ════════════════════════════════════════════════════════════════
  // تسجيل حساب خريج جديد
  // ════════════════════════════════════════════════════════════════
  Future<Response> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String university,
    required String degree,
    required String major,
    required int    graduationYear,
    required int    yearsOfExperience,
    required String experienceSummary,
    required String city,
    required String country,
    String? linkedIn,   // null لو فاضي — مش string فاضي
    String? gitHub,     // null لو فاضي
    String? portfolio,  // null لو فاضي
    File?   profileImage,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        'Email':             email,
        'Password':          password,
        'FirstName':         firstName,
        'LastName':          lastName,
        'University':        university,
        'Degree':            degree,
        'Major':             major,
        'GraduationYear':    graduationYear,
        'YearsOfExperience': yearsOfExperience,
        'ExperienceSummary': experienceSummary,
        'City':              city,
        'Country':           country,
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
      debugPrint("📡 Graduate Register STATUS: ${response.statusCode}");
      debugPrint("📡 Graduate Register BODY: ${response.data}");
      return response;
    } on DioException catch (e) {
      debugPrint("❌ Graduate Register Error: ${e.message}");
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // تسجيل دخول الخريج
  // ════════════════════════════════════════════════════════════════
  Future<Response> login(String email, String password) async {
    try {
      final response = await _dio.post('login', data: {
        'email':       email,
        'password':    password,
        'accountType': 'Graduate',
        'rememberMe':  true,
      });

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        final String? token =
            response.data['token'] ?? response.data['data']?['token'];

        if (token != null) {
          await prefs.setString('graduate_token', token);
          debugPrint("💾 Success: Graduate Token saved.");
        } else {
          debugPrint("⚠️ Warning: Login successful but no token found.");
        }

        final dynamic userProfile =
            response.data['data']?['userProfile'] ??
                response.data['data']              ??
                response.data['user']              ??
                response.data;

        debugPrint("📦 [GRADUATE] userProfile raw: $userProfile");

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
            'degree':          userProfile['degree']?.toString()     ?? userProfile['Degree']?.toString()     ?? '',
            'major':           userProfile['major']?.toString()      ?? userProfile['Major']?.toString()      ?? '',
            'profileImageUrl': profileImageUrl,
            'id':              userProfile['id']?.toString()         ?? userProfile['Id']?.toString()         ?? '',
            'role':            'graduate',
          };

          await prefs.setString('graduate_user_data', jsonEncode(userData));
          debugPrint("💾 Success: Graduate user data saved → name: ${userData['name']}");
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
    await prefs.remove('graduate_token');
    await prefs.remove('graduate_user_data');
    await prefs.remove('user_data');
    debugPrint("🚪 Logged out: Graduate token & user data removed.");
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
  Future<bool> isGraduateLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('graduate_token');
    return token != null && token.isNotEmpty;
  }
}