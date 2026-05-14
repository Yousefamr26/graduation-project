// ignore_for_file: avoid_print
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarRepository {
  late Dio _dio;
  static const String _serverBase = "http://smartcareerhub.runasp.net";
  static const String _calendarUrl = "$_serverBase/api/calendar/events";
  static const String _interviewsUrl = "$_serverBase/api/Interviews";

  CalendarRepository() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(minutes: 2),
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();

        // ✅ جرب company_token الأول، لو مش موجود جرب user_token
        final token = prefs.getString('company_token') ??
            prefs.getString('user_token');

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          debugPrint("✅ [CALENDAR AUTH] Token attached: ${token.substring(0, 20)}...");
        } else {
          debugPrint("🛑 [CALENDAR AUTH] No token found in SharedPreferences!");
          // ✅ اطبع كل الـ keys الموجودة عشان نعرف المشكلة
          final keys = prefs.getKeys();
          debugPrint("🔑 [CALENDAR AUTH] Available keys: $keys");
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint("📥 [CALENDAR RESPONSE] ${response.requestOptions.path} → ${response.statusCode}");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        debugPrint("🛑 [CALENDAR ERROR] ${e.requestOptions.path} → ${e.response?.statusCode}");
        debugPrint("🛑 [CALENDAR ERROR DATA]: ${e.response?.data}");
        return handler.next(e);
      },
    ));
  }

  Future<List<Map<String, dynamic>>> getAllEvents() async {
    final List<Map<String, dynamic>> allEvents = [];

    // 1️⃣ Calendar Events
    try {
      debugPrint("📤 [CALENDAR] Fetching: $_calendarUrl");
      final res = await _dio.get(
        _calendarUrl,
        options: Options(validateStatus: (s) => s! < 500),
      );
      debugPrint("📥 [CALENDAR EVENTS] Status: ${res.statusCode}");
      debugPrint("📥 [CALENDAR EVENTS] Data: ${res.data}");

      if (res.statusCode == 200) {
        final raw = _extractList(res.data);
        allEvents.addAll(raw.map((e) => Map<String, dynamic>.from(e)));
        debugPrint("✅ [CALENDAR] ${raw.length} calendar events loaded");
      }
    } catch (e) {
      debugPrint("❌ [CALENDAR EVENTS ERROR]: $e");
    }

    // 2️⃣ Interviews → convert to events
    try {
      debugPrint("📤 [CALENDAR] Fetching interviews: $_interviewsUrl");
      final res = await _dio.get(
        _interviewsUrl,
        options: Options(validateStatus: (s) => s! < 500),
      );
      debugPrint("📥 [INTERVIEWS] Status: ${res.statusCode}");
      debugPrint("📥 [INTERVIEWS] Data: ${res.data}");

      if (res.statusCode == 200) {
        final raw = _extractList(res.data);
        debugPrint("✅ [CALENDAR] ${raw.length} interviews to convert");

        for (final item in raw) {
          final interview = Map<String, dynamic>.from(item);

          // ✅ جرب كل أسماء الـ date field الممكنة
          final dateStr =
              interview['scheduledDate']?.toString() ??
                  interview['ScheduledDate']?.toString() ??
                  interview['date']?.toString() ??
                  interview['Date']?.toString() ??
                  '';

          if (dateStr.isEmpty) {
            debugPrint("⚠️ [INTERVIEW] No date in keys: ${interview.keys.toList()}");
            continue;
          }

          final studentName =
              interview['studentName']?.toString() ??
                  interview['StudentName']?.toString() ??
                  'Interview';

          final interviewType =
              interview['interviewType']?.toString() ??
                  interview['InterviewType']?.toString() ??
                  'Interview';

          final interviewerName =
              interview['interviewerName']?.toString() ??
                  interview['InterviewerName']?.toString() ??
                  'N/A';

          final notes =
              interview['additionalNotes']?.toString() ??
                  interview['AdditionalNotes']?.toString() ??
                  '';

          allEvents.add({
            ...interview,
            'date':        dateStr,         // ✅ الـ key اللي بيقرأه CalendarScreen
            'title':       studentName,
            'type':        interviewType,
            'location':    interviewType,
            'description': 'Interviewer: $interviewerName'
                '${notes.isNotEmpty ? '\nNotes: $notes' : ''}',
          });
        }
      }
    } catch (e) {
      debugPrint("❌ [INTERVIEWS FETCH ERROR]: $e");
    }

    debugPrint("✅ [CALENDAR] Total merged: ${allEvents.length} events");
    return allEvents;
  }

  // ✅ helper يشيل الـ data من أي response structure
  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      if (data['data'] is List) return data['data'];
      if (data['items'] is List) return data['items'];
      if (data['result'] is List) return data['result'];
    }
    return [];
  }
}