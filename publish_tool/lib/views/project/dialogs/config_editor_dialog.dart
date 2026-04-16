import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:publish_tool/viewmodels/project_controller.dart';

class ConfigEditorDialog extends StatefulWidget {
  final String tag;
  const ConfigEditorDialog({super.key, required this.tag});

  @override
  State<ConfigEditorDialog> createState() => _ConfigEditorDialogState();
}

class _ConfigEditorDialogState extends State<ConfigEditorDialog> {
  late TextEditingController _ignoreFoldersCtrl;
  late TextEditingController _ignoreFilesCtrl;

  @override
  void initState() {
    super.initState();
    // Pre-fill with current config if available
    _ignoreFoldersCtrl = TextEditingController();
    _ignoreFilesCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _ignoreFoldersCtrl.dispose();
    _ignoreFilesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProjectController>(tag: widget.tag);
    return ContentDialog(
      title: Text('配置项编辑 - ${ctrl.projectConfig.title}'),
      constraints: const BoxConstraints(maxWidth: 480),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('忽略文件夹（每行一个）',
              style: TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          SizedBox(
            height: 80,
            child: TextBox(
              controller: _ignoreFoldersCtrl,
              maxLines: null,
              placeholder: 'bin\nobj\n.git',
            ),
          ),
          const SizedBox(height: 12),
          const Text('忽略文件（每行一个）',
              style: TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          SizedBox(
            height: 80,
            child: TextBox(
              controller: _ignoreFilesCtrl,
              maxLines: null,
              placeholder: '*.pdb\n*.xml',
            ),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () {
            // TODO: save ignore config via ProjectService.updateProject
            Navigator.pop(context);
          },
          child: const Text('保存'),
        ),
        Button(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ],
    );
  }
}
