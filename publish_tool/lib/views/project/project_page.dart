import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:publish_tool/models/project_config.dart';
import 'package:publish_tool/viewmodels/project_controller.dart';
import 'package:publish_tool/views/project/bottom_action_bar.dart';
import 'package:publish_tool/views/project/local_files_panel.dart';
import 'package:publish_tool/views/project/operation_buttons.dart';
import 'package:publish_tool/views/project/server_info_bar.dart';
import 'package:publish_tool/views/project/toolbar_bar.dart';
import 'package:publish_tool/views/project/upload_queue_panel.dart';

class ProjectPage extends StatefulWidget {
  final ProjectConfig config;
  const ProjectPage({super.key, required this.config});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ProjectController>(tag: widget.config.name)) {
      Get.put(ProjectController(widget.config), tag: widget.config.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tag = widget.config.name;
    return Column(
      children: [
        ServerInfoBar(tag: tag),
        ToolbarBar(tag: tag),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: LocalFilesPanel(tag: tag),
              ),
              OperationButtons(tag: tag),
              Expanded(
                flex: 4,
                child: UploadQueuePanel(tag: tag),
              ),
            ],
          ),
        ),
        BottomActionBar(tag: tag),
      ],
    );
  }
}
