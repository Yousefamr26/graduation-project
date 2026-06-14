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
      sendTimeout: const Duration(minutes: 10),
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
  // JOBS
  // ─────────────────────────────────────────────────────────────
  Future<List<int>> _getCompanyJobIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final companyName = prefs.getString('company_name') ?? '';

      debugPrint('🏢 [JOBS LIST] Filtering for companyName="$companyName"');

      final response = await _dio.get(
        '$_serverBase/api/Jobs',
        options: Options(validateStatus: (s) => s! < 500),
      );

      if (response.statusCode == 200) {
        List<dynamic> raw = [];
        if (response.data is List) {
          raw = response.data as List;
        } else if (response.data is Map) {
          raw = (response.data['data'] ??
              response.data['items'] ??
              response.data['jobs'] ??
              []) as List;
        }

        final filtered = companyName.isNotEmpty
            ? raw.where((e) {
          final name = (e['companyName'] ?? '').toString().toLowerCase();
          return name == companyName.toLowerCase();
        }).toList()
            : raw;

        final ids = filtered
            .map((e) =>
        int.tryParse((e['id'] ?? e['jobId'] ?? 0).toString()) ?? 0)
            .where((id) => id > 0)
            .toList();

        debugPrint('✅ [JOBS LIST] Total: ${raw.length} → Company jobs: ${ids.length} → IDs: $ids');
        return ids;
      }
    } catch (e) {
      debugPrint('❌ [JOBS LIST] Error: $e');
    }
    return [];
  }

  Future<List<ApplicationModel>> getApplicantsByJobId(int jobId) async {
    try {
      final response = await _dio.get(
        '$_serverBase/api/Jobs/$jobId/applicants',
        options: Options(validateStatus: (s) => s! < 500),
      );

      if (response.statusCode == 200) {
        List<dynamic> raw = [];
        if (response.data is List) {
          raw = response.data as List;
        } else if (response.data is Map) {
          raw = (response.data['data'] ??
              response.data['applicants'] ??
              response.data['items'] ??
              []) as List;
        }

        debugPrint('✅ [JOB APPLICANTS] Found ${raw.length} for job $jobId');
        if (raw.isNotEmpty) {
          debugPrint('🔑 Keys: ${(raw[0] as Map).keys.toList()}');
        }

        return raw.map((e) {
          final map = Map<String, dynamic>.from(e);
          map['_jobId'] = jobId;
          map['applicationType'] = 'Job';
          return ApplicationModel.fromJson(map);
        }).toList();
      }
    } catch (e) {
      debugPrint('❌ [JOB APPLICANTS] Error for job $jobId: $e');
    }
    return [];
  }

  // ─────────────────────────────────────────────────────────────
  // INTERNSHIPS
  // ─────────────────────────────────────────────────────────────
  Future<List<int>> _getCompanyInternshipIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final companyName = prefs.getString('company_name') ?? '';

      debugPrint('🏢 [INTERNSHIPS LIST] Filtering for companyName="$companyName"');

      final response = await _dio.get(
        '$_serverBase/api/Internships',
        options: Options(validateStatus: (s) => s! < 500),
      );

      if (response.statusCode == 200) {
        List<dynamic> raw = [];
        if (response.data is List) {
          raw = response.data as List;
        } else if (response.data is Map) {
          raw = (response.data['data'] ??
              response.data['items'] ??
              response.data['internships'] ??
              []) as List;
        }

        final filtered = companyName.isNotEmpty
            ? raw.where((e) {
          final name = (e['companyName'] ?? '').toString().toLowerCase();
          return name == companyName.toLowerCase();
        }).toList()
            : raw;

        final ids = filtered
            .map((e) =>
        int.tryParse((e['id'] ?? e['internshipId'] ?? 0).toString()) ?? 0)
            .where((id) => id > 0)
            .toList();

        debugPrint('✅ [INTERNSHIPS LIST] Total: ${raw.length} → Company internships: ${ids.length} → IDs: $ids');
        return ids;
      }
    } catch (e) {
      debugPrint('❌ [INTERNSHIPS LIST] Error: $e');
    }
    return [];
  }

  Future<List<ApplicationModel>> getApplicantsByInternshipId(int internshipId) async {
    try {
      final response = await _dio.get(
        '$_serverBase/api/Internships/$internshipId/applicants',
        options: Options(validateStatus: (s) => s! < 500),
      );

      if (response.statusCode == 200) {
        List<dynamic> raw = [];
        if (response.data is List) {
          raw = response.data as List;
        } else if (response.data is Map) {
          raw = (response.data['data'] ??
              response.data['applicants'] ??
              response.data['items'] ??
              []) as List;
        }

        debugPrint('✅ [INTERNSHIP APPLICANTS] Found ${raw.length} for internship $internshipId');
        if (raw.isNotEmpty) {
          debugPrint('🔑 Keys: ${(raw[0] as Map).keys.toList()}');
        }

        return raw.map((e) {
          final map = Map<String, dynamic>.from(e);
          map['_internshipId'] = internshipId;
          map['applicationType'] = 'Internship';
          return ApplicationModel.fromJson(map);
        }).toList();
      }
    } catch (e) {
      debugPrint('❌ [INTERNSHIP APPLICANTS] Error for internship $internshipId: $e');
    }
    return [];
  }

  // ─────────────────────────────────────────────────────────────
  // GET ALL = Jobs + Internships
  // ─────────────────────────────────────────────────────────────
  Future<List<ApplicationModel>> getMyApplications() async {
    try {
      final jobIds        = await _getCompanyJobIds();
      final internshipIds = await _getCompanyInternshipIds();

      final futures = [
        ...jobIds.map((id) => getApplicantsByJobId(id)),
        ...internshipIds.map((id) => getApplicantsByInternshipId(id)),
      ];

      final results         = await Future.wait(futures);
      final allApplications = results.expand((list) => list).toList();

      debugPrint('✅ [APPLICATIONS] Total: ${allApplications.length} '
          '(${jobIds.length} jobs + ${internshipIds.length} internships)');
      return allApplications;
    } catch (e) {
      debugPrint('❌ [APPLICATIONS] getMyApplications error: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────
  // UPDATE STATUS
  // بيحدد تلقائياً Jobs أو Internships حسب الـ applicationType
  // ─────────────────────────────────────────────────────────────
  Future<bool> updateApplicationStatus(
      int id, int applicationId, String status,
      {bool isInternship = false}) async {
    final type     = isInternship ? 'Internships' : 'Jobs';
    final endpoint = '$_serverBase/api/$type/$id/applicants/$applicationId/status';

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

      debugPrint('⚠️ [UPDATE STATUS] Unexpected: ${response.statusCode}');
      return false;
    } on DioException catch (e) {
      debugPrint('❌ [UPDATE STATUS] DioException: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('❌ [UPDATE STATUS] Error: $e');
      return false;
    }
  }
}