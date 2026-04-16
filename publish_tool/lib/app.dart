import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:publish_tool/views/main_window.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: '长飞客户端软件版本发布工具',
      navigatorKey: Get.key,
      theme: FluentThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.blue,
      ),
      home: const MainWindow(),
    );
  }
}
