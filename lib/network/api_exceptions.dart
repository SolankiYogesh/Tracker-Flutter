import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;

  // Response info
  final int? statusCode;
  final dynamic responseData;
  final Map<String, dynamic>? responseHeaders;

  // Request info
  final String? url;
  final String? method;
  final Map<String, dynamic>? requestHeaders;
  final dynamic requestBody;
  final Map<String, dynamic>? queryParameters;

  // Dio specific
  final DioExceptionType? type;

  ApiException({
    required this.message,
    this.statusCode,
    this.responseData,
    this.responseHeaders,
    this.url,
    this.method,
    this.requestHeaders,
    this.requestBody,
    this.queryParameters,
    this.type,
  });

  factory ApiException.fromDio(DioException e) {
    final request = e.requestOptions;
    final response = e.response;

    return ApiException(
      message: _extractMessage(e),
      statusCode: response?.statusCode,
      responseData: response?.data,
      responseHeaders: response?.headers.map,
      url: request.uri.toString(),
      method: request.method,
      requestHeaders: request.headers,
      requestBody: request.data,
      queryParameters: request.queryParameters,
      type: e.type,
    );
  }

  static String _extractMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map) {
      return (data['message'] ??
              data['error'] ??
              data['detail'] ??
              'Server error')
          .toString();
    }

    if (data is String) {
      return data;
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.badResponse:
        return 'Invalid server response';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      default:
        return e.message ?? 'Network error';
    }
  }

  /// 🔥 Pretty debug output
  @override
  String toString() {
    return '''
════════════════════════════════════
API EXCEPTION
════════════════════════════════════
URL: $url
Method: $method
Status Code: $statusCode
Error Type: $type

Request Headers:
$requestHeaders

Query Parameters:
$queryParameters

Request Body:
$requestBody

Response Headers:
$responseHeaders

Response Data:
$responseData

Message:
$message
════════════════════════════════════
''';
  }
}
