// ignore_for_file: avoid_print
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventUniRepository {
  late Dio _dio;
  static const String _baseUrl    = "http://smartcareerhub.runasp.net/api/Events";
  static const String _serverBase = "http://smartcareerhub.runasp.net";

  EventUniRepository() {
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
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        debugPrint("🛑 [ERROR] Status: ${e.response?.statusCode}");
        debugPrint("🛑 [ERROR MSG]: ${e.message}");
        return handler.next(e);
      },
    ));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  Map<String, dynamic> _processBanner(dynamic rawValue) {
    if (rawValue == null) return {'type': null, 'value': null};
    final s = rawValue.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return {'type': null, 'value': null};

    if (s.startsWith('http://') || s.startsWith('https://')) {
      debugPrint("🖼️ [BANNER] Full URL: ${s.substring(0, s.length.clamp(0, 80))}");
      return {'type': 'url', 'value': s};
    }

    if (s.startsWith('/uploads/') || s.startsWith('uploads/')) {
      final fixed = s.startsWith('/') ? "$_serverBase$s" : "$_serverBase/$s";
      debugPrint("🖼️ [BANNER] Path → Fixed URL: $fixed");
      return {'type': 'url', 'value': fixed};
    }

    if (s.startsWith('/9j/') || s.startsWith('iVBOR') || s.startsWith('data:image')) {
      final clean = s.startsWith('data:image') ? s.substring(s.indexOf(',') + 1) : s;
      debugPrint("🖼️ [BANNER] Base64 image detected (len: ${clean.length})");
      return {'type': 'base64', 'value': clean};
    }

    if (s.startsWith('/')) {
      final fixed = "$_serverBase$s";
      debugPrint("🖼️ [BANNER] Generic path → Fixed: $fixed");
      return {'type': 'url', 'value': fixed};
    }

    debugPrint("🖼️ [BANNER] Unknown format, ignoring.");
    return {'type': null, 'value': null};
  }

  String _getMimeType(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    if (ext == 'png')  return 'image/png';
    if (ext == 'webp') return 'image/webp';
    return 'image/jpeg';
  }

  String _toSafeDateString(DateTime date) {
    return DateTime(date.year, date.month, date.day, 12, 0, 0).toIso8601String();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GET ALL
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllEvents() async {
    try {
      debugPrint("📤 [GET ALL EVENTS] Fetching from: $_baseUrl");

      final response = await _dio.get(
        _baseUrl,
        options: Options(validateStatus: (status) => status! < 500),
      );

      debugPrint("📥 [GET ALL EVENTS] Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> result = [];
        if (response.data is List) {
          result = List<Map<String, dynamic>>.from(response.data);
        } else if (response.data is Map && response.data['data'] != null) {
          result = List<Map<String, dynamic>>.from(response.data['data']);
        }

        debugPrint("📦 [EVENTS COUNT]: ${result.length}");
        if (result.isNotEmpty) {
          debugPrint("🔑 [FIRST EVENT KEYS]: ${result[0].keys.toList()}");
        }

        return result.map((e) {
          final rawValue =
              e['bannerUrl']      ??
                  e['banner']         ??
                  e['bannerPath']     ??
                  e['coverImage']     ??
                  e['coverImageUrl']  ??
                  e['coverImagePath'] ??
                  e['image']          ??
                  e['imageUrl'];

          final info = _processBanner(rawValue);

          return {
            ...e,
            'bannerType':  info['type'],
            'bannerValue': info['value'],
            'banner': info['type'] == 'url' ? info['value'] : null,
          };
        }).toList();
      }

      return [];
    } catch (e) {
      debugPrint("❌ getAllEvents Error: $e");
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CREATE
  // ─────────────────────────────────────────────────────────────────────────

  Future<Response?> createEvent({
    required String title,
    required String description,
    required String eventType,
    required String mode,
    required DateTime startDate,
    required DateTime endDate,
    required String startTime,
    required String endTime,
    required int maxCapacity,
    required bool isPublished,
    required bool allowWaitingList,
    required bool sendAutoEmail,
    required int pointsForAttendance,
    required int pointsForFullParticipation,
    double minPoints                   = 0,
    bool completedRoadmap              = false,
    bool completed50PercentCourses     = false,
    bool highCommunicationSkills       = false,
    bool highTechnicalSkills           = false,
    bool top30PercentProgress          = false,
    bool inviteOnlyEligibleStudents    = false,
    String? location,
    File? banner,
  }) async {
    try {
      final formData = FormData();
      formData.fields.addAll([
        MapEntry("Title",                           title),
        MapEntry("Description",                     description),
        MapEntry("EventType",                       eventType),
        MapEntry("Mode",                            mode),
        MapEntry("StartDate",                       _toSafeDateString(startDate)),
        MapEntry("EndDate",                         _toSafeDateString(endDate)),
        MapEntry("StartTime",                       startTime),
        MapEntry("EndTime",                         endTime),
        MapEntry("MaxCapacity",                     maxCapacity.toString()),
        MapEntry("IsPublished",                     isPublished.toString()),
        MapEntry("AllowWaitingList",                allowWaitingList.toString()),
        MapEntry("SendAutoEmailToEligibleStudents", sendAutoEmail.toString()),
        MapEntry("PointsForAttendance",             pointsForAttendance.toString()),
        MapEntry("PointsForFullParticipation",      pointsForFullParticipation.toString()),
        MapEntry("MinimumRequiredPoints",           minPoints.round().toString()),
        MapEntry("CompletedRoadmap",                completedRoadmap.toString()),
        MapEntry("Completed50PercentCourses",       completed50PercentCourses.toString()),
        MapEntry("HighCommunicationSkills",         highCommunicationSkills.toString()),
        MapEntry("HighTechnicalSkills",             highTechnicalSkills.toString()),
        MapEntry("Top30PercentProgress",            top30PercentProgress.toString()),
        MapEntry("InviteOnlyEligibleStudents",      inviteOnlyEligibleStudents.toString()),
        if (location != null && location.isNotEmpty) MapEntry("Location", location),
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

      final response = await _dio.post(
        _baseUrl,
        data:    formData,
        options: Options(validateStatus: (s) => s! < 500),
      );
      debugPrint("✅ [CREATE EVENT] Status: ${response.statusCode}");
      return response;
    } catch (e) {
      debugPrint("❌ createEvent Error: $e");
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UPDATE
  // ─────────────────────────────────────────────────────────────────────────

  Future<Response?> updateEvent({
    required String eventId,
    required String title,
    required String description,
    required String eventType,
    required String mode,
    required DateTime startDate,
    required DateTime endDate,
    required String startTime,
    required String endTime,
    required int maxCapacity,
    required bool isPublished,
    required bool allowWaitingList,
    required bool sendAutoEmail,
    required int pointsForAttendance,
    required int pointsForFullParticipation,
    double minPoints                   = 0,
    bool completedRoadmap              = false,
    bool completed50PercentCourses     = false,
    bool highCommunicationSkills       = false,
    bool highTechnicalSkills           = false,
    bool top30PercentProgress          = false,
    bool inviteOnlyEligibleStudents    = false,
    String? location,
    File? banner,
  }) async {
    try {
      final formData = FormData();
      formData.fields.addAll([
        MapEntry("Title",                           title),
        MapEntry("Description",                     description),
        MapEntry("EventType",                       eventType),
        MapEntry("Mode",                            mode),
        MapEntry("StartDate",                       _toSafeDateString(startDate)),
        MapEntry("EndDate",                         _toSafeDateString(endDate)),
        MapEntry("StartTime",                       startTime),
        MapEntry("EndTime",                         endTime),
        MapEntry("MaxCapacity",                     maxCapacity.toString()),
        MapEntry("IsPublished",                     isPublished.toString()),
        MapEntry("AllowWaitingList",                allowWaitingList.toString()),
        MapEntry("SendAutoEmailToEligibleStudents", sendAutoEmail.toString()),
        MapEntry("PointsForAttendance",             pointsForAttendance.toString()),
        MapEntry("PointsForFullParticipation",      pointsForFullParticipation.toString()),
        MapEntry("MinimumRequiredPoints",           minPoints.round().toString()),
        MapEntry("CompletedRoadmap",                completedRoadmap.toString()),
        MapEntry("Completed50PercentCourses",       completed50PercentCourses.toString()),
        MapEntry("HighCommunicationSkills",         highCommunicationSkills.toString()),
        MapEntry("HighTechnicalSkills",             highTechnicalSkills.toString()),
        MapEntry("Top30PercentProgress",            top30PercentProgress.toString()),
        MapEntry("InviteOnlyEligibleStudents",      inviteOnlyEligibleStudents.toString()),
        if (location != null && location.isNotEmpty) MapEntry("Location", location),
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

      final response = await _dio.put(
        "$_baseUrl/$eventId",
        data:    formData,
        options: Options(validateStatus: (s) => s! < 500),
      );
      debugPrint("✅ [UPDATE EVENT] Status: ${response.statusCode}");
      return response;
    } catch (e) {
      debugPrint("❌ updateEvent Error: $e");
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────────────────────────────────

  Future<Response?> deleteEvent(dynamic eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('university_token');

      debugPrint("🗑️ [DELETE EVENT] id: $eventId");
      debugPrint("🔑 [DELETE EVENT] token: ${token != null ? '${token.substring(0, 20)}...' : 'NULL ❌'}");

      if (token == null || token.isEmpty) {
        debugPrint("🛑 [DELETE EVENT] Aborted — no university token found");
        return Response(
          requestOptions: RequestOptions(path: "$_baseUrl/$eventId"),
          statusCode: 401,
          statusMessage: "Unauthorized: No university token found",
        );
      }

      final response = await _dio.delete(
        "$_baseUrl/${eventId.toString()}",
        options: Options(
          validateStatus: (s) => s! < 500,
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      debugPrint("📥 [DELETE EVENT] Status: ${response.statusCode}");
      debugPrint("📥 [DELETE EVENT] Data: ${response.data}");
      return response;
    } catch (e) {
      debugPrint("❌ deleteEvent Error: $e");
      rethrow;
    }
  }
}