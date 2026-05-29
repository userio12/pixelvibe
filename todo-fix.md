# pixelvibe — Final Production Roadmap (v1.0.0 Target)

This document provides a final module-wise breakdown of the remaining tasks required to polish `pixelvibe` into a pristine, fully production-ready state, ensuring all features feel instantaneous ("real-time") and stable.

## 1. Core Module (`lib/core/`)
- [x] **Complete Theme Centralization**: Successfully migrated all hardcoded colors (e.g., `Colors.white`, `Colors.cyan`, `Colors.black87`) in `player_controls_bar.dart`, `seek_bar.dart`, `player_error_overlay.dart`, and `player_button_widget.dart` to the centralized `PixelvibeColors` theme extension. This ensures 1:1 color accuracy in AMOLED Black, standard Dark, and Light modes.

## 2. Data Module (`lib/data/`)
- [x] **Optimized**: Caching, indexing, and JSON overhead have been fully resolved. The data pipeline is real-time.
- [x] **Schema Migrations Verification**: Successfully bumped database schema to `v3` and implemented explicit `MigrationStrategy`.
    *   Verified that adding `contentUri`, `playCount`, and `watched` columns is handled gracefully.
    *   Added explicit `m.createIndex` calls in `onUpgrade` to ensure that newly optimized SQLite indexes are properly established on existing user databases during app updates.

## 3. Service Module (`lib/services/`)
- [x] **Split `PreferencesService`**: Refactored the monolithic `preferences_service.dart` (21KB) into distinct domains using Dart mixins for maintainability.
- [x] **Advanced File Logging**: Upgraded `Logger` to support log levels (DEBUG, INFO, WARN, ERROR) and automated file rotation (`current_log.txt`, `old_log.txt`) in the application support directory. Stack traces are now persistently captured for all error-level logs.
- [x] **Network Auto-discovery (Zeroconf/mDNS)**: Implemented `NetworkDiscoveryService` using the `nsd` package to scan for local SMB, FTP, and WebDAV services. Integrated discovery results into the `NetworkScreen`, allowing for one-tap connection pre-filling and server discovery without manual IP entry.

## 4. Presentation Module (`lib/presentation/`)
- [x] **Optimized**: Skeleton loaders, refresh indicators, and localized error handling are fully implemented.
- [x] **Settings Polish**: Fully refactored all settings screens (`Player`, `Gestures`, `Decoder`, `Subtitles`, `Appearance`, `Advanced`, `Folders`, `PlayerLayout`) to use a global, centralized, and reactive provider architecture. All UI toggles now correctly reflect and update the underlying mixin-based `PreferencesService` without redundant manual refreshes.

## 5. Native Module (`android/`)
- [x] **Optimized**: Chunked media scanning, proxy lifecycle management, and hardware decoder routing are fully stable.
- [x] **Audio Focus & PiP Hardening**: Performed a full lifecycle audit of `MainActivity.kt`.
    - [x] Ensured explicit `abandonFocus()` and `stopForegroundService()` calls on activity destruction.
    - [x] Secured broadcast receiver unregistration with try-catch to prevent crashes during abnormal termination.
    - [x] Verified PiP seamless transition with `setAutoEnterEnabled` for Android 12+.

## 6. Testing & Quality Assurance
- [x] **Player Smoke Tests**: Successfully implemented robust widget tests in `test/widget/player_smoke_test.dart`.
    *   Resolved **Gesture Ambiguity**: Refactored `GestureHandler` to unify drag and scale gestures, preventing Flutter render-time exceptions.
    *   Harden **Widget Lifecycle**: Fixed `PlayerScreen` to correctly defer initialization and safely cleanup native services in `dispose`, ensuring stability in production environments.
- [x] **Integration Tests**: Successfully configured the modern `integration_test` framework in `test/integration/app_test.dart`.
    *   Implemented an end-to-end smoke test covering: App Boot, Multi-tab Navigation (Home, Network, Playlist, Settings), and reactive Preference toggling.
    *   Verified that the navigation router and Riverpod providers interact correctly during complex user flows.

---
## Final Recap: Production Ready Status
The `pixelvibe` codebase has undergone a total transformation into a high-performance, production-ready video player.

### ✅ Key Performance Wins:
- **Zero-lag Discovery**: Move to native chunked scanning and direct binary MethodChannel mapping.
- **Buttery Smooth UI**: Isolate-driven filtering/sorting and shimmering skeleton loaders.
- **Real-time Seeks**: Random-access SMB/FTP reads and in-memory proxy buffer caching.

### ✅ Architecture & Stability:
- **Modular Core**: Decoupled player components and mixin-based preferences for scalability.
- **OS Hardening**: Industrial-grade Audio Focus and PiP lifecycle management.
- **Diagnostic Foundation**: Multi-level rotating file logger for field debugging.
- **Automated Delivery**: Tag-driven GitHub Actions with signed multi-abi APK releases.

** pixelvibe v1.0.0 is ready for shipping. **

