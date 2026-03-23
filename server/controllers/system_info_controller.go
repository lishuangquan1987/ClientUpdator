package controllers

import (
	"clientupdator/server/ent"
	"clientupdator/server/internal/service"
	"clientupdator/server/models"
	"runtime"

	"github.com/gin-gonic/gin"
	"github.com/shirou/gopsutil/cpu"
	"github.com/shirou/gopsutil/disk"
	"github.com/shirou/gopsutil/host"
)

// GetServerOSInfo 获取服务器系统信息
func GetServerOSInfo(ctx *gin.Context) {
	var projectIdUrl struct {
		ProjectId int `json:"projectId"`
	}
	if err := ctx.BindUri(&projectIdUrl); err != nil {
		ctx.JSON(200, models.NGWithError(err))
		return
	}

	projectResult := service.GetProjectById(projectIdUrl.ProjectId)
	if !projectResult.IsSuccess {
		ctx.JSON(200, models.NG(projectResult.ErrorMsg))
		return
	}

	project := projectResult.Data.(*ent.Project)

	platform, _, _, _ := host.PlatformInformation() //内核信息

	infos, _ := cpu.Info() //cpu信息工具类

	diskInfo, _ := disk.Usage(project.WatchDir) //获取客户端更新文件所在盘的容量信息

	serverOSInfo := make([]models.ServerOSInfo, 0)
	serverOSInfo = append(serverOSInfo, models.ServerOSInfo{
		OS:              runtime.GOOS,
		Platform:        platform,
		GOARCH:          runtime.GOARCH,
		Version:         runtime.Version(),
		NumCPU:          runtime.NumCPU(),
		CPUName:         infos[0].ModelName,
		CPUMhz:          infos[0].Mhz,
		DiskUsed:        float64((diskInfo.Used) / (1024 * 1024 * 1024)), //Byte 转为操作系统的 Gib 单位
		DiskFree:        float64((diskInfo.Free) / (1024 * 1024 * 1024)),
		DiskTotal:       float64((diskInfo.Total) / (1024 * 1024 * 1024)),
		DiskUsedPercent: diskInfo.UsedPercent,
	})
	ctx.JSON(200, models.CommonResponse{
		IsSuccess: true,
		Data:      serverOSInfo,
	})
}
