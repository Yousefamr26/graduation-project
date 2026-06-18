import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApiService {
  static const String _base = 'http://smartcareerhub.runasp.net/api';

  static Dio _dio({String? token}) {
    final d = Dio(BaseOptions(
      baseUrl: _base,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      validateStatus: (s) => s! < 600,
    ));
    return d;
  }

  // ─── Token helpers ───────────────────────────────────────────────
  static Future<String?> getToken(String userType) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('${userType}_token');
  }

  static Future<Map<String, dynamic>> getUserData(String userType) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('${userType}_user_data');
    if (raw == null) return {};
    return json.decode(raw) as Map<String, dynamic>;
  }

  // ─── GET ─────────────────────────────────────────────────────────
  static Future<dynamic> get(String path, {String? userType}) async {
    final token = userType != null ? await getToken(userType) : null;
    final res = await _dio(token: token).get(path);
    if (res.statusCode! >= 200 && res.statusCode! < 300) return res.data;
    final errMsg = res.data is Map ? (res.data['message'] ?? 'Error ${res.statusCode}') : (res.data?.toString() ?? 'Error ${res.statusCode}');
    throw Exception(errMsg);
  }

  // ─── POST ────────────────────────────────────────────────────────
  static Future<dynamic> post(String path, {dynamic data, String? userType}) async {
    final token = userType != null ? await getToken(userType) : null;
    final res = await _dio(token: token).post(path, data: data);
    if (res.statusCode! >= 200 && res.statusCode! < 300) return res.data;
    throw Exception(res.data?['message'] ?? res.data?.toString() ?? 'Error ${res.statusCode}');
  }

  // ─── PUT ─────────────────────────────────────────────────────────
  static Future<dynamic> put(String path, {dynamic data, String? userType}) async {
    final token = userType != null ? await getToken(userType) : null;
    final res = await _dio(token: token).put(path, data: data);
    if (res.statusCode! >= 200 && res.statusCode! < 300) return res.data;
    final errMsg = res.data is Map ? (res.data['message'] ?? 'Error ${res.statusCode}') : (res.data?.toString() ?? 'Error ${res.statusCode}');
    throw Exception(errMsg);
  }

  // ─── DELETE ──────────────────────────────────────────────────────
  static Future<dynamic> delete(String path, {String? userType}) async {
    final token = userType != null ? await getToken(userType) : null;
    final res = await _dio(token: token).delete(path);
    if (res.statusCode! >= 200 && res.statusCode! < 300) return res.data;
    final errMsg = res.data is Map ? (res.data['message'] ?? 'Error ${res.statusCode}') : (res.data?.toString() ?? 'Error ${res.statusCode}');
    throw Exception(errMsg);
  }

  // ─── PATCH ───────────────────────────────────────────────────────
  static Future<dynamic> patch(String path, {dynamic data, String? userType}) async {
    final token = userType != null ? await getToken(userType) : null;
    final res = await _dio(token: token).patch(path, data: data);
    if (res.statusCode! >= 200 && res.statusCode! < 300) return res.data;
    final errMsg = res.data is Map ? (res.data['message'] ?? 'Error ${res.statusCode}') : (res.data?.toString() ?? 'Error ${res.statusCode}');
    throw Exception(errMsg);
  }

  // ─── PROFILE UPDATE (multipart) ──────────────────────────────────
  static Future<dynamic> putFormData(String path, FormData formData, {String? userType}) async {
    final token = userType != null ? await getToken(userType) : null;
    final res = await _dio(token: token).put(path, data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}));
    if (res.statusCode! >= 200 && res.statusCode! < 300) return res.data;
    final errMsg = res.data is Map ? (res.data['message'] ?? 'Error ${res.statusCode}') : (res.data?.toString() ?? 'Error ${res.statusCode}');
    throw Exception(errMsg);
  }
}
