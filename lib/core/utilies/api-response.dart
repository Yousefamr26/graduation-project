class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;
  final dynamic error;
  // Backend error fields (RFC 7807 / custom error format)
  final String? errorCode;        // "code" field from backend
  final String? errorDescription; // "description" field from backend

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
    this.error,
    this.errorCode,
    this.errorDescription,
  });

  factory ApiResponse.success(T data, {String? message, int? statusCode}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode ?? 200,
    );
  }

  factory ApiResponse.error(
      String message, {
        int? statusCode,
        dynamic error,
        String? errorCode,
        String? errorDescription,
      }) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode ?? 500,
      error: error,
      errorCode: errorCode,
      errorDescription: errorDescription,
    );
  }

  /// Parse directly from backend JSON response
  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic)? fromData,
      int statusCode,
      ) {
    final isSuccess = statusCode >= 200 && statusCode < 300;

    if (isSuccess) {
      return ApiResponse(
        success: true,
        statusCode: statusCode,
        data: fromData != null ? fromData(json) : json as T?,
      );
    } else {
      return ApiResponse(
        success: false,
        statusCode: statusCode,
        // Backend error format: { "code": "...", "description": "..." }
        errorCode: json['code']?.toString(),
        errorDescription: json['description']?.toString(),
        message: json['description']?.toString() ??
            json['message']?.toString() ??
            'Something went wrong',
        error: json,
      );
    }
  }

  /// Helper to get the most useful error message to show user
  String get displayMessage {
    if (success) return message ?? 'Success';
    return errorDescription ?? message ?? 'Something went wrong';
  }
}