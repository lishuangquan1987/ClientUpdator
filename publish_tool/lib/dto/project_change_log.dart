import 'package:json_annotation/json_annotation.dart';

part 'project_change_log.g.dart';

@JsonSerializable()
class ProjectChangeLog {
  /*
return []ent.Field{
		field.String("version").Comment("版本号"),
		field.JSON("logs", []string{}).Comment("变更日志集合"),
		field.String("time").Comment("变更时间"),
		field.Time("created_at").Default(time.Now).Comment("创建日期"),
		field.Bool("is_deleted").Default(false).Comment("是否被删除"),
	}
  */

  String version;
  List<String> logs;
  String time;
  DateTime createdAt;
  bool isDeleted;
  ProjectChangeLog({
    required this.version,
    required this.logs,
    required this.time,
    required this.createdAt,
    required this.isDeleted,
  });

  factory ProjectChangeLog.fromJson(Map<String, dynamic> json) =>
      _$ProjectChangeLogFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectChangeLogToJson(this);
}
