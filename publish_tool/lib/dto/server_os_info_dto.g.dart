// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_os_info_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerOsInfoDto _$ServerOsInfoDtoFromJson(Map<String, dynamic> json) =>
    ServerOsInfoDto(
      json['os'] as String,
      json['platform'] as String,
      json['goARCH'] as String,
      json['version'] as String,
      (json['numCPU'] as num).toInt(),
      json['cpuName'] as String,
      json['cpuMhz'] as String,
      json['diskUsed'] as String,
      json['diskFree'] as String,
      json['diskTotal'] as String,
      json['diskUsedPercent'] as String,
    );

Map<String, dynamic> _$ServerOsInfoDtoToJson(ServerOsInfoDto instance) =>
    <String, dynamic>{
      'os': instance.os,
      'platform': instance.platform,
      'goARCH': instance.goARCH,
      'version': instance.version,
      'numCPU': instance.numCPU,
      'cpuName': instance.cpuName,
      'cpuMhz': instance.cpuMhz,
      'diskUsed': instance.diskUsed,
      'diskFree': instance.diskFree,
      'diskTotal': instance.diskTotal,
      'diskUsedPercent': instance.diskUsedPercent,
    };
