import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:publish_tool/viewmodels/project_controller.dart';
import 'package:publish_tool/views/project/dialogs/config_editor_dialog.dart';
import 'package:publish_tool/views/project/dialogs/project_settings_dialog.dart';

class ToolbarBar extends StatelessWidget {
  final String tag;
  const ToolbarBar({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProjectController>(tag: tag);
    return Obx(() {
      final busy = ctrl.isBusy.value;
      return Container(
        height: 44,
        color: const Color(0xFF1e1e2e),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            _btn('刷新状态', FluentIcons.refresh, busy ? null : ctrl.refreshStatus),
            _btn('项目设置', FluentIcons.settings, () => _showSettings(context, ctrl)),
            _btn('配置项编辑', FluentIcons.edit, () => _showConfigEditor(context, ctrl)),
            _btn('打包项目', FluentIcons.build_definition, busy ? null : ctrl.buildProject),
            _btn('默认启动', FluentIcons.play, ctrl.defaultLaunch),
            _btn('自定义启动', FluentIcons.play_resume_media, () => _customLaunch(context, ctrl)),
            _btn('日志预览', FluentIcons.document, ctrl.previewLogs),
            _btn('资源管理器', FluentIcons.folder_open, ctrl.openExplorer),
          ],
        ),
      );
    });
  }

  Widget _btn(String label, IconData icon, VoidCallback? onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Button(
          onPressed: onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14),
              Text(label, style: const TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettings(BuildContext context, ProjectController ctrl) {
    showDialog(
      context: context,
      builder: (_) => ProjectSettingsDialog(tag: tag),
    );
  }

  void _showConfigEditor(BuildContext context, ProjectController ctrl) {
    showDialog(
      context: context,
      builder: (_) => ConfigEditorDialog(tag: tag),
    );
  }

  void _customLaunch(BuildContext context, ProjectController ctrl) {
    final argsCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => ContentDialog(
        title: const Text('自定义启动参数'),
        content: TextBox(
          controller: argsCtrl,
          placeholder: '输入启动参数（空格分隔）',
        ),
        actions: [
          Button(
            onPressed: () {
              Navigator.pop(context);
              ctrl.customLaunch(argsCtrl.text);
            },
            child: const Text('启动'),
          ),
          Button(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
}
