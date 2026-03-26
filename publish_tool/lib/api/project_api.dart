import 'package:publish_tool/api/base_api.dart';
import 'package:publish_tool/dto/common_response.dart';
import 'package:publish_tool/dto/create_project_dto.dart';
import 'package:publish_tool/dto/project_change_log.dart';
import 'package:publish_tool/dto/project_dto.dart';
import 'package:publish_tool/dto/server_os_info_dto.dart';
import 'package:publish_tool/dto/update_project_dto.dart';

class ProjectApi extends BaseApi {
  ProjectApi(super.baseUrl);

  Future<CommonResponseWithT<ProjectDto>> createProject(
    CreateProjectDto dto,
  ) async {
    var url = "api/project/create_project";
    final response = await doPostWithT<ProjectDto>(
      url,
      dto,
      (data) => ProjectDto.fromJson(data as Map<String, dynamic>),
    );

    return response;
  }

  Future<CommonResponse> updateProject(UpdateProjectDto dto) async {
    var url = "api/project/update_project";
    final response = await doPost(url, dto);
    return response;
  }

  Future<CommonResponse> deleteProject(int id) async {
    var url = "api/project/delete_project/$id";
    final response = await doPost(url, {});
    return response;
  }

  Future<CommonResponseWithT<List<ProjectDto>>> getAllProjects() async {
    var url = "api/project/get_all_projects";
    final response = await doGet<List<ProjectDto>>(
      url,
      (data) => (data as List)
          .map((e) => ProjectDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return response;
  }

  Future<CommonResponseWithT<List<ProjectChangeLog>>> getProjectChangeLogs(
    int projectId,
  ) async {
    var url = "api/project/get_project_change_logs/$projectId";
    final response = await doGet<List<ProjectChangeLog>>(
      url,
      (data) => (data as List)
          .map((e) => ProjectChangeLog.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return response;
  }

  Future<CommonResponseWithT<ServerOsInfoDto>> getProjectOsInfo(int projectId) {
    var url = "api/project/get_project_os_info/$projectId";
    return doGet(
      url,
      (o) => ServerOsInfoDto.fromJson(o as Map<String, dynamic>),
    );
  }
}
