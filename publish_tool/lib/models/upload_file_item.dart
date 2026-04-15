enum UploadStatus { pending, uploading, done, failed }

class UploadFileItem {
  String fileName;
  String localPath;
  String relativePath;
  DateTime lastModified;
  UploadStatus status;

  UploadFileItem({
    required this.fileName,
    required this.localPath,
    required this.relativePath,
    required this.lastModified,
    this.status = UploadStatus.pending,
  });
}
