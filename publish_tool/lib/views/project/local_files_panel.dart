import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:publish_tool/viewmodels/project_controller.dart';

class LocalFilesPanel extends StatelessWidget {
  final String tag;
  const LocalFilesPanel({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProjectController>(tag: tag);
    final dateFmt = DateFormat('MM-dd HH:mm');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 服务器版本号
        Obx(() => Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const Text('服务器版本: ',
                      style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
                  Text(
                    ctrl.serverVersion.value.isEmpty
                        ? '暂无版本'
                        : ctrl.serverVersion.value,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF5599cc)),
                  ),
                ],
              ),
            )),
        // 更新日志
        Obx(() {
          final logs = ctrl.serverChangeLogs;
          if (logs.isEmpty) return const SizedBox.shrink();
          final latest = logs.first;
          return Container(
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF0e0e1a),
              borderRadius: BorderRadius.circular(4),
            ),
            child: SingleChildScrollView(
              child: Text(
                latest.logs.join('\n'),
                style: const TextStyle(fontSize: 11, color: Color(0xFFcccccc)),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        // 过滤 + 打开文件夹
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: TextBox(
                  placeholder: '过滤文件...',
                  onChanged: (v) => ctrl.localFileFilter.value = v,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(FluentIcons.folder_open),
                onPressed: ctrl.openLocalFolder,
              ),
              IconButton(
                icon: const Icon(FluentIcons.refresh),
                onPressed: ctrl.loadLocalFiles,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // 文件列表
        Expanded(
          child: Obx(() {
            final files = ctrl.filteredLocalFiles;
            if (files.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('暂无文件',
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Button(
                      onPressed: ctrl.loadLocalFiles,
                      child: const Text('扫描本地文件'),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: files.length,
              itemBuilder: (_, i) {
                final f = files[i];
                return Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  color: i.isEven
                      ? const Color(0xFF1a1a2e)
                      : const Color(0xFF16213e),
                  child: Row(
                    children: [
                      Checkbox(
                        checked: f.isChecked,
                        onChanged: (v) {
                          f.isChecked = v ?? false;
                          ctrl.localFiles.refresh();
                        },
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          f.relativePath,
                          style: TextStyle(
                            fontSize: 11,
                            color: f.isModified
                                ? const Color(0xFFffaa00)
                                : Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        dateFmt.format(f.lastModified),
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF666666)),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
