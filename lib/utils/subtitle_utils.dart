import '../domain/models/subtitle_file.dart';

final _subtitleExtensions = {
  'srt': SubtitleFormat.srt,
  'ass': SubtitleFormat.ass,
  'ssa': SubtitleFormat.ass,
  'vtt': SubtitleFormat.vtt,
  'webvtt': SubtitleFormat.vtt,
  'sub': SubtitleFormat.srt,
};

SubtitleFile? parseSubtitleFile(String path) {
  final ext = path.split('.').last.toLowerCase();
  final format = _subtitleExtensions[ext];
  if (format == null) return null;
  final name = path.split('/').last.split('\\').last;
  return SubtitleFile(path: path, name: name, format: format);
}
