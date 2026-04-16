import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:publish_tool/viewmodels/project_controller.dart';

class OperationButtons extends StatelessWidget {
  final String tag;
  const OperationButtons({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProjectController>(tag: tag);
    return Obx(() {
      final busy = ctrl.isBusy.value;
      return SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _circleBtn(
              icon: FluentIcons.chevron_right,
              tooltip: '全部推送',
              color: const Color(0xFF0078d4),
              onPressed: busy ? null : ctrl.pushAll,
            ),
            const SizedBox(height: 12),
            _circleBtn(
              icon: FluentIcons.stop,
              tooltip: '停止',
              color: const Color(0xFFcc3333),
              onPressed: busy ? ctrl.stop : null,
            ),
            const SizedBox(height: 12),
            _circleBtn(
              icon: FluentIcons.download,
              tooltip: '全部下载',
              color: const Color(0xFF107c10),
              onPressed: busy ? null : ctrl.downloadAll,
            ),
            const SizedBox(height: 12),
            _circleBtn(
              icon: FluentIcons.chevron_left,
              tooltip: '全部拉取',
              color: const Color(0xFF8764b8),
              onPressed: busy ? null : ctrl.pullAll,
            ),
            const SizedBox(height: 12),
            _circleBtn(
              icon: FluentIcons.refresh,
              tooltip: '刷新',
              color: const Color(0xFF666666),
              onPressed: busy ? null : ctrl.refreshFiles,
            ),
          ],
        ),
      );
    });
  }

  Widget _circleBtn({
    required IconData icon,
    required String tooltip,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onPressed != null ? color : const Color(0xFF333333),
        ),
        child: IconButton(
          icon: Icon(icon, size: 16, color: Colors.white),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
