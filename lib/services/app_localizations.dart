import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const _strings = <String, Map<String, String>>{
    'en': {
      'appTitle': 'pixelvibe',
      'browse': 'Browse',
      'files': 'Files',
      'recentlyPlayed': 'Recently Played',
      'mostPlayed': 'Most Played',
      'playlists': 'Playlists',
      'network': 'Network',
      'settings': 'Settings',
      'about': 'About pixelvibe',
      'searchVideos': 'Search videos...',
      'searchSettings': 'Search settings...',
      'noVideos': 'No videos found',
      'noPlaylists': 'No playlists yet',
      'noRecent': 'No recently played videos',
      'noFrequent': 'No frequently played videos yet',
      'rescan': 'Rescan device',
      'openUrl': 'Open URL',
      'sort': 'Sort',
      'filter': 'Filter',
      'play': 'Play',
      'pause': 'Pause',
      'delete': 'Delete',
      'cancel': 'Cancel',
      'close': 'Close',
      'done': 'Done',
      'loading': 'Loading...',
      'error': 'Error',
      'updateAvailable': 'Update available',
      'currentVersion': 'Current',
      'latestVersion': 'Latest',
      'download': 'Download',
      'later': 'Later',
      'changelog': 'Changelog',
      'sleepTimer': 'Sleep timer',
      'mediaInfo': 'Media Info',
      'chapters': 'Chapters',
      'noChapters': 'No chapters found',
      'properties': 'Properties',
      'selected': 'selected',
      'addToPlaylist': 'Add to playlist',
      'deleteConfirm': 'Delete file(s)? This cannot be undone.',
      'headphonesDisconnected': 'Headphones disconnected — playback paused',
      'speed': 'Speed',
      'skipInterval': 'Skip interval',
      'orientation': 'Player orientation',
      'themeMode': 'Theme mode',
      'dynamicColor': 'Dynamic color',
      'amoledMode': 'AMOLED dark mode',
      'contrast': 'Contrast level',
      'resumePlayback': 'Resume playback',
      'autoPip': 'Auto PiP',
      'autoplayNext': 'Autoplay next',
      'showTimeRemaining': 'Show time remaining',
      'reduceMotion': 'Reduce motion',
    },
  };

  String t(String key) {
    final lang = locale.languageCode;
    return _strings[lang]?[key] ?? _strings['en']?[key] ?? key;
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<AppLocalizations> load(Locale locale) => Future.value(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
