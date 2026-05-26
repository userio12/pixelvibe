class M3uParser {
  static const _extM3u = '#EXTM3U';
  static const _extInf = '#EXTINF:';
  static const _extXStream = '#EXT-X-STREAM-INF:';

  static bool isM3uFile(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.m3u') || lower.endsWith('.m3u8');
  }

  static M3uPlaylist parse(String content, {String? basePath}) {
    final lines = content.split('\n');
    final entries = <M3uEntry>[];
    bool isExtended = false;
    String? currentTitle;
    int? currentDuration;

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      if (line == _extM3u) {
        isExtended = true;
        continue;
      }

      if (line.startsWith(_extInf)) {
        final rest = line.substring(_extInf.length);
        final commaIndex = rest.indexOf(',');
        if (commaIndex >= 0) {
          currentDuration = int.tryParse(rest.substring(0, commaIndex));
          currentTitle = rest.substring(commaIndex + 1).trim();
        }
        continue;
      }

      if (line.startsWith(_extXStream) || line.startsWith('#')) continue;

      if (line.isNotEmpty && !line.startsWith('#')) {
        String resolvedPath = line;
        if (basePath != null && !line.startsWith('http://') && !line.startsWith('https://')) {
          resolvedPath = '${basePath.replaceAll('\\', '/')}/'
              '${line.replaceAll('\\', '/')}';
          resolvedPath = Uri.tryParse(resolvedPath)?.toString() ?? resolvedPath;
        }
        entries.add(M3uEntry(
          path: resolvedPath,
          title: currentTitle,
          durationMs: currentDuration != null ? currentDuration * 1000 : null,
        ));
        currentTitle = null;
        currentDuration = null;
      }
    }

    return M3uPlaylist(isExtended: isExtended, entries: entries);
  }

  static String generate(List<M3uEntry> entries) {
    final buffer = StringBuffer();
    buffer.writeln('#EXTM3U');
    for (final entry in entries) {
      if (entry.durationMs != null || entry.title != null) {
        buffer.write('#EXTINF:');
        if (entry.durationMs != null) {
          buffer.write(entry.durationMs! ~/ 1000);
        }
        if (entry.title != null) {
          buffer.write(',${entry.title}');
        }
        buffer.writeln();
      }
      buffer.writeln(entry.path);
    }
    return buffer.toString();
  }
}

class M3uPlaylist {
  final bool isExtended;
  final List<M3uEntry> entries;

  const M3uPlaylist({required this.isExtended, required this.entries});

  bool get isEmpty => entries.isEmpty;
  int get length => entries.length;
  bool get hasNetworkStreams => entries.any((e) => e.isNetworkStream);
}

class M3uEntry {
  final String path;
  final String? title;
  final int? durationMs;

  const M3uEntry({
    required this.path,
    this.title,
    this.durationMs,
  });

  bool get isNetworkStream =>
      path.startsWith('http://') || path.startsWith('https://') || path.startsWith('rtmp://');
}
