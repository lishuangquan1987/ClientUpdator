// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommonResponse _$CommonResponseFromJson(Map<String, dynamic> json) =>
    CommonResponse(
      isSuccess: json['isSuccess'] as bool,
      errorMsg: json['errorMsg'] as String?,
      data: json['data'],
    );

Map<String, dynamic> _$CommonResponseToJson(CommonResponse instance) =>
    <String, dynamic>{
      'isSuccess': instance.isSuccess,
      'errorMsg': instance.errorMsg,
      'data': instance.data,
    };

CommonResponseWithT<T> _$CommonResponseWithTFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => CommonResponseWithT<T>(
  data: _$nullableGenericFromJson(json['data'], fromJsonT),
  isSuccess: json['isSuccess'] as bool,
  errorMsg: json['errorMsg'] as String?,
);

Map<String, dynamic> _$CommonResponseWithTToJson<T>(
  CommonResponseWithT<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'isSuccess': instance.isSuccess,
  'errorMsg': instance.errorMsg,
  'data': _$nullableGenericToJson(instance.data, toJsonT),
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);
