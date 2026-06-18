import 'dart:convert';
import 'api_service.dart';
import '../models/Student/student-workshop-model.dart';

class WorkshopService {
  /// Fetches enrolled workshops with full details.
  ///
  /// Flow:
  ///   1. GET /WorkshopEnrollment/my-workshops  → list of enrollment objects (each has workshopId)
  ///   2. For each enrollment, GET /Workshops/{id} → full workshop details
  ///   3. Map the enriched data to [StudentWorkshop]
  Future<List<StudentWorkshop>> getMyWorkshops({required String? userType}) async {
    // Step 1: get enrollment list
    final res = await ApiService.get('/WorkshopEnrollment/my-workshops', userType: userType);
    final parsed = res is String ? json.decode(res) : res;
    final List<dynamic> enrollments = parsed is List
        ? parsed
        : (parsed is Map && parsed['data'] is List ? parsed['data'] : []);

    if (enrollments.isEmpty) return [];

    // Step 2: fetch full details for each enrolled workshop
    final fetchFutures = enrollments.map((enrollment) {
      final wId = enrollment['workshopId'] ??
          enrollment['WorkshopId'] ??
          (enrollment['workshop'] is Map
              ? (enrollment['workshop']['id'] ?? enrollment['workshop']['Id'])
              : null) ??
          enrollment['id'] ??
          enrollment['Id'];

      if (wId != null) {
        return ApiService.get('/Workshops/$wId', userType: userType)
            .then((detail) {
              if (detail is Map) {
                // Merge enrollment ID into the flat workshop map for unenroll
                return {
                  ...Map<String, dynamic>.from(detail),
                  '_enrollmentId': enrollment['enrollmentId'] ??
                      enrollment['EnrollmentId'] ??
                      enrollment['id'] ??
                      enrollment['Id'],
                };
              }
              return enrollment;
            })
            .catchError((_) => enrollment);
      }
      return Future<dynamic>.value(enrollment);
    }).toList();

    final fetched = await Future.wait(fetchFutures);

    // Step 3: map to StudentWorkshop model
    return fetched
        .whereType<Map>()
        .map((item) => StudentWorkshop.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }
}
