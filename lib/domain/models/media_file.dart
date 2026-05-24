class MediaFile {
  final String path;
  final String name;
  final String extension;
  final int sizeBytes;
  final int durationMs;
  final int? width;
  final int? height;
  final String? thumbnailPath;
  final DateTime? lastModified;

  const MediaFile({
    required this.path,
    required this.name,
    required this.extension,
    required this.sizeBytes,
    required this.durationMs,
    this.width,
    this.height,
    this.thumbnailPath,
    this.lastModified,
  });

  bool get isVideo =>
      ['mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'webm', 'm4v'].contains(extension);
}
