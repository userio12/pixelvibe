import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'logger.dart';

class OnlineSubtitle {
  final int fileId;
  final String title;
  final String language;
  final String fileName;
  final int downloads;
  final bool hearingImpaired;

  const OnlineSubtitle({
    required this.fileId,
    required this.title,
    required this.language,
    required this.fileName,
    this.downloads = 0,
    this.hearingImpaired = false,
  });

  String get format {
    final ext = fileName.split('.').last.toLowerCase();
    if (ext == 'srt') return 'SRT';
    if (ext == 'ass' || ext == 'ssa') return 'ASS';
    if (ext == 'vtt' || ext == 'webvtt') return 'VTT';
    return ext.toUpperCase();
  }
}

class SubtitleApiService {
  static const _baseUrl = 'https://api.opensubtitles.com/api/v1';
  static const _userAgent = 'pixelvibe v1.0';

  final String apiKey;

  SubtitleApiService(this.apiKey);

  Future<List<OnlineSubtitle>> search(String query, {String language = 'en'}) async {
    if (apiKey.isEmpty) return [];
    try {
      final uri = Uri.parse('$_baseUrl/subtitles').replace(queryParameters: {
        'query': query,
        'languages': language,
        'order_by': 'download_count',
        'order_direction': 'desc',
        'limit': '20',
      });
      final response = await http.get(
        uri,
        headers: {
          'Api-Key': apiKey,
          'User-Agent': _userAgent,
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode != 200) {
        Logger.error('OpenSubtitles search: ${response.statusCode} ${response.body}');
        return [];
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as List?;
      if (data == null || data.isEmpty) return [];
      return data.map((item) {
        final attrs = item['attributes'] as Map<String, dynamic>;
        final featureDetails = attrs['feature_details'] as Map<String, dynamic>?;
        final title = featureDetails?['title'] as String? ?? 'Unknown';
        final files = attrs['files'] as List?;
        final firstFile = files?.firstOrNull as Map<String, dynamic>?;
        return OnlineSubtitle(
          fileId: firstFile?['file_id'] as int? ?? 0,
          title: title,
          language: attrs['language'] as String? ?? 'en',
          fileName: firstFile?['file_name'] as String? ?? 'subtitle.srt',
          downloads: attrs['download_count'] as int? ?? 0,
          hearingImpaired: attrs['hearing_impaired'] as bool? ?? false,
        );
      }).toList();
    } catch (e) {
      Logger.error('OpenSubtitles search error', e);
      return [];
    }
  }

  Future<String?> download(int fileId) async {
    if (apiKey.isEmpty) return null;
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/download'),
        headers: {
          'Api-Key': apiKey,
          'User-Agent': _userAgent,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'file_id': fileId}),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        Logger.error('OpenSubtitles download: ${response.statusCode} ${response.body}');
        return null;
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final link = body['link'] as String?;
      final fileName = body['file_name'] as String? ?? 'subtitle.srt';
      if (link == null) return null;

      final fileResponse = await http.get(Uri.parse(link));
      if (fileResponse.statusCode != 200) return null;

      final dir = await getTemporaryDirectory();
      final subDir = Directory('${dir.path}/subtitles');
      if (!await subDir.exists()) await subDir.create(recursive: true);

      final bytes = fileResponse.bodyBytes;

      if (fileName.endsWith('.zip') || (bytes.length > 4 && bytes[0] == 0x50 && bytes[1] == 0x4B)) {
        final archive = ZipDecoder().decodeBytes(bytes);
        for (final file in archive) {
          if (file.isFile) {
            final ext = file.name.split('.').last.toLowerCase();
            if (['srt', 'ass', 'ssa', 'vtt', 'sub'].contains(ext)) {
              final outFile = File('${subDir.path}/${file.name}');
              await outFile.writeAsBytes(file.content as List<int>);
              return outFile.path;
            }
          }
        }
        return null;
      }

      final outFile = File('${subDir.path}/$fileName');
      await outFile.writeAsBytes(bytes);
      return outFile.path;
    } catch (e) {
      Logger.error('OpenSubtitles download error', e);
      return null;
    }
  }
}
