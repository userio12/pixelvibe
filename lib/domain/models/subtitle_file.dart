enum SubtitleFormat { srt, ass, vtt, unknown }

class SubtitleFile {
  final String path;
  final String name;
  final SubtitleFormat format;

  const SubtitleFile({
    required this.path,
    required this.name,
    required this.format,
  });

  bool get isValid => format != SubtitleFormat.unknown;
}
