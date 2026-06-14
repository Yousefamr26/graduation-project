import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrainingCenterAuthRepository {
  static const String _baseUrl = 'http://smartcareerhub.runasp.net/api/TrainingCenterAuth/';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    headers: {'Accept': 'application/json'},
    validateStatus: (status) => status! < 500,
  ));

  // ════════════════════════════════════════════════════════════════
  // تسجيل حساب مركز تدريب جديد
  // ════════════════════════════════════════════════════════════════
  Future<Response> register({
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
      final Map<String, dynamic> dataMap = {
        'Name': name,
        'Email': email,
        'Password': password,
        'ConfirmPassword': confirmPassword,
        'PhoneNumber': phoneNumber,
        'Country': country,
        'City': city,
      };

      FormData formData = FormData.fromMap(dataMap);

      if (organizationLogo != null && organizationLogo.existsSync()) {
        final Uint8List? compressedBytes = await _compressImage(organizationLogo);
        if (compressedBytes != null) {
          formData.files.add(MapEntry(
            'OrganizationLogo',
            MultipartFile.fromBytes(
              compressedBytes,
              filename: 'logo_${DateTime.now().millisecondsSinceEpoch}.jpg',
              contentType: DioMediaType('image', 'jpeg'),
            ),
          ));
        }
      }

      final response = await _dio.post('register', data: formData);
      return response;
    } on DioException catch (e) {
      debugPrint("❌ TrainingCenter Register Error: ${e.message}");
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // تسجيل دخول مركز التدريب
  // ════════════════════════════════════════════════════════════════
  Future<Response> login(String email, String password) async {
    try {
      final response = await _dio.post('login', data: {
        'email': email,
        'password': password,
        'accountType': 'TrainingCenter',
        'rememberMe': true,
      });

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        final String? token =
            response.data['token'] ?? response.data['data']?['token'];

        if (token != null) {
          await prefs.setString('training_center_token', token);
          debugPrint("💾 Success: Training Center Token saved.");
        } else {
          debugPrint("⚠️ Warning: Login successful but no token found.");
        }

        final dynamic userProfile =
            response.data['data']?['userProfile'] ??
                response.data['data'] ??
                response.data['user'] ??
                response.data;

        debugPrint("📦 [TRAINING_CENTER] userProfile raw: $userProfile");

        if (userProfile is Map) {
          final String logoUrl =
              userProfile['organizationLogoUrl']?.toString() ??
                  userProfile['OrganizationLogoUrl']?.toString() ??
                  userProfile['logoUrl']?.toString() ??
                  userProfile['LogoUrl']?.toString() ??
                  '';

          final String centerName =
              userProfile['name']?.toString() ??
                  userProfile['Name']?.toString() ??
                  userProfile['organizationName']?.toString() ??
                  userProfile['OrganizationName']?.toString() ??
                  '';

          final Map<String, dynamic> userData = {
            'name': centerName,
            'email': userProfile['email']?.toString() ?? userProfile['Email']?.toString() ?? email,
            'city': userProfile['city']?.toString() ?? userProfile['City']?.toString() ?? '',
            'country': userProfile['country']?.toString() ?? userProfile['Country']?.toString() ?? '',
            'phone': userProfile['phoneNumber']?.toString() ?? userProfile['PhoneNumber']?.toString() ?? '',
            'organizationLogoUrl': logoUrl,
            'id': userProfile['id']?.toString() ?? userProfile['Id']?.toString() ?? '',
            'role': 'training_center',
          };

          await prefs.setString('training_center_user_data', jsonEncode(userData));
          debugPrint("💾 Success: Training Center user data saved → name: ${userData['name']} | logo: $logoUrl");
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
    await prefs.remove('training_center_token');
    await prefs.remove('training_center_user_data');
    await prefs.remove('user_data');
    debugPrint("🚪 Logged out: Training Center token & user data removed.");
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
  Future<bool> isTrainingCenterLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('training_center_token');
    return token != null && token.isNotEmpty;
  }
}