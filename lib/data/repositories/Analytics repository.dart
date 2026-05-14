// ignore_for_file: avoid_print
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsRepository {
  late Dio _dio;
  static const String _baseUrl = "http://smartcareerhub.runasp.net/api/Analytics";

  AnalyticsRepository() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 10),
        sendTimeout: const Duration(minutes: 10),
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('company_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          debugPrint("✅ [ANALYTICS AUTH] Token attached");
        } else {
          debugPrint("🛑 [ANALYTICS AUTH] No token found!");
        }
        debugPrint("📤 [ANALYTICS REQUEST] ${options.method} ${options.uri}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint("📥 [ANALYTICS RESPONSE] Status: ${response.statusCode}");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        debugPrint("🛑 [ANALYTICS ERROR] Status: ${e.response?.statusCode}");
        debugPrint("🛑 [ANALYTICS ERROR MSG]: ${e.message}");
        return handler.next(e);
      },
    ));
  }

  Map<String, dynamic> _safeMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  Future<Map<String, dynamic>> _get(String endpoint) async {
    try {
      final response = await _dio.get(
        "$_baseUrl/$endpoint",
        options: Options(validateStatus: (status) => status! < 500),
      );
      debugPrint("📊 [$endpoint] Status: ${response.statusCode}");
      debugPrint("📊 [$endpoint] Data: ${response.data}");
      if (response.statusCode == 200) return _safeMap(response.data);
      return {};
    } catch (e) {
      debugPrint("❌ [$endpoint ERROR]: $e");
      return {};
    }
  }

  // ─── 1. Dashboard Overview ───────────────────────────────────
  // GET /api/Analytics/dashboard-overview
  // Response shape:
  // { roadmap: {...}, jobs: {...}, internships: {...},
  //   workshops: {...}, events: {...}, interviews: {...}, universities: {...} }
  Future<Map<String, dynamic>> getDashboardOverview() => _get('dashboard-overview');

  // ─── 2. Roadmaps ─────────────────────────────────────────────
  // GET /api/Analytics/roadmaps
  // Response: { totalRoadmaps, activeRoadmaps, totalEnrolled,
  //             completionRate, avgProgress, distributionByTargetRole }
  Future<Map<String, dynamic>> getRoadmapsAnalytics() => _get('roadmaps');

  // ─── 3. Jobs ─────────────────────────────────────────────────
  // GET /api/Analytics/jobs
  // Response: { totalJobPostings, totalApplications, interviewRate,
  //             hiringSuccessRate, byTypeAndLevel }
  Future<Map<String, dynamic>> getJobsAnalytics() => _get('jobs');

  // ─── 4. Internships ──────────────────────────────────────────
  // GET /api/Analytics/internships
  Future<Map<String, dynamic>> getInternshipsAnalytics() => _get('internships');

  // ─── 5. Workshops ────────────────────────────────────────────
  // GET /api/Analytics/workshops
  // Response: { totalWorkshops, totalParticipants, attendanceRate, byType }
  Future<Map<String, dynamic>> getWorkshopsAnalytics() => _get('workshops');

  // ─── 6. Events ───────────────────────────────────────────────
  // GET /api/Analytics/events
  // Response: { totalEvents, totalRegistrations, attendanceRate, byMode }
  Future<Map<String, dynamic>> getEventsAnalytics() => _get('events');

  // ─── 7. Interviews ───────────────────────────────────────────
  // GET /api/Analytics/interviews
  // Response: { totalInterviews, attendanceRate, hiringRate,
  //             completedCount, scheduledCount, completionRateOverTime }
  Future<Map<String, dynamic>> getInterviewsAnalytics() => _get('interviews');

  // ─── 8. Interviews Over Time ──────────────────────────────────
  // GET /api/Analytics/interviews/overtime
  Future<Map<String, dynamic>> getInterviewsOverTime() => _get('interviews/overtime');

  // ─── 9. Universities ─────────────────────────────────────────
  // GET /api/Analytics/universities
  // Response: { totalActivePartners, mostActiveCampus, newPartnerships }
  Future<Map<String, dynamic>> getUniversitiesAnalytics() => _get('universities');

  // ─── Fetch ALL in parallel ───────────────────────────────────
  Future<Map<String, dynamic>> fetchAllAnalytics() async {
    try {
      final results = await Future.wait([
        getDashboardOverview(),      // 0
        getRoadmapsAnalytics(),      // 1
        getJobsAnalytics(),          // 2
        getInternshipsAnalytics(),   // 3
        getWorkshopsAnalytics(),     // 4
        getEventsAnalytics(),        // 5
        getInterviewsAnalytics(),    // 6
        getInterviewsOverTime(),     // 7
        getUniversitiesAnalytics(),  // 8
      ]);

      return {
        'overview':      results[0],
        'roadmaps':      results[1],
        'jobs':          results[2],
        'internships':   results[3],
        'workshops':     results[4],
        'events':        results[5],
        'interviews':    results[6],
        'interviewsOT':  results[7],
        'universities':  results[8],
      };
    } catch (e) {
      debugPrint("❌ [FETCH ALL ANALYTICS ERROR]: $e");
      return {};
    }
  }
}