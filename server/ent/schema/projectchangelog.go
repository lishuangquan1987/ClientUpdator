package schema

import (
	"entgo.io/ent"
	"entgo.io/ent/schema/edge"
	"entgo.io/ent/schema/field"
)

// ProjectChangeLog holds the schema definition for the ProjectChangeLog entity.
type ProjectChangeLog struct {
	ent.Schema
}

// Fields of the ProjectChangeLog.
func (ProjectChangeLog) Fields() []ent.Field {
	return []ent.Field{
		field.String("version").Comment("版本号"),
		field.JSON("logs", []string{}).Comment("变更日志集合"),
		field.String("time").Comment("变更时间"),
	}
}

// Edges of the ProjectChangeLog.
func (ProjectChangeLog) Edges() []ent.Edge {
	return []ent.Edge{
		edge.From("project", Project.Type).Ref("change_logs").Unique(),
	}
}
