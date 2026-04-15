import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:publish_tool/models/project_config.dart';

class ConfigService {
  static const _fileName = 'publish_tool_config.json';

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<List<ProjectConfig>> loadConfigs() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final list = json['projects'] as List<dynamic>? ?? [];
      return list
          .map((e) => ProjectConfig.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveConfigs(List<ProjectConfig> configs) async {
    final file = await _getFile();
    final json = {'projects': configs.map((e) => e.toJson()).toList()};
    await file.writeAsString(jsonEncode(json));
  }
}
