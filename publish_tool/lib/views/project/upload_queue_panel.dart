import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:publish_tool/models/upload_file_item.dart';
import 'package:publish_tool/viewmodels/project_controller.dart';

class UploadQueuePanel extends StatelessWidget {
  final String tag;
  const UploadQueuePanel({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProjectController>(tag: tag);
    final dateFmt = DateFormat('MM-dd HH:mm');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 版本号输入
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: Obx(() => TextBox(
                      placeholder: '更新后版本号',
                      controller: TextEditingController(
                          text: ctrl.newVersion.value)
                        ..selection = TextSelection.collapsed(
                            offset: ctrl.newVersion.value.length),
                      onChanged: (v) => ctrl.newVersion.value = v,
                    )),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(FluentIcons.auto_fill_template, size: 16),
                onPressed: ctrl.autoGenerateVersion,
              ),
            ],
          ),
        ),
        // 更新日志输入
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            height: 80,
            child: TextBox(
              placeholder: '更新日志（每行一条）',
              maxLines: null,
              onChanged: (v) => ctrl.newChangeLogs.value = v,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('待上传文件',
              style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
        ),
        const SizedBox(height: 4),
        // 待上传列表
        Expanded(
          child: Obx(() {
            final queue = ctrl.uploadQueue;
            if (queue.isEmpty) {
              return const Center(
                child: Text('队列为空', style: TextStyle(color: Colors.grey)),
              );
            }
            return ListView.builder(
              itemCount: queue.length,
              itemBuilder: (_, i) {
                final item = queue[i];
                return Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  color: i.isEven
                      ? const Color(0xFF1a1a2e)
                      : const Color(0xFF16213e),
                  child: Row(
                    children: [
                      Icon(
                        _statusIcon(item.status),
                        size: 12,
                        color: _statusColor(item.status),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.relativePath,
                          style: const TextStyle(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        dateFmt.format(item.lastModified),
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF666666)),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => ctrl.removeFromUploadQueue(item),
                        child: const Icon(FluentIcons.chrome_close,
                            size: 10, color: Color(0xFF666666)),
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

  IconData _statusIcon(UploadStatus status) {
    switch (status) {
      case UploadStatus.pending:
        return FluentIcons.clock;
      case UploadStatus.uploading:
        return FluentIcons.upload;
      case UploadStatus.done:
        return FluentIcons.check_mark;
      case UploadStatus.failed:
        return FluentIcons.error_badge;
    }
  }

  Color _statusColor(UploadStatus status) {
    switch (status) {
      case UploadStatus.pending:
        return const Color(0xFF888888);
      case UploadStatus.uploading:
        return const Color(0xFF0078d4);
      case UploadStatus.done:
        return const Color(0xFF107c10);
      case UploadStatus.failed:
        return const Color(0xFFcc3333);
    }
  }
}
