# pixelvibe — Research

## 1. Reference Project: mpvEx

**Repo**: https://github.com/marlboro-advance/mpvEx  
**Type**: Native Android (Kotlin + Jetpack Compose), **not** Flutter  
**Status**: 2.1k stars, 118 forks, 219 commits, v1.2.9 (March 2026)  
**License**: Apache 2.0  
**Forked from**: mpvKt (abdallahmehiz/mpvKt), which itself is based on mpv-android

### Architecture

Clean Architecture + MVVM with Koin DI. Layer stack:

```
ui/ (Compose Screens + ViewModels via StateFlow)
  → domain/ (pure Kotlin models + repository interfaces)
  → repository/ (implementations)
  → database/ (Room, 6 tables, WAL mode)
  → preferences/ (AndroidPreferenceStore wrapping DataStore)
```

### mpv Integration

- Bundled AAR: `app/libs/mpv-android-lib-v0.0.1.aar` (community library fork)
- Direct JNI via `is.xyz.mpv.MPVLib` static methods
- `BaseMPVView` (SurfaceView subclass) renders video
- Custom `MPVView` extends `BaseMPVView`, configures all mpv options
- `PlayerObserver` listens to mpv property changes via `MPVLib.addObserver()`
- User config via `mpv.conf`, `input.conf`, `scripts/`, `shaders/`, `fonts/` directories

### Key Features Implementation

| Feature | Approach |
|---------|----------|
| **SMB/FTP/WebDAV** | Protocol-specific libraries (smbj, commons-net, sardine-android) + Local HTTP proxy (NanoHTTPD on localhost) |
| **PiP** | Native `PictureInPictureParams` + `RemoteAction` BroadcastReceiver in `MPVPipHelper` |
| **Background playback** | `MediaBrowserServiceCompat` foreground service + `MediaSession` for lockscreen/Bluetooth/WearOS |
| **Subtitles** | mpv options (sid, secondary-sid, font config) + Wyzie API subtitle search |
| **Auto-resume** | Room `playback_state` table, saved per file path |
| **APK variants** | 5 ABI splits: universal, arm64-v8a, armeabi-v7a, x86, x86_64 |

### Gradle Build

- AGP 9.1.0, Kotlin 2.3.20, Compose BOM 2026.03.00, compileSdk 36, minSdk 26
- 3 product flavors: `standard` (GitHub), `playstore` (scoped storage), `fdroid` (arm64-v8a only)
- KSP for Room/Room compiler, Kotlinx Serialization

---

## 2. Flutter mpv Plugin Landscape

### Primary Recommendation: `media_kit`

- **pub.dev**: https://pub.dev/packages/media_kit
- **GitHub**: https://github.com/media-kit/media-kit (2k stars, 60+ contributors)
- **Latest**: `^1.2.6` (core), `^2.0.1` (video), `^1.0.7` (libs)
- **License**: MIT
- **Platforms**: Android 5.0+, iOS 9+, macOS 10.9+, Windows 7+, Linux

**How it works**: Dart FFI directly to libmpv — ~80% of codebase is pure Dart. Ships pre-built libmpv binaries per platform via `media_kit_libs_video` / `media_kit_libs_audio`.

**Feature set**: Hardware/GPU acceleration, playlists, libass subtitles, track selection (audio/video/subtitle), screenshots, pitch/speed control, HTTP headers, gapless playback, raw `mpvCommand()` for advanced control.

**Modular packages**:
| Package | Purpose |
|---------|---------|
| `media_kit` | Core player logic (Dart FFI) |
| `media_kit_video` | Video rendering widget + controller |
| `media_kit_libs_video` | Bundled libmpv for all platforms (Android ~15MB per arch) |
| `media_kit_libs_audio` | Audio-only bundling (smaller) |

### Low-level alternatives

| Package | Approach | Status |
|---------|----------|--------|
| `libmpv_dart` | Raw Dart FFI bindings to libmpv C API | Experimental, no Flutter widgets |
| `fvp` | FFmpeg-based (libmdk), NOT mpv | Viable alternative for non-mpv use |

### Flutter Gaps vs Native mpvEx

| Feature | Flutter-native solution | Needs platform channel |
|---------|------------------------|----------------------|
| Video playback | `media_kit_video` widget | — |
| Subtitles | `media_kit` built-in | — |
| Playlists | Custom Dart code | — |
| SMB/FTP/WebDAV | Dart packages exist (immature) | ✅ Local proxy in Kotlin |
| PiP | None | ✅ Native PictureInPictureParams |
| Background playback | None | ✅ MediaBrowserServiceCompat |
| Custom mpv scripts | `mpvCommand()` raw exposure | — |

### Known `media_kit` Risk

**Main-thread blocking** (GitHub #1395): mpv operations can block the main thread during orientation change or video resize on Android, causing ANR. Mitigation: isolate heavy operations, test in release mode early.

---

## 3. Android Build Requirements

### ABI Splits

```kotlin
android {
  splits {
    abi {
      enable true
      reset()
      include "arm64-v8a", "armeabi-v7a", "x86_64", "x86"
      universalApk true
    }
  }
}
```

### SDK minimums

| Parameter | Value |
|-----------|-------|
| minSdk | 26 (Android 8.0) |
| targetSdk | 36 |
| compileSdk | 36 |

### Permissions

| Permission | Required for |
|------------|-------------|
| `READ_MEDIA_VIDEO` | Browsing device videos (Android 13+) |
| `POST_NOTIFICATIONS` | Background playback notification (Android 13+) |
| `FOREGROUND_SERVICE` | Background playback service |
| `FOREGROUND_SERVICE_MEDIA_PLAYBACK` | Media foreground service |

**Not requested**: Location, Contacts, Phone, Camera, Microphone, SMS.

---

## 4. Database Schema (drift / SQLite)

Uses `drift` + `drift_flutter` (no separate SQLite plugin — v3 of `package:sqlite3` uses Dart build hooks auto-bundling native SQLite).

| Table | Purpose |
|-------|---------|
| `playback_states` | Auto-resume position per file |
| `recently_played` | Recently played history |
| `video_metadata` | Cached media info |
| `network_connections` | Saved SMB/FTP/WebDAV credentials |
| `playlists` | Playlist groups |
| `playlist_items` | Items within playlists |

---

## 5. State Management: Riverpod

| Provider | Purpose |
|----------|---------|
| `playerStateProvider` | Playback state (playing/paused/buffering) |
| `playlistProvider` | Active playlist queue |
| `browserStateProvider` | Browser path, view mode, search |
| `networkConnectionProvider` | Active network connections |
| `settingsProviders` | Individual preference reads |
| `databaseProvider` | Drift database instance |

---

## 6. License Compliance

All proposed dependencies use permissive licenses only (MIT, BSD-3-Clause, Apache 2.0). **No GPL/AGPL** libraries are required.
The sole nuance: `media_kit_libs_video` bundles libmpv binaries (LGPL-2.1+). On Android these are dynamically linked, which is compatible with closed-source distribution under LGPL's dynamic-linking exception. A license notice must still be included in the app (About screen).
Runtime-only dev dependencies (build_runner, drift_dev, freezed, etc.) have no distribution licensing obligations.

---

## 7. Key Architecture Decisions

| Decision | Choice |
|----------|--------|
| UI Framework | Flutter + Material3 |
| State management | Riverpod |
| Database | drift (SQLite) |
| mpv integration | `media_kit` |
| SMB/FTP/WebDAV | Platform channel to Kotlin (reuse mpvEx proxy) |
| PiP | Platform channel to Kotlin |
| Background playback | Platform channel to Kotlin |
| Platform scope | Android-only |
| DI | Riverpod (no separate DI framework) |
