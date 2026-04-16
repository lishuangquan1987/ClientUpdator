import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:publish_tool/models/project_config.dart';
import 'package:publish_tool/viewmodels/app_controller.dart';
import 'package:publish_tool/viewmodels/project_controller.dart';

class ProjectCard extends StatelessWidget {
  final ProjectConfig config;
  final int index;

  const ProjectCard({super.key, required this.config, required this.index});

  @override
  Widget build(BuildContext context) {
    final appCtrl = Get.find<AppController>();
    final isOnline = Get.isRegistered<ProjectController>(tag: config.name)
        ? Get.find<ProjectController>(tag: config.name).serverOsInfo.value != null
        : false;

    return GestureDetector(
      onTap: () => appCtrl.openTab(config),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF2d2d3f),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? Colors.green : Colors.grey,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(config.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  if (config.exePath.isNotEmpty)
                    Text(config.exePath.split('\\').last,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF888888)),
                        overflow: TextOverflow.ellipsis),
                  Text(config.serverUrl,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF5599cc)),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _iconBtn(FluentIcons.chevron_up, () => appCtrl.moveUp(index)),
                _iconBtn(
                    FluentIcons.chevron_down, () => appCtrl.moveDown(index)),
                _iconBtn(FluentIcons.settings, () {
                  appCtrl.openTab(config);
                  // settings dialog opened from project page
                }),
                _iconBtn(FluentIcons.delete, () => appCtrl.deleteProject(index),
                    color: Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onPressed, {Color? color}) {
    return IconButton(
      icon: Icon(icon, size: 14, color: color),
      onPressed: onPressed,
    );
  }
}
