import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:publish_tool/viewmodels/app_controller.dart';
import 'package:publish_tool/viewmodels/project_controller.dart';
import 'package:publish_tool/views/project/project_page.dart';
import 'package:publish_tool/views/widgets/project_list_panel.dart';
import 'package:publish_tool/views/widgets/project_tab_bar.dart';
import 'package:publish_tool/views/widgets/status_bar.dart';

class MainWindow extends StatelessWidget {
  const MainWindow({super.key});

  @override
  Widget build(BuildContext context) {
    final appCtrl = Get.find<AppController>();
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // 左侧项目列表面板
                const ProjectListPanel(),
                // 右侧内容区
                Expanded(
                  child: Column(
                    children: [
                      // Tab 栏
                      const ProjectTabBar(),
                      // 主内容区（IndexedStack）
                      Expanded(
                        child: Obx(() {
                          final tabs = appCtrl.openTabs;
                          if (tabs.isEmpty) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(FluentIcons.product_list,
                                      size: 48, color: Color(0xFF444444)),
                                  SizedBox(height: 16),
                                  Text(
                                    '请从左侧选择项目',
                                    style: TextStyle(
                                        color: Color(0xFF666666), fontSize: 16),
                                  ),
                                ],
                              ),
                            );
                          }
                          return IndexedStack(
                            index: appCtrl.activeTabIndex.value
                                .clamp(0, tabs.length - 1),
                            children: tabs
                                .map((config) => ProjectPage(config: config))
                                .toList(),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 底部状态栏
          const StatusBar(),
        ],
      ),
    );
  }
}
