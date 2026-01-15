import 'package:dio/dio.dart';

class ApiException implements Exception {

  ApiException(this.message, {this.statusCode, this.data});

  factory ApiException.fromDio(DioException e) {
    return ApiException(
      _extractMessage(e),
      statusCode: e.response?.statusCode,
      data: e.response?.data,
    );
  }
  final String message;
  final int? statusCode;
  final dynamic data;

  static String _extractMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map) {
      return (data['message'] ??
          data['error'] ??
          data['detail'] ??
          'Server error') as String;
    }

    if (data is String) {
      return data;
    }

    return e.message ?? 'Network error';
  }

  @override
  String toString() {
    return '''
ApiException(
  statusCode: $statusCode,
  message: $message,
  data: $data
)
''';
  }
}
