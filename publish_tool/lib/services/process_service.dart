import 'dart:io';

class ProcessService {
  Future<void> launchExe(String exePath, {List<String>? args}) async {
    await Process.start(exePath, args ?? [], runInShell: false);
  }

  Future<void> openFolder(String folderPath) async {
    if (Platform.isWindows) {
      await Process.start('explorer.exe', [folderPath]);
    } else if (Platform.isMacOS) {
      await Process.start('open', [folderPath]);
    } else {
      await Process.start('xdg-open', [folderPath]);
    }
  }

  Future<void> openFile(String filePath) async {
    if (Platform.isWindows) {
      await Process.start('explorer.exe', [filePath]);
    } else if (Platform.isMacOS) {
      await Process.start('open', [filePath]);
    } else {
      await Process.start('xdg-open', [filePath]);
    }
  }

  Future<ProcessResult> buildProject(
      String buildCommand, String workDir) async {
    final parts = buildCommand.split(' ');
    return await Process.run(
      parts.first,
      parts.skip(1).toList(),
      workingDirectory: workDir,
      runInShell: true,
    );
  }
}
