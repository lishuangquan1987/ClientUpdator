package controllers

import (
	"clientupdator/server/ent"
	"clientupdator/server/ent/project"
	"clientupdator/server/internal/db"
	"clientupdator/server/internal/service"
	"clientupdator/server/models"
	"fmt"

	"github.com/gin-gonic/gin"
	"github.com/utils-go/ngo/io/directory"
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
	if !directory.Exists(createProjectDto.WatchDir) {
		//创建文件夹
		if err := directory.CreateDirectory(createProjectDto.WatchDir); err != nil {
			ctx.JSON(200, models.NGWithError(err))
			return
		}
	}
	//判断项目名称是否存在
	_, err := db.Client.Project.Query().Where(project.NameEQ(createProjectDto.Name)).First(ctx)
	if err == nil {
		ctx.JSON(200, models.NG(fmt.Sprintf("项目名称:%s已存在", createProjectDto.Name)))
		return
	}

	//插入
	result := service.CreateProjectWithFirstLog(
		createProjectDto.Name,
		createProjectDto.WatchDir,
		createProjectDto.IsForceUpdate,
		createProjectDto.IgnoreFolders,
		createProjectDto.IgnoreFiles)

	ctx.JSON(200, result)
}

func UpdateProject(ctx *gin.Context) {
	var updateProjectDto struct {
		ID            int      `json:"id"`
		Name          string   `json:"name"`
		WatchDir      string   `json:"watch_dir"`
		IsForceUpdate bool     `json:"is_force_update"`
		IgnoreFolders []string `json:"ignore_folders"`
		IgnoreFiles   []string `json:"ignore_files"`
	}
	if err := ctx.ShouldBindJSON(&updateProjectDto); err != nil {
		ctx.JSON(200, models.NGWithError(err))
		return
	}
	if updateProjectDto.ID <= 0 {
		ctx.JSON(200, models.NG("项目ID不能为空"))
		return
	}

	//判断项目名称是否为空
	if updateProjectDto.Name == "" {
		ctx.JSON(200, models.NG("项目名称不能为空"))
		return
	}
	//判断监控文件夹是否为空
	if updateProjectDto.WatchDir == "" {
		ctx.JSON(200, models.NG("监控文件夹不能为空"))
		return
	}
	if !directory.Exists(updateProjectDto.WatchDir) {
		//创建文件夹
		if err := directory.CreateDirectory(updateProjectDto.WatchDir); err != nil {
			ctx.JSON(200, models.NGWithError(err))
			return
		}
	}

	//判断项目名称是否存在
	_, err := db.Client.Project.Query().Where(project.IDEQ(int(updateProjectDto.ID))).First(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			ctx.JSON(200, models.NG("项目不存在"))
			return
		}
		ctx.JSON(200, models.NGWithError(err))
		return
	}

	//更新
	result := service.UpdateProject(
		updateProjectDto.ID,
		updateProjectDto.Name,
		updateProjectDto.WatchDir,
		updateProjectDto.IsForceUpdate,
		updateProjectDto.IgnoreFolders,
		updateProjectDto.IgnoreFiles)

	ctx.JSON(200, result)
}

func DeleteProject(ctx *gin.Context) {
	var projectIdDto struct {
		ProjectId int `json:"projectId"`
	}
	if err := ctx.BindUri(&projectIdDto); err != nil {
		ctx.JSON(200, models.NGWithError(err))
		return
	}

	ctx.JSON(200, service.DeleteProject(projectIdDto.ProjectId))
}

func GetAllProjects(ctx *gin.Context) {
	ctx.JSON(200, service.GetAllProjects())
}

func GetProjectChangeLogs(ctx *gin.Context) {
	var projectIdDto struct {
		ProjectId int `json:"projectId"`
	}
	if err := ctx.BindUri(&projectIdDto); err != nil {
		ctx.JSON(200, models.NGWithError(err))
		return
	}

	if projectIdDto.ProjectId <= 0 {
		ctx.JSON(200, models.NG("项目ID不能为空"))
		return
	}

	ctx.JSON(200, service.GetProjectChangeLogs(projectIdDto.ProjectId))
}
