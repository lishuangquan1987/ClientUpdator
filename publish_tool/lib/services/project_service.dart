import 'package:publish_tool/api/project_api.dart';
import 'package:publish_tool/dto/create_project_dto.dart';
import 'package:publish_tool/dto/project_change_log.dart';
import 'package:publish_tool/dto/project_dto.dart';
import 'package:publish_tool/dto/server_os_info_dto.dart';
import 'package:publish_tool/dto/update_project_dto.dart';

class ProjectService {
  ProjectApi _api(String serverUrl) => ProjectApi(serverUrl);

  Future<List<ProjectDto>> getAllProjects(String serverUrl) async {
    final res = await _api(serverUrl).getAllProjects();
    if (!res.isSuccess) throw Exception(res.errorMsg);
    return res.data ?? [];
  }

  Future<ServerOsInfoDto?> getOsInfo(String serverUrl, int projectId) async {
    final res = await _api(serverUrl).getProjectOsInfo(projectId);
    if (!res.isSuccess) return null;
    return res.data;
  }

  Future<List<ProjectChangeLog>> getChangeLogs(
      String serverUrl, int projectId) async {
    final res = await _api(serverUrl).getProjectChangeLogs(projectId);
    if (!res.isSuccess) throw Exception(res.errorMsg);
    return res.data ?? [];
  }

  Future<ProjectDto> createProject(
      String serverUrl, CreateProjectDto dto) async {
    final res = await _api(serverUrl).createProject(dto);
    if (!res.isSuccess || res.data == null) throw Exception(res.errorMsg);
    return res.data!;
  }

  Future<void> updateProject(String serverUrl, UpdateProjectDto dto) async {
    final res = await _api(serverUrl).updateProject(dto);
    if (!res.isSuccess) throw Exception(res.errorMsg);
  }

  Future<void> deleteProject(String serverUrl, int id) async {
    final res = await _api(serverUrl).deleteProject(id);
    if (!res.isSuccess) throw Exception(res.errorMsg);
  }
}
