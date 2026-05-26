# pixelvibe — Add mpvEx Features (Phase 4-11)

Multi-phase plan based on analysis of mpvExtended v1.2.9.

Estimated: ~200 tasks | ~12 weeks

---

## Phase 4: UI/UX Design Polish (Weeks 1-2)

### 4.1 Design Token System
- [ ] Create `Spacing` class with named tokens (4/8/12/16/24/32/48/64dp) exposed via provider
- [ ] Add custom shapes: `LeftSideOvalShape`, `RightSideOvalShape`, pill shape (R50)
- [ ] Add AMOLED dark mode variant (pure black background, `0x0A0A0A` containers)
- [ ] Add surface container alpha system (0.05/0.06/0.08/0.11 for depth without elevation)
- [ ] Add high/medium contrast color variants for each theme mode
- [ ] Create `PlayerControlColor` constant (white icons over video, surface colors over chrome)
- [ ] Custom ripple configuration per control type (pressed/focused/dragged/hovered alphas)

### 4.2 Animation System
- [ ] Create reusable pulsing animation modifier (0.6→1.0 alpha, 2.5s, Reverse)
- [ ] Create reusable pulsing scale animation (1.0→1.1, 2s, Reverse)
- [ ] Add inline expand/collapse animation utility (fadeIn + expandHorizontally, 250ms)
- [ ] Add chevron stacking animation component (spawns per interaction, drifts outward, fades)
- [ ] Add scale bounce animation (1.0→1.2→1.0, 150ms tween)
- [ ] Add tab transition animation (slide horizontal + fade, 250ms, FastOutSlowInEasing)
- [ ] Add bottom nav show/hide animation (slide vertical, 300ms)
- [ ] Add seek overlay auto-dismiss timers (800ms text, 300ms horizontal seek, 10s frame nav)

### 4.3 State Composables
- [ ] Create `EmptyState` widget (icon + title + subtitle + pulsing alpha animation)
- [ ] Create `LoadingState` widget (icon + title + pulsing alpha animation)
- [ ] Create `PermissionDeniedState` widget (animated warning, contextual card, primary button, help link)
- [ ] All three share consistent layout: centered Column, rounded icon container, titleLarge/bodyMedium

### 4.4 Player Overlay System
- [ ] Create `PlayerUpdates` sealed class (None, HorizontalSeek, SpeedChange, AspectRatio, Zoom, FrameInfo, RepeatMode, Shuffle, ShowText)
- [ ] Replace raw setState overlay toggles with PlayerUpdates-driven state machine
- [ ] Create inline expand/collapse for frame navigation (animate container opening)
- [ ] Create inline expand/collapse for A-B loop controls
- [ ] Add seek time overlay (current time + delta display, 800ms auto-dismiss)
- [ ] Separate seekbar visibility from controls visibility (seekbar lingers after controls hide)

### 4.5 Visual Feedback Components
- [ ] Create `DoubleTapSeekOvals` widget (semi-transparent ovals + scale bounce text + chevrons)
- [ ] Create `DoubleTapChevron` animation (spawn per tap, stack multiple, drift + fade)
- [ ] Create `ModeIndicator` chip (colored badge for active repeat/shuffle/zoom/speed states)
- [ ] Add speed change indicator overlay (large floating text, dynamic speed control display)
- [ ] Add aspect ratio change toast indicator
- [ ] Add zoom level indicator overlay

### 4.6 Screen Architecture
- [ ] Reorganize browser into 4-tab layout (Files / Recently Played / Playlists / Network)
- [ ] Add animated tab transitions (horizontal slide + fade, 250ms)
- [ ] Add animated bottom navigation bar (slide show/hide, rounded top corners 28dp)
- [ ] Add selection mode visual state (animated bar hide, selection count in AppBar)
- [ ] Add FAB area padding (80dp clearance above nav bar)

### 4.7 Platform Integration
- [ ] Add orientation management (8-mode enum via SystemChrome + platform channel)
- [ ] Add system bar show/hide on controls toggle (via SystemChrome.setSystemUIOverlayStyle)
- [ ] Add display cutout handling (LAYOUT_IN_CUTOUT_MODE_SHORT_EDGES on player)
- [ ] Add keep-screen-on when playing (via WidgetsBinding or WakelockPlus)
- [ ] Add brightness persistence and gesture control

### 4.8 Haptic & Ripple System
- [ ] Define per-button RippleConfiguration (rippleAlpha for pressed/focused/hovered/dragged)
- [ ] Add haptic on long press activation (HapticFeedbackType.longPress)
- [ ] Add haptic on speed preset snap (HapticFeedbackType.selectionClick)
- [ ] Add haptic on multi-tap seek accumulation

---

## Phase 5: Playlist & Playback Engine (Weeks 3-4)

### 5.1 Playlist Playback
- [ ] Convert `PlayerScreen` to accept playlist data (list of URIs + index)
- [ ] Add next/previous track navigation to PlayerControlsBar
- [ ] Add repeat modes: Off / One / All (enum + provider + UI toggle)
- [ ] Add shuffle mode (randomized index list + provider + UI toggle)
- [ ] Add `playlist_mode` boolean to PlayerPreferences (auto-generate folder playlist)
- [ ] Add autoplay-next-video when current file ends (listen to player stream end)
- [ ] Create playlist sheet in player (PeekablePlaylistSheet widget)
- [ ] Persist repeat/shuffle state in PreferencesService

### 5.2 M3U Playlist Support
- [ ] Detect and parse .m3u files in media scanner
- [ ] Store M3U playlist metadata in database
- [ ] Play M3U from file browser (pass URI list to player)
- [ ] M3U network stream support (HTTP live streams)

### 5.3 Sleep Timer
- [ ] Create SleepTimerService (countdown timer + provider)
- [ ] Add sleep timer sheet: 15/30/45/60/90 min, custom, end-of-file
- [ ] Pause/stop player when timer fires
- [ ] Show remaining time indicator in player controls

### 5.4 Windowed Playlist Loading
- [ ] Add paginated loading for large playlists (500+ items)
- [ ] Load items in windows of 100, load next window on scroll
- [ ] Prevent ANR with large M3U playlists

---

## Phase 6: Player Controls & Gestures (Weeks 5-6)

### 6.1 Gesture System
- [ ] Create `GestureHandler` widget with gesture config provider
- [ ] Add swipe-left/right for seeking (horizontalSwipeToSeek toggle)
- [ ] Add swipe-left-edge for brightness (brightnessGesture toggle)
- [ ] Add swipe-right-edge for volume (volumeGesture toggle)
- [ ] Add pinch-to-zoom gesture (pinchToZoomGesture toggle)
- [ ] Add double-tap-left/center/right configurable actions (seek/play-pause/custom)
- [ ] Add configurable double-tap seek area width
- [ ] Add single-tap-center action config
- [ ] Add showDoubleTapOvals toggle (animated seek indicators on double-tap)
- [ ] Add showSeekTimeWhileSeeking toggle
- [ ] Add horizontalSwipeSensitivity slider to settings
- [ ] Create GesturePreferencesService

### 6.2 Player Orientation
- [ ] Add PlayerOrientation enum: Free / Video / Portrait / ReversePortrait / SensorPortrait / Landscape / ReverseLandscape / SensorLandscape
- [ ] Lock screen orientation to setting in player (via SystemChrome or platform channel)
- [ ] Persist orientation setting

### 6.3 Player Lock
- [ ] Add controls lock button (disables all gesture/controls)
- [ ] Show lock icon when locked (tap to unlock)
- [ ] Persist "reduce motion" setting for less animation

### 6.4 Seekbar Enhancements
- [ ] Add wavy/curved seekbar option (alternative to linear slider)
- [ ] Add custom skip duration setting (replace fixed 10s)
- [ ] Add precise seeking toggle (sub-second seek precision)
- [ ] Show time remaining or invert duration toggle

---

## Phase 7: Video Quality & Filters (Weeks 7-8)

### 7.1 Video Filters
- [ ] Create FilterPreset enum (12+ presets: Vivid, Warm Tone, Cool Tone, Soft Pastel, Cinematic, Dramatic, Night Mode, Nostalgic, Ghibli Style, Neon Pop, Deep Black, None)
- [ ] Create filter preset bottom sheet in player
- [ ] Create individual slider sheet for: Brightness, Saturation, Contrast, Gamma, Hue, Sharpness
- [ ] Apply mpv filter properties via player commands (use MPVLib.command equivalent in media_kit)
- [ ] Persist filter values per-session or as default
- [ ] Add filter presets to player "More" sheet

### 7.2 Aspect Ratio & Zoom
- [ ] Add VideoAspect enum: Crop / Fit / Stretch (apply via mpv video-aspect property)
- [ ] Add aspect ratio bottom sheet (presets + custom ratio input)
- [ ] Add default aspect setting in preferences
- [ ] Add video zoom (pinch gesture + default zoom setting)
- [ ] Add pan-and-zoom mode toggle

### 7.3 Decoder Selection
- [ ] Add Decoder enum: AutoCopy / Auto / SW / HW / HW+
- [ ] Apply decoder via mpv `hwdec` property
- [ ] Add decoder bottom sheet in player
- [ ] Persist decoder preference

### 7.4 MPV Profiles
- [ ] Add MPVProfile enum: Fast / Default / HighQuality / GpuHQ / LowLatency / SwFast
- [ ] Apply profile via mpv `profile` property
- [ ] Add profile setting in preferences (with note about availability)
- [ ] Note: media_kit may not expose setProperty; use command line if blocked

### 7.5 Deband Settings
- [ ] Add DebandSettings enum: None / CPU / GPU
- [ ] Add deband iterations/threshold/range/grain sliders
- [ ] Apply via mpv deband-* properties
- [ ] Add deband sheet in player

### 7.6 Screenshot / Snapshot
- [ ] Add screenshot button in player (player.screenshot() in media_kit)
- [ ] Add include-subtitles-in-snapshot toggle
- [ ] Save screenshots to Pictures/pixelvibe/ folder
- [ ] Show snackbar confirmation with open button

---

## Phase 8: Subtitle System Overhaul (Weeks 7-8)

### 8.1 Subtitle Customization
- [ ] Create SubtitlePreferencesService (font, size, scale, color, border, position)
- [ ] Font selection: picker from device fonts or custom font file
- [ ] Font folder picker (SAF DocumentFile)
- [ ] Font size slider (55-200, mpv subtitle-font-size)
- [ ] Subtitle scale slider (0.5-2.0, mpv sub-scale)
- [ ] Border style selector: Outline / OutlineAndShadow / Bezel / Opaque / None
- [ ] Border size slider (0-10)
- [ ] Bold / italic toggles
- [ ] Text color picker (ColorPicker dialog)
- [ ] Border color picker
- [ ] Background color picker
- [ ] Subtitle position slider (0-100, mpv sub-pos)
- [ ] Justification: Auto / Left / Center / Right
- [ ] Override ASS subs toggle (mpv sub-ass-override)
- [ ] Scale-by-window toggle
- [ ] Default delay spinner
- [ ] Default speed spinner
- [ ] Autoload matching subtitles toggle

### 8.2 Online Subtitle Search
- [ ] Add subdl.com API integration (API key setting, search by filename/hash)
- [ ] Add wyzie API integration (sources, formats, encodings, hearing impaired filter)
- [ ] Create OnlineSubtitleSearchSheet widget
- [ ] Save downloaded subtitles to app folder
- [ ] Auto-load downloaded subtitle
- [ ] Language selection for subtitle downloads
- [ ] Persist API keys and settings

### 8.3 Subtitle Settings Panel
- [ ] Create SubtitleSettings panel (in-player slide-up panel)
- [ ] Create Subtitle Delay panel
- [ ] Create Audio Delay panel
- [ ] All with real-time preview while adjusting

---

## Phase 9: Settings Expansion (Weeks 9-10)

### 9.1 Appearance Settings
- [ ] Add custom theme color picker (override seed color)
- [ ] Add AMOLED dark mode toggle (true black background)
- [ ] Add pure black dark mode toggle
- [ ] Add custom background shade / player UI brightness setting
- [ ] Add theme mode: System / Light / Dark (already exists, enhance)

### 9.2 Audio Settings
- [ ] Preferred audio language list
- [ ] Default audio delay (ms)
- [ ] Audio pitch correction toggle (mpv audio-pitch-correction)
- [ ] Audio channel selector: Auto / AutoSafe / Mono / Stereo / ReverseStereo
- [ ] Volume boost cap slider (0-100%)
- [ ] Automatic background playback toggle
- [ ] Volume normalization / loudness equalizer toggle (mpv audio-normalize)

### 9.3 Gesture Settings Screen
- [ ] Brightness gesture toggle
- [ ] Volume gesture toggle
- [ ] Horizontal swipe to seek toggle
- [ ] Horizontal swipe sensitivity slider
- [ ] Pinch to zoom toggle
- [ ] Double-tap seek area width selector: Narrow / Medium / Wide
- [ ] Double-tap action: Seek / Play-Pause / Custom command
- [ ] Single-tap center action setting
- [ ] Show double-tap ovals toggle
- [ ] Allow gestures in panels toggle

### 9.4 Player Settings Screen
- [ ] Orientation selector (8 modes)
- [ ] Invert duration toggle
- [ ] Hold for multiple speed (hold duration)
- [ ] Show dynamic speed overlay toggle
- [ ] Show seek time while seeking toggle
- [ ] Use precise seeking toggle
- [ ] Display volume as percentage toggle
- [ ] Swap volume and brightness sides toggle
- [ ] Show loading circle toggle
- [ ] Save position on quit toggle
- [ ] Close after reaching end of video toggle
- [ ] Keep screen on when paused toggle
- [ ] Remember brightness toggle
- [ ] Default brightness slider
- [ ] Show system status bar toggle
- [ ] Show system navigation bar toggle
- [ ] Player time to disappear slider (1-10s)
- [ ] Reduce motion toggle
- [ ] Custom skip duration (10-300s, default 90s)
- [ ] Use wavy seekbar toggle
- [ ] Include subtitles in snapshot toggle
- [ ] Pan and zoom enabled toggle
- [ ] Default video zoom slider
- [ ] Default aspect ratio selector
- [ ] Reset all player settings button

### 9.5 Decoder Settings Screen
- [ ] Decoder selector: AutoCopy / Auto / SW / HW / HW+
- [ ] Deband mode: None / CPU / GPU
- [ ] Deband iterations slider (0-16)
- [ ] Deband threshold slider (0-200)
- [ ] Deband range slider (1-64)
- [ ] Deband grain slider (0-200)
- [ ] MPV profile selector

### 9.6 Advanced Settings
- [ ] mpv.conf editor (built-in text editor with file picker for storage location)
- [ ] input.conf editor (built-in text editor)
- [ ] Verbose logging toggle (debug only)
- [ ] Statistics page selector (off / page 0-3)
- [ ] Enable/disable recently played

### 9.7 Folders Settings
- [ ] Add custom video folders (folder picker dialog)
- [ ] Add excluded folders (folder picker)
- [ ] Persist folder list in database
- [ ] Scan only selected folders instead of full device

### 9.8 Control Layout Editor
- [ ] Create button list with drag handles
- [ ] Available buttons: play/pause, skip back, skip forward, speed, subtitles, audio, chapters, info, playlist, screenshot, zoom, aspect ratio, lock, etc.
- [ ] Persist layout order
- [ ] Rebuild control bar based on saved layout
- [ ] Reset to defaults button

### 9.9 Settings Search
- [ ] Create searchable settings index (map setting name → screen + action)
- [ ] Add search bar to settings screen
- [ ] Show grouped results with navigation on tap

---

## Phase 10: File Browser Enhancements (Weeks 9-10)

### 10.1 Folder Tree Browser
- [ ] Create FolderListScreen with directory navigation
- [ ] Show parent directory ("..") at top
- [ ] Display files grouped: folders first, then videos
- [ ] Show file metadata: size, date, resolution, codec
- [ ] Navigate into subdirectories
- [ ] Create file system abstraction layer (works with full storage + SAF)

### 10.2 File Sorting & Filtering
- [ ] Add sort options: Name / Date / Size / Type
- [ ] Add ascending/descending toggle
- [ ] Filter by video/audio/subtitle/playlist/image/archive
- [ ] Show file count in current view

### 10.3 Bulk Selection Operations
- [ ] Create SelectionManager with multi-select mode
- [ ] Select all / invert selection
- [ ] Bulk delete files
- [ ] Bulk add to playlist
- [ ] Share selected files
- [ ] Show selected count in app bar
- [ ] Selection mode FAB with action menu

### 10.4 File Properties Dialog
- [ ] Show: name, path, size, duration, resolution, codec, bitrate, frame rate, date added
- [ ] Parse media info via platform channel (MediaMetadataRetriever or ffprobe)

### 10.5 Thumbnail Enhancements
- [ ] Add resolution/codec overlay on thumbnails
- [ ] Add duration badge on thumbnails
- [ ] Show grid/list toggle (already exists, enhance)
- [ ] Fast thumbnail caching layer

### 10.6 SAF (Storage Access Framework) Support
- [ ] Add DocumentFile-based file operations
- [ ] Use SAF for folder picking (custom scan folders)
- [ ] Support content:// URIs for file operations
- [ ] Graceful fallback if SAF is not available

---

## Phase 11: Remaining Gaps (Weeks 11-12)

### 11.1 Chapters
- [ ] Add chapter detection via mpv chapter-list property
- [ ] Create ChapterSheet with chapter list
- [ ] Add seeker lib integration for chapter markers on seekbar
- [ ] Seek to chapter on tap

### 11.2 Media Info Enhancement
- [ ] Upgrade MediaInfoSheet with full codec/resolution/bitrate/framerate
- [ ] Add libmediainfo integration (via platform channel or Dart pure)
- [ ] Show file path, size, container format
- [ ] Show audio track info (codec, channels, sample rate)
- [ ] Show subtitle track info

### 11.3 HTTP/Network Streaming
- [ ] Add direct HTTP/HTTPS URL playback (paste URL dialog)
- [ ] Add referer/cookie headers support for streaming
- [ ] Add network proxy settings (host/port for streaming)

### 11.4 Notifications & Audio Focus
- [ ] Add noisy receiver (pause on headphone disconnect)
- [ ] Add audio focus management (duck/loss/transient/gain)
- [ ] Enhance MediaSession metadata with full track info

### 11.5 Update Checker
- [ ] Check latest release from GitHub API
- [ ] Show update dialog with changelog
- [ ] Download APK on device (standard flavor only)
- [ ] Preview build update channel

### 11.6 Language Translations
- [ ] Set up Flutter localization framework (flutter_localizations / ARB files)
- [ ] Add English locale
- [ ] Add locale detection (system language)
- [ ] Follow Flutter i18n best practices for 18+ languages

### 11.7 Hardware Key Support
- [ ] Media playback keys: play/pause, next, previous
- [ ] Volume keys: always control media volume (not ringer)
- [ ] Keyboard shortcuts (external keyboard)

### 11.8 Metadata Caching
- [ ] Cache scanned video metadata in DB (already done in pixelvibe, enhance)
- [ ] Add periodic cache maintenance (clean stale entries)
- [ ] Add manual "rescan" with incremental update

### 11.9 Frequently Played
- [ ] Track play count per video
- [ ] Add "Most Played" section in browser (separate from Recently Played)
- [ ] Sort by play count (descending)

---

## Verification Gates

- [ ] `flutter analyze` passes after each phase
- [ ] `flutter test` passes after each phase
- [ ] `flutter build apk --debug` compiles after each phase

---

Total: ~200 tasks | Estimated: ~12 weeks
