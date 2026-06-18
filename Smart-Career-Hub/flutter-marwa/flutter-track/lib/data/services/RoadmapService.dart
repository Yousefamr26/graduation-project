import 'dart:convert';
import 'api_service.dart';
import '../models/Student/student-roadmap-model.dart';

class RoadmapService {
  Future<List<StudentRoadmap>> getPublishedRoadmaps({
    required String? userType,
  }) async {
    final res = await ApiService.get('/Roadmaps/published', userType: userType);
    final parsed = res is String ? json.decode(res) : res;
    final List<dynamic> list = parsed is List
        ? parsed
        : (parsed is Map && parsed['data'] is List ? parsed['data'] : []);
    return list
        .map(
          (item) =>
              StudentRoadmap.fromMap(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<List<StudentRoadmap>> getMyRoadmaps({
    required String? userType,
    required String userRole,
  }) async {
    final prefix = userRole == 'graduate' ? '/graduate' : '/student';
    final res = await ApiService.get('$prefix/roadmaps/my', userType: userType);
    final parsed = res is String ? json.decode(res) : res;
    final List<dynamic> list = parsed is List
        ? parsed
        : (parsed is Map && parsed['data'] is List ? parsed['data'] : []);
    return list
        .map(
          (item) =>
              StudentRoadmap.fromMap(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<dynamic> enrollRoadmap(
    dynamic id, {
    required String? userType,
    required String userRole,
  }) async {
    final prefix = userRole == 'graduate' ? '/graduate' : '/student';
    return await ApiService.post(
      '$prefix/roadmaps/enroll',
      data: {'roadmapId': id},
      userType: userType,
    );
  }

  Future<dynamic> unenrollRoadmap(
    dynamic id, {
    required String? userType,
    required String userRole,
  }) async {
    final prefix = userRole == 'graduate' ? '/graduate' : '/student';
    return await ApiService.delete(
      '$prefix/roadmaps/$id/unenroll',
      userType: userType,
    );
  }
}
