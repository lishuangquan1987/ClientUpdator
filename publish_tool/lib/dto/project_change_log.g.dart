// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_change_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectChangeLog _$ProjectChangeLogFromJson(Map<String, dynamic> json) =>
    ProjectChangeLog(
      version: json['version'] as String,
      logs: (json['logs'] as List<dynamic>).map((e) => e as String).toList(),
      time: json['time'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isDeleted: json['isDeleted'] as bool,
    );

Map<String, dynamic> _$ProjectChangeLogToJson(ProjectChangeLog instance) =>
    <String, dynamic>{
      'version': instance.version,
      'logs': instance.logs,
      'time': instance.time,
      'createdAt': instance.createdAt.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };
