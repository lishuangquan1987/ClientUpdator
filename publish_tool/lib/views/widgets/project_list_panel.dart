import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:publish_tool/viewmodels/app_controller.dart';
import 'package:publish_tool/views/project/dialogs/add_project_dialog.dart';
import 'package:publish_tool/views/widgets/project_card.dart';

class ProjectListPanel extends StatelessWidget {
  const ProjectListPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AppController>();
    return Container(
      width: 280,
      color: const Color(0xFF1a1a2e),
      child: Column(
        children: [
          // 顶部按钮栏
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => _showAddDialog(context),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FluentIcons.add, size: 14),
                        SizedBox(width: 4),
                        Text('新增项目'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(FluentIcons.refresh),
                  onPressed: ctrl.refreshAllProjects,
                ),
              ],
            ),
          ),
          // 过滤输入框
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextBox(
              placeholder: '搜索项目...',
              onChanged: (v) => ctrl.filterKeyword.value = v,
              prefix: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(FluentIcons.search, size: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 项目列表
          Expanded(
            child: Obx(() {
              final projects = ctrl.filteredProjects;
              if (projects.isEmpty) {
                return const Center(
                  child: Text('暂无项目', style: TextStyle(color: Colors.grey)),
                );
              }
              return ListView.builder(
                itemCount: projects.length,
                itemBuilder: (_, i) {
                  final idx = ctrl.projectConfigs.indexOf(projects[i]);
                  return ProjectCard(config: projects[i], index: idx);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AddProjectDialog(),
    );
  }
}
