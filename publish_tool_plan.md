# publish_tool Flutter MVVM 重构计划

> 生成时间：2026-04-15  
> 目标：将 publish_tool 从默认模板重构为完整的 MVVM 架构桌面工具，UI 完全还原 WPF 版本截图风格，使用 fluent_ui + GetX 实现。

---

## 一、整体架构设计（对标 WPF MVVM）

```
WPF 概念          →  Flutter 对应
─────────────────────────────────────────────
View (XAML)       →  lib/views/          Widget（纯 UI，不含业务逻辑）
ViewModel         →  lib/viewmodels/     GetxController（状态 + 命令）
Model / Service   →  lib/services/       业务逻辑封装（调用 API）
Repository/API    →  lib/api/            已有，保持不变
DTO               →  lib/dto/            已有，保持不变
ICommand          →  方法 + RxBool isXxxEnabled
Binding           →  Obx(() => ...)
RelayCommand      →  普通方法，Rx 变量自动驱动 UI
```

**状态管理**：`get` 包（GetxController + Rx 响应式变量，对标 WPF INotifyPropertyChanged；Get.find() 对标 DI 容器）

---

## 二、最终目录结构

```
lib/
├── main.dart                          # 入口，注册全局 Binding
├── app.dart                           # GetMaterialApp / FluentApp 配置
│
├── api/                               # 已有，不改动
│   ├── base_api.dart
│   ├── project_api.dart
│   └── file_api.dart
│
├── dto/                               # 已有，不改动
│   └── *.dart
│
├── logger/                            # 已有，不改动
│   └── log_helper.dart
│
├── models/                            # 本地业务模型（非 DTO）
│   ├── project_config.dart            # 本地项目配置（含 exePath/serverUrl/localPath/sortOrder）
│   ├── local_file_item.dart           # 本地文件列表项（含 isChecked）
│   └── upload_file_item.dart          # 待上传文件列表项
│
├── services/                          # 业务服务层（对标 WPF Service/Repository）
│   ├── config_service.dart            # 本地配置读写（JSON 文件持久化）
│   ├── project_service.dart           # 项目相关业务（封装 ProjectApi）
│   ├── file_service.dart              # 文件扫描/上传/下载业务（封装 FileApi）
│   └── process_service.dart           # 启动进程（默认启动/自定义启动/打包）
│
├── viewmodels/                        # ViewModel 层（GetxController）
│   ├── app_controller.dart            # 全局：项目列表、Tab 管理、配置保存
│   └── project_controller.dart        # 单项目：服务器信息、文件列表、推送操作
│
└── views/                             # View 层（纯 Widget）
    ├── main_window.dart               # 主窗口（左侧面板 + Tab 区域）
    ├── widgets/
    │   ├── project_list_panel.dart    # 左侧项目列表面板
    │   ├── project_card.dart          # 项目卡片（含上移/下移/设置/删除）
    │   ├── project_tab_bar.dart       # 顶部 Tab 栏
    │   └── status_bar.dart            # 最底部状态栏（编译时间/当前时间）
    └── project/
        ├── project_page.dart          # 单项目主页（组合以下子 Widget）
        ├── server_info_bar.dart       # 服务器信息栏
        ├── toolbar_bar.dart           # 工具栏（8个按钮）
        ├── local_files_panel.dart     # 左侧本地文件区
        ├── operation_buttons.dart     # 中间5个操作按钮
        ├── upload_queue_panel.dart    # 右侧待推送区
        ├── bottom_action_bar.dart     # 底部推送操作栏
        └── dialogs/
            ├── add_project_dialog.dart    # 新增项目对话框
            ├── project_settings_dialog.dart # 项目设置对话框
            └── config_editor_dialog.dart  # 配置项编辑对话框
```

---

## 三、新增依赖包

在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  get: ^4.6.6               # MVVM 状态管理 + DI（对标 WPF INotifyPropertyChanged + IoC）
  path_provider: ^2.1.4     # 获取本地路径（存储配置文件）
  file_picker: ^8.1.7       # 选择本地文件夹/文件
  process_run: ^1.2.1       # 启动外部进程（默认启动/自定义启动/打包）
  intl: ^0.19.0             # 日期格式化
```

> 移除 `provider`、`shared_preferences`（GetX 自带 GetStorage 可替代）

---

## 四、本地模型设计

### 4.1 `ProjectConfig`（本地配置，持久化到 JSON）

```dart
class ProjectConfig {
  int    serverId;      // 对应服务端 ProjectDto.id
  String name;          // 项目唯一名称
  String title;         // 显示名称
  String serverUrl;     // 服务器地址（如 http://10.96.115.14:2002）
  String exePath;       // exe 文件路径（用于默认启动）
  String localPath;     // 本地文件夹路径（扫描本地文件）
  int    sortOrder;     // 排序序号（上移/下移）
}
```

> 持久化路径：`{appDocDir}/publish_tool_config.json`

### 4.2 `LocalFileItem`

```dart
class LocalFileItem {
  String   fileName;
  String   absolutePath;
  String   relativePath;
  DateTime lastModified;
  bool     isChecked;      // √ 标记（是否选中推送）
  bool     isModified;     // 与服务端 MD5 对比后标记
}
```

### 4.3 `UploadFileItem`

```dart
class UploadFileItem {
  String   fileName;
  String   localPath;
  String   relativePath;
  DateTime lastModified;
  UploadStatus status;    // pending / uploading / done / failed
}
```

---

## 五、ViewModel 设计（GetxController）

### 5.1 `AppController`（全局单例，对标 WPF MainWindowViewModel）

```dart
class AppController extends GetxController {
  // Rx 状态属性（对标 WPF ObservableCollection / INotifyPropertyChanged）
  final projectConfigs = <ProjectConfig>[].obs;   // 左侧项目列表
  final filterKeyword  = ''.obs;                  // 关键字过滤
  final openTabs       = <ProjectConfig>[].obs;   // 已打开的 Tab
  final activeTabIndex = 0.obs;                   // 当前激活 Tab

  // computed（对标 WPF get 属性）
  List<ProjectConfig> get filteredProjects => projectConfigs
      .where((p) => p.title.contains(filterKeyword.value) ||
                    p.name.contains(filterKeyword.value))
      .toList();
}
```

**命令方法：**
| 方法 | 说明 |
|------|------|
| `loadConfig()` | 从本地 JSON 加载项目配置 |
| `saveConfig()` | 保存配置到本地 JSON |
| `addProject(ProjectConfig)` | 新增项目（调用服务端 + 保存本地配置） |
| `deleteProject(int index)` | 删除项目 |
| `moveUp(int index)` | 上移项目 |
| `moveDown(int index)` | 下移项目 |
| `openTab(ProjectConfig)` | 打开 Tab（若已存在则激活） |
| `closeTab(int index)` | 关闭 Tab |
| `refreshAllProjects()` | 刷新所有项目状态 |

### 5.2 `ProjectController`（每个 Tab 独立实例，对标 WPF ProjectViewModel）

```dart
class ProjectController extends GetxController {
  final ProjectConfig projectConfig;
  ProjectController(this.projectConfig);

  // Rx 状态属性
  final serverOsInfo      = Rxn<ServerOsInfoDto>();
  final serverVersion     = ''.obs;
  final serverChangeLogs  = <ProjectChangeLog>[].obs;
  final localFiles        = <LocalFileItem>[].obs;
  final localFileFilter   = ''.obs;
  final uploadQueue       = <UploadFileItem>[].obs;
  final newVersion        = ''.obs;
  final newChangeLogs     = ''.obs;
  final appendToLatest    = false.obs;
  final autoRefreshAfterPush = true.obs;
  final statusMessage     = ''.obs;
  final isBusy            = false.obs;

  List<LocalFileItem> get filteredLocalFiles => localFiles
      .where((f) => f.fileName.contains(localFileFilter.value))
      .toList();
}
```

**命令方法：**
| 方法 | 说明 |
|------|------|
| `refreshStatus()` | 刷新服务器信息 + 版本 + 日志 |
| `loadLocalFiles()` | 扫描本地文件夹 |
| `openLocalFolder()` | 打开本地文件夹（process_run） |
| `pushAll()` | 全部推送（上传 uploadQueue 所有文件） |
| `stop()` | 停止当前操作（cancelToken.cancel） |
| `downloadAll()` | 全部下载（从服务端下载到本地） |
| `pullAll()` | 全部拉取（对比 MD5，下载差异文件） |
| `refreshFiles()` | 刷新本地文件列表 |
| `autoGenerateVersion()` | 自动生成版本号（yyyyMMdd-HHmm 格式） |
| `pushUpdate()` | 推送更新（上传文件 + 提交版本日志） |
| `addToUploadQueue(List<LocalFileItem>)` | 将选中文件加入待上传队列 |
| `removeFromUploadQueue(UploadFileItem)` | 从队列移除 |
| `openProjectSettings()` | 打开项目设置对话框 |
| `openConfigEditor()` | 打开配置项编辑对话框 |
| `buildProject()` | 打包项目（调用 process_run 执行构建命令） |
| `defaultLaunch()` | 默认启动（运行 exePath） |
| `customLaunch()` | 自定义启动（弹出参数输入后运行） |
| `previewLogs()` | 日志预览（打开日志文件） |
| `openExplorer()` | 资源管理器（打开 localPath） |

---

## 六、View 层设计

### 6.1 主窗口布局（`main_window.dart`）

```
┌─────────────────────────────────────────────────────────────┐
│  标题栏：长飞客户端软件版本发布工具                              │
├──────────────┬──────────────────────────────────────────────┤
│              │  [Tab1: 石英MES客户端 ×] [Tab2 ×] ...        │
│  左侧面板     ├──────────────────────────────────────────────┤
│  (宽 280px)  │                                              │
│              │         ProjectPage（右侧主内容）              │
│  ProjectList │                                              │
│  Panel       │                                              │
│              │                                              │
└──────────────┴──────────────────────────────────────────────┘
│  状态栏：编译时间 2025/6/23 18:08:02   当前时间：2026-04-15   │
└─────────────────────────────────────────────────────────────┘
```

**实现要点：**
- 使用 `Row` 分左右，左侧固定宽度 280，右侧 `Expanded`
- 左侧使用 `Column`：顶部3按钮 + 过滤输入框 + `ListView`（项目卡片）
- 右侧使用 `Column`：Tab 栏 + `IndexedStack`（各项目页面）
- 底部 `StatusBar` 固定在最底部

### 6.2 项目卡片（`project_card.dart`）

```
● 石英MES客户端          ↑ ↓ ⚙ 🗑
  YOFC.iMES-Q.exe
  http://10.96.115.14:2002
  E:\Yofc\Code\YOFC.iMES-Q.Client\...
```

- 绿点/灰点：根据对应 `ProjectController.serverOsInfo` 是否为 null 判断连接状态
- 点击卡片 → `AppController.openTab(config)`
- 4个图标按钮：上移/下移/设置/删除

### 6.3 服务器信息栏（`server_info_bar.dart`）

```
平台 ubuntu  处理器型号 INTEL(R) XEON(R) GOLD 5520+  线程 112  磁盘容量 [████░░░░] 已用/可用/总量
环境 go1.22.5  架构 amd64  频率 4000
```

- 磁盘进度条：`ProgressBar`（fluent_ui），value = `diskUsedPercent / 100`
- 已用红色、可用绿色、总量白色

### 6.4 工具栏（`toolbar_bar.dart`）

8个 `Button`（fluent_ui），图标 + 文字，等宽排列：
`刷新状态` | `项目设置` | `配置项编辑` | `打包项目` | `默认启动` | `自定义启动` | `日志预览` | `资源管理器`

### 6.5 主内容区（三栏布局）

```
┌─────────────────────┬──────┬──────────────────────┐
│  最新远程状态、本地文件 │ 操作  │  待推送区              │
│  (Expanded flex:5)  │按钮区 │  (Expanded flex:4)   │
│                     │(固定) │                      │
└─────────────────────┴──────┴──────────────────────┘
```

**左侧面板（`local_files_panel.dart`）：**
- 服务器版本号（蓝色超链接样式文本）
- 更新日志文本框（只读，多行）
- 本地文件过滤输入框 + 打开本地文件夹按钮
- 文件列表（`ListView`）：√ checkbox + 文件名 + 最后修改日期

**中间操作按钮（`operation_buttons.dart`）：**
竖排5个圆形按钮：
- `→` 全部推送（将选中本地文件加入上传队列）
- `●` 停止
- `●` 全部下载
- `←` 全部拉取
- `↺` 刷新

**右侧待推送区（`upload_queue_panel.dart`）：**
- 更新后版本号输入框 + 自动生成版本号按钮
- 更新日志提示文本（可编辑 TextBox）
- 待上传文件列表：文件名 + 最后修改日期 + 本地路径

### 6.6 底部操作栏（`bottom_action_bar.dart`）

```
[状态消息文本]  □ 附加到最新版本号：20260413-1554  ☑ 推送成功自动刷新状态  [↑ 推送更新]
```

---

## 七、服务层设计

### 7.1 `ConfigService`

```dart
// 本地配置持久化（JSON 文件）
Future<List<ProjectConfig>> loadConfigs();
Future<void> saveConfigs(List<ProjectConfig> configs);
```

### 7.2 `ProjectService`

```dart
// 封装 ProjectApi，处理错误，返回业务结果
Future<List<ProjectDto>> getAllProjects(String serverUrl);
Future<ServerOsInfoDto> getOsInfo(String serverUrl, int projectId);
Future<List<ProjectChangeLog>> getChangeLogs(String serverUrl, int projectId);
Future<void> createProject(String serverUrl, CreateProjectDto dto);
Future<void> updateProject(String serverUrl, UpdateProjectDto dto);
Future<void> deleteProject(String serverUrl, int id);
```

### 7.3 `FileService`

```dart
// 本地文件扫描
Future<List<LocalFileItem>> scanLocalFiles(String localPath);

// 封装 FileApi
Future<List<FileInfoDto>> getServerFiles(String serverUrl, int projectId);
Future<void> uploadFile(String serverUrl, UploadFileItem item, String projectName, {Function(int,int)? progress, CancelToken? token});
Future<void> downloadFile(String serverUrl, FileInfoDto serverFile, String localBasePath, {Function(int,int)? progress, CancelToken? token});

// MD5 对比，返回需要下载的文件列表
Future<List<FileInfoDto>> diffFiles(List<LocalFileItem> local, List<FileInfoDto> server);
```

### 7.4 `ProcessService`

```dart
Future<void> launchExe(String exePath, {List<String>? args});
Future<void> openFolder(String folderPath);
Future<void> openFile(String filePath);
Future<void> buildProject(String buildCommand, String workDir);
```

---

## 八、实现步骤（按优先级）

### Step 1：基础设施
1. `pubspec.yaml` 添加 `get`、`path_provider`、`file_picker`、`process_run`、`intl`
2. 创建 `lib/models/` 下三个模型类
3. 创建 `ConfigService`（JSON 读写本地配置）
4. 改造 `main.dart`：`Get.put(AppController())` 注册全局控制器

### Step 2：左侧项目列表
5. 实现 `AppController`（loadConfig/saveConfig/addProject/deleteProject/moveUp/moveDown/openTab/closeTab）
6. 实现 `ProjectListPanel` + `ProjectCard`（含过滤、上移/下移/设置/删除）
7. 实现 `AddProjectDialog`（新增项目表单）

### Step 3：Tab 管理 + 主窗口骨架
8. 实现 `ProjectTabBar`（多 Tab + 关闭按钮）
9. 实现 `MainWindow`（左右布局 + Tab + StatusBar）

### Step 4：单项目页面
10. 实现 `ProjectController`（refreshStatus/loadLocalFiles），每个 Tab 打开时 `Get.put(ProjectController(config), tag: config.name)`
11. 实现 `ServerInfoBar`（服务器信息 + 磁盘进度条）
12. 实现 `ToolbarBar`（8个工具按钮）
13. 实现 `LocalFilesPanel`（本地文件列表 + 过滤 + checkbox）
14. 实现 `OperationButtons`（5个操作按钮）
15. 实现 `UploadQueuePanel`（待上传队列 + 版本号输入）
16. 实现 `BottomActionBar`（状态消息 + checkbox + 推送按钮）

### Step 5：核心业务逻辑
17. 实现 `FileService`（本地扫描 + MD5 对比 + 上传 + 下载）
18. 实现 `ProjectController` 完整命令（pushAll/stop/downloadAll/pullAll/pushUpdate）
19. 实现 `ProcessService`（启动进程/打开文件夹）
20. 实现 `ProjectSettingsDialog` + `ConfigEditorDialog`

### Step 6：细节完善
21. 主题适配（深色主题，对标截图配色：背景 #1e1e2e，蓝色强调色）
22. 版本号自动生成逻辑（`yyyyMMdd-HHmm` 格式）
23. 底部状态栏实时时间（`ever` worker 或 `Timer.periodic` 每秒刷新）
24. 编译时间注入（通过 `dart-define` 或构建脚本写入常量）
25. 错误处理统一（API 失败 → `statusMessage.value = errMsg`）

---

## 九、关键技术说明

### MVVM 绑定模式（对标 WPF）

```dart
// WPF: <TextBlock Text="{Binding ServerVersion}"/>
// Flutter + GetX:
Obx(() => Text(ctrl.serverVersion.value))

// WPF: Command="{Binding RefreshCommand}" IsEnabled="{Binding !IsBusy}"
// Flutter + GetX:
Obx(() => Button(
  onPressed: ctrl.isBusy.value ? null : ctrl.refreshStatus,
  child: Text('刷新状态'),
))
```

### 多 Tab 独立 Controller（tag 隔离）

```dart
// 打开 Tab 时注册（tag = 项目唯一名称）
Get.put(ProjectController(config), tag: config.name);

// View 中获取
final ctrl = Get.find<ProjectController>(tag: config.name);

// 关闭 Tab 时销毁，释放资源
Get.delete<ProjectController>(tag: config.name);
```

### 服务注册（GetX DI，对标 WPF IoC 容器）

```dart
// main.dart
void main() {
  Get.put(ConfigService());
  Get.put(ProjectService());
  Get.put(FileService());
  Get.put(ProcessService());
  Get.put(AppController());
  runApp(const MyApp());
}
```

### 本地配置结构（JSON）

```json
{
  "projects": [
    {
      "serverId": 1,
      "name": "YOFC.iMES-Q.Client",
      "title": "石英MES客户端",
      "serverUrl": "http://10.96.115.14:2002",
      "exePath": "E:\\Yofc\\Code\\...\\YOFC.iMES-Q.exe",
      "localPath": "E:\\Yofc\\Code\\YOFC.iMES-Q.Client\\bin\\Debug",
      "sortOrder": 0
    }
  ]
}
```

---

## 十、文件清单（需新建）

| 文件路径 | 说明 |
|---------|------|
| `lib/app.dart` | FluentApp 配置 |
| `lib/models/project_config.dart` | 本地项目配置模型 |
| `lib/models/local_file_item.dart` | 本地文件列表项 |
| `lib/models/upload_file_item.dart` | 待上传文件项 |
| `lib/services/config_service.dart` | 本地配置持久化 |
| `lib/services/project_service.dart` | 项目业务服务 |
| `lib/services/file_service.dart` | 文件业务服务 |
| `lib/services/process_service.dart` | 进程启动服务 |
| `lib/viewmodels/app_controller.dart` | 全局 Controller |
| `lib/viewmodels/project_controller.dart` | 单项目 Controller |
| `lib/views/main_window.dart` | 主窗口 |
| `lib/views/widgets/project_list_panel.dart` | 左侧项目列表 |
| `lib/views/widgets/project_card.dart` | 项目卡片 |
| `lib/views/widgets/project_tab_bar.dart` | Tab 栏 |
| `lib/views/widgets/status_bar.dart` | 底部状态栏 |
| `lib/views/project/project_page.dart` | 单项目主页 |
| `lib/views/project/server_info_bar.dart` | 服务器信息栏 |
| `lib/views/project/toolbar_bar.dart` | 工具栏 |
| `lib/views/project/local_files_panel.dart` | 本地文件区 |
| `lib/views/project/operation_buttons.dart` | 中间操作按钮 |
| `lib/views/project/upload_queue_panel.dart` | 待推送区 |
| `lib/views/project/bottom_action_bar.dart` | 底部操作栏 |
| `lib/views/project/dialogs/add_project_dialog.dart` | 新增项目对话框 |
| `lib/views/project/dialogs/project_settings_dialog.dart` | 项目设置对话框 |
| `lib/views/project/dialogs/config_editor_dialog.dart` | 配置项编辑对话框 |

**已有文件（保持不变）：**
- `lib/api/base_api.dart`
- `lib/api/project_api.dart`
- `lib/api/file_api.dart`
- `lib/dto/*.dart`
- `lib/logger/log_helper.dart`

---

## 十一、注意事项

1. **ProjectDto 缺少 id 字段**：服务端返回的 `ent.Project` 有 `id`，但现有 `ProjectDto` 未包含，需补充 `int id` 字段并重新生成 `.g.dart`。
2. **FileApi.uploadFile 参数名**：服务端接收 `relativeFileName`，但 `FileApi` 传的是 `relativeFilePath`，需对齐。
3. **本地配置与服务端解耦**：`serverUrl`、`exePath`、`localPath` 存本地 JSON，不上传服务端，服务端只存 `name/title/isForceUpdate/ignoreFolders/ignoreFiles`。
4. **Windows 桌面应用**：`process_run` 在 Windows 下调用 `explorer.exe` 打开文件夹，`Process.run` 启动 exe。
5. **fluent_ui 与 GetX 路由冲突**：fluent_ui 使用自己的 `FluentApp`，GetX 导航用 `Get.key` 注入 `navigatorKey`，对话框用 `Get.dialog()` 或直接调用 `showDialog`，不依赖 GetX 路由。
6. **Tab Controller 生命周期**：`Get.put(..., tag:)` 注册，`Get.delete(..., tag:)` 销毁，避免内存泄漏。
7. **fluent_ui 版本**：当前使用 `^4.15.0`，`ProgressBar`、`Checkbox`、`TabView` 等组件 API 以该版本为准。
