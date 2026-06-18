import 'dart:convert';
import 'api_service.dart';
import '../models/Student/student-roadmap-model.dart';

class CatalogService {
  Future<List<StudentRoadmap>> getCatalogRoadmaps({
    required String? userType,
    required String userRole,
  }) async {
    final prefix = userRole == 'graduate' ? '/graduate' : '/student';
    final res = await ApiService.get('$prefix/roadmaps/catalog', userType: userType);
    final parsed = res is String ? json.decode(res) : res;
    final List<dynamic> list = parsed is List 
        ? parsed 
        : (parsed is Map && parsed['data'] is List ? parsed['data'] : []);
    return list.map((item) => StudentRoadmap.fromMap(Map<String, dynamic>.from(item as Map))).toList();
  }
}
