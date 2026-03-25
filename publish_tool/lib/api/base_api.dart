import 'package:dio/dio.dart';
import 'package:publish_tool/logger/log_helper.dart';

class BaseApi {
  late Dio _dio;
  String baseUrl = "";
  BaseApi(this.baseUrl) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 500),
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          LogHelper.trace(options);
          return handler.next(options);
        },
        onResponse: (response, handler) {
          LogHelper.trace(response);
          return handler.next(response);
        },
        onError: (error, handler) {
          LogHelper.errorWithError(error);
          return handler.next(error);
        },
      ),
    );
  }
}
