import 'dart:convert';
import 'api_service.dart';
import '../models/Student/student-event-model.dart';

class EventService {
  Future<List<StudentEvent>> getMyEvents({required String? userType}) async {
    final res = await ApiService.get('/events/my-events', userType: userType);
    final parsed = res is String ? json.decode(res) : res;
    final List<dynamic> list = parsed is List
        ? parsed
        : (parsed is Map && parsed['data'] is List ? parsed['data'] : []);

    if (list.isEmpty) return [];

    // Fetch full details for each enrolled event in parallel
    final fetchFutures = list.map((enr) async {
      final eventId = enr['eventId'] ?? enr['id'];
      if (eventId != null) {
        try {
          final detailRes = await ApiService.get(
            '/events/$eventId',
            userType: userType,
          );
          final parsedDetail = detailRes is String
              ? json.decode(detailRes)
              : detailRes;
          final detailMap =
              (parsedDetail is Map && parsedDetail['data'] != null)
              ? parsedDetail['data']
              : parsedDetail;
          if (detailMap is Map) {
            return StudentEvent.fromMap(Map<String, dynamic>.from(detailMap));
          }
        } catch (_) {}
      }
      return null;
    }).toList();

    final results = await Future.wait(fetchFutures);
    return results.whereType<StudentEvent>().toList();
  }
}
