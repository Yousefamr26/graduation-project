// ignore_for_file: avoid_print
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InternshipRepository {
  late Dio _dio;
  static const String _baseUrl =
      "http://smartcareerhub.runasp.net/api/internships";

  InternshipRepository() {
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

  // ── Converters ───────────────────────────────────────────

  int _typeStringToInt(String type) {
    switch (type) {
      case "On-site 🏢":
        return 0;
      case "Remote 🌐":
        return 1;
      case "Hybrid 🔄":
        return 2;
      default:
        return 0;
    }
  }

  String _typeIntToString(dynamic type) {
    switch (type.toString()) {
      case "0":
        return "On-site 🏢";
      case "1":
        return "Remote 🌐";
      case "2":
        return "Hybrid 🔄";
      default:
        return "On-site 🏢";
    }
  }

  String _monthsToDurationString(dynamic months) {
    final m = int.tryParse(months.toString()) ?? 1;
    return m == 1 ? "1 month" : "$m months";
  }

  String _statusIntToString(dynamic status) {
    switch (status.toString()) {
      case "0":
        return "Published";
      case "1":
        return "Closed";
      default:
        return "Published";
    }
  }

  // ── Create ───────────────────────────────────────────────

  Future<Response?> createInternship({
    required String title,
    required String type,
    required bool isPaid,
    required int maxTrainees,
    required int durationInMonths,
    required DateTime applicationDeadline,
    required String location,
    required String description,
    required List<String> requiredSkills,
    required List<String> requirements,
  }) async {
    try {
      final body = {
        "title": title,
        "type": _typeStringToInt(type),
        "isPaid": isPaid,
        "maxTrainees": maxTrainees,
        "durationInMonths": durationInMonths,
        "applicationDeadline": applicationDeadline.toIso8601String(),
        "location": location,
        "description": description,
        "requiredSkills": requiredSkills,
        "requirements": requirements,
        // ✅ status مشيل — الـ API مش بيقبله في create
      };
      debugPrint("📤 [CREATE INTERNSHIP] body: $body");
      final response = await _dio.post(
        _baseUrl,
        data: body,
        options: Options(
          validateStatus: (status) => status! < 500,
          contentType: 'application/json',
        ),
      );
      debugPrint("✅ [CREATE INTERNSHIP] Status: ${response.statusCode}");
      debugPrint("✅ [CREATE INTERNSHIP] Data: ${response.data}");
      return response;
    } catch (e) {
      debugPrint("❌ [CREATE INTERNSHIP ERROR]: $e");
      rethrow;
    }
  }

  // ── Update ───────────────────────────────────────────────

  Future<Response?> updateInternship({
    required dynamic internshipId,
    required String title,
    required String type,
    required bool isPaid,
    required int maxTrainees,
    required int durationInMonths,
    required DateTime applicationDeadline,
    required String location,
    required String description,
    required List<String> requiredSkills,
    required List<String> requirements,
  }) async {
    try {
      final body = {
        "title": title,
        "type": _typeStringToInt(type),
        "isPaid": isPaid,
        "maxTrainees": maxTrainees,
        "durationInMonths": durationInMonths,
        "applicationDeadline": applicationDeadline.toIso8601String(),
        "location": location,
        "description": description,
        "requiredSkills": requiredSkills,
        "requirements": requirements,
        // ✅ status مشيل — الـ API مش بيقبله في update
      };
      debugPrint("📤 [UPDATE INTERNSHIP] id=$internshipId body: $body");
      final response = await _dio.put(
        "$_baseUrl/$internshipId",
        data: body,
        options: Options(
          validateStatus: (status) => status! < 500,
          contentType: 'application/json',
        ),
      );
      debugPrint("✅ [UPDATE INTERNSHIP] Status: ${response.statusCode}");
      debugPrint("✅ [UPDATE INTERNSHIP] Data: ${response.data}");
      return response;
    } catch (e) {
      debugPrint("❌ [UPDATE INTERNSHIP ERROR]: $e");
      rethrow;
    }
  }

  // ── Get All ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllInternships() async {
    try {
      debugPrint("📤 [GET ALL INTERNSHIPS] Fetching from: $_baseUrl");
      final response = await _dio.get(
        _baseUrl,
        options: Options(validateStatus: (status) => status! < 500),
      );
      debugPrint("📥 [GET ALL INTERNSHIPS] Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        List<dynamic> rawList = [];
        if (response.data is List) {
          rawList = response.data as List;
        } else if (response.data is Map && response.data['data'] != null) {
          rawList = response.data['data'] as List;
        }

        debugPrint("📥 [GET ALL INTERNSHIPS] Found ${rawList.length} items");

        return rawList.map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          return {
            ...map,
            'type': _typeIntToString(map['type']),
            'duration': _monthsToDurationString(map['durationInMonths'] ?? 1),
            'status': _statusIntToString(map['status']),
          };
        }).toList();
      }

      debugPrint(
          "⚠️ getAllInternships unexpected status: ${response.statusCode}");
      return [];
    } catch (e) {
      debugPrint("❌ [GET ALL INTERNSHIPS ERROR]: $e");
      return [];
    }
  }

  // ── Delete ───────────────────────────────────────────────

  Future<Response?> deleteInternship(dynamic internshipId) async {
    try {
      debugPrint("🗑️ [DELETE INTERNSHIP] id=$internshipId");
      return await _dio.delete(
        "$_baseUrl/${internshipId.toString()}",
        options: Options(validateStatus: (status) => status! < 500),
      );
    } catch (e) {
      debugPrint("❌ [DELETE INTERNSHIP ERROR]: $e");
      rethrow;
    }
  }

  // ── Apply ────────────────────────────────────────────────

  Future<Response?> applyToInternship(dynamic internshipId) async {
    try {
      debugPrint("📤 [APPLY] internshipId=$internshipId");
      final response = await _dio.post(
        "$_baseUrl/$internshipId/apply",
        options: Options(
          validateStatus: (status) => status! < 500,
          contentType: 'application/json',
        ),
      );
      debugPrint("✅ [APPLY] Status: ${response.statusCode}");
      return response;
    } catch (e) {
      debugPrint("❌ [APPLY ERROR]: $e");
      rethrow;
    }
  }

  // ── Get Applicants ───────────────────────────────────────

  Future<List<Map<String, dynamic>>> getApplicants(
      dynamic internshipId) async {
    try {
      debugPrint("📤 [GET APPLICANTS] internshipId=$internshipId");
      final response = await _dio.get(
        "$_baseUrl/$internshipId/applicants",
        options: Options(validateStatus: (status) => status! < 500),
      );
      debugPrint("📥 [GET APPLICANTS] Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        List<dynamic> rawList = [];
        if (response.data is List) {
          rawList = response.data as List;
        } else if (response.data is Map && response.data['data'] != null) {
          rawList = response.data['data'] as List;
        }
        return rawList
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("❌ [GET APPLICANTS ERROR]: $e");
      return [];
    }
  }

  // ── Update Applicant Status ──────────────────────────────

  Future<Response?> updateApplicantStatus({
    required dynamic internshipId,
    required dynamic applicationId,
    required int status,
  }) async {
    try {
      debugPrint(
          "📤 [UPDATE APPLICANT STATUS] internshipId=$internshipId applicationId=$applicationId status=$status");
      final response = await _dio.patch(
        "$_baseUrl/$internshipId/applicants/$applicationId/status",
        data: {"status": status},
        options: Options(
          validateStatus: (s) => s! < 500,
          contentType: 'application/json',
        ),
      );
      debugPrint(
          "✅ [UPDATE APPLICANT STATUS] Status: ${response.statusCode}");
      return response;
    } catch (e) {
      debugPrint("❌ [UPDATE APPLICANT STATUS ERROR]: $e");
      rethrow;
    }
  }

  // ── My Applications (Trainee) ────────────────────────────

  Future<List<Map<String, dynamic>>> getMyApplications() async {
    try {
      debugPrint("📤 [GET MY APPLICATIONS]");
      final response = await _dio.get(
        "$_baseUrl/my-applications",
        options: Options(validateStatus: (status) => status! < 500),
      );
      debugPrint("📥 [GET MY APPLICATIONS] Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        List<dynamic> rawList = [];
        if (response.data is List) {
          rawList = response.data as List;
        } else if (response.data is Map && response.data['data'] != null) {
          rawList = response.data['data'] as List;
        }
        return rawList
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("❌ [GET MY APPLICATIONS ERROR]: $e");
      return [];
    }
  }

  // ── Withdraw Application ─────────────────────────────────

  Future<Response?> withdrawApplication(dynamic applicationId) async {
    try {
      debugPrint("📤 [WITHDRAW APPLICATION] applicationId=$applicationId");
      final response = await _dio.delete(
        "$_baseUrl/applications/$applicationId/withdraw",
        options: Options(validateStatus: (status) => status! < 500),
      );
      debugPrint("✅ [WITHDRAW APPLICATION] Status: ${response.statusCode}");
      return response;
    } catch (e) {
      debugPrint("❌ [WITHDRAW APPLICATION ERROR]: $e");
      rethrow;
    }
  }

  // ── Search ───────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> searchInternships(String query) async {
    try {
      debugPrint("📤 [SEARCH INTERNSHIPS] query=$query");
      final response = await _dio.get(
        "$_baseUrl/search",
        queryParameters: {"q": query},
        options: Options(validateStatus: (status) => status! < 500),
      );
      debugPrint("📥 [SEARCH INTERNSHIPS] Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        List<dynamic> rawList = [];
        if (response.data is List) {
          rawList = response.data as List;
        } else if (response.data is Map && response.data['data'] != null) {
          rawList = response.data['data'] as List;
        }
        return rawList.map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          return {
            ...map,
            'type': _typeIntToString(map['type']),
            'duration': _monthsToDurationString(map['durationInMonths'] ?? 1),
            'status': _statusIntToString(map['status']),
          };
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint("❌ [SEARCH INTERNSHIPS ERROR]: $e");
      return [];
    }
  }
}