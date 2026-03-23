package controllers

import (
	"clientupdator/server/internal/service"
	"clientupdator/server/models"
	"fmt"

	"github.com/gin-gonic/gin"
	"github.com/utils-go/ngo/io/directory"
	"github.com/utils-go/ngo/io/path"
	"github.com/utils-go/ngo/stringUtils"
)

func UploadFile(ctx *gin.Context) {
	f, err := ctx.FormFile("file")
	if err != nil {
		ctx.JSON(200, models.NGWithError(err))
		return
	}

	var fileInfo struct {
		ProjectName string `json:"projectName"`
		FileName    string `json:"fileName"`
	}
	if err := ctx.ShouldBindJSON(&fileInfo); err != nil {
		ctx.JSON(200, models.NGWithError(err))
		return
	}

	if len(fileInfo.ProjectName) == 0 {
		ctx.JSON(200, models.NG("项目名称不能为空"))
		return
	}
	if len(fileInfo.FileName) == 0 {
		ctx.JSON(200, models.NG("header中必须包含FileName"))
		return
	}

	workDir, err := service.GetProjectWorkPath(fileInfo.ProjectName)
	if err != nil {
		ctx.JSON(200, models.NGWithError(err))
		return
	}

	fileName := stringUtils.Replace(fileInfo.FileName, "\\", "/")
	absFileName := path.Combine(workDir, fileName)
	dir := path.GetDirectoryName(absFileName)
	if !directory.Exists(dir) {
		if err = directory.CreateDirectory(dir); err != nil {
			ctx.JSON(200, models.NG(fmt.Sprintf("create directory error:%v", err)))
			return
		}
	}

	if err = ctx.SaveUploadedFile(f, absFileName); err != nil {
		ctx.JSON(200, models.NG(fmt.Sprintf("save upload file error:%v", err)))
		return
	}

	ctx.JSON(200, models.OK())
}
