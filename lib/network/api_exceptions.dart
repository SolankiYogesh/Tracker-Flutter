import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  factory ApiException.fromDio(DioException e) {
    if (e.response != null) {
      return ApiException(e.response?.data.toString() ?? 'Server error');
    }
    return ApiException('Network error');
  }
}
