import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import '../../settings/settings_provider.dart';
import '../gesture_config_provider.dart';
import '../player_overlay.dart';
import '../player_provider.dart';
import '../player_updates.dart';

class GestureHandler extends ConsumerStatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final void Function(int seconds) onSkip;
  final bool locked;

  const GestureHandler({
    super.key,
    required this.child,
    required this.onTap,
    required this.onSkip,
    this.locked = false,
  });

  @override
  ConsumerState<GestureHandler> createState() => _GestureHandlerState();
}

class _GestureHandlerState extends ConsumerState<GestureHandler> {
  double _startX = 0;
  double _startY = 0;
  double _currentBrightness = 1.0;
  double _currentVolume = 1.0;
  double _currentZoom = 0.0;
  double _baseZoom = 0.0;

  @override
  void initState() {
    super.initState();
    _currentBrightness = 1.0;
    _currentVolume = ref.read(playerVolumeProvider).asData?.value ?? 1.0;
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.locked) return;
    widget.onTap();
  }

  void _onDoubleTapDown(TapDownDetails details) {
    if (widget.locked) return;
    if (!ref.read(doubleTapSeekProvider)) return;
    final half = (context.size?.width ?? MediaQuery.of(context).size.width) / 2;
    final interval = ref.read(skipIntervalProvider);
    if (details.localPosition.dx < half) {
      widget.onSkip(-interval);
    } else {
      widget.onSkip(interval);
    }
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (widget.locked) return;
    if (!ref.read(horizontalSwipeSeekProvider)) return;
    _startX = details.localPosition.dx;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!ref.read(horizontalSwipeSeekProvider)) return;
    final delta = details.localPosition.dx - _startX;
    if (delta.abs() < 20) return;
    final sensitivity = ref.read(gestureSensitivityProvider);
    final width = context.size?.width ?? 1;
    final seconds = ((delta / width) * 120 * sensitivity).round();
    if (seconds.abs() >= 1) {
      widget.onSkip(seconds);
      _startX = details.localPosition.dx;
    }
  }

  void _onVerticalDragStart(DragStartDetails details) {
    if (widget.locked) return;
    _startY = details.localPosition.dy;
    _startX = details.localPosition.dx;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final width = context.size?.width ?? 1;
    final edgeWidth = width * 0.15;
    final delta = (details.localPosition.dy - _startY) / (context.size?.height ?? 1);

    if (details.localPosition.dx < edgeWidth && ref.read(brightnessGestureProvider)) {
      _currentBrightness = (_currentBrightness - delta).clamp(0.0, 1.0);
      _startY = details.localPosition.dy;
    } else if (details.localPosition.dx > width - edgeWidth && ref.read(volumeGestureProvider)) {
      _currentVolume = (_currentVolume - delta).clamp(0.0, 1.0);
      ref.read(playerProvider).setVolume(_currentVolume);
      _startY = details.localPosition.dy;
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (widget.locked) return;
    if (!ref.read(pinchToZoomGestureProvider)) return;
    _baseZoom = _currentZoom;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (!ref.read(pinchToZoomGestureProvider)) return;
    final newZoom = _baseZoom + (details.scale - 1.0);
    _currentZoom = newZoom.clamp(-1.0, 2.0);
    final platform = ref.read(playerProvider).platform;
    if (platform is NativePlayer) {
      platform.setProperty('video-zoom', _currentZoom.toStringAsFixed(2));
    }
    ref.read(playerOverlayProvider.notifier).show(
      ZoomChange(_currentZoom),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: _onTapUp,
      onDoubleTapDown: _onDoubleTapDown,
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onVerticalDragStart: _onVerticalDragStart,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      child: widget.child,
    );
  }
}
