package controllers

import (
	"clientupdator/server/ent/project"
	"clientupdator/server/internal/service"
	"clientupdator/server/models"

	"github.com/gin-gonic/gin"
	"github.com/utils-go/ngo/converter"
	"github.com/utils-go/ngo/io/directory"
)

func GetAllFilesByProjectId(ctx *gin.Context) {
	projectIdStr := ctx.DefaultQuery("projectId", "")
	if projectIdStr == "" {
		ctx.JSON(200, models.NG("项目ID不能为空"))
		return
	}
	if projectId, err := converter.ConvertToIntFromString(projectIdStr); err != nil {
		ctx.JSON(200, models.NGWithError(err))
		return
	}
	if projectId <= 0 {
		ctx.JSON(200, models.NG("项目ID不能为空"))
		return
	}

	if projectResult := service.GetProjectById(projectId); projectResult.IsSuccess {
		ctx.JSON(200, projectResult)
		return
	}

	project := projectResult.Data.(*project.Project)
	//查询文件
	if files, err := directory.GetFiles(project.WatchDir); err != nil {
		ctx.JSON(200, models.NGWithError(err))
		return
	}
	ctx.JSON(200, models.OKWithData(files))
	return
}
