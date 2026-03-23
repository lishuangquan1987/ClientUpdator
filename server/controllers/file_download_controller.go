package controllers

import (
	"clientupdator/server/ent"
	"clientupdator/server/internal/service"
	"clientupdator/server/models"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/utils-go/ngo/collections/generic"
	"github.com/utils-go/ngo/io/directory"
	"github.com/utils-go/ngo/io/file"
	"github.com/utils-go/ngo/io/path"
	"github.com/utils-go/ngo/linq"
)

func GetAllFilesByProjectId(ctx *gin.Context) {
	var projectIdDto struct {
		ProjectId int `json:"projectId"`
	}
	if err := ctx.BindUri(&projectIdDto); err != nil {
		ctx.JSON(200, models.NGWithError(err))
		return
	}

	projectResult := service.GetProjectById(projectIdDto.ProjectId)
	if !projectResult.IsSuccess {
		ctx.JSON(200, projectResult)
		return
	}

	p := projectResult.Data.(*ent.Project)
	files, err := directory.GetFiles(p.WatchDir, "*,*", true)
	//查询文件
	if err != nil {
		ctx.JSON(200, models.NGWithError(err))
		return
	}

	result := generic.NewList[string]()
	for i := 0; i < len(files); i++ {
		//f是全路径
		f := files[i]
		//获取相对路径
		relPath, _ := path.GetRelativePath(p.WatchDir, f)
		if linq.From[string](p.IgnoreFolders).Where(func(ignoreFolder string) bool {
			return path.IsSubPath(relPath, ignoreFolder)
		}).Count() > 0 {
			//忽略的文件夹，跳过
			continue
		}
		if linq.From(p.IgnoreFiles).Where(func(ignoreFile string) bool {
			return ignoreFile == relPath
		}).Count() > 0 {
			//忽略的文件，跳过
			continue
		}
		result.Add(f)
	}

	ctx.JSON(200, models.OKWithData(result.ToArray()))
	return
}

func DownloadFile(ctx *gin.Context) {
	pathStr := ctx.Query("path")
	if !file.Exists(pathStr) {
		ctx.Redirect(http.StatusNotFound, "/404")
		return
	}
	fileName := path.GetFileName(pathStr)
	ctx.Header("Content-Type", "application/octet-stream")
	ctx.Header("Content-Disposition", "attachment; filename="+fileName)
	ctx.Header("Content-Transfer-Encoding", "binary")
	ctx.File(pathStr)
}
