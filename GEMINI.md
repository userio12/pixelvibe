# pixelvibe — Project Instructions

`pixelvibe` is a polished Android-first video player built with Flutter, powered by `media_kit` (libmpv via Dart FFI).

## Project Overview

- **Purpose:** A feature-rich video player for Android focusing on performance and a modern Material 3 experience.
- **Main Technologies:**
    - **Framework:** Flutter (Material 3)
    - **Playback Engine:** [media_kit](https://github.com/media-kit/media-kit) (libmpv integration)
    - **State Management:** Riverpod 3.x
    - **Database:** Drift (SQLite)
    - **Navigation:** GoRouter
    - **Networking:** Kotlin-based proxy (NanoHTTPD) for SMB/FTP/WebDAV streaming.
- **Platform Support:** Android only (v1 focus). Minimum SDK: 26 (Android 8.0).

## Architecture

The project follows a layered architecture to ensure separation of concerns:

- `lib/core/`: DI (Riverpod), router (GoRouter), theme, and app-wide constants.
- `lib/data/`: Data persistence (Drift), repositories, and network clients.
- `lib/domain/`: Pure Dart domain models and service interfaces.
- `lib/presentation/`: UI screens and widgets, organized by feature (player, browser, playlist, settings).
- `lib/services/`: Platform channel wrappers and cross-cutting concerns (PiP, background playback).
- `lib/utils/`: Helper functions, extensions, and permission management.
- `android/`: Kotlin implementation for PiP, foreground services, and local HTTP proxy for network streams.

## Building and Running

### Prerequisites
- Flutter SDK 3.41+
- Java 17+ (for Android builds)

### Key Commands
- **Install Dependencies:** `flutter pub get`
- **Code Generation:** `dart run build_runner build --delete-conflicting-outputs` (Required for Drift database code)
- **Static Analysis:** `flutter analyze`
- **Run Tests:** `flutter test`
- **Debug Build:** `flutter build apk --debug --split-per-abi`
- **Release Build:** `flutter build apk --release --split-per-abi` (Requires `key.properties`)

## Development Conventions

- **State Management:** Use Riverpod with `@riverpod` annotations (via `riverpod_generator`). Avoid legacy manual providers where possible.
- **Database:** Define entities in `lib/data/database/entities/` and DAOs in `lib/data/database/daos/`. Always run `build_runner` after schema changes.
- **UI:** Strictly adhere to Material 3 guidelines. Use `DynamicColorBuilder` for theme support.
- **Async Code:** Prefer `AsyncValue` from Riverpod for handling asynchronous data in the UI.
- **Searching:** Use `rg` (ripgrep) via `run_shell_command` for code searches (e.g., `rg -tdart "pattern"`).
- **Documentation:** Maintain `project-arch-tree.md` when adding major new components or directories.

## Project Resources

- `AGENTS.md`: High-level overview and command quick-reference for AI agents.
- `project-arch-tree.md`: Detailed map of the file structure and architecture.
- `todo.md`: Comprehensive task list and project roadmap.
- `research.md`: Technical research and design decisions.
