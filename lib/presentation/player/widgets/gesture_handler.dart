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
  double _currentBrightness = 1.0;
  double _currentVolume = 1.0;
  double _currentZoom = 0.0;
  double _baseZoom = 0.0;
  
  Offset? _startFocalPoint;
  bool _isVerticalDrag = false;
  bool _isHorizontalDrag = false;

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

  void _onScaleStart(ScaleStartDetails details) {
    if (widget.locked) return;
    _startFocalPoint = details.localFocalPoint;
    _baseZoom = _currentZoom;
    _isVerticalDrag = false;
    _isHorizontalDrag = false;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (widget.locked || _startFocalPoint == null) return;

    // Handle Zoom (Scale)
    if (details.scale != 1.0 && ref.read(pinchToZoomGestureProvider)) {
      final newZoom = _baseZoom + (details.scale - 1.0);
      _currentZoom = newZoom.clamp(-1.0, 2.0);
      final platform = ref.read(playerProvider).platform;
      if (platform is NativePlayer) {
        platform.setProperty('video-zoom', _currentZoom.toStringAsFixed(2));
      }
      ref.read(playerOverlayProvider.notifier).show(ZoomChange(_currentZoom));
      return;
    }

    // Handle Panning (Drag)
    final delta = details.localFocalPoint - _startFocalPoint!;
    
    // Determine drag direction if not yet established
    if (!_isVerticalDrag && !_isHorizontalDrag) {
      if (delta.dy.abs() > delta.dx.abs() && delta.dy.abs() > 10) {
        _isVerticalDrag = true;
      } else if (delta.dx.abs() > delta.dy.abs() && delta.dx.abs() > 10) {
        _isHorizontalDrag = true;
      }
    }

    if (_isVerticalDrag) {
      _handleVerticalDrag(delta.dy);
      _startFocalPoint = details.localFocalPoint;
    } else if (_isHorizontalDrag) {
      _handleHorizontalDrag(delta.dx);
      _startFocalPoint = details.localFocalPoint;
    }
  }

  void _handleVerticalDrag(double deltaY) {
    final height = context.size?.height ?? 1;
    final width = context.size?.width ?? 1;
    final edgeWidth = width * 0.2;
    final normalizedDelta = deltaY / height;

    if (_startFocalPoint!.dx < edgeWidth && ref.read(brightnessGestureProvider)) {
      _currentBrightness = (_currentBrightness - normalizedDelta).clamp(0.0, 1.0);
      // In a real app, use a service to set system brightness
    } else if (_startFocalPoint!.dx > width - edgeWidth && ref.read(volumeGestureProvider)) {
      _currentVolume = (_currentVolume - normalizedDelta).clamp(0.0, 1.0);
      ref.read(playerProvider).setVolume(_currentVolume);
    }
  }

  void _handleHorizontalDrag(double deltaX) {
    if (!ref.read(horizontalSwipeSeekProvider)) return;
    final width = context.size?.width ?? 1;
    final sensitivity = ref.read(gestureSensitivityProvider);
    final seconds = ((deltaX / width) * 120 * sensitivity).round();
    if (seconds.abs() >= 1) {
      widget.onSkip(seconds);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: _onTapUp,
      onDoubleTapDown: _onDoubleTapDown,
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      child: widget.child,
    );
  }
}
