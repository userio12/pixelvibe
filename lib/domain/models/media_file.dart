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

  String get directory {
    final slash = path.lastIndexOf('/');
    final backslash = path.lastIndexOf('\\');
    final idx = slash > backslash ? slash : backslash;
    return idx > 0 ? path.substring(0, idx) : '/';
  }

  String get sizeFormatted {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    if (sizeBytes < 1024 * 1024 * 1024) return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get resolutionLabel {
    if (width == null || height == null) return '';
    if (height! >= 2160) return '4K';
    if (height! >= 1440) return '2K';
    if (height! >= 1080) return '1080p';
    if (height! >= 720) return '720p';
    if (height! >= 480) return '480p';
    return '${width}x$height';
  }

  bool get isVideo =>
      ['mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'webm', 'm4v'].contains(extension);

  bool get isPlaylist => ['m3u', 'm3u8'].contains(extension);
}
