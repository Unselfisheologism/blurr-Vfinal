class GoogleDriveFile {
  final String id;
  final String name;
  final String mimeType;
  final int? size;
  final String? createdTime;
  final String? webViewLink;

  const GoogleDriveFile({
    required this.id,
    required this.name,
    required this.mimeType,
    this.size,
    this.createdTime,
    this.webViewLink,
  });

  factory GoogleDriveFile.fromMap(Map<String, dynamic> map) {
    return GoogleDriveFile(
      id: map['id'] as String,
      name: map['name'] as String,
      mimeType: map['mimeType'] as String,
      size: (map['size'] as num?)?.toInt(),
      createdTime: map['createdTime'] as String?,
      webViewLink: map['webViewLink'] as String?,
    );
  }
}
