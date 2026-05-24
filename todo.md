# pixelvibe — Task Breakdown

## Phase 1: Foundation (Weeks 1-2)

### 1.1 Project Scaffold
- [ ] `flutter create --org com.pixelvibe pixelvibe`
- [ ] Set minSdk 26, compileSdk 36, targetSdk 36
- [ ] Remove default counter demo code
- [ ] Update AGENTS.md with build/test commands

### 1.2 Dependencies
- [ ] Add: media_kit, media_kit_video, media_kit_libs_video
- [ ] Add: flutter_riverpod, riverpod_annotation, go_router
- [ ] Add: drift, drift_flutter
- [ ] Add: dio, file_picker, path_provider, path
- [ ] Add: permission_handler, intl, share_plus, url_launcher
- [ ] Add: freezed_annotation, json_annotation
- [ ] Add: flutter_local_notifications
- [ ] Add dev: flutter_lints, build_runner, freezed, json_serializable, drift_dev, riverpod_generator, mocktail
- [ ] Run flutter pub get

### 1.3 Core Architecture
- [ ] Create core/theme/ (app_theme, colors, typography)
- [ ] Create core/router/ (app_router + ShellRoute, route constants)
- [ ] Create core/constants/ (app_constants, permission_ids)
- [ ] Create core/di/providers.dart

### 1.4 Database Setup
- [ ] Create data/database/app_database.dart
- [ ] Create entities (6 tables)
- [ ] Create DAOs (5 DAOs)
- [ ] Create migrations.dart
- [ ] Run build_runner

### 1.5 App Scaffold
- [ ] Create app.dart (MaterialApp.router + ProviderScope)
- [ ] Create bootstrap.dart
- [ ] Update main.dart
- [ ] Create placeholder screens
- [ ] Verify: flutter analyze, flutter test

## Phase 2: File Browser (Week 3)
- [ ] Create media_scanner, media_file model, media_repository
- [ ] Create thumbnail_service
- [ ] Create permission_handler with rationale dialog
- [ ] Create browser_screen with grid/list/tree views
- [ ] Create view_mode_toggle, video_grid_tile, video_list_tile, folder_list_tile
- [ ] Create debounced search with search_screen
- [ ] Wire search into browser top bar

## Phase 3: Player Core (Weeks 4-6)
- [ ] Integrate media_kit Player + Video widget
- [ ] Create player_host, player_provider, player_screen
- [ ] Create overlay controls (play/pause, seekbar, volume, speed)
- [ ] Implement auto-hide overlay
- [ ] Implement gesture handling (brightness, volume, seek, zoom)
- [ ] Create track_selector_sheet (audio + subtitle tracks)
- [ ] Implement external subtitle loading and styling
- [ ] Implement external audio loading
- [ ] Create chapter_selector_sheet with seek
- [ ] Create frame_navigation_controls
- [ ] Verify: local video playback works end-to-end

## Phase 4: Advanced Playback (Weeks 7-8)
- [ ] Create PiPHelper.kt (PictureInPictureParams + RemoteAction)
- [ ] Create Dart pip_service.dart + register channel
- [ ] Create BackgroundPlaybackService.kt (MediaBrowserServiceCompat)
- [ ] Create Dart background_playback_service.dart
- [ ] Update AndroidManifest.xml
- [ ] Create StreamingProxy.kt (NanoHTTPD local proxy)
- [ ] Create ProxyLifecycleObserver.kt
- [ ] Add smbj, commons-net, sardine-android deps
- [ ] Create SMB/FTP/WebDAV client classes + factory
- [ ] Create PixelvibePlugin.kt (MethodChannel router)
- [ ] Create network_browser_screen + connection_form_screen
- [ ] Create network_repository, network models
- [ ] Verify: PiP, background playback, network streaming all work

## Phase 5: Library & Management (Weeks 9-10)
- [ ] Create playlist CRUD (list, detail, edit screens)
- [ ] Implement drag-to-reorder in playlists
- [ ] Create add_to_playlist_sheet
- [ ] Create recently_played_repository + UI
- [ ] Create playback_state_repository (auto-resume)
- [ ] Create media_info_sheet with codec/resolution/bitrate
- [ ] Verify: playlists, resume, recently played all functional

## Phase 6: Settings & Polish (Weeks 11-12)
- [ ] Create settings_screen with grouped sections
- [ ] Create all preference classes (player, subtitle, decoder, etc.)
- [ ] Create settings sections (appearance, playback, subtitles, audio, decoder, gestures, network)
- [ ] Create advanced_config section (mpv.conf, input.conf file picker + editor)
- [ ] Implement Lua scripting support (file picker, load into mpv)
- [ ] Add page transitions, overlay fade, haptic feedback
- [ ] Add accessibility support (content descriptions, large text)
- [ ] Add edge-to-edge display
- [ ] Create about_screen with licenses
- [ ] Verify: all settings functional, UI polished

## Phase 7: Build & Release (Week 13)
- [ ] Configure ABI splits (arm64-v8a, armeabi-v7a, x86_64, x86, universal)
- [ ] Create proguard-rules.pro
- [ ] Test flutter build apk --split-per-abi
- [ ] Create .github/workflows/build.yml
- [ ] Configure release signing via GitHub Secrets
- [ ] Document release process
- [ ] Create initial v0.1.0-alpha tag

## Verification Gates
- [ ] flutter analyze passes after each phase
- [ ] flutter test passes after each phase
- [ ] flutter build apk --debug compiles after each phase

Total: ~140 tasks | Estimated: ~13 weeks
