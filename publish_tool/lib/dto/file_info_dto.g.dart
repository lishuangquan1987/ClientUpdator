// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_info_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileInfoDto _$FileInfoDtoFromJson(Map<String, dynamic> json) => FileInfoDto(
  json['fileAbsolutePath'] as String,
  json['fileRelativePath'] as String,
  DateTime.parse(json['lastUpdateTime'] as String),
  (json['fileSize'] as num).toInt(),
  json['md5'] as String,
);

Map<String, dynamic> _$FileInfoDtoToJson(FileInfoDto instance) =>
    <String, dynamic>{
      'fileAbsolutePath': instance.fileAbsolutePath,
      'fileRelativePath': instance.fileRelativePath,
      'lastUpdateTime': instance.lastUpdateTime.toIso8601String(),
      'fileSize': instance.fileSize,
      'md5': instance.md5,
    };
