// ignore_for_file: avoid_print
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CvRepository {
  late Dio _dio;
  static const String _baseUrl = "http://smartcareerhub.runasp.net/api/company/cv";

  CvRepository() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(minutes: 5),
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('company_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          debugPrint("✅ [CV AUTH] Token attached: ${token.substring(0, 20)}...");
        } else {
          debugPrint("🛑 [CV AUTH] Warning: No token found!");
        }
        debugPrint("📤 [CV REQUEST] ${options.method} ${options.uri}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint("📥 [CV RESPONSE] Status: ${response.statusCode}");
        debugPrint("📥 [CV RESPONSE DATA]: ${response.data}");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        debugPrint("🛑 [CV ERROR] Status: ${e.response?.statusCode}");
        debugPrint("🛑 [CV ERROR DATA]: ${e.response?.data}");
        return handler.next(e);
      },
    ));
  }

  // ─── GET /api/company/cv/templates ────────────────────────────
  Future<List<Map<String, dynamic>>> getTemplates() async {
    try {
      final response = await _dio.get(
        "$_baseUrl/templates",
        options: Options(validateStatus: (status) => status! < 500),
      );
      if (response.statusCode == 200) {
        if (response.data is List) {
          return List<Map<String, dynamic>>.from(response.data);
        } else if (response.data is Map && response.data['data'] != null) {
          return List<Map<String, dynamic>>.from(response.data['data']);
        }
      }
      return [];
    } catch (e) {
      debugPrint("❌ [CV GET TEMPLATES ERROR]: $e");
      return [];
    }
  }

  // ─── POST /api/company/cv/upload-template ─────────────────────
  // multipart/form-data: TemplateFile (binary), Title, Description
  Future<Response?> uploadTemplate({
    required File templateFile,
    required String title,
    String? description,
  }) async {
    try {
      final String fileName = templateFile.path.split('/').last;
      final String ext      = fileName.split('.').last.toLowerCase();

      String mimeType;
      if (ext == 'pdf') {
        mimeType = 'application/pdf';
      } else if (ext == 'doc') {
        mimeType = 'application/msword';
      } else if (ext == 'docx') {
        mimeType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      } else {
        mimeType = 'application/octet-stream';
      }

      final formData = FormData();

      formData.files.add(MapEntry(
        'TemplateFile',
        await MultipartFile.fromFile(
          templateFile.path,
          filename: fileName,
          contentType: DioMediaType.parse(mimeType),
        ),
      ));

      formData.fields.add(MapEntry('Title', title));
      if (description != null && description.isNotEmpty) {
        formData.fields.add(MapEntry('Description', description));
      }

      debugPrint("📤 [CV UPLOAD] File: $fileName | Title: $title");

      return await _dio.post(
        "$_baseUrl/upload-template",
        data: formData,
        options: Options(validateStatus: (status) => status! < 500),
      );
    } catch (e) {
      debugPrint("❌ [CV UPLOAD ERROR]: $e");
      rethrow;
    }
  }

  // ─── DELETE /api/company/cv/templates/{templateId} ────────────
  Future<Response?> deleteTemplate(dynamic templateId) async {
    try {
      return await _dio.delete(
        "$_baseUrl/templates/${templateId.toString()}",
        options: Options(validateStatus: (status) => status! < 500),
      );
    } catch (e) {
      debugPrint("❌ [CV DELETE ERROR]: $e");
      rethrow;
    }
  }
}