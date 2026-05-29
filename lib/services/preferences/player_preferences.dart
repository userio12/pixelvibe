import 'base_preferences.dart';

mixin PlayerPreferences on BasePreferences {
  static const _defaultSpeed = 'default_speed';
  static const _resumePlayback = 'resume_playback';
  static const _autoPip = 'auto_pip';
  static const _skipInterval = 'skip_interval';
  static const _repeatMode = 'repeat_mode';
  static const _shuffleEnabled = 'shuffle_enabled';
  static const _autoplayNext = 'autoplay_next';
  static const _playerOrientation = 'player_orientation';
  static const _reduceMotion = 'reduce_motion';
  static const _showTimeRemaining = 'show_time_remaining';
  static const _seekbarStyle = 'seekbar_style';
  static const _topLeftControls = 'top_left_controls';
  static const _topRightControls = 'top_right_controls';
  static const _bottomCenterControls = 'bottom_center_controls';
  static const _enableNextPrevNavigation = 'enable_next_prev_navigation';
  static const _rememberBrightness = 'remember_brightness';
  static const _keepScreenOnWhenPaused = 'keep_screen_on_when_paused';
  static const _showRippleWhenSeeking = 'show_ripple_when_seeking';
  static const _showSeekTime = 'show_seek_time';
  static const _swapVolumeBrightness = 'swap_volume_brightness';
  static const _showLoadingCircle = 'show_loading_circle';
  static const _showStatusBarWithControls = 'show_status_bar_with_controls';
  static const _showNavBarWithControls = 'show_nav_bar_with_controls';
  static const _dynamicSpeedOverlay = 'dynamic_speed_overlay';
  static const _doubleTapSeekDuration = 'double_tap_seek_duration';
  static const _doubleTapSeekAreaWidth = 'double_tap_seek_area_width';
  static const _audioPitchCorrection = 'audio_pitch_correction';
  static const _preferredAudioLanguages = 'preferred_audio_languages';
  static const _volumeBoostCap = 'volume_boost_cap';
  static const _audioBackground = 'audio_background';
  static const _volumeNormalization = 'volume_normalization';
  static const _audioChannels = 'audio_channels';
  static const _abLoopEnabled = 'ab_loop_enabled';
  static const _closeAfterEnd = 'close_after_end';
  static const _watchedThreshold = 'watched_threshold';
  static const _httpHeaders = 'http_headers';
  static const _fileBrightnessPrefix = 'file_br_';
  static const _mirror = 'mirror';
  static const _flip = 'flip';
  static const _videoBrightness = 'video_brightness';
  static const _videoContrast = 'video_contrast';
  static const _videoSaturation = 'video_saturation';
  static const _videoGamma = 'video_gamma';
  static const _hrSeek = 'hr_seek';
  static const _tapToToggleVisibility = 'tap_to_toggle_visibility';
  static const _displaySeekbarSeconds = 'display_seekbar_seconds';
  static const _dimControlsSeconds = 'dim_controls_seconds';
  static const _doubleTapAnimation = 'double_tap_animation';
  static const _disableControlsTouchInput = 'disable_controls_touch_input';

  static const _defaultTopLeft = 'backArrow';
  static const _defaultTopRight = 'info,loadSubtitle,addToPlaylist,more,lock,pip,sleepTimer,volume';
  static const _defaultBottomCenter = 'skipBack,playPause,skipForward';

  double getDefaultSpeed() => getDouble(_defaultSpeed, 1.0);
  Future<void> setDefaultSpeed(double v) => setDouble(_defaultSpeed, v);

  bool getResumePlayback() => getBool(_resumePlayback, true);
  Future<void> setResumePlayback(bool v) => setBool(_resumePlayback, v);

  bool getAutoPip() => getBool(_autoPip, true);
  Future<void> setAutoPip(bool v) => setBool(_autoPip, v);

  int getSkipInterval() => getInt(_skipInterval, 10);
  Future<void> setSkipInterval(int v) => setInt(_skipInterval, v);

  String getRepeatMode() => getString(_repeatMode, 'off');
  Future<void> setRepeatMode(String v) => setString(_repeatMode, v);

  bool getShuffleEnabled() => getBool(_shuffleEnabled, false);
  Future<void> setShuffleEnabled(bool v) => setBool(_shuffleEnabled, v);

  bool getAutoplayNext() => getBool(_autoplayNext, true);
  Future<void> setAutoplayNext(bool v) => setBool(_autoplayNext, v);

  String getPlayerOrientation() => getString(_playerOrientation, 'free');
  Future<void> setPlayerOrientation(String v) => setString(_playerOrientation, v);

  bool getReduceMotion() => getBool(_reduceMotion, false);
  Future<void> setReduceMotion(bool v) => setBool(_reduceMotion, v);

  bool getShowTimeRemaining() => getBool(_showTimeRemaining, false);
  Future<void> setShowTimeRemaining(bool v) => setBool(_showTimeRemaining, v);

  String getSeekbarStyle() => getString(_seekbarStyle, 'standard');
  Future<void> setSeekbarStyle(String v) => setString(_seekbarStyle, v);

  String getTopLeftControls() => getString(_topLeftControls, _defaultTopLeft);
  Future<void> setTopLeftControls(String v) => setString(_topLeftControls, v);
  String getTopRightControls() => getString(_topRightControls, _defaultTopRight);
  Future<void> setTopRightControls(String v) => setString(_topRightControls, v);
  String getBottomCenterControls() => getString(_bottomCenterControls, _defaultBottomCenter);
  Future<void> setBottomCenterControls(String v) => setString(_bottomCenterControls, v);

  bool getEnableNextPrevNavigation() => getBool(_enableNextPrevNavigation, true);
  Future<void> setEnableNextPrevNavigation(bool v) => setBool(_enableNextPrevNavigation, v);

  bool getRememberBrightness() => getBool(_rememberBrightness, false);
  Future<void> setRememberBrightness(bool v) => setBool(_rememberBrightness, v);

  bool getKeepScreenOnWhenPaused() => getBool(_keepScreenOnWhenPaused, false);
  Future<void> setKeepScreenOnWhenPaused(bool v) => setBool(_keepScreenOnWhenPaused, v);

  bool getShowRippleWhenSeeking() => getBool(_showRippleWhenSeeking, true);
  Future<void> setShowRippleWhenSeeking(bool v) => setBool(_showRippleWhenSeeking, v);

  bool getShowSeekTime() => getBool(_showSeekTime, true);
  Future<void> setShowSeekTime(bool v) => setBool(_showSeekTime, v);

  bool getSwapVolumeBrightness() => getBool(_swapVolumeBrightness, false);
  Future<void> setSwapVolumeBrightness(bool v) => setBool(_swapVolumeBrightness, v);

  bool getShowLoadingCircle() => getBool(_showLoadingCircle, true);
  Future<void> setShowLoadingCircle(bool v) => setBool(_showLoadingCircle, v);

  bool getShowStatusBarWithControls() => getBool(_showStatusBarWithControls, false);
  Future<void> setShowStatusBarWithControls(bool v) => setBool(_showStatusBarWithControls, v);

  bool getShowNavBarWithControls() => getBool(_showNavBarWithControls, false);
  Future<void> setShowNavBarWithControls(bool v) => setBool(_showNavBarWithControls, v);

  bool getDynamicSpeedOverlay() => getBool(_dynamicSpeedOverlay, true);
  Future<void> setDynamicSpeedOverlay(bool v) => setBool(_dynamicSpeedOverlay, v);

  int getDoubleTapSeekDuration() => getInt(_doubleTapSeekDuration, 10);
  Future<void> setDoubleTapSeekDuration(int v) => setInt(_doubleTapSeekDuration, v);

  int getDoubleTapSeekAreaWidth() => getInt(_doubleTapSeekAreaWidth, 35);
  Future<void> setDoubleTapSeekAreaWidth(int v) => setInt(_doubleTapSeekAreaWidth, v);

  bool getAudioPitchCorrection() => getBool(_audioPitchCorrection, true);
  Future<void> setAudioPitchCorrection(bool v) => setBool(_audioPitchCorrection, v);

  String getPreferredAudioLanguages() => getString(_preferredAudioLanguages, '');
  Future<void> setPreferredAudioLanguages(String v) => setString(_preferredAudioLanguages, v);

  double getVolumeBoostCap() => getDouble(_volumeBoostCap, 0.15);
  Future<void> setVolumeBoostCap(double v) => setDouble(_volumeBoostCap, v);

  bool getAudioBackground() => getBool(_audioBackground, false);
  Future<void> setAudioBackground(bool v) => setBool(_audioBackground, v);

  bool getVolumeNormalization() => getBool(_volumeNormalization, false);
  Future<void> setVolumeNormalization(bool v) => setBool(_volumeNormalization, v);

  String getAudioChannels() => getString(_audioChannels, 'auto');
  Future<void> setAudioChannels(String v) => setString(_audioChannels, v);

  bool getAbLoopEnabled() => getBool(_abLoopEnabled, false);
  Future<void> setAbLoopEnabled(bool v) => setBool(_abLoopEnabled, v);

  bool getCloseAfterEnd() => getBool(_closeAfterEnd, false);
  Future<void> setCloseAfterEnd(bool v) => setBool(_closeAfterEnd, v);

  int getWatchedThreshold() => getInt(_watchedThreshold, 95);
  Future<void> setWatchedThreshold(int v) => setInt(_watchedThreshold, v);

  String getHttpHeaders() => getString(_httpHeaders, '');
  Future<void> setHttpHeaders(String v) => setString(_httpHeaders, v);

  double getFileBrightness(String path) => getDouble('$_fileBrightnessPrefix$path', 1.0);
  Future<void> setFileBrightness(String path, double v) => setDouble('$_fileBrightnessPrefix$path', v);

  bool getMirror() => getBool(_mirror, false);
  Future<void> setMirror(bool v) => setBool(_mirror, v);

  bool getFlip() => getBool(_flip, false);
  Future<void> setFlip(bool v) => setBool(_flip, v);

  int getVideoBrightness() => getInt(_videoBrightness, 0);
  Future<void> setVideoBrightness(int v) => setInt(_videoBrightness, v);

  int getVideoContrast() => getInt(_videoContrast, 0);
  Future<void> setVideoContrast(int v) => setInt(_videoContrast, v);

  int getVideoSaturation() => getInt(_videoSaturation, 0);
  Future<void> setVideoSaturation(int v) => setInt(_videoSaturation, v);

  int getVideoGamma() => getInt(_videoGamma, 0);
  Future<void> setVideoGamma(int v) => setInt(_videoGamma, v);

  bool getHrSeek() => getBool(_hrSeek, true);
  Future<void> setHrSeek(bool v) => setBool(_hrSeek, v);

  bool getTapToToggleVisibility() => getBool(_tapToToggleVisibility, true);
  Future<void> setTapToToggleVisibility(bool v) => setBool(_tapToToggleVisibility, v);

  bool getDisplaySeekbarSeconds() => getBool(_displaySeekbarSeconds, true);
  Future<void> setDisplaySeekbarSeconds(bool v) => setBool(_displaySeekbarSeconds, v);

  int getDimControlsSeconds() => getInt(_dimControlsSeconds, 5);
  Future<void> setDimControlsSeconds(int v) => setInt(_dimControlsSeconds, v);

  bool getDoubleTapAnimation() => getBool(_doubleTapAnimation, true);
  Future<void> setDoubleTapAnimation(bool v) => setBool(_doubleTapAnimation, v);

  bool getDisableControlsTouchInput() => getBool(_disableControlsTouchInput, false);
  Future<void> setDisableControlsTouchInput(bool v) => setBool(_disableControlsTouchInput, v);
}
