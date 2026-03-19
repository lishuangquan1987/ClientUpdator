package controllers

import (
	"clientupdator/server/ent/project"
	"clientupdator/server/internal/db"
	"clientupdator/server/models"

	"github.com/gin-gonic/gin"
)

func CreateProject(ctx *gin.Context) {
	var createProjectDto struct {
		Name          string   `json:"name"`
		WatchDir      string   `json:"watch_dir"`
		IsForceUpdate bool     `json:"is_force_update"`
		IgnoreFolders []string `json:"ignore_folders"`
		IgnoreFiles   []string `json:"ignore_files"`
	}
	// 解析请求体
	if err := ctx.ShouldBindJSON(&createProjectDto); err != nil {
		ctx.JSON(200, models.NGWithError(err))
		return
	}

	//判断项目名称是否为空
	if createProjectDto.Name == "" {
		ctx.JSON(200, models.NG("项目名称不能为空"))
		return
	}
	//判断监控文件夹是否为空
	if createProjectDto.WatchDir == "" {
		ctx.JSON(200, models.NG("监控文件夹不能为空"))
		return
	}
	//判断项目名称是否存在
	_, err := db.Client.Project.Query().Where(project.NameEQ(createProjectDto.Name)).First(ctx)
	if err == nil {
		ctx.JSON(200, models.NG("项目名称已存在"))
		return
	}

	//插入
	project, err := db.Client.Project.Create().
		SetName(createProjectDto.Name).
		SetVersion("V1.0.0").
		SetForceUpdate(createProjectDto.IsForceUpdate).
		SetWatchDir(createProjectDto.WatchDir).
		SetIgnoreFolders(createProjectDto.IgnoreFolders).
		SetIgnoreFiles(createProjectDto.IgnoreFiles).
		Save(ctx)
	if err != nil {
		ctx.JSON(200, models.NGWithError(err))
		return
	}
}
