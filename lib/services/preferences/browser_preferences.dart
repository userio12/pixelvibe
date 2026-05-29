import 'base_preferences.dart';

mixin BrowserPreferences on BasePreferences {
  static const _onboardingComplete = 'onboarding_complete';
  static const _showFullFileNames = 'show_full_file_names';
  static const _showNewLabel = 'show_new_label';
  static const _daysThreshold = 'days_threshold';
  static const _autoScrollToLastPlayed = 'auto_scroll_to_last_played';
  static const _tapThumbnailToSelect = 'tap_thumbnail_to_select';
  static const _showNetworkThumbnails = 'show_network_thumbnails';
  static const _blacklistedFolders = 'blacklisted_folders';

  bool isOnboardingComplete() => getBool(_onboardingComplete, false);
  Future<void> setOnboardingComplete() => setBool(_onboardingComplete, true);

  bool getShowFullFileNames() => getBool(_showFullFileNames, false);
  Future<void> setShowFullFileNames(bool v) => setBool(_showFullFileNames, v);

  bool getShowNewLabel() => getBool(_showNewLabel, true);
  Future<void> setShowNewLabel(bool v) => setBool(_showNewLabel, v);

  int getDaysThreshold() => getInt(_daysThreshold, 7);
  Future<void> setDaysThreshold(int v) => setInt(_daysThreshold, v);

  bool getAutoScrollToLastPlayed() => getBool(_autoScrollToLastPlayed, false);
  Future<void> setAutoScrollToLastPlayed(bool v) => setBool(_autoScrollToLastPlayed, v);

  bool getTapThumbnailToSelect() => getBool(_tapThumbnailToSelect, false);
  Future<void> setTapThumbnailToSelect(bool v) => setBool(_tapThumbnailToSelect, v);

  bool getShowNetworkThumbnails() => getBool(_showNetworkThumbnails, false);
  Future<void> setShowNetworkThumbnails(bool v) => setBool(_showNetworkThumbnails, v);

  List<String> getBlacklistedFolders() => prefs.getStringList(_blacklistedFolders) ?? [];
  Future<void> setBlacklistedFolders(List<String> v) => prefs.setStringList(_blacklistedFolders, v);
}
