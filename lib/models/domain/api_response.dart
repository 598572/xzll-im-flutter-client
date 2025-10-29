// API响应基础模型
class ApiResponse<T> {
  bool get success => code == 1;
  final int? code;
  final String? message;
  final T? data;

  ApiResponse({this.code, this.message, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(Map<String, dynamic>)? fromJsonT,
  }) {
    return ApiResponse<T>(
      code: json['code'],
      message: json['message'],
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : null,
    );
  }

  factory ApiResponse.success(T data) {
    return ApiResponse<T>(code: 1, data: data);
  }

  factory ApiResponse.error(String message, {int? code}) {
    return ApiResponse<T>(code: code, message: message);
  }
}
