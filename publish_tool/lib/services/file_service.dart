import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:publish_tool/api/file_api.dart';
import 'package:publish_tool/dto/file_info_dto.dart';
import 'package:publish_tool/models/local_file_item.dart';
import 'package:publish_tool/models/upload_file_item.dart';

class FileService {
  FileApi _api(String serverUrl) => FileApi(serverUrl);

  Future<List<LocalFileItem>> scanLocalFiles(String localPath) async {
    final dir = Directory(localPath);
    if (!await dir.exists()) return [];
    final items = <LocalFileItem>[];
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        final stat = await entity.stat();
        final relativePath =
            p.relative(entity.path, from: localPath).replaceAll('\\', '/');
        items.add(LocalFileItem(
          fileName: p.basename(entity.path),
          absolutePath: entity.path,
          relativePath: relativePath,
          lastModified: stat.modified,
        ));
      }
    }
    return items;
  }

  Future<List<FileInfoDto>> getServerFiles(
      String serverUrl, int projectId) async {
    final res = await _api(serverUrl).getAllFilesByProjectId(projectId);
    if (!res.isSuccess) throw Exception(res.errorMsg);
    return res.data ?? [];
  }

  Future<void> uploadFile(
    String serverUrl,
    UploadFileItem item,
    String projectName, {
    Function(int, int)? progress,
    CancelToken? token,
  }) async {
    final res = await _api(serverUrl).uploadFile(
      item.localPath,
      item.relativePath,
      projectName,
      progress: progress,
      token: token,
    );
    if (!res.isSuccess) throw Exception(res.errorMsg);
  }

  Future<void> downloadFile(
    String serverUrl,
    FileInfoDto serverFile,
    String localBasePath, {
    Function(int, int)? progress,
    CancelToken? token,
  }) async {
    final savePath =
        p.join(localBasePath, serverFile.fileRelativePath.replaceAll('/', p.separator));
    final saveFile = File(savePath);
    await saveFile.parent.create(recursive: true);
    final res = await _api(serverUrl).downloadFile(
      serverFile.fileAbsolutePath,
      savePath,
      progress: progress,
      token: token,
    );
    if (!res.isSuccess) throw Exception(res.errorMsg);
  }

  Future<List<FileInfoDto>> diffFiles(
    List<LocalFileItem> local,
    List<FileInfoDto> server,
  ) async {
    final localMd5Map = <String, String>{};
    for (final item in local) {
      final bytes = await File(item.absolutePath).readAsBytes();
      localMd5Map[item.relativePath] = md5.convert(bytes).toString();
    }
    return server.where((s) {
      final localHash = localMd5Map[s.fileRelativePath];
      return localHash == null || localHash != s.md5;
    }).toList();
  }
}
