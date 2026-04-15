import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:publish_tool/viewmodels/app_controller.dart';

class ProjectTabBar extends StatelessWidget {
  const ProjectTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AppController>();
    return Obx(() {
      if (ctrl.openTabs.isEmpty) {
        return const SizedBox(height: 36);
      }
      return Container(
        height: 36,
        color: const Color(0xFF16213e),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: ctrl.openTabs.length,
          itemBuilder: (_, i) {
            final isActive = ctrl.activeTabIndex.value == i;
            return GestureDetector(
              onTap: () => ctrl.activeTabIndex.value = i,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF2d2d3f)
                      : const Color(0xFF16213e),
                  border: isActive
                      ? const Border(
                          bottom: BorderSide(color: Color(0xFF0078d4), width: 2))
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ctrl.openTabs[i].title,
                      style: TextStyle(
                        fontSize: 13,
                        color: isActive ? Colors.white : const Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => ctrl.closeTab(i),
                      child: const Icon(FluentIcons.chrome_close,
                          size: 10, color: Color(0xFF888888)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
