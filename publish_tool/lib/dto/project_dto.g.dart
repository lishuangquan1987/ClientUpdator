// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectDto _$ProjectDtoFromJson(Map<String, dynamic> json) => ProjectDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      title: json['title'] as String,
      isForceUpdate: json['isForceUpdate'] as bool,
      ignoreFolders: (json['ignoreFolders'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      ignoreFiles: (json['ignoreFiles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createAt: DateTime.parse(json['createAt'] as String),
      isDeleted: json['isDeleted'] as bool?,
      version: json['version'] as String?,
    );

Map<String, dynamic> _$ProjectDtoToJson(ProjectDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'title': instance.title,
      'version': instance.version,
      'isForceUpdate': instance.isForceUpdate,
      'ignoreFolders': instance.ignoreFolders,
      'ignoreFiles': instance.ignoreFiles,
      'createAt': instance.createAt.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };
