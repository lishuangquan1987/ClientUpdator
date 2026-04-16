import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:publish_tool/viewmodels/project_controller.dart';

class ProjectSettingsDialog extends StatefulWidget {
  final String tag;
  const ProjectSettingsDialog({super.key, required this.tag});

  @override
  State<ProjectSettingsDialog> createState() => _ProjectSettingsDialogState();
}

class _ProjectSettingsDialogState extends State<ProjectSettingsDialog> {
  late TextEditingController _titleCtrl;
  late TextEditingController _exePathCtrl;
  late TextEditingController _localPathCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final ctrl = Get.find<ProjectController>(tag: widget.tag);
    _titleCtrl = TextEditingController(text: ctrl.projectConfig.title);
    _exePathCtrl = TextEditingController(text: ctrl.projectConfig.exePath);
    _localPathCtrl = TextEditingController(text: ctrl.projectConfig.localPath);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _exePathCtrl.dispose();
    _localPathCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      await Get.find<ProjectController>(tag: widget.tag).updateProjectSettings(
        _titleCtrl.text.trim(),
        _exePathCtrl.text.trim(),
        _localPathCtrl.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickExe() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['exe'],
    );
    if (result?.files.single.path != null) {
      _exePathCtrl.text = result!.files.single.path!;
    }
  }

  Future<void> _pickFolder() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) _localPathCtrl.text = result;
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('项目设置'),
      constraints: const BoxConstraints(maxWidth: 480),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _field('显示标题', _titleCtrl),
          _pathField('exe 路径', _exePathCtrl, _pickExe),
          _pathField('本地文件夹', _localPathCtrl, _pickFolder, isFolder: true),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: _loading ? null : _save,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: ProgressRing(strokeWidth: 2))
              : const Text('保存'),
        ),
        Button(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          TextBox(controller: ctrl),
        ],
      ),
    );
  }

  Widget _pathField(String label, TextEditingController ctrl,
      VoidCallback onPick,
      {bool isFolder = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(child: TextBox(controller: ctrl)),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(isFolder
                    ? FluentIcons.folder_open
                    : FluentIcons.document_search),
                onPressed: onPick,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
