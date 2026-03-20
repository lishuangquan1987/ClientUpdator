package schema

import (
	"entgo.io/ent"
	"entgo.io/ent/schema/edge"
	"entgo.io/ent/schema/field"
)

// Project holds the schema definition for the Project entity.
type Project struct {
	ent.Schema
}

// Fields of the Project.
func (Project) Fields() []ent.Field {
	return []ent.Field{
		field.String("name").Comment("项目名称"),
		field.String("version").Comment("项目版本"),
		field.Bool("force_update").Comment("是否强制更新"),
		field.String("watch_dir").Comment("监控文件夹"),
		field.JSON("ignore_folders", []string{}).Optional().Comment("忽略的文件夹"),
		field.JSON("ignore_files", []string{}).Optional().Comment("忽略的文件"),
	}
}

// Edges of the Project.
func (Project) Edges() []ent.Edge {
	return []ent.Edge{
		edge.To("change_logs", ProjectChangeLog.Type),
	}
}
