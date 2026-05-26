sealed class PlayerUpdates {
  const PlayerUpdates();
}

class None extends PlayerUpdates {
  const None();
}

class HorizontalSeek extends PlayerUpdates {
  final String timeText;
  final String deltaText;
  final bool isForward;

  const HorizontalSeek({
    required this.timeText,
    required this.deltaText,
    required this.isForward,
  });
}

class SpeedChange extends PlayerUpdates {
  final double speed;

  const SpeedChange(this.speed);
}

class AspectRatioChange extends PlayerUpdates {
  final String label;

  const AspectRatioChange(this.label);
}

class ZoomChange extends PlayerUpdates {
  final double zoom;

  const ZoomChange(this.zoom);
}

class FrameInfo extends PlayerUpdates {
  final int frame;
  final int totalFrames;

  const FrameInfo(this.frame, this.totalFrames);
}

class RepeatModeChange extends PlayerUpdates {
  final String label;

  const RepeatModeChange(this.label);
}

class ShuffleChange extends PlayerUpdates {
  final bool enabled;

  const ShuffleChange(this.enabled);
}

class ShowText extends PlayerUpdates {
  final String message;

  const ShowText(this.message);
}
