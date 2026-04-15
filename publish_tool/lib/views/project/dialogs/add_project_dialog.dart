import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:publish_tool/models/project_config.dart';
import 'package:publish_tool/viewmodels/app_controller.dart';

class AddProjectDialog extends StatefulWidget {
  const AddProjectDialog({super.key});

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  final _nameCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _serverUrlCtrl = TextEditingController(text: 'http://');
  final _exePathCtrl = TextEditingController();
  final _localPathCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _titleCtrl.dispose();
    _serverUrlCtrl.dispose();
    _exePathCtrl.dispose();
    _localPathCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.isEmpty ||
        _titleCtrl.text.isEmpty ||
        _serverUrlCtrl.text.isEmpty) {
      setState(() => _error = '名称、标题、服务器地址为必填项');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final config = ProjectConfig(
        serverId: 0,
        name: _nameCtrl.text.trim(),
        title: _titleCtrl.text.trim(),
        serverUrl: _serverUrlCtrl.text.trim(),
        exePath: _exePathCtrl.text.trim(),
        localPath: _localPathCtrl.text.trim(),
      );
      await Get.find<AppController>().addProject(config);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickExe() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['exe'],
    );
    if (result != null && result.files.single.path != null) {
      _exePathCtrl.text = result.files.single.path!;
    }
  }

  Future<void> _pickFolder() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      _localPathCtrl.text = result;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('新增项目'),
      constraints: const BoxConstraints(maxWidth: 480),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_error!,
                  style: const TextStyle(color: Color(0xFFcc3333))),
            ),
          _field('项目名称 *', _nameCtrl, '唯一标识，如 YOFC.iMES-Q.Client'),
          _field('显示标题 *', _titleCtrl, '如 石英MES客户端'),
          _field('服务器地址 *', _serverUrlCtrl, 'http://10.96.115.14:2002'),
          _pathField('exe 路径', _exePathCtrl, _pickExe),
          _pathField('本地文件夹', _localPathCtrl, _pickFolder, isFolder: true),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: ProgressRing(strokeWidth: 2))
              : const Text('确定'),
        ),
        Button(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl, String placeholder) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          TextBox(controller: ctrl, placeholder: placeholder),
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
