import 'dart:async';
import 'package:app_links/app_links.dart';
import 'logger.dart';

final appLinks = AppLinks();

class DeepLinkService {
  StreamSubscription? _sub;
  void Function(String uri)? onLink;

  Future<void> init() async {
    try {
      final initial = await appLinks.getInitialLink();
      if (initial != null) {
        Logger.info('DeepLink: initial $initial');
        onLink?.call(initial.toString());
      }
      _sub = appLinks.uriLinkStream.listen((uri) {
        Logger.info('DeepLink: $uri');
        onLink?.call(uri.toString());
      });
    } catch (e) {
      Logger.error('DeepLinkService.init error', e);
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}
