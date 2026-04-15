class ProjectConfig {
  int serverId;
  String name;
  String title;
  String serverUrl;
  String exePath;
  String localPath;
  int sortOrder;

  ProjectConfig({
    required this.serverId,
    required this.name,
    required this.title,
    required this.serverUrl,
    this.exePath = '',
    this.localPath = '',
    this.sortOrder = 0,
  });

  factory ProjectConfig.fromJson(Map<String, dynamic> json) => ProjectConfig(
        serverId: (json['serverId'] as num).toInt(),
        name: json['name'] as String,
        title: json['title'] as String,
        serverUrl: json['serverUrl'] as String,
        exePath: json['exePath'] as String? ?? '',
        localPath: json['localPath'] as String? ?? '',
        sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'serverId': serverId,
        'name': name,
        'title': title,
        'serverUrl': serverUrl,
        'exePath': exePath,
        'localPath': localPath,
        'sortOrder': sortOrder,
      };
}
