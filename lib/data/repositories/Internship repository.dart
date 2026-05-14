// ignore_for_file: avoid_print
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InternshipRepository {
  late Dio _dio;
  static const String _baseUrl = "http://smartcareerhub.runasp.net/api/internships";

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

  int _typeStringToInt(String type) {
    switch (type) {
      case "On-site 🏢": return 0;
      case "Remote 🌐":  return 1;
      case "Hybrid 🔄":  return 2;
      default:           return 0;
    }
  }

  String _typeIntToString(dynamic type) {
    switch (type.toString()) {
      case "0": return "On-site 🏢";
      case "1": return "Remote 🌐";
      case "2": return "Hybrid 🔄";
      default:  return "On-site 🏢";
    }
  }

  String _monthsToDurationString(dynamic months) {
    final m = int.tryParse(months.toString()) ?? 1;
    return m == 1 ? "1 month" : "$m months";
  }

  // ✅ FIX: status int → String
  String _statusIntToString(dynamic status) {
    switch (status.toString()) {
      case "0": return "Draft";
      case "1": return "Published";
      case "2": return "Closed";
      default:  return "Draft";
    }
  }

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
      return response;
    } catch (e) {
      debugPrint("❌ [CREATE INTERNSHIP ERROR]: $e");
      rethrow;
    }
  }

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
      return response;
    } catch (e) {
      debugPrint("❌ [UPDATE INTERNSHIP ERROR]: $e");
      rethrow;
    }
  }

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

        // ✅ FIX: API بيرجع { data: [...] } مش List مباشرة
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
            'type':     _typeIntToString(map['type']),
            'duration': _monthsToDurationString(map['durationInMonths'] ?? 1),
            'status':   _statusIntToString(map['status']),   // ✅ FIX
          };
        }).toList();
      }

      debugPrint("⚠️ getAllInternships unexpected status: ${response.statusCode}");
      return [];
    } catch (e) {
      debugPrint("❌ [GET ALL INTERNSHIPS ERROR]: $e");
      return [];
    }
  }

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
}