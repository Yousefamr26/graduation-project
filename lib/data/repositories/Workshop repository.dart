// ignore_for_file: avoid_print
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkshopRepository {
  late Dio _dio;
  static const String _baseUrl    = "http://smartcareerhub.runasp.net/api/Workshops";
  static const String _serverBase = "http://smartcareerhub.runasp.net";

  WorkshopRepository() {
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
        final token = prefs.getString('company_token');

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          debugPrint("✅ [AUTH] Token attached: ${token.substring(0, 20)}...");
        } else {
          debugPrint("🛑 [AUTH] No company token found — rejecting request");
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: 401,
                statusMessage: "Unauthorized: No company token found",
              ),
              type: DioExceptionType.badResponse,
            ),
          );
          return;
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

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────

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

  String _toSafeDateString(DateTime date) {
    final safeDate = DateTime(date.year, date.month, date.day, 12, 0, 0);
    return safeDate.toIso8601String();
  }

  Future<void> _addMaterialsToForm(
      FormData formData,
      List<Map<String, dynamic>> materials, {
        bool includeId = false,
      }) async {
    for (int i = 0; i < materials.length; i++) {
      final m            = materials[i];
      final materialType = m["type"] ?? "PDF";

      if (includeId && m["id"] != null)
        formData.fields.add(MapEntry("Materials[$i].Id", m["id"].toString()));

      formData.fields.addAll([
        MapEntry("Materials[$i].Title",  m["title"]  ?? ""),
        MapEntry("Materials[$i].Points", (m["points"] ?? 0).toString()),
        MapEntry("Materials[$i].Type",   materialType),
      ]);

      if (materialType == "PDF") {
        formData.fields.addAll([
          MapEntry("Materials[$i].TitlePdf",  m["titlePdf"] ?? m["title"] ?? ""),
          MapEntry("Materials[$i].PageCount", (m["pageCount"] ?? 1).toString()),
        ]);
      }

      if (materialType == "Video") {
        formData.fields.add(
          MapEntry("Materials[$i].Duration", (m["duration"] ?? 0).toString()),
        );
      }

      if (m["file"] != null && m["file"] is File) {
        final file = m["file"] as File;
        formData.files.add(MapEntry(
          "Materials[$i].FilePath",
          await MultipartFile.fromFile(
            file.path,
            filename:    file.path.split('/').last,
            contentType: DioMediaType.parse(_getMimeType(file.path)),
          ),
        ));
      }
    }
  }

  void _addActivitiesToForm(
      FormData formData,
      List<Map<String, dynamic>> activities, {
        bool includeId = false,
      }) {
    for (int i = 0; i < activities.length; i++) {
      final a = activities[i];

      if (includeId && a["id"] != null)
        formData.fields.add(MapEntry("Activities[$i].Id", a["id"].toString()));

      formData.fields.addAll([
        MapEntry("Activities[$i].Title",       a["title"]       ?? ""),
        MapEntry("Activities[$i].Name",        a["name"]        ?? ""),
        MapEntry("Activities[$i].Description", a["description"] ?? ""),
        MapEntry("Activities[$i].Points",      (a["points"] ?? 0).toString()),
        MapEntry("Activities[$i].Difficulty",  a["difficulty"]  ?? "Easy"),
      ]);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GET ALL
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllWorkshops() async {
    try {
      debugPrint("📤 [GET ALL WORKSHOPS] Fetching from: $_baseUrl");

      final response = await _dio.get(
        _baseUrl,
        options: Options(validateStatus: (status) => status! < 500),
      );

      debugPrint("📥 [GET ALL WORKSHOPS] Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> result = [];

        if (response.data is List) {
          result = List<Map<String, dynamic>>.from(response.data);
        } else if (response.data is Map && response.data['data'] != null) {
          result = List<Map<String, dynamic>>.from(response.data['data']);
        }

        return result.map((w) {
          final rawUrl   = w['banner'] ?? w['bannerUrl'] ?? w['coverImage'];
          final fixedUrl = _fixImageUrl(rawUrl);
          debugPrint("🖼️ [WORKSHOP BANNER] '${w['title']}' → $fixedUrl");
          return {...w, 'banner': fixedUrl};
        }).toList();
      }

      return [];
    } catch (e) {
      debugPrint("❌ Fetch Workshops Error: $e");
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CREATE
  // ─────────────────────────────────────────────────────────────────────────

  Future<Response?> createWorkshop({
    required String title,
    required String description,
    required String hostType,
    required String workshopType,
    required String location,
    required int    maxCapacity,
    required bool   requireCV,
    required bool   requireRoadmapCompletion,
    required bool   isPublished,
    int?    universityId,
    String? companyId,
    File?   banner,
    DateTime? startDate,
    DateTime? endDate,
    String?   startTime,
    String?   endTime,
    List<Map<String, dynamic>> materials  = const [],
    List<Map<String, dynamic>> activities = const [],
  }) async {
    try {
      final formData = FormData();

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
        if (companyId    != null) MapEntry("CompanyId",    companyId),
        if (startDate    != null) MapEntry("StartDate",    _toSafeDateString(startDate)),
        if (endDate      != null) MapEntry("EndDate",      _toSafeDateString(endDate)),
        if (startTime != null && startTime.isNotEmpty) MapEntry("StartTime", startTime),
        if (endTime   != null && endTime.isNotEmpty)   MapEntry("EndTime",   endTime),
      ]);

      if (banner != null && banner.existsSync()) {
        formData.files.add(MapEntry(
          "Banner",
          await MultipartFile.fromFile(
            banner.path,
            filename:    banner.path.split('/').last,
            contentType: DioMediaType.parse(_getMimeType(banner.path)),
          ),
        ));
      }

      await _addMaterialsToForm(formData, materials);
      _addActivitiesToForm(formData, activities);

      debugPrint("📤 [SENDING CREATE WORKSHOP] to: $_baseUrl");

      final response = await _dio.post(
        _baseUrl,
        data:    formData,
        options: Options(validateStatus: (status) => status! < 500),
      );

      debugPrint("✅ [CREATE WORKSHOP RESPONSE] Status: ${response.statusCode}");
      return response;
    } catch (e) {
      debugPrint("❌ [CRITICAL ERROR in createWorkshop]: $e");
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UPDATE
  // ─────────────────────────────────────────────────────────────────────────

  Future<Response?> updateWorkshop({
    required String workshopId,
    required String title,
    required String description,
    required String hostType,
    required String workshopType,
    required String location,
    required int    maxCapacity,
    required bool   requireCV,
    required bool   requireRoadmapCompletion,
    required bool   isPublished,
    int?    universityId,
    String? companyId,
    File?   banner,
    DateTime? startDate,
    DateTime? endDate,
    String?   startTime,
    String?   endTime,
    List<Map<String, dynamic>> materials  = const [],
    List<Map<String, dynamic>> activities = const [],
  }) async {
    try {
      final formData = FormData();

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
        if (companyId    != null) MapEntry("CompanyId",    companyId),
        if (startDate    != null) MapEntry("StartDate",    _toSafeDateString(startDate)),
        if (endDate      != null) MapEntry("EndDate",      _toSafeDateString(endDate)),
        if (startTime != null && startTime.isNotEmpty) MapEntry("StartTime", startTime),
        if (endTime   != null && endTime.isNotEmpty)   MapEntry("EndTime",   endTime),
      ]);

      if (banner != null && banner.existsSync()) {
        formData.files.add(MapEntry(
          "Banner",
          await MultipartFile.fromFile(
            banner.path,
            filename:    banner.path.split('/').last,
            contentType: DioMediaType.parse(_getMimeType(banner.path)),
          ),
        ));
      }

      await _addMaterialsToForm(formData, materials, includeId: true);
      _addActivitiesToForm(formData, activities, includeId: true);

      debugPrint("📤 [SENDING UPDATE WORKSHOP] to: $_baseUrl/$workshopId");

      return await _dio.put(
        "$_baseUrl/$workshopId",
        data:    formData,
        options: Options(validateStatus: (status) => status! < 500),
      );
    } catch (e) {
      debugPrint("❌ Update Workshop Error: $e");
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────────────────────────────────

  Future<Response?> deleteWorkshop(dynamic workshopId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('company_token');

      debugPrint("🗑️ [DELETE WORKSHOP] id: $workshopId");
      debugPrint("🔑 [DELETE WORKSHOP] token: ${token != null ? '${token.substring(0, 20)}...' : 'NULL ❌'}");

      if (token == null || token.isEmpty) {
        debugPrint("🛑 [DELETE WORKSHOP] Aborted — no company token found");
        return Response(
          requestOptions: RequestOptions(path: "$_baseUrl/$workshopId"),
          statusCode: 401,
          statusMessage: "Unauthorized: No company token found",
        );
      }

      final response = await _dio.delete(
        "$_baseUrl/${workshopId.toString()}",
        options: Options(
          validateStatus: (s) => s! < 500,
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      debugPrint("📥 [DELETE WORKSHOP] Status: ${response.statusCode}");
      debugPrint("📥 [DELETE WORKSHOP] Data: ${response.data}");
      return response;
    } catch (e) {
      debugPrint("❌ Delete Workshop Error: $e");
      rethrow;
    }
  }
}