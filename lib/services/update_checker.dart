import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'logger.dart';

class UpdateInfo {
  final String version;
  final String url;
  final String? changelog;
  final DateTime publishedAt;

  const UpdateInfo({
    required this.version,
    required this.url,
    this.changelog,
    required this.publishedAt,
  });
}

class UpdateChecker {
  static const _owner = 'anomalyco';
  static const _repo = 'pixelvibe';
  static const _apiUrl = 'https://api.github.com/repos/$_owner/$_repo/releases/latest';

  Future<UpdateInfo?> check() async {
    try {
      final client = HttpClient()
        ..userAgent = 'pixelvibe'
        ..connectionTimeout = const Duration(seconds: 10);
      final request = await client.getUrl(Uri.parse(_apiUrl));
      final response = await request.close();
      if (response.statusCode != 200) {
        Logger.warning('Update check returned ${response.statusCode}');
        return null;
      }
      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final tag = json['tag_name'] as String? ?? '';
      final htmlUrl = json['html_url'] as String? ?? '';
      final bodyText = json['body'] as String?;
      final published = json['published_at'] as String?;
      client.close();

      return UpdateInfo(
        version: tag.replaceAll(RegExp(r'^v'), ''),
        url: htmlUrl,
        changelog: bodyText,
        publishedAt: published != null ? DateTime.parse(published) : DateTime.now(),
      );
    } catch (e) {
      Logger.error('Update check failed', e);
      return null;
    }
  }
}

Future<void> showUpdateDialog(BuildContext context, UpdateInfo update) async {
  final currentVersion = '1.0.0';
  if (update.version == currentVersion) return;

  final download = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Update available: v${update.version}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current: v$currentVersion\nLatest: v${update.version}'),
            if (update.changelog != null && update.changelog!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Changelog:', style: Theme.of(ctx).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(update.changelog!, style: Theme.of(ctx).textTheme.bodySmall),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Later')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Download')),
      ],
    ),
  );

  if (download == true && context.mounted) {
    final uri = Uri.parse(update.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
