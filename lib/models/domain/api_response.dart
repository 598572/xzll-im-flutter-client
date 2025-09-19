// API响应基础模型
class ApiResponse<T> {
  final bool success;
  final int? code;
  final String? message;
  final T? data;

  ApiResponse({required this.success, this.code, this.message, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      code: json['code'],
      message: json['message'],
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : null,
    );
  }

  factory ApiResponse.success(T data) {
    return ApiResponse<T>(success: true, data: data);
  }

  factory ApiResponse.error(String message, {int? code}) {
    return ApiResponse<T>(success: false, code: code, message: message);
  }
}
