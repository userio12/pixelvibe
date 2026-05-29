import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class PixelvibeColors extends ThemeExtension<PixelvibeColors> {
  const PixelvibeColors({
    required this.playerControlColor,
    required this.playerControlActiveColor,
    required this.playerControlSecondaryColor,
    required this.playerControlBgColor,
    required this.playerErrorBg,
    required this.playerErrorIcon,
    required this.playerErrorText,
    required this.surfaceContainerLow,
    required this.surfaceContainerMid,
    required this.surfaceContainerHigh,
    required this.playerOverlayBg,
    required this.playerOverlayText,
  });

  final Color playerControlColor;
  final Color playerControlActiveColor;
  final Color playerControlSecondaryColor;
  final Color playerControlBgColor;
  final Color playerErrorBg;
  final Color playerErrorIcon;
  final Color playerErrorText;
  final Color surfaceContainerLow;
  final Color surfaceContainerMid;
  final Color surfaceContainerHigh;
  final Color playerOverlayBg;
  final Color playerOverlayText;

  static const _white = Colors.white;

  static const light = PixelvibeColors(
    playerControlColor: _white,
    playerControlActiveColor: Colors.cyan,
    playerControlSecondaryColor: Colors.white70,
    playerControlBgColor: Colors.white24,
    playerErrorBg: Colors.black87,
    playerErrorIcon: Colors.red,
    playerErrorText: _white,
    surfaceContainerLow: Color(0x0D000000),
    surfaceContainerMid: Color(0x10000000),
    surfaceContainerHigh: Color(0x1C000000),
    playerOverlayBg: Color(0x99000000),
    playerOverlayText: _white,
  );

  static const dark = PixelvibeColors(
    playerControlColor: _white,
    playerControlActiveColor: Colors.cyan,
    playerControlSecondaryColor: Colors.white70,
    playerControlBgColor: Colors.white24,
    playerErrorBg: Colors.black87,
    playerErrorIcon: Colors.red,
    playerErrorText: _white,
    surfaceContainerLow: Color(0x0DFFFFFF),
    surfaceContainerMid: Color(0x10FFFFFF),
    surfaceContainerHigh: Color(0x1CFFFFFF),
    playerOverlayBg: Color(0xCC000000),
    playerOverlayText: _white,
  );

  static const amoled = PixelvibeColors(
    playerControlColor: _white,
    playerControlActiveColor: Colors.cyan,
    playerControlSecondaryColor: Colors.white70,
    playerControlBgColor: Colors.white24,
    playerErrorBg: Colors.black87,
    playerErrorIcon: Colors.red,
    playerErrorText: _white,
    surfaceContainerLow: Color(0x0AFFFFFF),
    surfaceContainerMid: Color(0x0FFFFFFF),
    surfaceContainerHigh: Color(0x1AFFFFFF),
    playerOverlayBg: Color(0xE6000000),
    playerOverlayText: _white,
  );

  @override
  PixelvibeColors copyWith({
    Color? playerControlColor,
    Color? playerControlActiveColor,
    Color? playerControlSecondaryColor,
    Color? playerControlBgColor,
    Color? playerErrorBg,
    Color? playerErrorIcon,
    Color? playerErrorText,
    Color? surfaceContainerLow,
    Color? surfaceContainerMid,
    Color? surfaceContainerHigh,
    Color? playerOverlayBg,
    Color? playerOverlayText,
  }) {
    return PixelvibeColors(
      playerControlColor: playerControlColor ?? this.playerControlColor,
      playerControlActiveColor: playerControlActiveColor ?? this.playerControlActiveColor,
      playerControlSecondaryColor: playerControlSecondaryColor ?? this.playerControlSecondaryColor,
      playerControlBgColor: playerControlBgColor ?? this.playerControlBgColor,
      playerErrorBg: playerErrorBg ?? this.playerErrorBg,
      playerErrorIcon: playerErrorIcon ?? this.playerErrorIcon,
      playerErrorText: playerErrorText ?? this.playerErrorText,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainerMid: surfaceContainerMid ?? this.surfaceContainerMid,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      playerOverlayBg: playerOverlayBg ?? this.playerOverlayBg,
      playerOverlayText: playerOverlayText ?? this.playerOverlayText,
    );
  }

  @override
  PixelvibeColors lerp(ThemeExtension<PixelvibeColors>? other, double t) {
    if (other is! PixelvibeColors) return this;
    return PixelvibeColors(
      playerControlColor: Color.lerp(playerControlColor, other.playerControlColor, t)!,
      playerControlActiveColor: Color.lerp(playerControlActiveColor, other.playerControlActiveColor, t)!,
      playerControlSecondaryColor: Color.lerp(playerControlSecondaryColor, other.playerControlSecondaryColor, t)!,
      playerControlBgColor: Color.lerp(playerControlBgColor, other.playerControlBgColor, t)!,
      playerErrorBg: Color.lerp(playerErrorBg, other.playerErrorBg, t)!,
      playerErrorIcon: Color.lerp(playerErrorIcon, other.playerErrorIcon, t)!,
      playerErrorText: Color.lerp(playerErrorText, other.playerErrorText, t)!,
      surfaceContainerLow: Color.lerp(surfaceContainerLow, other.surfaceContainerLow, t)!,
      surfaceContainerMid: Color.lerp(surfaceContainerMid, other.surfaceContainerMid, t)!,
      surfaceContainerHigh: Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t)!,
      playerOverlayBg: Color.lerp(playerOverlayBg, other.playerOverlayBg, t)!,
      playerOverlayText: Color.lerp(playerOverlayText, other.playerOverlayText, t)!,
    );
  }

  static PixelvibeColors of(BuildContext context) {
    return Theme.of(context).extension<PixelvibeColors>() ?? dark;
  }
}

class PixelvibeRippleConfig extends ThemeExtension<PixelvibeRippleConfig> {
  const PixelvibeRippleConfig({
    required this.pressedAlpha,
    required this.focusedAlpha,
    required this.draggedAlpha,
    required this.hoveredAlpha,
  });

  final double pressedAlpha;
  final double focusedAlpha;
  final double draggedAlpha;
  final double hoveredAlpha;

  static const light = PixelvibeRippleConfig(
    pressedAlpha: 0.12,
    focusedAlpha: 0.12,
    draggedAlpha: 0.08,
    hoveredAlpha: 0.04,
  );

  static const dark = PixelvibeRippleConfig(
    pressedAlpha: 0.24,
    focusedAlpha: 0.24,
    draggedAlpha: 0.16,
    hoveredAlpha: 0.08,
  );

  @override
  PixelvibeRippleConfig copyWith({
    double? pressedAlpha,
    double? focusedAlpha,
    double? draggedAlpha,
    double? hoveredAlpha,
  }) {
    return PixelvibeRippleConfig(
      pressedAlpha: pressedAlpha ?? this.pressedAlpha,
      focusedAlpha: focusedAlpha ?? this.focusedAlpha,
      draggedAlpha: draggedAlpha ?? this.draggedAlpha,
      hoveredAlpha: hoveredAlpha ?? this.hoveredAlpha,
    );
  }

  @override
  PixelvibeRippleConfig lerp(ThemeExtension<PixelvibeRippleConfig>? other, double t) {
    if (other is! PixelvibeRippleConfig) return this;
    return PixelvibeRippleConfig(
      pressedAlpha: ui.lerpDouble(pressedAlpha, other.pressedAlpha, t) ?? pressedAlpha,
      focusedAlpha: ui.lerpDouble(focusedAlpha, other.focusedAlpha, t) ?? focusedAlpha,
      draggedAlpha: ui.lerpDouble(draggedAlpha, other.draggedAlpha, t) ?? draggedAlpha,
      hoveredAlpha: ui.lerpDouble(hoveredAlpha, other.hoveredAlpha, t) ?? hoveredAlpha,
    );
  }

  static PixelvibeRippleConfig of(BuildContext context) {
    return Theme.of(context).extension<PixelvibeRippleConfig>() ?? dark;
  }
}
