import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/routes.dart';

class UrlInputDialog extends StatefulWidget {
  const UrlInputDialog({super.key});

  @override
  State<UrlInputDialog> createState() => _UrlInputDialogState();
}

class _UrlInputDialogState extends State<UrlInputDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Open URL'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'https://example.com/video.mp4',
          labelText: 'Video URL',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.url,
        textInputAction: TextInputAction.go,
        onSubmitted: (_) => _open(context),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => _open(context), child: const Text('Open')),
      ],
    );
  }

  void _open(BuildContext context) {
    final url = _controller.text.trim();
    if (url.isEmpty) return;
    Navigator.pop(context);
    final encoded = Uri.encodeComponent(url);
    context.push('${Routes.player}/$encoded');
  }
}
