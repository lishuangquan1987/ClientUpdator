package routers

import (
	"github.com/gin-gonic/gin"
	"yofc.update.server/controllers"
)

func InitRouter(r *gin.Engine) {
	r.GET("/test", controllers.Test)
	r.GET("/get_all_files", controllers.GetAllFiles)
	r.GET("/download_file", controllers.DownloadFile)
	r.GET("/download_whole_package", controllers.DownloadWholePackage)
	r.GET("/get_version", controllers.GetVersionInfo)
	r.POST("/update_config", controllers.UpdateConfig)
	r.GET("/get_server_os_info", controllers.GetServerOSInfo)
	r.POST("upload_file", controllers.UploadFile)
}
