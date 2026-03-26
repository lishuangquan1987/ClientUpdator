import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:publish_tool/dto/common_response.dart';
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

  Future<CommonResponse> doPost(String url, Object data) async {
    try {
      final response = await _dio.post(url, data: data);
      var result = CommonResponse.fromJson(response.data);
      return result;
    } on Error catch (e) {
      return CommonResponse.ng(e);
    }
  }

  Future<CommonResponseWithT<T>> doPostWithT<T>(
    String url,
    Object data,
    T Function(Object? value) fromJson,
  ) async {
    try {
      final response = await _dio.post(url, data: data);
      var result = CommonResponseWithT.fromJson(response.data, fromJson);
      return result;
    } on Error catch (e) {
      return CommonResponseWithT.ng(e);
    }
  }

  Future<CommonResponseWithT<T>> doGet<T>(
    String url,
    T Function(Object? value) fromJson,
  ) async {
    try {
      final response = await _dio.get(url);
      var result = CommonResponseWithT.fromJson(response.data, fromJson);
      return result;
    } on Error catch (e) {
      return CommonResponseWithT.ng(e);
    }
  }

  Future<CommonResponse> doUploadFile(
    String url,
    String filePath,
    Map<String, String>? data,
    Function(int send, int total)? progress,
    CancelToken? token,
  ) async {
    try {
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filePath),
      });
      if (data != null) {
        data.forEach((key, value) {
          formData.fields.add(MapEntry(key, value));
        });
      }
      final response = await _dio.post(
        url,
        data: formData,
        onSendProgress: progress,
        cancelToken: token,
      );
      return CommonResponse.fromJson(response.data);
    } on Error catch (e) {
      return CommonResponse.ng(e);
    }
  }

  Future<CommonResponse> doDownloadFile(
    String url,
    String savePath,
    Function(int, int)? progress,
    CancelToken? token,
  ) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: progress,
        cancelToken: token,
      );
      return CommonResponse.ok();
    } on Error catch (e) {
      return CommonResponse.ng(e);
    }
  }
}
