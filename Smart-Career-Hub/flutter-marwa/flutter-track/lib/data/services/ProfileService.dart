import 'api_service.dart';

class ProfileService {
  Future<Map<String, dynamic>> getProfileSummary({required String? userType}) async {
    final res = await ApiService.get('/Profile/summary', userType: userType);
    return (res is Map ? res as Map<String, dynamic> : res?['data'] ?? {}) as Map<String, dynamic>;
  }
}
