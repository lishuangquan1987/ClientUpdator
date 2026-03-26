import 'dart:ffi';

import 'package:json_annotation/json_annotation.dart';

part 'file_info_dto.g.dart';

@JsonSerializable()
class FileInfoDto {
  /*
  type FileInfo struct {
	FileAbsolutePath string    //文件绝对路径，用于服务端
	FileRelativePath string    //文件相对路径，用于客户端
	LastUpdateTime   time.Time //最后更新时间
	FileSize         int64     //文件大小
	MD5              string    //文件的MD5,用于标识文件是否改变
}
  */

  String fileAbsolutePath;
  String fileRelativePath;
  DateTime lastUpdateTime;
  int fileSize;
  String md5;

  FileInfoDto(
    this.fileAbsolutePath,
    this.fileRelativePath,
    this.lastUpdateTime,
    this.fileSize,
    this.md5,
  );

  factory FileInfoDto.fromJson(Map<String, dynamic> json) =>
      _$FileInfoDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FileInfoDtoToJson(this);
}
