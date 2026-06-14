// ignore_for_file: avoid_print
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InterviewRepository {
  late Dio _dio;
  static const String _baseUrl =
      "http://smartcareerhub.runasp.net/api/Interviews";

  InterviewRepository() {
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

  // ── Get All Interviews ────────────────────────────────────
  Future<List<Map<String, dynamic>>> getAllInterviews() async {
    try {
      debugPrint("📤 [GET ALL] Fetching from: $_baseUrl");

      final response = await _dio.get(
        _baseUrl,
        options: Options(validateStatus: (status) => status! < 500),
      );

      debugPrint("📥 [INTERVIEWS RAW]: ${response.data}"); // ✅ أضيفيه هنا
      debugPrint("📥 [GET ALL] Status: ${response.statusCode}");
      debugPrint("📥 [GET ALL] Data: ${response.data}");

      if (response.statusCode == 200) {
        if (response.data is List)
          return List<Map<String, dynamic>>.from(response.data);
        if (response.data is Map && response.data['data'] != null)
          return List<Map<String, dynamic>>.from(response.data['data']);
      }

      debugPrint("⚠️ getAllInterviews unexpected status: ${response.statusCode}");
      return [];
    } catch (e) {
      debugPrint("❌ Fetch Interviews Error: $e");
      return [];
    }

  }

  // ── Create Interview ──────────────────────────────────────
  Future<Response?> createInterview({
    required String studentUserId,
    required String studentName,
    required int roadmapId,
    required DateTime scheduledDate,
    required String interviewType,
    required String interviewerName,
    String? additionalNotes,
  }) async {
    try {
      final body = {
        "studentUserId":   studentUserId,
        "studentName":     studentName,
        "roadmapId":       roadmapId,
        "scheduledDate":   scheduledDate.toUtc().toIso8601String(),
        "interviewType":   interviewType,
        "interviewerName": interviewerName,
        if (additionalNotes != null && additionalNotes.trim().isNotEmpty)
          "additionalNotes": additionalNotes.trim(),
      };

      debugPrint("------------------------------------------");
      debugPrint("🚀 [CREATE] Starting createInterview...");
      debugPrint("📝 Body: $body");
      debugPrint("------------------------------------------");

      final response = await _dio.post(
        _baseUrl,
        data: body,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status! < 500,
        ),
      );

      debugPrint("✅ [CREATE RESPONSE] Status: ${response.statusCode}");
      debugPrint("✅ [CREATE DATA]: ${response.data}");
      return response;
    } catch (e) {
      debugPrint("❌ [CRITICAL ERROR in createInterview]: $e");
      rethrow;
    }

  }

  // ── Delete Interview ──────────────────────────────────────
  Future<Response?> deleteInterview(dynamic interviewId) async {
    try {
      return await _dio.delete(
        "$_baseUrl/${interviewId.toString()}",
        options: Options(validateStatus: (status) => status! < 500),
      );
    } catch (e) {
      debugPrint("❌ Delete Interview Error: $e");
      rethrow;
    }
  }
}