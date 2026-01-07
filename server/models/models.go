package models

import "time"

type FileInfo struct {
	FileAbsolutePath string    //文件绝对路径，用于服务端
	FileRelativePath string    //文件相对路径，用于客户端
	LastUpdateTime   time.Time //最后更新时间
	FileSize         int64     //文件大小
	MD5              string    //文件的MD5,用于标识文件是否改变
}

type CommonResponse struct {
	IsSuccess bool
	ErrorMsg  string
	Data      interface{}
}

// 模型-系统信息
type ServerOSInfo struct {
	OS              string  //系统类型
	Platform        string  //平台
	GOARCH          string  //架构
	Version         string  //Go版本
	NumCPU          int     //线程数
	CPUName         string  //处理器型号
	CPUMhz          float64 //处理器频率
	DiskUsed        float64 //磁盘已用容量
	DiskFree        float64 //磁盘剩余容量
	DiskTotal       float64 //磁盘容量
	DiskUsedPercent float64 //磁盘使用率
}
