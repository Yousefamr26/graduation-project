// ignore_for_file: avoid_print
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarRepository {
  late Dio _dio;
  static const String _serverBase = "http://smartcareerhub.runasp.net";
  static const String _calendarUrl = "$_serverBase/api/calendar/events";

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
        final token = prefs.getString('company_token') ??
            prefs.getString('user_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          debugPrint("✅ [CALENDAR AUTH] Token attached");
        } else {
          debugPrint("🛑 [CALENDAR AUTH] No token found!");
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint("📥 [CALENDAR RESPONSE] ${response.requestOptions.path} → ${response.statusCode}");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        debugPrint("🛑 [CALENDAR ERROR] ${e.requestOptions.path} → ${e.response?.statusCode}");
        return handler.next(e);
      },
    ));
  }

  Future<List<Map<String, dynamic>>> getAllEvents() async {
    final List<Map<String, dynamic>> allEvents = [];

    // جيب الشهر الحالي والجاي — الـ calendar API بيضم كل حاجة (jobs + interviews)
    final now = DateTime.now();
    for (final dt in [now, DateTime(now.year, now.month + 1)]) {
      try {
        final url = "$_calendarUrl?month=${dt.month}&year=${dt.year}";
        debugPrint("📤 [CALENDAR] Fetching: $url");
        final res = await _dio.get(
          url,
          options: Options(validateStatus: (s) => s! < 500),
        );
        debugPrint("📥 [CALENDAR EVENTS ${dt.month}/${dt.year}] Status: ${res.statusCode}");

        if (res.statusCode == 200) {
          final raw = _extractList(res.data);
          allEvents.addAll(raw.map((e) => Map<String, dynamic>.from(e)));
          debugPrint("✅ [CALENDAR] ${raw.length} events for ${dt.month}/${dt.year}");
        }
      } catch (e) {
        debugPrint("❌ [CALENDAR EVENTS ERROR]: $e");
      }
    }

    debugPrint("✅ [CALENDAR] Total: ${allEvents.length} events");
    return allEvents;
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      if (data['data'] is List) return data['data'];
      if (data['items'] is List) return data['items'];
      if (data['result'] is List) return data['result'];
      if (data['value'] is List) return data['value'];
    }
    return [];
  }
}