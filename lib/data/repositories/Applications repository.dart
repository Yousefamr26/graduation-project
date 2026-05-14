// ignore_for_file: avoid_print
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/company/application-model.dart';

class ApplicationsRepository {
  late final Dio _dio;
  static const String _serverBase = 'http://smartcareerhub.runasp.net';

  ApplicationsRepository() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(minutes: 5),
      receiveTimeout: const Duration(minutes: 10),
      sendTimeout:    const Duration(minutes: 10),
      headers: {'Accept': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('company_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          debugPrint('✅ [APPLICATIONS AUTH] Token: ${token.substring(0, 20)}...');
        } else {
          debugPrint('🛑 [APPLICATIONS AUTH] No company_token!');
        }
        debugPrint('📤 [APPLICATIONS] ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('📥 [APPLICATIONS] Status: ${response.statusCode}');
        debugPrint('📥 [APPLICATIONS] Data: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        debugPrint('🛑 [APPLICATIONS ERROR] ${e.response?.statusCode}: ${e.message}');
        return handler.next(e);
      },
    ));
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 1: جيب كل الـ Jobs الخاصة بالـ company
  // ─────────────────────────────────────────────────────────────
  Future<List<int>> _getCompanyJobIds() async {
    try {
      final response = await _dio.get(
        '$_serverBase/api/Jobs',
        options: Options(validateStatus: (s) => s! < 500),
      );

      debugPrint('📦 [JOBS LIST] Status: ${response.statusCode}');
      debugPrint('📦 [JOBS LIST] Data: ${response.data}');

      if (response.statusCode == 200) {
        List<dynamic> raw = [];
        if (response.data is List) {
          raw = response.data as List;
        } else if (response.data is Map) {
          raw = (response.data['data'] ?? response.data['items'] ?? []) as List;
        }

        final ids = raw
            .map((e) => int.tryParse((e['id'] ?? e['jobId'] ?? 0).toString()) ?? 0)
            .where((id) => id > 0)
            .toList();

        debugPrint('✅ [JOBS LIST] Found ${ids.length} job IDs: $ids');
        return ids;
      }
    } catch (e) {
      debugPrint('❌ [JOBS LIST] Error: $e');
    }
    return [];
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 2: جيب الـ applicants لكل job
  // GET /api/Jobs/{id}/applicants
  // ─────────────────────────────────────────────────────────────
  Future<List<ApplicationModel>> getApplicantsByJobId(int jobId) async {
    try {
      final endpoint = '$_serverBase/api/Jobs/$jobId/applicants';
      debugPrint('📤 [APPLICANTS] Fetching for jobId=$jobId');

      final response = await _dio.get(
        endpoint,
        options: Options(validateStatus: (s) => s! < 500),
      );

      debugPrint('📥 [APPLICANTS] Status: ${response.statusCode} ← $endpoint');
      debugPrint('📥 [APPLICANTS] Data: ${response.data}');

      if (response.statusCode == 200) {
        List<dynamic> raw = [];
        if (response.data is List) {
          raw = response.data as List;
        } else if (response.data is Map) {
          raw = (response.data['data']       ??
              response.data['applicants'] ??
              response.data['items']      ??
              []) as List;
        }

        debugPrint('✅ [APPLICANTS] Found ${raw.length} applicants for job $jobId');
        if (raw.isNotEmpty) {
          debugPrint('🔑 Keys: ${(raw[0] as Map).keys.toList()}');
          debugPrint('🔍 First: ${raw[0]}');
        }

        return raw.map((e) {
          final map = Map<String, dynamic>.from(e);
          // ✅ أضف الـ jobId للـ map عشان نعرف جاي من أنهي job
          map['_jobId'] = jobId;
          map['applicationType'] = 'Job'; // ✅ مهم للـ filter في الـ screen
          return ApplicationModel.fromJson(map);
        }).toList();
      }
    } catch (e) {
      debugPrint('❌ [APPLICANTS] Error for job $jobId: $e');
    }
    return [];
  }

  // ─────────────────────────────────────────────────────────────
  // GET ALL APPLICATIONS = كل الـ jobs × applicants كل job
  // ─────────────────────────────────────────────────────────────
  Future<List<ApplicationModel>> getMyApplications() async {
    try {
      // Step 1: جيب الـ job IDs
      final jobIds = await _getCompanyJobIds();

      if (jobIds.isEmpty) {
        debugPrint('⚠️ [APPLICATIONS] No jobs found — returning empty');
        return [];
      }

      // Step 2: جيب الـ applicants لكل job بالتوازي
      final futures = jobIds.map((id) => getApplicantsByJobId(id));
      final results = await Future.wait(futures);

      // Step 3: ادمج كل النتائج
      final allApplications = results.expand((list) => list).toList();

      debugPrint('✅ [APPLICATIONS] Total: ${allApplications.length} applicants across ${jobIds.length} jobs');
      return allApplications;
    } catch (e) {
      debugPrint('❌ [APPLICATIONS] getMyApplications error: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────
  // UPDATE STATUS — PATCH /api/Jobs/{id}/status
  // ─────────────────────────────────────────────────────────────
  Future<bool> updateApplicationStatus(int applicationId, String status) async {
    // ✅ PATCH من الـ Swagger
    final endpoints = [
      '$_serverBase/api/Jobs/$applicationId/status',
      '$_serverBase/api/Jobs/applicants/$applicationId/status',
    ];

    for (final endpoint in endpoints) {
      try {
        debugPrint('📤 [UPDATE STATUS] PATCH $endpoint | status=$status');

        final response = await _dio.patch(
          endpoint,
          data: {'status': status},
          options: Options(
            validateStatus: (s) => s! < 500,
            headers: {'Content-Type': 'application/json'},
          ),
        );

        debugPrint('📥 [UPDATE STATUS] ${response.statusCode}');

        if (response.statusCode == 200 || response.statusCode == 204) {
          debugPrint('✅ [UPDATE STATUS] Success!');
          return true;
        }
        if (response.statusCode == 404) continue;
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) continue;
        debugPrint('❌ [UPDATE STATUS] Error: ${e.message}');
      } catch (e) {
        debugPrint('❌ [UPDATE STATUS] Error: $e');
      }
    }
    return false;
  }
}