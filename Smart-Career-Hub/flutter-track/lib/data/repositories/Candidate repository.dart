// ignore_for_file: avoid_print
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CandidateRepository {
  late Dio _dio;
  static const String _baseUrl =
      "http://smartcareerhub.runasp.net/api/Candidates";

  CandidateRepository() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 10),
        sendTimeout:    const Duration(minutes: 10),
        headers: {'Accept': 'application/json'},
      ),
    );

    // ✅ نفس الـ interceptor بالظبط زي RoadmapRepository
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('company_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          debugPrint("✅ [AUTH] Token attached: ${token.substring(0, 20)}...");
        } else {
          debugPrint("🛑 [AUTH] Warning: No token found!");
        }
        debugPrint("📤 [REQUEST] ${options.method} ${options.uri}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint("📥 [RESPONSE] Status: ${response.statusCode}");
        debugPrint("📥 [DATA]: ${response.data}");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        debugPrint("🛑 [ERROR] Status: ${e.response?.statusCode}");
        debugPrint("🛑 [ERROR DATA]: ${e.response?.data}");
        debugPrint("🛑 [ERROR MSG]: ${e.message}");
        return handler.next(e);
      },
    ));
  }

  // ── Get All Candidates ────────────────────────────────────
  Future<List<Map<String, dynamic>>> getAllCandidates() async {
    try {
      debugPrint("📤 [GET ALL] Fetching from: $_baseUrl");

      final response = await _dio.get(
        _baseUrl,
        options: Options(validateStatus: (status) => status! < 500),
      );

      debugPrint("📥 [GET ALL] Status: ${response.statusCode}");
      debugPrint("📥 [GET ALL] Data type: ${response.data.runtimeType}");
      debugPrint("📥 [GET ALL] Data: ${response.data}");

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> result = [];

        if (response.data is List) {
          result = List<Map<String, dynamic>>.from(response.data);
        } else if (response.data is Map && response.data['data'] != null) {
          result = List<Map<String, dynamic>>.from(response.data['data']);
        }

        return result;
      }

      debugPrint(
          "⚠️ getAllCandidates unexpected status: ${response.statusCode}");
      return [];
    } catch (e) {
      debugPrint("❌ Fetch Candidates Error: $e");
      return [];
    }
  }
}