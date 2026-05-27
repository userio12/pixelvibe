# pixelvibe

Flutter Android video player built on `media_kit` (libmpv via Dart FFI). Material 3, Riverpod, drift, GoRouter.

## Commands

```bash
flutter pub get              # install dependencies
flutter analyze              # static analysis
flutter test                 # run tests
dart run build_runner build  # code generation (drift)
```

## Architecture

| Layer | Path | Tech |
|-------|------|------|
| UI | `lib/presentation/` | Flutter + Material 3 |
| State | `lib/core/di/` | Riverpod |
| Data | `lib/data/` | drift (SQLite), platform channels |
| Domain | `lib/domain/` | Pure Dart models |
| Platform | `android/.../kotlin/` | PiP, background playback, network proxy |

## Default Tools

- **grep**: Use `rg` (ripgrep) via bash for all code searches, not the built-in Grep tool. Prefer `rg -n` with file-type flags (e.g. `-tdart`).
- **graphify**: Always load the graphify-windows skill before answering questions about the codebase to leverage the persistent knowledge graph in `graphify-out/`.

## Key Constraints

- **minSdk 26**, compileSdk/targetSdk 36
- Android-only v1 (PiP/background/platform channels)
- `media_kit` for mpv — not ExoPlayer or `video_player`
- `drift_flutter` for DB (no `sqlite3_flutter_libs`)
- Permissions requested only: `READ_MEDIA_VIDEO`, `POST_NOTIFICATIONS`, `FOREGROUND_SERVICE*`
