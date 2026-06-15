import 'package:dio/dio.dart';

class DioHelper {
  static late Dio dio;

  static init() {
    dio = Dio(
      BaseOptions(
        baseUrl: "https://smartcareerhub.runasp.net/api/",
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
      error: true,
      logPrint: (o) => print('🔍 $o'),
    ));
  }

  static Future<Response> post({
    required String url,
    Map<String, dynamic>? data,
  }) async {
    return await dio.post(url, data: data);
  }

  static Future<Response> postFormData({
    required String url,
    required FormData data,
  }) async {
    return await dio.post(
      url,
      data: data,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );
  }
}
