import 'package:json_annotation/json_annotation.dart';

part 'server_os_info_dto.g.dart';

@JsonSerializable()
class ServerOsInfoDto {
  /*
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
  */

  String os;
  String platform;
  String goARCH;
  String version;
  int numCPU;
  String cpuName;
  String cpuMhz;
  String diskUsed;
  String diskFree;
  String diskTotal;
  String diskUsedPercent;

  ServerOsInfoDto(
    this.os,
    this.platform,
    this.goARCH,
    this.version,
    this.numCPU,
    this.cpuName,
    this.cpuMhz,
    this.diskUsed,
    this.diskFree,
    this.diskTotal,
    this.diskUsedPercent,
  );

  factory ServerOsInfoDto.fromJson(Map<String, dynamic> json) =>
      _$ServerOsInfoDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ServerOsInfoDtoToJson(this);
}
