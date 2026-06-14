import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompanyAuthRepository {
  static const String _baseUrl = 'http://smartcareerhub.runasp.net/api/CompanyAuth/';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    headers: {'Accept': 'application/json'},
    validateStatus: (status) => status! < 500,
  ));

  // ════════════════════════════════════════════════════════════════
  // تسجيل حساب شركة جديد
  // ════════════════════════════════════════════════════════════════
  Future<Response> register({
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
      final Map<String, dynamic> dataMap = {
        'Email': email,
        'Password': password,
        'FirstName': firstName,
        'LastName': lastName,
        'OrganizationName': organizationName,
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
      debugPrint("❌ Register Error: ${e.message}");
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // تسجيل دخول الشركة
  // ════════════════════════════════════════════════════════════════
  Future<Response> login(String email, String password) async {
    try {
      final response = await _dio.post('login', data: {
        'email': email,
        'password': password,
        'accountType': 'Company',
        'rememberMe': true,
      });

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        // ── 1. حفظ التوكن ───────────────────────────────────────
        final String? token =
            response.data['token'] ?? response.data['data']?['token'];

        if (token != null) {
          await prefs.setString('company_token', token);
          debugPrint("💾 Success: Company Token saved.");
        } else {
          debugPrint("⚠️ Warning: Login successful but no token found.");
        }

        // ── 2. استخرج userProfile من response.data['data']['userProfile'] ──
        // ✅ الـ response structure: {success, message, data: {token, userProfile}}
        final dynamic userProfile =
            response.data['data']?['userProfile'] ??  // ✅ المسار الصح
                response.data['data']    ??
                response.data['user']    ??
                response.data;

        debugPrint("📦 [COMPANY] userProfile raw: $userProfile");

        if (userProfile is Map) {
          // ✅ استخرج الـ logo URL الصح من userProfile
          final String logoUrl =
              userProfile['organizationLogoUrl']?.toString() ??
                  userProfile['OrganizationLogoUrl']?.toString() ??
                  userProfile['logoUrl']?.toString()             ??
                  userProfile['LogoUrl']?.toString()             ??
                  userProfile['organizationLogo']?.toString()    ??
                  userProfile['OrganizationLogo']?.toString()    ??
                  '';

          // ✅ استخرج الاسم الصح
          final String name =
              userProfile['organizationName']?.toString()  ??
                  userProfile['OrganizationName']?.toString()  ??
                  userProfile['companyName']?.toString()       ??
                  userProfile['CompanyName']?.toString()       ??
                  userProfile['name']?.toString()              ??
                  userProfile['Name']?.toString()              ??
                  '${userProfile['firstName'] ?? userProfile['FirstName'] ?? ''} ${userProfile['lastName'] ?? userProfile['LastName'] ?? ''}'.trim();

          final Map<String, dynamic> userData = {
            'name':               name,
            'email':              userProfile['email']?.toString()       ?? userProfile['Email']?.toString()       ?? email,
            'city':               userProfile['city']?.toString()        ?? userProfile['City']?.toString()        ?? '',
            'country':            userProfile['country']?.toString()     ?? userProfile['Country']?.toString()     ?? '',
            'phone':              userProfile['phoneNumber']?.toString() ?? userProfile['PhoneNumber']?.toString() ?? '',
            'organizationLogoUrl': logoUrl,   // ✅ نفس الـ key اللي بيتقرأ في profileCompany
            'id':                 userProfile['id']?.toString()          ?? userProfile['Id']?.toString()          ?? '',
            'role':               'company',
          };

          await prefs.setString('company_user_data', jsonEncode(userData));
          debugPrint("💾 Success: Company user data saved → name: ${userData['name']} | logo: $logoUrl");
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
  // تسجيل الخروج ومسح كل البيانات
  // ════════════════════════════════════════════════════════════════
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('company_token');
    await prefs.remove('company_user_data');
    await prefs.remove('user_data');
    debugPrint("🚪 Logged out: Company token & user data removed.");
  }

  // ════════════════════════════════════════════════════════════════
  // ضغط الصور (Private Helper)
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
  Future<bool> isCompanyLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('company_token');
    return token != null && token.isNotEmpty;
  }
}