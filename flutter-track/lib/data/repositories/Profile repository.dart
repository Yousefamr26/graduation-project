// ignore_for_file: avoid_print
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepository {
  late final Dio _dio;
  static const String _serverBase = 'http://smartcareerhub.runasp.net';

  ProfileRepository() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(minutes: 5),
      receiveTimeout: const Duration(minutes: 10),
      sendTimeout: const Duration(minutes: 10),
      headers: {'Accept': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('company_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          debugPrint('✅ [PROFILE AUTH] Token attached');
        } else {
          debugPrint('🛑 [PROFILE AUTH] No company_token!');
        }
        debugPrint('📤 [PROFILE] ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('📥 [PROFILE] Status: ${response.statusCode}');
        debugPrint('📥 [PROFILE] Data: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        debugPrint('🛑 [PROFILE ERROR] ${e.response?.statusCode}: ${e.message}');
        return handler.next(e);
      },
    ));
  }

  /// ✅ GET /api/Profile/public/{userId}
  /// جلب البروفايل العام للطالب باستخدام الـ userId الخاص به
  Future<Map<String, dynamic>?> getProfileSummary(String userId) async {
    if (userId.isEmpty) {
      debugPrint('⚠️ [PROFILE] userId is empty — skipping fetch');
      return null;
    }

    try {
      final endpoint = '$_serverBase/api/Profile/public/$userId';
      debugPrint('📤 [PROFILE] Fetching: $endpoint');

      final response = await _dio.get(
        endpoint,
        options: Options(validateStatus: (s) => s! < 500),
      );

      debugPrint('📥 [PROFILE] Status: ${response.statusCode}');
      debugPrint('📥 [PROFILE] Keys: ${response.data is Map ? (response.data as Map).keys.toList() : "not a map"}');

      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }

      debugPrint('⚠️ [PROFILE] Unexpected response: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('❌ [PROFILE SUMMARY ERROR]: $e');
      return null;
    }
  }
}