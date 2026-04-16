import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:publish_tool/dto/project_change_log.dart';
import 'package:publish_tool/dto/server_os_info_dto.dart';
import 'package:publish_tool/dto/update_project_dto.dart';
import 'package:publish_tool/models/local_file_item.dart';
import 'package:publish_tool/models/project_config.dart';
import 'package:publish_tool/models/upload_file_item.dart';
import 'package:publish_tool/services/file_service.dart';
import 'package:publish_tool/services/process_service.dart';
import 'package:publish_tool/services/project_service.dart';

class ProjectController extends GetxController {
  final ProjectConfig projectConfig;
  ProjectController(this.projectConfig);

  final _projectService = Get.find<ProjectService>();
  final _fileService = Get.find<FileService>();
  final _processService = Get.find<ProcessService>();

  CancelToken? _cancelToken;

  final serverOsInfo = Rxn<ServerOsInfoDto>();
  final serverVersion = ''.obs;
  final serverChangeLogs = <ProjectChangeLog>[].obs;
  final localFiles = <LocalFileItem>[].obs;
  final localFileFilter = ''.obs;
  final uploadQueue = <UploadFileItem>[].obs;
  final newVersion = ''.obs;
  final newChangeLogs = ''.obs;
  final appendToLatest = false.obs;
  final autoRefreshAfterPush = true.obs;
  final statusMessage = ''.obs;
  final isBusy = false.obs;

  List<LocalFileItem> get filteredLocalFiles => localFiles
      .where((f) =>
          localFileFilter.value.isEmpty ||
          f.fileName.contains(localFileFilter.value))
      .toList();

  @override
  void onInit() {
    super.onInit();
    refreshStatus();
  }

  Future<void> refreshStatus() async {
    isBusy.value = true;
    statusMessage.value = '正在刷新服务器信息...';
    try {
      final osInfo = await _projectService.getOsInfo(
          projectConfig.serverUrl, projectConfig.serverId);
      serverOsInfo.value = osInfo;

      final logs = await _projectService.getChangeLogs(
          projectConfig.serverUrl, projectConfig.serverId);
      serverChangeLogs.assignAll(logs);
      serverVersion.value = logs.isNotEmpty ? logs.first.version : '';
      statusMessage.value = '刷新完成';
    } catch (e) {
      statusMessage.value = '刷新失败: $e';
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> loadLocalFiles() async {
    if (projectConfig.localPath.isEmpty) {
      statusMessage.value = '本地路径未配置';
      return;
    }
    isBusy.value = true;
    statusMessage.value = '正在扫描本地文件...';
    try {
      final files = await _fileService.scanLocalFiles(projectConfig.localPath);
      localFiles.assignAll(files);
      statusMessage.value = '扫描完成，共 ${files.length} 个文件';
    } catch (e) {
      statusMessage.value = '扫描失败: $e';
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> openLocalFolder() async {
    if (projectConfig.localPath.isNotEmpty) {
      await _processService.openFolder(projectConfig.localPath);
    }
  }

  void addToUploadQueue(List<LocalFileItem> items) {
    for (final item in items) {
      if (!uploadQueue.any((u) => u.relativePath == item.relativePath)) {
        uploadQueue.add(UploadFileItem(
          fileName: item.fileName,
          localPath: item.absolutePath,
          relativePath: item.relativePath,
          lastModified: item.lastModified,
        ));
      }
    }
  }

  void removeFromUploadQueue(UploadFileItem item) {
    uploadQueue.remove(item);
  }

  Future<void> pushAll() async {
    final checked = localFiles.where((f) => f.isChecked).toList();
    if (checked.isEmpty) {
      statusMessage.value = '请先选择要推送的文件';
      return;
    }
    addToUploadQueue(checked);
    await _uploadQueue();
  }

  Future<void> _uploadQueue() async {
    if (uploadQueue.isEmpty) return;
    _cancelToken = CancelToken();
    isBusy.value = true;
    int done = 0;
    for (final item in uploadQueue) {
      if (_cancelToken!.isCancelled) break;
      item.status = UploadStatus.uploading;
      uploadQueue.refresh();
      try {
        await _fileService.uploadFile(
          projectConfig.serverUrl,
          item,
          projectConfig.name,
          token: _cancelToken,
        );
        item.status = UploadStatus.done;
        done++;
      } catch (e) {
        item.status = UploadStatus.failed;
        statusMessage.value = '上传失败: $e';
      }
      uploadQueue.refresh();
    }
    isBusy.value = false;
    statusMessage.value = '上传完成 $done/${uploadQueue.length}';
    if (autoRefreshAfterPush.value) await refreshStatus();
  }

  void stop() {
    _cancelToken?.cancel('用户停止');
    isBusy.value = false;
    statusMessage.value = '已停止';
  }

  Future<void> downloadAll() async {
    if (projectConfig.localPath.isEmpty) {
      statusMessage.value = '本地路径未配置';
      return;
    }
    isBusy.value = true;
    _cancelToken = CancelToken();
    statusMessage.value = '正在下载所有文件...';
    try {
      final serverFiles = await _fileService.getServerFiles(
          projectConfig.serverUrl, projectConfig.serverId);
      for (final f in serverFiles) {
        if (_cancelToken!.isCancelled) break;
        await _fileService.downloadFile(
          projectConfig.serverUrl,
          f,
          projectConfig.localPath,
          token: _cancelToken,
        );
      }
      statusMessage.value = '下载完成，共 ${serverFiles.length} 个文件';
    } catch (e) {
      statusMessage.value = '下载失败: $e';
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> pullAll() async {
    if (projectConfig.localPath.isEmpty) {
      statusMessage.value = '本地路径未配置';
      return;
    }
    isBusy.value = true;
    _cancelToken = CancelToken();
    statusMessage.value = '正在对比文件...';
    try {
      final serverFiles = await _fileService.getServerFiles(
          projectConfig.serverUrl, projectConfig.serverId);
      final local = await _fileService.scanLocalFiles(projectConfig.localPath);
      final diff = await _fileService.diffFiles(local, serverFiles);
      statusMessage.value = '需要下载 ${diff.length} 个文件';
      for (final f in diff) {
        if (_cancelToken!.isCancelled) break;
        await _fileService.downloadFile(
          projectConfig.serverUrl,
          f,
          projectConfig.localPath,
          token: _cancelToken,
        );
      }
      statusMessage.value = '拉取完成，更新 ${diff.length} 个文件';
    } catch (e) {
      statusMessage.value = '拉取失败: $e';
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> refreshFiles() async {
    await loadLocalFiles();
  }

  void autoGenerateVersion() {
    newVersion.value = DateFormat('yyyyMMdd-HHmm').format(DateTime.now());
  }

  Future<void> pushUpdate() async {
    if (newVersion.value.isEmpty) {
      statusMessage.value = '请输入版本号';
      return;
    }
    await _uploadQueue();
    // TODO: submit version log via API when endpoint is available
    statusMessage.value = '推送更新完成，版本: ${newVersion.value}';
  }

  Future<void> openProjectSettings() async {
    // Triggered from view layer via dialog
  }

  Future<void> openConfigEditor() async {
    // Triggered from view layer via dialog
  }

  Future<void> buildProject() async {
    statusMessage.value = '正在打包...';
    isBusy.value = true;
    try {
      final result = await _processService.buildProject(
          'flutter build windows --release', projectConfig.localPath);
      statusMessage.value =
          result.exitCode == 0 ? '打包成功' : '打包失败: ${result.stderr}';
    } catch (e) {
      statusMessage.value = '打包失败: $e';
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> defaultLaunch() async {
    if (projectConfig.exePath.isEmpty) {
      statusMessage.value = 'exe 路径未配置';
      return;
    }
    await _processService.launchExe(projectConfig.exePath);
  }

  Future<void> customLaunch(String args) async {
    if (projectConfig.exePath.isEmpty) {
      statusMessage.value = 'exe 路径未配置';
      return;
    }
    await _processService.launchExe(projectConfig.exePath,
        args: args.split(' ').where((s) => s.isNotEmpty).toList());
  }

  Future<void> previewLogs() async {
    // open log file if exists
  }

  Future<void> openExplorer() async {
    await openLocalFolder();
  }

  Future<void> updateProjectSettings(
      String title, String exePath, String localPath) async {
    projectConfig.title = title;
    projectConfig.exePath = exePath;
    projectConfig.localPath = localPath;
    try {
      final dto = UpdateProjectDto(
        id: projectConfig.serverId,
        title: title,
        isForceUpdate: false,
        ignoreFolders: [],
        ignoreFiles: [],
      );
      await _projectService.updateProject(projectConfig.serverUrl, dto);
      statusMessage.value = '设置已保存';
    } catch (e) {
      statusMessage.value = '保存失败: $e';
    }
  }
}
