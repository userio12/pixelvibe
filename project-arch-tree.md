# pixelvibe — Project Architecture Tree

```
pixelvibe/
│
├── lib/
│   ├── main.dart                          # App entrypoint
│   ├── app.dart                           # MaterialApp.router + theme + riverpod scope
│   ├── bootstrap.dart                     # Initialization (DB, prefs, platform channels)
│   │
│   ├── core/
│   │   ├── di/
│   │   │   └── providers.dart             # Top-level Riverpod providers
│   │   ├── router/
│   │   │   ├── app_router.dart            # GoRouter config + ShellRoute
│   │   │   └── routes.dart                # Route path constants
│   │   ├── theme/
│   │   │   ├── app_theme.dart             # Material3 dynamic color light/dark
│   │   │   ├── colors.dart                # Custom color tokens
│   │   │   └── typography.dart            # Text style overrides
│   │   └── constants/
│   │       ├── app_constants.dart         # App-wide constants
│   │       └── permission_ids.dart        # Runtime permission identifiers
│   │
│   ├── data/
│   │   ├── database/
│   │   │   ├── app_database.dart          # Drift database class
│   │   │   ├── entities/
│   │   │   │   ├── playback_state_entity.dart
│   │   │   │   ├── recently_played_entity.dart
│   │   │   │   ├── video_metadata_entity.dart
│   │   │   │   ├── network_connection_entity.dart
│   │   │   │   ├── playlist_entity.dart
│   │   │   │   └── playlist_item_entity.dart
│   │   │   ├── daos/
│   │   │   │   ├── playback_state_dao.dart
│   │   │   │   ├── recently_played_dao.dart
│   │   │   │   ├── video_metadata_dao.dart
│   │   │   │   ├── network_connection_dao.dart
│   │   │   │   └── playlist_dao.dart
│   │   │   └── migrations.dart            # Schema migrations
│   │   ├── repositories/
│   │   │   ├── media_repository.dart       # Local media file scanning
│   │   │   ├── playback_state_repository.dart
│   │   │   ├── recently_played_repository.dart
│   │   │   ├── playlist_repository.dart
│   │   │   └── network_repository.dart     # SMB/FTP/WebDAV operations
│   │   ├── network/
│   │   │   ├── clients/
│   │   │   │   ├── smb_client.dart
│   │   │   │   ├── ftp_client.dart
│   │   │   │   ├── webdav_client.dart
│   │   │   │   └── network_client_factory.dart
│   │   │   ├── proxy/
│   │   │   │   ├── streaming_proxy.dart    # Dart-side proxy interface
│   │   │   │   └── proxy_lifecycle.dart
│   │   │   └── models/
│   │   │       ├── network_connection.dart
│   │   │       └── network_file.dart
│   │   └── preferences/
│   │       ├── player_preferences.dart
│   │       ├── subtitle_preferences.dart
│   │       ├── decoder_preferences.dart
│   │       ├── appearance_preferences.dart
│   │       └── gesture_preferences.dart
│   │
│   ├── domain/
│   │   ├── models/                         # Pure Dart domain models
│   │   │   ├── media_file.dart
│   │   │   ├── playback_state.dart
│   │   │   ├── playlist.dart
│   │   │   ├── playlist_item.dart
│   │   │   ├── track.dart
│   │   │   ├── chapter.dart
│   │   │   └── subtitle_file.dart
│   │   └── services/
│   │       ├── media_scanner.dart
│   │       └── thumbnail_service.dart
│   │
│   ├── presentation/
│   │   ├── player/
│   │   │   ├── player_screen.dart          # Full player composable
│   │   │   ├── player_host.dart            # Manages mpv lifecycle + overlay
│   │   │   ├── player_provider.dart        # Playback state Riverpod
│   │   │   ├── widgets/
│   │   │   │   ├── player_controls.dart    # Overlay control bar
│   │   │   │   ├── seekbar.dart            # Custom seekbar widget
│   │   │   │   ├── volume_slider.dart
│   │   │   │   ├── playback_speed_selector.dart
│   │   │   │   ├── track_selector_sheet.dart
│   │   │   │   ├── chapter_selector_sheet.dart
│   │   │   │   ├── subtitle_selector.dart
│   │   │   │   ├── zoom_gesture_detector.dart
│   │   │   │   └── frame_navigation_controls.dart
│   │   │   └── enums/
│   │   │       ├── player_mode.dart
│   │   │       └── gesture_mode.dart
│   │   │
│   │   ├── browser/
│   │   │   ├── browser_screen.dart
│   │   │   ├── browser_provider.dart
│   │   │   ├── widgets/
│   │   │   │   ├── video_grid_tile.dart
│   │   │   │   ├── video_list_tile.dart
│   │   │   │   ├── folder_list_tile.dart
│   │   │   │   ├── view_mode_toggle.dart
│   │   │   │   ├── search_bar.dart
│   │   │   │   └── empty_state.dart
│   │   │   └── enums/
│   │   │       └── view_mode.dart
│   │   │
│   │   ├── network_browser/
│   │   │   ├── network_browser_screen.dart
│   │   │   ├── network_browser_provider.dart
│   │   │   ├── connection_form_screen.dart
│   │   │   └── widgets/
│   │   │       ├── connection_tile.dart
│   │   │       ├── protocol_selector.dart
│   │   │       └── credential_form.dart
│   │   │
│   │   ├── playlist/
│   │   │   ├── playlist_list_screen.dart
│   │   │   ├── playlist_detail_screen.dart
│   │   │   ├── playlist_edit_screen.dart
│   │   │   ├── playlist_provider.dart
│   │   │   └── widgets/
│   │   │       ├── playlist_tile.dart
│   │   │       ├── draggable_playlist_item.dart
│   │   │       └── add_to_playlist_sheet.dart
│   │   │
│   │   ├── settings/
│   │   │   ├── settings_screen.dart
│   │   │   ├── settings_provider.dart
│   │   │   ├── sections/
│   │   │   │   ├── appearance_settings.dart
│   │   │   │   ├── playback_settings.dart
│   │   │   │   ├── subtitle_settings.dart
│   │   │   │   ├── audio_settings.dart
│   │   │   │   ├── decoder_settings.dart
│   │   │   │   ├── gesture_settings.dart
│   │   │   │   ├── advanced_config.dart
│   │   │   │   └── network_settings.dart
│   │   │   └── widgets/
│   │   │       ├── settings_section.dart
│   │   │       └── settings_tile.dart
│   │   │
│   │   ├── search/
│   │   │   ├── search_screen.dart
│   │   │   ├── search_provider.dart
│   │   │   └── widgets/
│   │   │       ├── search_result_tile.dart
│   │   │       └── recent_searches.dart
│   │   │
│   │   ├── media_info/
│   │   │   ├── media_info_sheet.dart
│   │   │   └── widgets/
│   │   │       ├── codec_info_tile.dart
│   │   │       └── metadata_table.dart
│   │   │
│   │   └── about/
│   │       └── about_screen.dart
│   │
│   ├── services/
│   │   ├── background_playback_service.dart
│   │   ├── pip_service.dart
│   │   └── platform_channels.dart
│   │
│   └── utils/
│       ├── permissions/
│       │   ├── permission_handler.dart
│       │   └── permission_ids.dart
│       ├── file_utils.dart
│       ├── subtitle_utils.dart
│       ├── format_utils.dart
│       └── extensions/
│           ├── context_extensions.dart
│           ├── string_extensions.dart
│           └── datetime_extensions.dart
│
├── android/
│   └── app/
│       ├── build.gradle.kts                # + ABI splits config
│       ├── proguard-rules.pro
│       └── src/main/
│           ├── AndroidManifest.xml
│           └── kotlin/com/pixelvibe/
│               ├── PixelvibePlugin.kt
│               ├── PiPHelper.kt
│               ├── BackgroundPlaybackService.kt
│               └── proxy/
│                   ├── StreamingProxy.kt
│                   └── ProxyLifecycleObserver.kt
│
├── assets/shaders/
├── test/
│   ├── unit/ (repositories, providers, services)
│   ├── widget/ (player, browser, settings)
│   └── integration/ (playback flow)
├── .github/workflows/build.yml
├── pubspec.yaml
└── analysis_options.yaml
```
