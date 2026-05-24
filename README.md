# pixelvibe

**Polished Android video player** — Flutter + `media_kit` (libmpv via Dart FFI), Material 3, Riverpod, drift (SQLite), GoRouter.

Android-only v1. PiP, background playback, network streaming (SMB/FTP/WebDAV), playlist management, auto-resume, recently played, and a full settings suite.

---

## Features

| Category | Details |
|----------|---------|
| **Player** | media_kit (libmpv) — hardware decoding, subtitles, multi-speed, auto-resume, media info sheet (codec/resolution/bitrate/tracks) |
| **File Browser** | Grid / list / folder tree views, debounced search with `SearchBar`, recently played section, permission handling |
| **Picture-in-Picture** | Auto-enter PiP on background (toggle), PictureInPictureParams + RemoteAction via platform channel |
| **Background Playback** | Foreground service with persistent notification, MediaSessionCompat for lock screen controls |
| **Network Streaming** | SMB, FTP, WebDAV protocol clients (Kotlin) → local NanoHTTPD proxy (port 8765) → media_kit plays `http://127.0.0.1:8765/path` |
| **Playlists** | CRUD with name + description, `ReorderableListView` drag-to-reorder, add-to-playlist bottom sheet |
| **Recently Played** | Auto-record on playback start, horizontal section in browser, configurable limit |
| **Resume Playback** | Position auto-saved every 5s, resume dialog on re-open |
| **Settings** | Theme (system/light/dark), dynamic color, default playback speed, skip interval, subtitle font size, hardware decoding toggle, GPU API selector, mpv.conf/input.conf loader (stub), Lua script browser (stub) |
| **CI/CD** | GitHub Actions — `flutter analyze` → `flutter test` → `flutter build apk --debug --split-per-abi` → artifact upload |

---

## Tech Stack

| Layer | Technology | License |
|-------|-----------|---------|
| UI | Flutter + Material 3 | BSD-3-Clause |
| mpv Integration | [media_kit](https://github.com/media-kit/media-kit) (Dart FFI) | MIT |
| State Management | [Riverpod](https://riverpod.dev/) 3.x | MIT |
| Database | [drift](https://drift.simonbinder.eu/) (SQLite) | MIT |
| Navigation | [GoRouter](https://pub.dev/packages/go_router) | BSD-3-Clause |
| Notifications | `flutter_local_notifications` | BSD-3-Clause |
| Local HTTP Proxy | [NanoHTTPD](https://github.com/NanoHttpd/nanohttpd) | BSD-2-Clause |
| FTP Client | Apache Commons Net | Apache-2.0 |
| SMB Client | jcifs-ng (stub — TBD) | LGPL-2.1 |
| Code Gen | build_runner + drift_dev + freezed | BSD-3-Clause |

---

## Architecture

```
lib/
├── core/          # DI (Riverpod providers), router (GoRouter), theme, constants
├── data/          # drift database (6 entities, 5 DAOs), repositories, network clients
├── domain/        # Pure Dart models (MediaFile, Track, Chapter, Playlist, …)
├── presentation/  # Flutter screens + widgets (browser, player, playlist, settings, about, …)
├── services/      # Platform channel wrappers (PiP, background, network)
└── utils/         # Permission handler, format utilities, extensions

android/…/kotlin/com/pixelvibe/
├── PixelvibePlugin.kt          # MethodChannel router (6 methods)
├── MainActivity.kt             # Registers 3 channel handlers
├── pip/PiPHelper.kt            # PiP params + auto-enter
├── background/PlaybackService.kt    # Foreground service + notification
├── mediasession/MediaSessionCallback.kt  # MediaSessionCompat + BroadcastReceiver
├── network/                    # SMBClient, FTPClient, WebDAVClient, Factory
└── proxy/StreamingProxy.kt     # NanoHTTPD on port 8765
```

### Routes

| Path | Screen | In Shell? |
|------|--------|-----------|
| `/` | Browse (grid/list/tree) | Yes |
| `/playlists` | Playlist list | Yes |
| `/settings` | Settings | Yes |
| `/player/:filePath` | Video player | Full screen |
| `/network-browser` | Network connection list | Full screen |
| `/network-connection-form` | Add/edit connection | Full screen |
| `/playlist-detail/:id` | Playlist detail + reorder | Full screen |
| `/about` | About + licenses | Full screen |

---

## Getting Started

### Prerequisites

- Flutter SDK **3.41** (stable)
- Java 17+ (for Android builds)
- Android Studio (for emulator / device)

### Setup

```bash
git clone https://github.com/userio12/pixelvibe.git
cd pixelvibe
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Commands

```bash
flutter analyze              # Static analysis (must pass)
flutter test                 # Run unit/widget tests
flutter build apk --debug    # Debug APK (universal)
flutter build apk --debug --split-per-abi   # Split APKs (arm64-v8a + armeabi-v7a)
```

---

## Configuration

### Android SDK

| Property | Value |
|----------|-------|
| minSdk | **26** (Android 8.0) |
| compileSdk | **36** |
| targetSdk | **36** |

### Permissions (runtime)

| Permission | Purpose |
|-----------|---------|
| `READ_MEDIA_VIDEO` | Browse local video files |
| `POST_NOTIFICATIONS` | Playback notification channel |
| `FOREGROUND_SERVICE` | Keep process alive in background |
| `FOREGROUND_SERVICE_MEDIA_PLAYBACK` | Media playback category |

### ABI Splits

APKs are split per-ABI. Only `arm64-v8a` and `armeabi-v7a` are included (`x86_64` and `x86` excluded).

### Drift Database

6 tables: `video_metadata`, `recently_played`, `playback_state`, `playlist`, `playlist_item`, `network_connection`.

---

## Build & Release

### Debug Builds

```bash
flutter build apk --debug --split-per-abi
```

Output: `build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk` + `app-armeabi-v7a-debug.apk`

### Release Builds

1. Create `android/key.properties` (see `key.properties.template`):
   ```
   storePassword=<pass>
   keyPassword=<pass>
   keyAlias=<alias>
   storeFile=<path-to-keystore>
   ```
2. Build:
   ```bash
   flutter build apk --release --split-per-abi
   ```

### CI/CD (GitHub Actions)

Every push to `main` triggers:
1. **analyze** — `flutter analyze`
2. **test** — `flutter test`
3. **build-apks** — `flutter build apk --debug --split-per-abi` → upload as artifact

---

## Dependencies

All dependencies are permissively licensed (MIT, BSD, Apache-2.0). Full list in `pubspec.yaml` and `android/app/build.gradle.kts`. Library licenses are shown in-app at Settings → About.

---

## Next Steps / Known Gaps

- **SMB client** — currently stubbed; needs correct jcifs-ng API or switch to smbj/hierynomus
- **mpv.conf / input.conf editor** — file picker + in-app text editor (SnackBar stub)
- **Lua script browser** — browse scripts directory and load into mpv (SnackBar stub)
- **Device media scanning** — ContentResolver returns empty; needs implementation to populate browser
- **PiP actions** — RemoteAction for play/pause/skip in PiP overlay
- **Frame-step navigation** — frame advance/back controls
- **External subtitles** — load `.srt`/`.ass` files from device
- **Release signing** — key.properties + keystore for signed APK distribution

---

## License

MIT License — see [LICENSE](LICENSE) (not yet created).

© 2026 pixelvibe
