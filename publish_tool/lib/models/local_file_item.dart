class LocalFileItem {
  String fileName;
  String absolutePath;
  String relativePath;
  DateTime lastModified;
  bool isChecked;
  bool isModified;

  LocalFileItem({
    required this.fileName,
    required this.absolutePath,
    required this.relativePath,
    required this.lastModified,
    this.isChecked = false,
    this.isModified = false,
  });
}
