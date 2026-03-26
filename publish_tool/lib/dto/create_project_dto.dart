import 'package:json_annotation/json_annotation.dart';

part 'create_project_dto.g.dart';

@JsonSerializable()
class CreateProjectDto {
  final String name;
  final String title;
  final bool isForceUpdate;
  final List<String> ignoreFolders;
  final List<String> ignoreFiles;

  CreateProjectDto({
    required this.name,
    required this.title,
    required this.isForceUpdate,
    required this.ignoreFolders,
    required this.ignoreFiles,
  });

  factory CreateProjectDto.fromJson(Map<String, dynamic> json) =>
      _$CreateProjectDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CreateProjectDtoToJson(this);
}
