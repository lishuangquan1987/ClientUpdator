import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:publish_tool/app.dart';
import 'package:publish_tool/logger/log_helper.dart';
import 'package:publish_tool/services/config_service.dart';
import 'package:publish_tool/services/file_service.dart';
import 'package:publish_tool/services/process_service.dart';
import 'package:publish_tool/services/project_service.dart';
import 'package:publish_tool/viewmodels/app_controller.dart';

void main() {
  LogHelper.configureLogging();

  Get.put(ConfigService());
  Get.put(ProjectService());
  Get.put(FileService());
  Get.put(ProcessService());
  Get.put(AppController());

  runApp(const App());
}
