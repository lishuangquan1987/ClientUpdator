import 'package:json_annotation/json_annotation.dart';

part 'project_dto.g.dart';

@JsonSerializable()
class ProjectDto {
  final String name;
  final String title;
  final String? version;
  final bool isForceUpdate;
  final List<String>? ignoreFolders;
  final List<String>? ignoreFiles;
  final DateTime createAt;
  final bool? isDeleted;
  ProjectDto({
    required this.name,
    required this.title,
    required this.isForceUpdate,
    this.ignoreFolders,
    this.ignoreFiles,
    required this.createAt,
    this.isDeleted,
    this.version,
  });

  factory ProjectDto.fromJson(Map<String, dynamic> json) =>
      _$ProjectDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectDtoToJson(this);
}
