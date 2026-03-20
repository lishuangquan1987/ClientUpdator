package service

import (
	"clientupdator/server/ent"
	"clientupdator/server/ent/project"
	"clientupdator/server/ent/projectchangelog"
	"clientupdator/server/internal/db"
	"clientupdator/server/models"
	"context"

	"github.com/utils-go/ngo/datetime"
)

func CreateProjectWithFirstLog(name string, watchDir string, isForceUpdate bool, ignoreFolders []string, ignoreFiles []string) models.CommonResponse {
	ctx := context.Background()
	var project *ent.Project
	err := db.WithTx(ctx, func(tx *ent.Tx) error {
		//插入项目
		var err error
		project, err = tx.Project.Create().
			SetName(name).
			SetVersion("V1.0.0").
			SetWatchDir(watchDir).
			SetForceUpdate(isForceUpdate).
			SetIgnoreFolders(ignoreFolders).
			SetIgnoreFiles(ignoreFiles).
			Save(ctx)
		if err != nil {
			return err
		}
		//插入项目变更日志
		timeStr, _ := datetime.Now().ToString("yyyy-MM-dd HH:mm:ss")
		_, err = tx.ProjectChangeLog.Create().
			SetProject(project).
			SetVersion("V1.0.0").
			SetLogs([]string{
				"第一次创建",
			}).
			SetTime(timeStr).
			Save(ctx)
		return err
	})
	if err != nil {
		return models.NGWithError(err)
	} else {
		return models.OKWithData(project)
	}
}

func UpdateProject(id int, name string, watchDir string, isForceUpdate bool, ignoreFolders []string, ignoreFiles []string) models.CommonResponse {
	ctx := context.Background()
	err := db.WithTx(ctx, func(tx *ent.Tx) error {
		//更新项目
		var err error
		_, err = tx.Project.Update().
			Where(project.IDEQ(id)).
			SetName(name).
			SetWatchDir(watchDir).
			SetForceUpdate(isForceUpdate).
			SetIgnoreFolders(ignoreFolders).
			SetIgnoreFiles(ignoreFiles).
			Save(ctx)
		if err != nil {
			return err
		}
		return err
	})
	if err != nil {
		return models.NGWithError(err)
	} else {
		return models.OK()
	}
}

func GetAllProjects() models.CommonResponse {
	ctx := context.Background()
	projects, err := db.Client.Project.Query().All(ctx)
	if err != nil {
		return models.NGWithError(err)
	} else {
		return models.OKWithData(projects)
	}
}

func GetProjectChangeLogs(projectId int) models.CommonResponse {
	ctx := context.Background()
	projectLogs, err := db.Client.ProjectChangeLog.
		Query().
		Where(projectchangelog.HasProjectWith(project.IDEQ(projectId))).
		All(ctx)
	if err != nil {
		return models.NGWithError(err)
	} else {
		return models.OKWithData(projectLogs)
	}
}

func GetProjectById(projectId int) models.CommonResponse {
	ctx := context.Background()
	project, err := db.Client.Project.Query().Where(project.IDEQ(projectId)).First(ctx)
	if err != nil {
		return models.NGWithError(err)
	} else {
		return models.OKWithData(project)
	}
}