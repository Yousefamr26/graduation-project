import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UniversityAuthRepository {
  static const String _baseUrl = 'http://smartcareerhub.runasp.net/api/UniversityAuth/';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    headers: {'Accept': 'application/json'},
    validateStatus: (status) => status! < 500,
  ));

  // ════════════════════════════════════════════════════════════════
  // تسجيل حساب جامعة جديد
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
      final FormData formData = FormData();

      formData.fields.addAll([
        MapEntry('Name',            name.trim()),
        MapEntry('Email',           email.trim()),
        MapEntry('Password',        password),
        MapEntry('ConfirmPassword', confirmPassword),
        MapEntry('PhoneNumber',     phoneNumber.trim()),
        MapEntry('Country',         country.trim()),
        MapEntry('City',            city.trim()),
      ]);

      debugPrint("📤 [REGISTER UNI] ─────────────────────────");
      debugPrint("   Name:          $name");
      debugPrint("   Email:         $email");
      debugPrint("   Phone:         $phoneNumber");
      debugPrint("   Country:       $country");
      debugPrint("   City:          $city");

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
          debugPrint("   Logo: attached (${compressedBytes.length} bytes)");
        }
      }

      final response = await _dio.post(
        'register',
        data: formData,
        options: Options(validateStatus: (s) => s! < 500),
      );

      debugPrint("📥 [REGISTER UNI] Status: ${response.statusCode}");
      debugPrint("📥 [REGISTER UNI] Body:   ${response.data}");

      return response;
    } on DioException catch (e) {
      debugPrint("❌ [REGISTER UNI] DioException: ${e.message}");
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // التحقق من البريد الإلكتروني عبر OTP
  // ════════════════════════════════════════════════════════════════
  Future<Response> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      debugPrint("📤 [VERIFY EMAIL] email=$email | otp=$otp");
      final response = await _dio.post(
        'verify-email',
        data: {'email': email.trim(), 'otp': otp.trim()},
        options: Options(validateStatus: (s) => s! < 500),
      );
      debugPrint("📥 [VERIFY EMAIL] Status: ${response.statusCode}");
      debugPrint("📥 [VERIFY EMAIL] Body:   ${response.data}");
      return response;
    } on DioException catch (e) {
      debugPrint("❌ [VERIFY EMAIL] Error: ${e.message}");
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // إعادة إرسال OTP
  // ════════════════════════════════════════════════════════════════
  Future<Response> resendOtp({required String email}) async {
    try {
      debugPrint("📤 [RESEND OTP] email=$email");
      final response = await _dio.post(
        'resend-otp',
        data: {'email': email.trim()},
        options: Options(validateStatus: (s) => s! < 500),
      );
      debugPrint("📥 [RESEND OTP] Status: ${response.statusCode}");
      debugPrint("📥 [RESEND OTP] Body:   ${response.data}");
      return response;
    } on DioException catch (e) {
      debugPrint("❌ [RESEND OTP] Error: ${e.message}");
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // تسجيل دخول الجامعة ✅ بيحفظ userProfile بعد الـ login
  // ════════════════════════════════════════════════════════════════
  Future<Response> login(String email, String password) async {
    try {
      debugPrint("📤 [LOGIN UNI] email=$email");
      final response = await _dio.post(
        'login',
        data: {
          'email':       email.trim(),
          'password':    password,
          'accountType': 'University',
          'rememberMe':  true,
        },
        options: Options(validateStatus: (s) => s! < 500),
      );

      debugPrint("📥 [LOGIN UNI] Status: ${response.statusCode}");
      debugPrint("📥 [LOGIN UNI] Body:   ${response.data}");

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        // ── 1. حفظ الـ token ─────────────────────────────────
        final String? token =
            response.data['token'] ?? response.data['data']?['token'];
        if (token != null) {
          await prefs.setString('university_token', token);
          debugPrint("💾 [LOGIN UNI] Token saved");
        } else {
          debugPrint("⚠️ [LOGIN UNI] No token in response");
        }

        // ── 2. حفظ userProfile ✅ ─────────────────────────────
        // structure: {success, message, data: {token, userProfile}}
        final dynamic userProfile =
            response.data['data']?['userProfile'] ??
                response.data['data']                 ??
                response.data['user']                 ??
                response.data;

        debugPrint("📦 [LOGIN UNI] userProfile: $userProfile");

        if (userProfile is Map) {
          // ✅ استخرج الـ logo URL الصح
          final String logoUrl =
              userProfile['organizationLogoUrl']?.toString() ??
                  userProfile['OrganizationLogoUrl']?.toString() ??
                  userProfile['logoPath']?.toString()            ??
                  userProfile['LogoPath']?.toString()            ??
                  userProfile['logoUrl']?.toString()             ??
                  userProfile['LogoUrl']?.toString()             ??
                  userProfile['organizationLogo']?.toString()    ??
                  userProfile['OrganizationLogo']?.toString()    ??
                  '';

          // ✅ بني الـ full URL لو كان relative path
          String fullLogoUrl = '';
          if (logoUrl.isNotEmpty) {
            fullLogoUrl = logoUrl.startsWith('http')
                ? logoUrl
                : 'http://smartcareerhub.runasp.net$logoUrl';
          }

          final Map<String, dynamic> userData = {
            'id':          userProfile['id']?.toString()          ?? '',
            'name':        userProfile['name']?.toString()        ?? '',
            'email':       userProfile['email']?.toString()       ?? email,
            'phoneNumber': userProfile['phoneNumber']?.toString() ?? '',
            'country':     userProfile['country']?.toString()     ?? '',
            'city':        userProfile['city']?.toString()        ?? '',
            'logoPath':    fullLogoUrl,   // ✅ full URL جاهز للعرض
          };

          await prefs.setString('university_user_data', jsonEncode(userData));
          debugPrint("💾 [LOGIN UNI] userProfile saved | logo: $fullLogoUrl");
        }
      }

      return response;
    } on DioException catch (e) {
      debugPrint("❌ [LOGIN UNI] DioException: ${e.message}");
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // تحديث بروفيل الجامعة
  // ════════════════════════════════════════════════════════════════
  Future<Response> updateProfile({
    required String name,
    required String phoneNumber,
    required String country,
    required String city,
    String? website,
    String? about,
    String? abbreviation,
    String? establishedYear,
    int? totalStudents,
    int? totalPrograms,
    double? successRate,
    int? totalPartners,
    List<String>? specializations,
    Map<String, String>? socialMedia,
    File? organizationLogo,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('university_token');

      final FormData formData = FormData();
      formData.fields.addAll([
        MapEntry('Name',        name.trim()),
        MapEntry('PhoneNumber', phoneNumber.trim()),
        MapEntry('Country',     country.trim()),
        MapEntry('City',        city.trim()),
        if (website != null && website.isNotEmpty)
          MapEntry('Website', website),
        if (about != null && about.isNotEmpty)
          MapEntry('About', about),
        if (abbreviation != null && abbreviation.isNotEmpty)
          MapEntry('Abbreviation', abbreviation),
        if (establishedYear != null && establishedYear.isNotEmpty)
          MapEntry('EstablishedYear', establishedYear),
        if (totalStudents != null)
          MapEntry('TotalStudents', totalStudents.toString()),
        if (totalPrograms != null)
          MapEntry('TotalPrograms', totalPrograms.toString()),
        if (successRate != null)
          MapEntry('SuccessRate', successRate.toString()),
        if (totalPartners != null)
          MapEntry('TotalPartners', totalPartners.toString()),
      ]);

      if (specializations != null) {
        for (int i = 0; i < specializations.length; i++) {
          formData.fields.add(MapEntry('Specializations[$i]', specializations[i]));
        }
      }

      if (socialMedia != null) {
        socialMedia.forEach((key, value) {
          if (value.isNotEmpty)
            formData.fields.add(MapEntry('SocialMedia.$key', value));
        });
      }

      if (organizationLogo != null && organizationLogo.existsSync()) {
        final Uint8List? bytes = await _compressImage(organizationLogo);
        if (bytes != null) {
          formData.files.add(MapEntry(
            'OrganizationLogo',
            MultipartFile.fromBytes(bytes,
                filename: 'logo_${DateTime.now().millisecondsSinceEpoch}.jpg',
                contentType: DioMediaType('image', 'jpeg')),
          ));
        }
      }

      final response = await _dio.put(
        'update-profile',
        data: formData,
        options: Options(
          validateStatus: (s) => s! < 500,
          headers: token != null ? {'Authorization': 'Bearer $token'} : {},
        ),
      );

      debugPrint("📥 [UPDATE PROFILE] Status: ${response.statusCode}");
      debugPrint("📥 [UPDATE PROFILE] Body:   ${response.data}");
      return response;
    } on DioException catch (e) {
      debugPrint("❌ [UPDATE PROFILE] Error: ${e.message}");
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // تسجيل الخروج
  // ════════════════════════════════════════════════════════════════
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('university_token');
    await prefs.remove('university_user_data');
    debugPrint("🚪 [LOGOUT UNI] Token & user data removed.");
  }

  // ════════════════════════════════════════════════════════════════
  // ضغط الصور
  // ════════════════════════════════════════════════════════════════
  Future<Uint8List?> _compressImage(File file) async {
    try {
      return await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: 25,
        format: CompressFormat.jpeg,
      );
    } catch (e) {
      debugPrint("❌ [COMPRESS] Error: $e");
      return null;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // هل المستخدم مسجل دخول؟
  // ════════════════════════════════════════════════════════════════
  Future<bool> isUniversityLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('university_token');
    return token != null && token.isNotEmpty;
  }
}