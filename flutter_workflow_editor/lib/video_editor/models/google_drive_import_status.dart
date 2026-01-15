import 'google_drive_file.dart';

class GoogleDriveImportStatus {
  final GoogleDriveFile file;
  final String status;
  final double progress;
  final int? bytesDownloaded;
  final int? totalBytes;
  final String? localPath;
  final String? error;

  const GoogleDriveImportStatus({
    required this.file,
    required this.status,
    required this.progress,
    this.bytesDownloaded,
    this.totalBytes,
    this.localPath,
    this.error,
  });

  bool get isActive => status == 'queued' || status == 'downloading';
  bool get isCompleted => status == 'completed';
  bool get isError => status == 'error';

  GoogleDriveImportStatus copyWith({
    String? status,
    double? progress,
    int? bytesDownloaded,
    int? totalBytes,
    String? localPath,
    String? error,
  }) {
    return GoogleDriveImportStatus(
      file: file,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      bytesDownloaded: bytesDownloaded ?? this.bytesDownloaded,
      totalBytes: totalBytes ?? this.totalBytes,
      localPath: localPath ?? this.localPath,
      error: error ?? this.error,
    );
  }

  static GoogleDriveImportStatus initial(GoogleDriveFile file) {
    return GoogleDriveImportStatus(
      file: file,
      status: 'queued',
      progress: 0,
    );
  }

  factory GoogleDriveImportStatus.fromNative({
    required GoogleDriveFile file,
    required Map<String, dynamic> map,
  }) {
    final progress = (map['progress'] as num?)?.toDouble() ?? 0;

    return GoogleDriveImportStatus(
      file: file,
      status: map['status'] as String? ?? 'queued',
      progress: progress.clamp(0, 1),
      bytesDownloaded: (map['bytesDownloaded'] as num?)?.toInt(),
      totalBytes: (map['totalBytes'] as num?)?.toInt(),
      localPath: map['localPath'] as String?,
      error: map['error'] as String?,
    );
  }
}
