// import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../core/Constants/apiConstants.dart';
// import '../../core/utilies/api-response.dart';
// class ApiService {
//   late Dio _dio;
//   String? _authToken;
//
//   static final ApiService _instance = ApiService._internal();
//   factory ApiService() => _instance;
//
//   ApiService._internal() {
//     _dio = Dio(BaseOptions(
//       baseUrl: ApiConstants.baseUrl,
//       connectTimeout: ApiConstants.timeoutDuration,
//       receiveTimeout: ApiConstants.timeoutDuration,
//       headers: {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//     ));
//
//     _dio.interceptors.add(InterceptorsWrapper(
//       onRequest: (options, handler) async {
//         if (_authToken != null) {
//           options.headers['Authorization'] = 'Bearer $_authToken';
//         }
//         print('REQUEST[${options.method}] => PATH: ${options.path}');
//         return handler.next(options);
//       },
//       onResponse: (response, handler) {
//         print('RESPONSE[${response.statusCode}] => DATA: ${response.data}');
//         return handler.next(response);
//       },
//       onError: (error, handler) {
//         print('ERROR[${error.response?.statusCode}] => MESSAGE: ${error.message}');
//         return handler.next(error);
//       },
//     ));
//
//     _loadToken();
//   }
//
//   Future<void> _loadToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     _authToken = prefs.getString('auth_token');
//   }
//
//   Future<void> setToken(String token) async {
//     _authToken = token;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('auth_token', token);
//   }
//
//   Future<void> removeToken() async {
//     _authToken = null;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('auth_token');
//   }
//
//   // ─── GET ────────────────────────────────────────────────────────────────────
//   Future<ApiResponse<T>> get<T>(
//       String endpoint, {
//         Map<String, dynamic>? queryParameters,
//         T Function(dynamic)? parser,
//       }) async {
//     try {
//       final response = await _dio.get(
//         endpoint,
//         queryParameters: queryParameters,
//       );
//       return _handleSuccess<T>(response, parser);
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     } catch (e) {
//       return ApiResponse.error('Unexpected error: ${e.toString()}');
//     }
//   }
//
//   // ─── POST ───────────────────────────────────────────────────────────────────
//   Future<ApiResponse<T>> post<T>(
//       String endpoint, {
//         dynamic data,
//         T Function(dynamic)? parser,
//       }) async {
//     try {
//       final response = await _dio.post(endpoint, data: data);
//       return _handleSuccess<T>(response, parser);
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     } catch (e) {
//       return ApiResponse.error('Unexpected error: ${e.toString()}');
//     }
//   }
//
//   // ─── PUT ────────────────────────────────────────────────────────────────────
//   Future<ApiResponse<T>> put<T>(
//       String endpoint, {
//         dynamic data,
//         T Function(dynamic)? parser,
//       }) async {
//     try {
//       final response = await _dio.put(endpoint, data: data);
//       return _handleSuccess<T>(response, parser);
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     } catch (e) {
//       return ApiResponse.error('Unexpected error: ${e.toString()}');
//     }
//   }
//
//   // ─── DELETE ─────────────────────────────────────────────────────────────────
//   Future<ApiResponse<bool>> delete(String endpoint) async {
//     try {
//       final response = await _dio.delete(endpoint);
//       final statusCode = response.statusCode ?? 500;
//
//       if (statusCode == 200 || statusCode == 204) {
//         return ApiResponse.success(
//           true,
//           message: response.data is Map ? response.data['message'] : 'Deleted successfully',
//           statusCode: statusCode,
//         );
//       }
//       return _parseErrorResponse(response.data, statusCode);
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     } catch (e) {
//       return ApiResponse.error('Unexpected error: ${e.toString()}');
//     }
//   }
//
//   // ─── HELPERS ────────────────────────────────────────────────────────────────
//
//   /// Handle any 2xx response uniformly
//   ApiResponse<T> _handleSuccess<T>(Response response, T Function(dynamic)? parser) {
//     final statusCode = response.statusCode ?? 200;
//
//     if (statusCode >= 200 && statusCode < 300) {
//       // response.data might be a raw object (not always a Map)
//       final data = parser != null ? parser(response.data) : response.data as T;
//       final message = response.data is Map ? response.data['message'] : null;
//       return ApiResponse.success(data, message: message, statusCode: statusCode);
//     }
//
//     return _parseErrorResponse(response.data, statusCode);
//   }
//
//   /// Parse backend error body  { "code": "...", "description": "..." }
//   ApiResponse<T> _parseErrorResponse<T>(dynamic responseData, int statusCode) {
//     if (responseData is Map<String, dynamic>) {
//       return ApiResponse.error(
//         responseData['description']?.toString() ??
//             responseData['message']?.toString() ??
//             'Server error occurred',
//         statusCode: statusCode,
//         errorCode: responseData['code']?.toString(),
//         errorDescription: responseData['description']?.toString(),
//         error: responseData,
//       );
//     }
//     return ApiResponse.error('Server error occurred', statusCode: statusCode);
//   }
//
//   /// Handle Dio-level errors (timeout, no internet, 4xx/5xx)
//   ApiResponse<T> _handleDioError<T>(DioException error) {
//     final statusCode = error.response?.statusCode;
//
//     switch (error.type) {
//       case DioExceptionType.connectionTimeout:
//       case DioExceptionType.sendTimeout:
//       case DioExceptionType.receiveTimeout:
//         return ApiResponse.error(
//           'Connection timeout. Please try again.',
//           statusCode: statusCode,
//           error: error,
//         );
//
//       case DioExceptionType.badResponse:
//       // ✅ هنا بنستخرج code و description من الـ backend error
//         final responseData = error.response?.data;
//         if (responseData is Map<String, dynamic>) {
//           return ApiResponse.error(
//             responseData['description']?.toString() ??
//                 responseData['message']?.toString() ??
//                 'Server error occurred',
//             statusCode: statusCode,
//             errorCode: responseData['code']?.toString(),
//             errorDescription: responseData['description']?.toString(),
//             error: error,
//           );
//         }
//         return ApiResponse.error(
//           'Server error occurred',
//           statusCode: statusCode,
//           error: error,
//         );
//
//       case DioExceptionType.cancel:
//         return ApiResponse.error('Request was cancelled', error: error);
//
//       case DioExceptionType.connectionError:
//         return ApiResponse.error('No internet connection', error: error);
//
//       default:
//         return ApiResponse.error('Something went wrong', error: error);
//     }
//   }
// }