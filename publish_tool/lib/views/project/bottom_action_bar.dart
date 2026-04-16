import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:publish_tool/viewmodels/project_controller.dart';

class BottomActionBar extends StatelessWidget {
  final String tag;
  const BottomActionBar({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProjectController>(tag: tag);
    return Obx(() => Container(
          height: 40,
          color: const Color(0xFF16213e),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              // 状态消息
              Expanded(
                child: Text(
                  ctrl.statusMessage.value,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // 附加到最新版本号
              Checkbox(
                checked: ctrl.appendToLatest.value,
                onChanged: (v) => ctrl.appendToLatest.value = v ?? false,
                content: Text(
                  '附加到最新版本号: ${ctrl.serverVersion.value}',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              const SizedBox(width: 12),
              // 推送成功自动刷新
              Checkbox(
                checked: ctrl.autoRefreshAfterPush.value,
                onChanged: (v) =>
                    ctrl.autoRefreshAfterPush.value = v ?? true,
                content: const Text('推送成功自动刷新状态',
                    style: TextStyle(fontSize: 11)),
              ),
              const SizedBox(width: 12),
              // 推送更新按钮
              FilledButton(
                onPressed: ctrl.isBusy.value ? null : ctrl.pushUpdate,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FluentIcons.upload, size: 14),
                    SizedBox(width: 4),
                    Text('推送更新'),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
