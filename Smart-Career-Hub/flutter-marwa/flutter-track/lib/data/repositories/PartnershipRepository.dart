// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/university/PartnershipModel.dart';

class PartnershipRepository {
  static const String _baseUrl =
      'http://smartcareerhub.runasp.net/api/Partnerships';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('university_token');
  }

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Parses a 400 validation error body and returns a human-readable message.
  /// Body example:
  /// {"errors":{"Website":["Invalid website URL"],"Email":["..."]},...}
  String _parseValidationError(String body, String action) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final errors = decoded['errors'] as Map<String, dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        // Collect all messages
        final messages = errors.entries.map((e) {
          final fieldMsgs = (e.value as List<dynamic>).join(', ');
          return '${e.key}: $fieldMsgs';
        }).join('\n');
        throw Exception('Validation error\n$messages');
      }
      final title = decoded['title'] as String?;
      if (title != null) throw Exception(title);
    } catch (e) {
      if (e is Exception) rethrow;
    }
    throw Exception('Failed to $action partnership: 400');
  }

  // GET /api/Partnerships
  Future<List<PartnershipModel>> getAll() async {
    try {
      final res = await http.get(
        Uri.parse(_baseUrl),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        final List<dynamic> json = jsonDecode(res.body);
        return json.map((e) => PartnershipModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load partnerships: ${res.statusCode}');
    } catch (e) {
      print('❌ [Partnership] getAll error: $e');
      rethrow;
    }
  }

  // GET /api/Partnerships/{id}
  Future<PartnershipModel> getById(String id) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        return PartnershipModel.fromJson(jsonDecode(res.body));
      }
      throw Exception('Failed to fetch partnership: ${res.statusCode}');
    } catch (e) {
      print('❌ [Partnership] getById error: $e');
      rethrow;
    }
  }

  // POST /api/Partnerships
  Future<PartnershipModel> create(PartnershipModel model) async {
    try {
      final body = model.toJson()..remove('companyId');
      print('📤 [Partnership] create body: $body');
      final res = await http.post(
        Uri.parse(_baseUrl),
        headers: await _headers(),
        body: jsonEncode(body),
      );
      print('📥 [Partnership] create status: ${res.statusCode}');
      print('📥 [Partnership] create body: ${res.body}');
      if (res.statusCode == 200 || res.statusCode == 201) {
        return PartnershipModel.fromJson(jsonDecode(res.body));
      }
      if (res.statusCode == 400) {
        _parseValidationError(res.body, 'create'); // always throws
      }
      throw Exception('Failed to create partnership: ${res.statusCode}');
    } catch (e) {
      print('❌ [Partnership] create error: $e');
      rethrow;
    }
  }

  // PUT /api/Partnerships/{id}
  Future<PartnershipModel> update(String id, PartnershipModel model) async {
    try {
      final res = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: await _headers(),
        body: jsonEncode(model.toJson()),
      );
      if (res.statusCode == 200 || res.statusCode == 204) {
        if (res.body.isEmpty) return model.copyWith(id: id);
        return PartnershipModel.fromJson(jsonDecode(res.body));
      }
      if (res.statusCode == 400) {
        _parseValidationError(res.body, 'update'); // always throws
      }
      throw Exception('Failed to update partnership: ${res.statusCode}');
    } catch (e) {
      print('❌ [Partnership] update error: $e');
      rethrow;
    }
  }

  // DELETE /api/Partnerships/{id}
  Future<void> delete(String id) async {
    try {
      final res = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: await _headers(),
      );
      if (res.statusCode != 200 && res.statusCode != 204) {
        throw Exception('Failed to delete partnership: ${res.statusCode}');
      }
    } catch (e) {
      print('❌ [Partnership] delete error: $e');
      rethrow;
    }
  }

  // PATCH /api/Partnerships/{id}/approve
  Future<void> approve(String id) async {
    try {
      final res = await http.patch(
        Uri.parse('$_baseUrl/$id/approve'),
        headers: await _headers(),
      );
      if (res.statusCode != 200 && res.statusCode != 204) {
        throw Exception('Failed to approve partnership: ${res.statusCode}');
      }
    } catch (e) {
      print('❌ [Partnership] approve error: $e');
      rethrow;
    }
  }
}