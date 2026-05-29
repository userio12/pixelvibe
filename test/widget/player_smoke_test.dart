import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:pixelvibe/presentation/player/player_screen.dart';
import 'package:pixelvibe/presentation/player/player_provider.dart';
import 'package:pixelvibe/core/di/providers.dart';
import 'package:pixelvibe/core/di/platform_providers.dart';
import 'package:pixelvibe/services/preferences_service.dart';
import 'package:pixelvibe/data/database/daos/playback_state_dao.dart';
import 'package:pixelvibe/data/database/daos/recently_played_dao.dart';
import 'package:pixelvibe/data/database/daos/video_metadata_dao.dart';
import 'package:pixelvibe/services/background_service.dart';
import 'package:pixelvibe/services/pip_service.dart';

class MockPlayer extends Mock implements Player {
  @override
  Future<int> get handle => Future.value(0);
}

class FakePreferencesService extends Fake implements PreferencesService {
  @override String getRepeatMode() => 'off';
  @override String getPlayerOrientation() => 'free';
  @override bool getAutoplayNext() => true;
  @override bool getReduceMotion() => false;
  @override bool getShuffleEnabled() => false;
  @override bool getResumePlayback() => true;
  @override bool getCloseAfterEnd() => false;
  @override int getWatchedThreshold() => 95;
  @override bool getAudioBackground() => false;
  @override bool getAutoPip() => true;
  @override bool getShowTimeRemaining() => false;
  @override String getSeekbarStyle() => 'standard';
  @override String getTopLeftControls() => 'backArrow';
  @override String getTopRightControls() => 'more';
  @override String getBottomCenterControls() => 'playPause';
  @override bool getEnableNextPrevNavigation() => true;
  @override bool getRememberBrightness() => false;
  @override bool getKeepScreenOnWhenPaused() => false;
  @override bool getShowRippleWhenSeeking() => true;
  @override bool getShowSeekTime() => true;
  @override bool getSwapVolumeBrightness() => false;
  @override bool getShowLoadingCircle() => true;
  @override bool getShowStatusBarWithControls() => false;
  @override bool getShowNavBarWithControls() => false;
  @override bool getDynamicSpeedOverlay() => true;
  @override double getGestureSensitivity() => 1.0;
  @override bool getAllowGesturesInPanels() => false;
  @override String getHwdec() => 'auto';
  @override String getGpuApi() => 'auto';
  @override String getFilterPreset() => 'none';
  @override bool getMirror() => false;
  @override bool getFlip() => false;
  @override bool getScreenshotSubs() => true;
  @override bool getHrSeek() => true;
  @override String getMpvProfiles() => '[]';
  @override String getMpvActiveProfile() => 'Default';
  @override String getSubtitleLanguages() => 'en';
  @override String getPreferredAudioLanguages() => 'ja';
  @override bool getScaleByWindow() => true;
  @override String getSubtitleFontsDirectory() => '';
  @override String getSubtitleSaveLocation() => '';
  @override String getSubtitleSources() => '';
  @override bool getAutoLoadSubtitles() => true;
  @override double getDouble(String key, [double defaultValue = 0.0]) => defaultValue;
  @override int getInt(String key, [int defaultValue = 0]) => defaultValue;
  @override bool getBool(String key, [bool defaultValue = false]) => defaultValue;
  @override String getString(String key, [String defaultValue = '']) => defaultValue;
  @override double getDefaultSpeed() => 1.0;
  @override bool getDynamicColor() => true;
  @override ThemeMode getThemeMode() => ThemeMode.system;
  @override String getSelectedThemeSwatch() => 'Default';
  @override double getContrastLevel() => 0.0;
  @override bool getAudioPitchCorrection() => true;
  @override bool getVolumeNormalization() => false;
  @override double getVolumeBoostCap() => 0.15;
  @override String getAudioChannels() => 'auto';
  bool getSmartSubtitleAutoSelect() => true;
  @override int getDoubleTapSeekDuration() => 10;
  @override int getDimControlsSeconds() => 5;
  @override bool getTapToToggleVisibility() => true;
  @override bool getDisplaySeekbarSeconds() => true;
  @override bool getDoubleTapAnimation() => true;
  @override bool getDisableControlsTouchInput() => false;
  @override String getHttpHeaders() => '';
  @override bool getShowFullFileNames() => false;
  @override bool getShowNewLabel() => true;
  @override int getDaysThreshold() => 7;
  @override bool getAutoScrollToLastPlayed() => false;
  @override bool getTapThumbnailToSelect() => false;
  @override bool getShowNetworkThumbnails() => false;
  @override List<String> getBlacklistedFolders() => [];
  @override String getConfigStoragePath() => '';
  @override bool getLuaScripts() => false;
  @override bool getRecentlyPlayed() => true;
  // Add missing ones from your recent refactor
  @override int getDoubleTapSeekAreaWidth() => 35;
  @override bool getCenterGestureSingleTap() => false;
  @override String getDoubleTapLeftAction() => 'Seek';
  @override String getDoubleTapRightAction() => 'Seek';
  @override bool getMediaControlsDoubleTap() => true;
  @override bool getMediaControlsSingleTap() => true;
  @override bool getMediaControlsLongPress() => true;
  @override bool getMediaControlsSwipe() => true;
  int getSubtitleJustify() => 0;
  int getSubtitleSecondarySid() => -1;
  bool getSubtitleAssOverride() => false;
  @override String getShaderPreset() => '';
  @override bool getGpuNext() => false;
  @override bool getYuv420p() => false;
  @override bool getAnime4k() => false;
}

class MockPlaybackStateDao extends Mock implements PlaybackStateDao {}
class MockRecentlyPlayedDao extends Mock implements RecentlyPlayedDao {}
class MockVideoMetadataDao extends Mock implements VideoMetadataDao {}
class MockBackgroundService extends Mock implements BackgroundService {}
class MockPiPService extends Mock implements PiPService {}

void main() {
  late MockPlayer mockPlayer;
  late FakePreferencesService fakePrefs;
  late MockPlaybackStateDao mockPlaybackDao;
  late MockRecentlyPlayedDao mockRecentDao;
  late MockVideoMetadataDao mockVideoDao;
  late MockBackgroundService mockBackground;
  late MockPiPService mockPip;

  setUpAll(() {
    registerFallbackValue(Media(''));
  });

  setUp(() {
    mockPlayer = MockPlayer();
    fakePrefs = FakePreferencesService();
    mockPlaybackDao = MockPlaybackStateDao();
    mockRecentDao = MockRecentlyPlayedDao();
    mockVideoDao = MockVideoMetadataDao();
    mockBackground = MockBackgroundService();
    mockPip = MockPiPService();

    // Stub player streams
    final streams = _MockPlayerStream();
    when(() => mockPlayer.stream).thenReturn(streams);
    when(() => mockPlayer.state).thenReturn(const PlayerState());
    when(() => mockPlayer.platform).thenReturn(null);
    when(() => mockPlayer.open(any(), play: any(named: 'play'))).thenAnswer((_) async {});
    when(() => mockPlayer.setRate(any())).thenAnswer((_) async {});
    when(() => mockPlayer.setVolume(any())).thenAnswer((_) async {});

    // Stub DAOs
    when(() => mockPlaybackDao.findByPath(any())).thenAnswer((_) async => null);
    when(() => mockRecentDao.record(any(), any(), any())).thenAnswer((_) async {});
    when(() => mockVideoDao.incrementPlayCount(any())).thenAnswer((_) async {});

    // Stub platform services
    when(() => mockBackground.stopService()).thenAnswer((_) async {});
    when(() => mockBackground.updateMetadata(title: any(named: 'title'), durationMs: any(named: 'durationMs'))).thenAnswer((_) async {});
    when(() => mockBackground.updatePlaybackState(playing: any(named: 'playing'), positionMs: any(named: 'positionMs'))).thenAnswer((_) async {});
    
    when(() => mockPip.onNoisy).thenAnswer((_) => const Stream.empty());
    when(() => mockPip.onAudioFocusChange).thenAnswer((_) => const Stream.empty());
    when(() => mockPip.requestAudioFocus()).thenAnswer((_) async {});
    when(() => mockPip.onPipModeChanged(any())).thenReturn(null);
    when(() => mockPip.onTogglePlayback).thenAnswer((_) => const Stream.empty());
  });

  testWidgets('PlayerScreen renders without crashing', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerProvider.overrideWithValue(mockPlayer),
            preferencesServiceProvider.overrideWithValue(fakePrefs),
            playbackStateDaoProvider.overrideWithValue(mockPlaybackDao),
            recentlyPlayedDaoProvider.overrideWithValue(mockRecentDao),
            videoMetadataDaoProvider.overrideWithValue(mockVideoDao),
            backgroundServiceProvider.overrideWithValue(mockBackground),
            pipServiceProvider.overrideWithValue(mockPip),
          ],
          child: const MaterialApp(
            home: PlayerScreen(filePath: '/test/video.mp4'),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(PlayerScreen), findsOneWidget);
      expect(find.byType(Stack), findsWidgets);
    });
  });
}

class _MockPlayerStream extends Mock implements PlayerStream {
  @override Stream<Duration> get position => const Stream.empty();
  @override Stream<Duration> get duration => const Stream.empty();
  @override Stream<double> get volume => const Stream.empty();
  @override Stream<bool> get playing => const Stream.empty();
  @override Stream<Duration> get buffer => const Stream.empty();
  @override Stream<bool> get buffering => const Stream.empty();
  @override Stream<String> get error => const Stream.empty();
  @override Stream<Tracks> get tracks => const Stream.empty();
  @override Stream<int?> get width => const Stream.empty();
  @override Stream<int?> get height => const Stream.empty();
  @override Stream<List<String>> get subtitle => const Stream.empty();
  @override Stream<Playlist> get playlist => const Stream.empty();
  @override Stream<double> get rate => const Stream.empty();
  @override Stream<AudioParams> get audioParams => const Stream.empty();
  @override Stream<VideoParams> get videoParams => const Stream.empty();
  @override Stream<AudioDevice> get audioDevice => const Stream.empty();
  @override Stream<List<AudioDevice>> get audioDevices => const Stream.empty();
  @override Stream<bool> get completed => const Stream.empty();
}
