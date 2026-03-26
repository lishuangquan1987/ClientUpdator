import 'package:json_annotation/json_annotation.dart';

part 'update_project_dto.g.dart';

@JsonSerializable()
class UpdateProjectDto {
  final int id;
  final String title;
  final bool isForceUpdate;
  final List<String> ignoreFolders;
  final List<String> ignoreFiles;

  UpdateProjectDto({
    required this.id,
    required this.title,
    required this.isForceUpdate,
    required this.ignoreFiles,
    required this.ignoreFolders,
  });

  factory UpdateProjectDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateProjectDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateProjectDtoToJson(this);
}
