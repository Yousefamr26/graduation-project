// ignore_for_file: avoid_print
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JobRepository {
  late Dio _dio;
  static const String _baseUrl = "http://smartcareerhub.runasp.net/api/Jobs";
  static const String _serverBase = "http://smartcareerhub.runasp.net";

  JobRepository() {
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

  String? _fixImageUrl(dynamic imageUrl) {
    if (imageUrl == null) return null;
    final url = imageUrl.toString().trim();
    if (url.isEmpty || url.toLowerCase() == 'null') return null;
    final cleanUrl = url.replaceAll('\\', '/');
    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      debugPrint("🖼️ [LOGO URL] Already full URL: $cleanUrl");
      return cleanUrl;
    }
    final fixedUrl = cleanUrl.startsWith('/')
        ? "$_serverBase$cleanUrl"
        : "$_serverBase/$cleanUrl";
    debugPrint("🖼️ [LOGO URL] Fixed: $url → $fixedUrl");
    return fixedUrl;
  }

  String _getMimeType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    if (['png', 'jpg', 'jpeg', 'webp'].contains(extension)) return 'image/jpeg';
    if (extension == 'pdf') return 'application/pdf';
    return 'image/jpeg';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CREATE
  // ─────────────────────────────────────────────────────────────────────────

  Future<Response?> createJob({
    required String title,
    required String description,
    required String requiredSkills,
    required String experienceLevel,
    required String jobType,      // ✅ "Remote" | "On-site" | "Hybrid"
    required String location,     // ✅ اسم المدينة فقط أو فاضي لو Remote
    required String salaryRange,
    File? companyLogo,
  }) async {
    try {
      FormData formData = FormData();
      debugPrint("🚀 [CREATE JOB] Building FormData...");

      formData.fields.addAll([
        MapEntry("Title", title),
        MapEntry("Description", description),
        MapEntry("RequiredSkills", requiredSkills),
        MapEntry("ExperienceLevel", experienceLevel),
        MapEntry("JobType", jobType),      // ✅ "Remote" | "On-site" | "Hybrid"
        MapEntry("Location", location),    // ✅ اسم المدينة
        MapEntry("SalaryRange", salaryRange),
      ]);

      if (companyLogo != null && companyLogo.existsSync()) {
        formData.files.add(MapEntry(
          "CompanyLogo",
          await MultipartFile.fromFile(
            companyLogo.path,
            filename: companyLogo.path.split('/').last,
            contentType: DioMediaType.parse(_getMimeType(companyLogo.path)),
          ),
        ));
        debugPrint("🖼️ [LOGO] Attached: ${companyLogo.path}");
      }

      debugPrint("📤 [SENDING CREATE JOB] to: $_baseUrl");
      debugPrint("📤 [JobType]: $jobType | [Location]: $location");

      final response = await _dio.post(
        _baseUrl,
        data: formData,
        options: Options(validateStatus: (status) => status! < 500),
      );

      debugPrint("✅ [CREATE JOB RESPONSE] Status: ${response.statusCode}");
      debugPrint("✅ [CREATE JOB DATA]: ${response.data}");

      return response;
    } catch (e) {
      debugPrint("❌ [CRITICAL ERROR in createJob]: $e");
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UPDATE
  // ─────────────────────────────────────────────────────────────────────────

  Future<Response?> updateJob({
    required String jobId,
    required String title,
    required String description,
    required String requiredSkills,
    required String experienceLevel,
    required String jobType,      // ✅ "Remote" | "On-site" | "Hybrid"
    required String location,     // ✅ اسم المدينة فقط
    required String salaryRange,
    File? companyLogo,
  }) async {
    try {
      FormData formData = FormData();

      formData.fields.addAll([
        MapEntry("Title", title),
        MapEntry("Description", description),
        MapEntry("RequiredSkills", requiredSkills),
        MapEntry("ExperienceLevel", experienceLevel),
        MapEntry("JobType", jobType),      // ✅ "Remote" | "On-site" | "Hybrid"
        MapEntry("Location", location),    // ✅ اسم المدينة
        MapEntry("SalaryRange", salaryRange),
      ]);

      if (companyLogo != null && companyLogo.existsSync()) {
        formData.files.add(MapEntry(
          "CompanyLogo",
          await MultipartFile.fromFile(
            companyLogo.path,
            filename: companyLogo.path.split('/').last,
            contentType: DioMediaType.parse(_getMimeType(companyLogo.path)),
          ),
        ));
      }

      debugPrint("📤 [SENDING UPDATE JOB] to: $_baseUrl/$jobId");
      debugPrint("📤 [JobType]: $jobType | [Location]: $location");

      return await _dio.put(
        "$_baseUrl/$jobId",
        data: formData,
        options: Options(validateStatus: (status) => status! < 500),
      );
    } catch (e) {
      debugPrint("❌ Update Job Error: $e");
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GET ALL
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllJobs() async {

    try {
      debugPrint("📤 [GET ALL JOBS] Fetching from: $_baseUrl");

      final response = await _dio.get(
        _baseUrl,
        options: Options(validateStatus: (status) => status! < 500),
      );

      debugPrint("📥 [GET ALL JOBS] Status: ${response.statusCode}");
      debugPrint("📥 [GET ALL JOBS] Data: ${response.data}");

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> result = [];

        if (response.data is List) {
          result = List<Map<String, dynamic>>.from(response.data);
        } else if (response.data is Map && response.data['data'] != null) {
          result = List<Map<String, dynamic>>.from(response.data['data']);
        }

        for (var j in result) {
          debugPrint("🔍 [RAW] companyLogo: '${j['companyLogo']}' | logoUrl: '${j['logoUrl']}'");
        }

        return result.map((job) {
          final rawUrl = job['companyLogo'] ?? job['logoUrl'] ?? job['logo'];
          final fixedUrl = _fixImageUrl(rawUrl);
          debugPrint("🖼️ [JOB LOGO] '${job['title']}' → Fixed URL: $fixedUrl");
          return {
            ...job,
            'companyLogo': fixedUrl,
          };
        }).toList();
      }

      debugPrint("⚠️ getAllJobs unexpected status: ${response.statusCode}");
      return [];
    } catch (e) {
      debugPrint("❌ Fetch Jobs Error: $e");
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────────────────────────────────

  Future<Response?> deleteJob(dynamic jobId) async {
    try {
      debugPrint("🗑️ [DELETE JOB] Deleting: $jobId");
      return await _dio.delete(
        "$_baseUrl/${jobId.toString()}",
        options: Options(validateStatus: (status) => status! < 500),
      );
    } catch (e) {
      debugPrint("❌ Delete Job Error: $e");
      rethrow;
    }
  }
}