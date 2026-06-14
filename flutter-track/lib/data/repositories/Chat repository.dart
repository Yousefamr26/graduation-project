import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatRepository {
  static const String _baseUrl = 'http://smartcareerhub.runasp.net/api/';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
    validateStatus: (status) => status! < 500,
  ));

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('company_token')    ??
        prefs.getString('university_token') ??
        prefs.getString('token');
  }

  Future<Options> _authOptions() async {
    final token = await _getToken();
    return Options(
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      validateStatus: (s) => s! < 500,
    );
  }

  Future<Response> getRooms() async {
    try {
      debugPrint('📤 [CHAT] GET rooms');
      final response = await _dio.get('Chat/rooms', options: await _authOptions());
      debugPrint('📥 [CHAT] GET rooms status: ${response.statusCode}');
      debugPrint('📥 [CHAT] GET rooms data: ${jsonEncode(response.data)}'); // ← غير السطر ده
      return response;
    } on DioException catch (e) {
      debugPrint('❌ [CHAT] GET rooms error: ${e.message}');
      rethrow;
    }
  }

  // ✅ EntityId هو الـ field الصح
  Future<Response> createRoom({required String participantId}) async {
    try {
      debugPrint('📤 [CHAT] POST create room | entityId=$participantId');
      final response = await _dio.post(
        'Chat/rooms',
        data: {'entityId': participantId},
        options: await _authOptions(),
      );
      debugPrint('📥 [CHAT] POST create room status: ${response.statusCode}');
      debugPrint('📥 [CHAT] POST create room data: ${response.data}');
      return response;
    } on DioException catch (e) {
      debugPrint('❌ [CHAT] POST create room error: ${e.message}');
      rethrow;
    }
  }

  Future<Response> getMessages(int roomId) async {
    try {
      debugPrint('📤 [CHAT] GET messages | roomId=$roomId');
      final response = await _dio.get(
        'Chat/rooms/$roomId/messages',
        options: await _authOptions(),
      );
      debugPrint('📥 [CHAT] GET messages status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      debugPrint('❌ [CHAT] GET messages error: ${e.message}');
      rethrow;
    }
  }

  Future<Response> sendMessage({
    required int roomId,
    required String content,
  }) async {
    try {
      debugPrint('📤 [CHAT] POST message | roomId=$roomId | content=$content');
      final response = await _dio.post(
        'Chat/rooms/$roomId/messages',
        data: {'roomId': roomId, 'content': content},
        options: await _authOptions(),
      );
      debugPrint('📥 [CHAT] POST message status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      debugPrint('❌ [CHAT] POST message error: ${e.message}');
      rethrow;
    }
  }

  Future<Response> markAsRead(int roomId) async {
    try {
      debugPrint('📤 [CHAT] PUT mark read | roomId=$roomId');
      final response = await _dio.put(
        'Chat/rooms/$roomId/read',
        options: await _authOptions(),
      );
      debugPrint('📥 [CHAT] PUT mark read status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      debugPrint('❌ [CHAT] PUT mark read error: ${e.message}');
      rethrow;
    }
  }
}