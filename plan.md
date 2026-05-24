# pixelvibe — Development Plan

## Overview

Polished Android video player using Flutter + `media_kit` (libmpv via Dart FFI). Simple Material 3 interface with full mpv power underneath. Android-only for v1.

### Key Technology Choices

| Area | Choice | Rationale |
|------|--------|-----------|
| UI | Flutter + Material 3 | User requirement |
| mpv integration | `media_kit` ^1.2.6 | Most mature Flutter mpv solution |
| State management | Riverpod | Compile-safe, testable |
| Database | drift (SQLite) | Type-safe, migration support |
| Navigation | GoRouter | Declarative, deep-link support |
| Platform scope | Android-only | PiP / background = platform channels |

---

## Phase 1: Foundation (Weeks 1–2)

- Scaffold project, set minSdk 26 / compileSdk 36
- Add deps: media_kit, riverpod, go_router, drift, drift_flutter, permission_handler, etc.
- Material3 theming (dynamic color, light/dark)
- GoRouter shell with bottom nav: Browse, Playlists, Settings
- Drift DB schema (6 tables) + generate code
- Core Riverpod providers
- **Milestone**: App launches with themed shell and bottom nav

## Phase 2: File Browser (Week 3)

- Media scanning via Android ContentResolver
- Browser UI: grid, list, folder tree view modes
- Real-time search with debounce
- Permission handling (READ_MEDIA_VIDEO / READ_EXTERNAL_STORAGE)
- **Milestone**: Working file browser showing device videos

## Phase 3: Player Core (Weeks 4–6)

- media_kit Player + Video widget integration
- Player screen with auto-hide overlay controls
- Gesture handling: brightness, volume, seek swipes + pinch zoom
- Track selector sheet (audio, subtitle tracks)
- External subtitle loading and styling
- External audio track loading
- Chapter selector with seek
- Frame-step navigation
- Subtitle styling preferences
- **Milestone**: Full mpv playback with controls, tracks, chapters

## Phase 4: Advanced Playback (Weeks 7–8)

- **PiP**: Platform channel to Kotlin PictureInPictureParams + RemoteAction
- **Background playback**: Platform channel to MediaBrowserServiceCompat + MediaSession
- **Network proxy**: Kotlin NanoHTTPD local HTTP proxy for SMB/FTP/WebDAV
- **Network browser UI**: Add/edit connections, browse shares
- Protocol-specific clients for SMB (smbj), FTP (commons-net), WebDAV (sardine-android)
- **Milestone**: PiP, background audio, SMB/FTP/WebDAV streaming

## Phase 5: Library & Management (Weeks 9–10)

- Playlist CRUD with drag-to-reorder
- Recently played history (auto-record)
- Resume playback (save position every 5s, show resume dialog)
- Media info sheet (codec, resolution, bitrate)
- **Milestone**: Playlists, resume, recently played

## Phase 6: Settings & Polish (Weeks 11–12)

- Full settings: appearance, playback, subtitles, audio, decoder, gestures
- Advanced mpv config: file picker for mpv.conf / input.conf, text editor
- Lua scripting: browse scripts directory, load into mpv
- UI animations, haptics, accessibility, edge-to-edge
- About screen with licenses
- **Milestone**: Full settings suite + power-user mpv scripting

## Phase 7: Build & Release (Week 13)

- ABI splits (arm64-v8a, armeabi-v7a, x86_64, x86, universal)
- ProGuard rules for media_kit native libs
- GitHub Actions CI: analyze → test → build signed APKs
- Version tagging: commit → tag → CI releases
- fastlane metadata (optional)
- **Milestone**: CI producing signed per-ABI APKs + universal APK

---

## Total: ~13 weeks

| Phase | Weeks | Milestone |
|-------|-------|-----------|
| Foundation | 1–2 | App shell with navigation + DB |
| File Browser | 3 | Browse + search local videos |
| Player Core | 4–6 | Full mpv playback |
| Advanced Playback | 7–8 | PiP, background, network streaming |
| Library & Management | 9–10 | Playlists, resume, recently played |
| Settings & Polish | 11–12 | Settings, mpv scripting, polish |
| Build & Release | 13 | CI + signed APKs |
