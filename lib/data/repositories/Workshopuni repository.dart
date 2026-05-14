// ignore_for_file: avoid_print
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkshopUniRepository {
  late Dio _dio;
  static const String _baseUrl    = "http://smartcareerhub.runasp.net/api/Workshops";
  static const String _serverBase = "http://smartcareerhub.runasp.net";

  WorkshopUniRepository() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 10),
        sendTimeout:    const Duration(minutes: 10),
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('university_token')
            ?? prefs.getString('company_token');
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
    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) return cleanUrl;
    return cleanUrl.startsWith('/') ? "$_serverBase$cleanUrl" : "$_serverBase/$cleanUrl";
  }

  String _getMimeType(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    if (['mp4', 'avi', 'mov', 'mkv'].contains(ext)) return 'video/mp4';
    if (ext == 'pdf') return 'application/pdf';
    return 'image/jpeg';
  }

  String _toSafeDateString(DateTime date) =>
      DateTime(date.year, date.month, date.day, 12, 0, 0).toIso8601String();

  // ─── CREATE ───────────────────────────────────────────────────
  Future<Response?> createWorkshop({
    required String title,
    required String description,
    required String hostType,
    required String workshopType,
    required String location,
    required int maxCapacity,
    required bool requireCV,
    required bool requireRoadmapCompletion,
    required bool isPublished,
    int? universityId,
    String? companyId,
    File? banner,
    List<Map<String, dynamic>> materials  = const [],
    List<Map<String, dynamic>> activities = const [],
  }) async {
    try {
      FormData formData = FormData();
      formData.fields.addAll([
        MapEntry("Title",                    title),
        MapEntry("Description",              description),
        MapEntry("HostType",                 hostType),
        MapEntry("WorkshopType",             workshopType),
        MapEntry("Location",                 location),
        MapEntry("MaxCapacity",              maxCapacity.toString()),
        MapEntry("RequireCV",                requireCV.toString()),
        MapEntry("RequireRoadmapCompletion", requireRoadmapCompletion.toString()),
        MapEntry("IsPublished",              isPublished.toString()),
        if (universityId != null) MapEntry("UniversityId", universityId.toString()),
        if (companyId != null)    MapEntry("CompanyId",    companyId),
      ]);
      if (banner != null && banner.existsSync()) {
        formData.files.add(MapEntry("Banner",
            await MultipartFile.fromFile(banner.path,
                filename: banner.path.split('/').last,
                contentType: DioMediaType.parse(_getMimeType(banner.path)))));
      }
      for (int i = 0; i < materials.length; i++) {
        final m = materials[i];
        formData.fields.addAll([
          MapEntry("Materials[$i].Title",  m["title"] ?? ""),
          MapEntry("Materials[$i].Points", (m["points"] ?? 0).toString()),
        ]);
        if (m["file"] != null && m["file"] is File) {
          final file = m["file"] as File;
          formData.files.add(MapEntry("Materials[$i].FilePath",
              await MultipartFile.fromFile(file.path,
                  filename: file.path.split('/').last,
                  contentType: DioMediaType.parse(_getMimeType(file.path)))));
        }
      }
      for (int i = 0; i < activities.length; i++) {
        final a = activities[i];
        formData.fields.addAll([
          MapEntry("Activities[$i].Title",       a["title"] ?? ""),
          MapEntry("Activities[$i].Description", a["description"] ?? ""),
          MapEntry("Activities[$i].Points",      (a["points"] ?? 0).toString()),
        ]);
      }
      final response = await _dio.post(_baseUrl,
          data: formData, options: Options(validateStatus: (status) => status! < 500));
      debugPrint("✅ [CREATE WORKSHOP RESPONSE] Status: ${response.statusCode}");
      return response;
    } catch (e) {
      debugPrint("❌ [CRITICAL ERROR in createWorkshop]: $e");
      rethrow;
    }
  }

  // ─── UPDATE ───────────────────────────────────────────────────
  Future<Response?> updateWorkshop({
    required String workshopId,
    required String title,
    required String description,
    required String hostType,
    required String workshopType,
    required String location,
    required int maxCapacity,
    required bool requireCV,
    required bool requireRoadmapCompletion,
    required bool isPublished,
    int? universityId,
    String? companyId,
    File? banner,
    List<Map<String, dynamic>> materials  = const [],
    List<Map<String, dynamic>> activities = const [],
  }) async {
    try {
      FormData formData = FormData();
      formData.fields.addAll([
        MapEntry("Title",                    title),
        MapEntry("Description",              description),
        MapEntry("HostType",                 hostType),
        MapEntry("WorkshopType",             workshopType),
        MapEntry("Location",                 location),
        MapEntry("MaxCapacity",              maxCapacity.toString()),
        MapEntry("RequireCV",                requireCV.toString()),
        MapEntry("RequireRoadmapCompletion", requireRoadmapCompletion.toString()),
        MapEntry("IsPublished",              isPublished.toString()),
        if (universityId != null) MapEntry("UniversityId", universityId.toString()),
        if (companyId != null)    MapEntry("CompanyId",    companyId),
      ]);
      if (banner != null && banner.existsSync()) {
        formData.files.add(MapEntry("Banner",
            await MultipartFile.fromFile(banner.path,
                filename: banner.path.split('/').last,
                contentType: DioMediaType.parse(_getMimeType(banner.path)))));
      }
      for (int i = 0; i < materials.length; i++) {
        final m = materials[i];
        if (m["id"] != null) formData.fields.add(MapEntry("Materials[$i].Id", m["id"].toString()));
        formData.fields.addAll([
          MapEntry("Materials[$i].Title",  m["title"] ?? ""),
          MapEntry("Materials[$i].Points", (m["points"] ?? 0).toString()),
        ]);
        if (m["file"] != null && m["file"] is File) {
          final file = m["file"] as File;
          formData.files.add(MapEntry("Materials[$i].FilePath",
              await MultipartFile.fromFile(file.path,
                  filename: file.path.split('/').last,
                  contentType: DioMediaType.parse(_getMimeType(file.path)))));
        }
      }
      for (int i = 0; i < activities.length; i++) {
        final a = activities[i];
        if (a["id"] != null) formData.fields.add(MapEntry("Activities[$i].Id", a["id"].toString()));
        formData.fields.addAll([
          MapEntry("Activities[$i].Title",       a["title"] ?? ""),
          MapEntry("Activities[$i].Description", a["description"] ?? ""),
          MapEntry("Activities[$i].Points",      (a["points"] ?? 0).toString()),
        ]);
      }
      return await _dio.put("$_baseUrl/$workshopId",
          data: formData, options: Options(validateStatus: (status) => status! < 500));
    } catch (e) {
      debugPrint("❌ Update Workshop Error: $e");
      rethrow;
    }
  }

  // ─── GET ALL ──────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getAllWorkshops() async {
    try {
      final response = await _dio.get(_baseUrl,
          options: Options(validateStatus: (status) => status! < 500));
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> result = [];
        if (response.data is List) {
          result = List<Map<String, dynamic>>.from(response.data);
        } else if (response.data is Map && response.data['data'] != null) {
          result = List<Map<String, dynamic>>.from(response.data['data']);
        }
        return result.map((w) {
          final rawUrl = w['banner'] ?? w['bannerUrl'] ?? w['coverImage'];
          final fixedUrl = _fixImageUrl(rawUrl);
          return {...w, 'banner': fixedUrl};
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint("❌ Fetch Workshops Error: $e");
      return [];
    }
  }

  // ─── DELETE ───────────────────────────────────────────────────
  Future<Response?> deleteWorkshop(dynamic workshopId) async {
    try {
      return await _dio.delete("$_baseUrl/${workshopId.toString()}",
          options: Options(validateStatus: (status) => status! < 500));
    } catch (e) {
      debugPrint("❌ Delete Workshop Error: $e");
      rethrow;
    }
  }
}