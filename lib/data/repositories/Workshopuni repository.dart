// ignore_for_file: avoid_print
import 'dart:convert';
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
        final token = prefs.getString('university_token');

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          debugPrint("✅ [AUTH] Token attached: ${token.substring(0, 20)}...");
        } else {
          debugPrint("🛑 [AUTH] No university token found — rejecting request");
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: 401,
                statusMessage: "Unauthorized: No university token found",
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

  Future<int?> _getMyUniversityId() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString('university_user_data') ?? prefs.getString('user_data');
    if (rawData != null) {
      try {
        final data = jsonDecode(rawData) as Map<String, dynamic>;
        final id = data['id'];
        if (id != null) return int.tryParse(id.toString());
      } catch (_) {}
    }
    final directId = prefs.getString('university_id') ?? prefs.getInt('university_id')?.toString();
    if (directId != null) return int.tryParse(directId);
    return null;
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

  String _toSafeDateString(DateTime date) {
    final safeDate = DateTime(date.year, date.month, date.day, 12, 0, 0);
    return safeDate.toIso8601String();
  }

  Map<String, dynamic> _fixWorkshopBanner(Map<String, dynamic> w) {
    final rawUrl   = w['banner'] ?? w['bannerUrl'] ?? w['coverImage'];
    final fixedUrl = _fixImageUrl(rawUrl);
    debugPrint("🖼️ [WORKSHOP BANNER] '${w['title']}' → $fixedUrl");
    return {...w, 'banner': fixedUrl};
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
  // ✅ GET ALL — بيجيب بس الـ workshops بتاعة جامعتك عن طريق /my-workshops
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllWorkshops() async {
    try {
      // ✅ استخدم /my-workshops بدل / — بيرجع بس اللي بتاعك وبيسمح بالحذف
      debugPrint("📤 [GET MY WORKSHOPS] Fetching from: $_baseUrl/my-workshops");

      final response = await _dio.get(
        "$_baseUrl/my-workshops",
        options: Options(validateStatus: (status) => status! < 500),
      );

      debugPrint("📥 [GET MY WORKSHOPS] Status: ${response.statusCode}");

      // لو /my-workshops مش شغال، ارجع للـ fallback مع filter
      if (response.statusCode == 404 || response.statusCode == 405) {
        debugPrint("⚠️ /my-workshops not found, falling back to GET all + filter");
        return await _getAllWithFilter();
      }

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> result = [];

        if (response.data is List) {
          result = List<Map<String, dynamic>>.from(response.data);
        } else if (response.data is Map && response.data['data'] != null) {
          result = List<Map<String, dynamic>>.from(response.data['data']);
        }

        debugPrint("✅ [MY WORKSHOPS] Got ${result.length} workshops");
        return result.map(_fixWorkshopBanner).toList();
      }

      return [];
    } catch (e) {
      debugPrint("❌ getAllWorkshops Error: $e");
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Fallback: GET all + filter by universityId
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> _getAllWithFilter() async {
    try {
      final myId = await _getMyUniversityId();
      debugPrint("🏫 [FALLBACK] universityId = $myId");

      final response = await _dio.get(
        _baseUrl,
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> result = [];

        if (response.data is List) {
          result = List<Map<String, dynamic>>.from(response.data);
        } else if (response.data is Map && response.data['data'] != null) {
          result = List<Map<String, dynamic>>.from(response.data['data']);
        }

        if (myId != null) {
          result = result.where((w) {
            final wUniId = w['universityId'] ?? w['UniversityId'] ?? w['university_id'];
            return wUniId != null && int.tryParse(wUniId.toString()) == myId;
          }).toList();
          debugPrint("✅ [FILTER] Kept ${result.length} workshops for universityId=$myId");
        }

        return result.map(_fixWorkshopBanner).toList();
      }

      return [];
    } catch (e) {
      debugPrint("❌ _getAllWithFilter Error: $e");
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GET BY ID
  // ─────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getWorkshopById(String workshopId) async {
    try {
      debugPrint("📤 [GET WORKSHOP BY ID] $workshopId");

      final response = await _dio.get(
        "$_baseUrl/$workshopId",
        options: Options(validateStatus: (status) => status! < 500),
      );

      debugPrint("📥 [GET WORKSHOP BY ID] Status: ${response.statusCode}");

      if (response.statusCode == 200 && response.data != null) {
        return _fixWorkshopBanner(Map<String, dynamic>.from(response.data));
      }

      return null;
    } catch (e) {
      debugPrint("❌ Get Workshop By ID Error: $e");
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SEARCH
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> searchWorkshops({
    String?   query,
    String?   workshopType,
    String?   hostType,
    String?   location,
    bool?     isPublished,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (query        != null && query.isNotEmpty)        queryParams['query']        = query;
      if (workshopType != null && workshopType.isNotEmpty) queryParams['workshopType'] = workshopType;
      if (hostType     != null && hostType.isNotEmpty)     queryParams['hostType']     = hostType;
      if (location     != null && location.isNotEmpty)     queryParams['location']     = location;
      if (isPublished  != null) queryParams['isPublished'] = isPublished.toString();
      if (startDate    != null) queryParams['startDate']   = _toSafeDateString(startDate);
      if (endDate      != null) queryParams['endDate']     = _toSafeDateString(endDate);

      debugPrint("📤 [SEARCH WORKSHOPS] params: $queryParams");

      final response = await _dio.get(
        "$_baseUrl/search",
        queryParameters: queryParams,
        options: Options(validateStatus: (status) => status! < 500),
      );

      debugPrint("📥 [SEARCH WORKSHOPS] Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> result = [];

        if (response.data is List) {
          result = List<Map<String, dynamic>>.from(response.data);
        } else if (response.data is Map && response.data['data'] != null) {
          result = List<Map<String, dynamic>>.from(response.data['data']);
        }

        // فلتر في الـ search كمان
        final myId = await _getMyUniversityId();
        if (myId != null) {
          result = result.where((w) {
            final wUniId = w['universityId'] ?? w['UniversityId'] ?? w['university_id'];
            return wUniId != null && int.tryParse(wUniId.toString()) == myId;
          }).toList();
        }

        return result.map(_fixWorkshopBanner).toList();
      }

      return [];
    } catch (e) {
      debugPrint("❌ Search Workshops Error: $e");
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
      universityId ??= await _getMyUniversityId();

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
      universityId ??= await _getMyUniversityId();

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
  // ✅ DELETE — الـ server بيتحقق من ownership عن طريق الـ JWT token تلقائياً
  // ─────────────────────────────────────────────────────────────────────────

  Future<Response?> deleteWorkshop(dynamic workshopId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('university_token');

      debugPrint("🗑️ [DELETE WORKSHOP] id: $workshopId");
      debugPrint("🔑 [DELETE WORKSHOP] token: ${token != null ? '${token.substring(0, 20)}...' : 'NULL ❌'}");

      if (token == null || token.isEmpty) {
        debugPrint("🛑 [DELETE WORKSHOP] Aborted — no university token found");
        return Response(
          requestOptions: RequestOptions(path: "$_baseUrl/$workshopId"),
          statusCode: 401,
          statusMessage: "Unauthorized: No university token found",
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

  // ─────────────────────────────────────────────────────────────────────────
  // TOGGLE PUBLISH
  // ─────────────────────────────────────────────────────────────────────────

  Future<Response?> toggleWorkshopStatus(dynamic workshopId) async {
    try {
      debugPrint("📤 [TOGGLE WORKSHOP STATUS] id: $workshopId");

      final response = await _dio.patch(
        "$_baseUrl/toggle/${workshopId.toString()}",
        options: Options(validateStatus: (status) => status! < 500),
      );

      debugPrint("📥 [TOGGLE WORKSHOP STATUS] Status: ${response.statusCode}");
      return response;
    } catch (e) {
      debugPrint("❌ Toggle Workshop Status Error: $e");
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BULK STATUS
  // ─────────────────────────────────────────────────────────────────────────

  Future<Response?> bulkUpdateStatus({
    required List<dynamic> workshopIds,
    required bool          isPublished,
  }) async {
    try {
      debugPrint("📤 [BULK STATUS UPDATE] ids: $workshopIds → isPublished: $isPublished");

      final response = await _dio.patch(
        "$_baseUrl/bulkstatus",
        data: {"ids": workshopIds, "isPublished": isPublished},
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status! < 500,
        ),
      );

      debugPrint("📥 [BULK STATUS UPDATE] Status: ${response.statusCode}");
      return response;
    } catch (e) {
      debugPrint("❌ Bulk Status Update Error: $e");
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BULK DELETE
  // ─────────────────────────────────────────────────────────────────────────

  Future<Response?> bulkDeleteWorkshops({
    required List<dynamic> workshopIds,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('university_token');

      debugPrint("📤 [BULK DELETE] ids: $workshopIds");
      debugPrint("🔑 [BULK DELETE] token: ${token != null ? '${token.substring(0, 20)}...' : 'NULL ❌'}");

      if (token == null || token.isEmpty) {
        debugPrint("🛑 [BULK DELETE] Aborted — no university token found");
        return Response(
          requestOptions: RequestOptions(path: "$_baseUrl/bulkdelete"),
          statusCode: 401,
          statusMessage: "Unauthorized: No university token found",
        );
      }

      if (workshopIds.isEmpty) {
        debugPrint("⚠️ [BULK DELETE] No ids to delete");
        return null;
      }

      final response = await _dio.delete(
        "$_baseUrl/bulkdelete",
        data: {"ids": workshopIds},
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status! < 500,
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      debugPrint("📥 [BULK DELETE] Status: ${response.statusCode}");
      return response;
    } catch (e) {
      debugPrint("❌ Bulk Delete Error: $e");
      rethrow;
    }
  }
}