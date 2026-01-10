import 'package:dio/dio.dart';
import 'package:tracker/constants/api_constants.dart';

class ApiKeyInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['x-api-key'] = Env.apiKey;
    super.onRequest(options, handler);
  }
}
