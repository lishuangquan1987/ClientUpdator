package controllers

import (
	"archive/zip"
	"clientupdator/server/configs"
	"clientupdator/server/models"
	"crypto/md5"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"runtime"
	"strings"

	. "github.com/ahmetb/go-linq/v3"
	"github.com/gin-gonic/gin"
	"github.com/shirou/gopsutil/cpu"
	"github.com/shirou/gopsutil/disk"
	"github.com/shirou/gopsutil/host"
	"github.com/utils-go/ngo/io/directory"
	"github.com/utils-go/ngo/io/path"
)

func GetAllFiles(ctx *gin.Context) {
	folder := configs.Config.WatchFolder
	files := make([]models.FileInfo, 0)
	err := filepath.Walk(folder, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			log.Fatalf("walk err:%v", err)
		}
		//fmt.Printf("filepath.Walk abs:%s\n", path)
		relPath, _ := filepath.Rel(configs.Config.WatchFolder, path)
		//fmt.Printf("filepath.Walk rel:%s\n", relPath)

		if info.IsDir() {
			return nil //文件夹，则跳过
		}

		dir := filepath.Dir(relPath)   //文件夹路径
		dir_name := filepath.Base(dir) //文件夹名称
		fmt.Printf("filepath.Walk Dir:%s,dir_name:%s\n", dir, dir_name)
		if From(configs.Config.IgnoreFolder).WhereT(func(ignoreFolder string) bool {
			return IsInFolder(dir, ignoreFolder)
		}).Count() > 0 {
			//忽略的文件夹。跳过
			return nil
		}
		if From(configs.Config.IgnoreFile).WhereT(func(ignoreFile string) bool {
			return strings.EqualFold(ignoreFile, relPath)
		}).Count() > 0 {
			//忽略的文件，跳过
			return nil
		}
		md5, _ := calcFileMD5(path)
		files = append(files, models.FileInfo{
			FileRelativePath: relPath,
			FileAbsolutePath: path,
			LastUpdateTime:   info.ModTime(),
			FileSize:         info.Size(),
			MD5:              md5,
		})
		return nil
	})
	if err != nil {
		ctx.JSON(200, models.CommonResponse{
			IsSuccess: false,
			ErrorMsg:  err.Error(),
		})
		return
	}
	ctx.JSON(200, models.CommonResponse{
		IsSuccess: true,
		Data:      files,
	})
}

// // 判断target是否在source文件夹中。即使target与source相等也算
// func IsInFolder(target, source string) bool {
// 	targetLower := strings.ToLower(target)
// 	sourceLower := strings.ToLower(source)
// 	if strings.HasPrefix(targetLower, sourceLower) {
// 		return true
// 	}
// 	s := strings.ReplaceAll(sourceLower, "\\", "/")
// 	t := strings.ReplaceAll(targetLower, "\\", "/")
// 	if strings.HasPrefix(t, s) {
// 		return true
// 	}
// 	return false
// }

// 方法1：使用 filepath.Rel
func IsInFolder(targetPath, basePath string) bool {
	rel, err := filepath.Rel(basePath, targetPath)
	if err != nil {
		return false
	}
	// 如果相对路径不以 "../" 开头，说明 targetPath 在 basePath 内
	return !strings.HasPrefix(rel, "..") && rel != ".."
}

func DownloadFile(ctx *gin.Context) {
	path := ctx.Query("path")
	if !fileExist(path) {
		ctx.Redirect(http.StatusNotFound, "/404")
		return
	}
	basePath := filepath.Base(path)
	ctx.Header("Content-Type", "application/octet-stream")
	ctx.Header("Content-Disposition", "attachment; filename="+basePath)
	ctx.Header("Content-Transfer-Encoding", "binary")
	ctx.File(path)
}
func DownloadWholePackage(ctx *gin.Context) {
	ctx.Header("Content-Type", "application/octet-stream")
	ctx.Header("Content-Disposition", "attachment; filename="+"debug.7z")
	ctx.Header("Content-Transfer-Encoding", "binary")
	folder := configs.Config.WatchFolder
	zipFile := filepath.Join(folder, "../Debug.7z")
	if !fileExist(zipFile) {
		compress(folder, zipFile)
	}
	ctx.File(zipFile)
}
func Test(ctx *gin.Context) {
	folder := "F:\\Langtian\\代码\\Langtian.DCS-New-gocommunication\\Langtian.DCS\\Langtian.DCS.UI\\bin\\Debug"
	zipFile := filepath.Join(folder, "../debug.7z")
	compress(folder, zipFile)
	ctx.JSON(200, gin.H{
		"message": "finish",
	})
}

// 打包成zip文件
func compress(src_dir string, zip_file_name string) {

	fmt.Printf("src_dir:%s\nzip_file_name:%s\n", src_dir, zip_file_name)
	// 预防：旧文件无法覆盖
	os.RemoveAll(zip_file_name)

	// 创建：zip文件
	zipfile, err := os.Create(zip_file_name)
	if err != nil {
		log.Fatalf("create zip file error:%v", zipfile)
	}
	defer zipfile.Close()

	// 打开：zip文件
	archive := zip.NewWriter(zipfile)
	defer archive.Close()

	// 遍历路径信息
	filepath.Walk(src_dir, func(path string, info os.FileInfo, err error) error {

		if err != nil {
			log.Fatalf("walk err:%v", err)
		}
		// 如果是源路径，提前进行下一个遍历
		if path == src_dir {
			return nil
		}

		// 获取：文件头信息
		header, _ := zip.FileInfoHeader(info)
		header.Name = strings.TrimPrefix(path, src_dir+`\`)

		// 判断：文件是不是文件夹
		if info.IsDir() {
			header.Name += `/`
		} else {
			// 设置：zip的文件压缩算法
			header.Method = zip.Deflate
		}

		// 创建：压缩包头部信息
		writer, _ := archive.CreateHeader(header)
		if !info.IsDir() {
			file, _ := os.Open(path)
			defer file.Close()
			io.Copy(writer, file)
		}
		return nil
	})
}

func fileExist(path string) bool {
	_, err := os.Lstat(path)
	return !os.IsNotExist(err)
}
func calcFileMD5(filename string) (string, error) {
	f, err := os.Open(filename) //打开文件
	if nil != err {
		fmt.Println(err)
		return "", err
	}
	defer f.Close()

	md5Handle := md5.New()         //创建 md5 句柄
	_, err = io.Copy(md5Handle, f) //将文件内容拷贝到 md5 句柄中
	if nil != err {
		fmt.Println(err)
		return "", err
	}
	md := md5Handle.Sum(nil) //计算 MD5 值，返回 []byte

	md5str := fmt.Sprintf("%x", md) //将 []byte 转为 string
	return md5str, nil
}

// 上传文件
func UploadFile(ctx *gin.Context) {
	f, err := ctx.FormFile("file")
	if err != nil {
		ctx.JSON(200, models.CommonResponse{IsSuccess: false, ErrorMsg: err.Error()})
		return
	}
	fileName := ctx.GetHeader("FileName")

	if len(fileName) == 0 {
		ctx.JSON(200, models.CommonResponse{IsSuccess: false, ErrorMsg: "header中必须包含FileName"})
		return
	}
	//使用的是url编码，不然中文会报错
	if fileName, err = url.QueryUnescape(fileName); err != nil {
		ctx.JSON(200, models.CommonResponse{IsSuccess: false, ErrorMsg: "fileName解码失败"})
		return
	}

	fileName = strings.ReplaceAll(fileName, "\\", "/")
	absFileName := path.Combine(configs.Config.WatchFolder, fileName)
	dir := path.GetDirectoryName(absFileName)
	if !directory.Exists(dir) {
		if err = directory.CreateDirectory(dir); err != nil {
			ctx.JSON(200, models.CommonResponse{IsSuccess: false, ErrorMsg: fmt.Sprintf("create directory error:%v", err)})
			return
		}
	}

	if err = ctx.SaveUploadedFile(f, absFileName); err != nil {
		ctx.JSON(200, models.CommonResponse{IsSuccess: false, ErrorMsg: fmt.Sprintf("save upload file error:%v", err)})
		return
	}

	ctx.JSON(200, models.CommonResponse{IsSuccess: true})
}

// 更新配置
func UpdateConfig(ctx *gin.Context) {
	var cfg configs.ConfigStruct
	if err := ctx.ShouldBindJSON(&cfg); err != nil {
		ctx.JSON(200, models.CommonResponse{IsSuccess: false, ErrorMsg: err.Error()})
		return
	}

	//将配置写入到文件
	if err := configs.SaveConfig(cfg); err != nil {
		ctx.JSON(200, models.CommonResponse{IsSuccess: false, ErrorMsg: err.Error()})
		return
	}

	ctx.JSON(200, models.CommonResponse{IsSuccess: true})
}

// 获取服务器系统信息
func GetServerOSInfo(ctx *gin.Context) {
	platform, _, _, _ := host.PlatformInformation() //内核信息

	infos, _ := cpu.Info() //cpu信息工具类

	diskInfo, _ := disk.Usage(configs.Config.WatchFolder) //获取客户端更新文件所在盘的容量信息

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
