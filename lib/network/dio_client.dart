import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:tracker/constants/env.dart';
import 'package:tracker/utils/talker.dart';
import 'package:tracker/constants/app_constants.dart';
import 'interceptors/api_key_interceptor.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;

  factory DioClient() => _instance;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: AppConstants.apiConnectTimeout,
        receiveTimeout: AppConstants.apiReceiveTimeout,
        responseType: ResponseType.json,
      ),
    );

    if (!kReleaseMode) {
      dio.interceptors.add(
        TalkerDioLogger(
          talker: talker,
          settings: const TalkerDioLoggerSettings(
            printErrorMessage: true,
            printErrorHeaders: true,
            printRequestExtra: true,
            printResponseData: true,
            printResponseMessage: true,
            printResponseRedirects: true,
            printResponseTime: true,
            printRequestHeaders: true,
            printRequestData: true,
            printResponseHeaders: false,
            printErrorData: true,
          ),
        ),
      );
    }

    dio.interceptors.add(ApiKeyInterceptor());
  }
}
