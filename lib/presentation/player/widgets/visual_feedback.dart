import 'package:flutter/material.dart';
import '../../../core/theme/app_theme_extensions.dart';

class DoubleTapChevron extends StatefulWidget {
  final bool isForward;
  final double startX;

  const DoubleTapChevron({
    super.key,
    required this.isForward,
    required this.startX,
  });

  @override
  State<DoubleTapChevron> createState() => _DoubleTapChevronState();
}

class _DoubleTapChevronState extends State<DoubleTapChevron>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _opacity = Tween<double>(begin: 0.8, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6, curve: Curves.easeOut)),
    );
    _offset = Tween<double>(begin: 0, end: widget.isForward ? 40 : -40).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _controller.dispose();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = PixelvibeColors.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => Transform.translate(
        offset: Offset(_offset.value, 0),
        child: Opacity(
          opacity: _opacity.value,
          child: Icon(
            widget.isForward ? Icons.chevron_right : Icons.chevron_left,
            color: colors.playerOverlayText,
            size: 48,
          ),
        ),
      ),
      child: const SizedBox.shrink(),
    );
  }
}

class DoubleTapSeekOvals extends StatelessWidget {
  final bool isForward;
  final int tapCount;
  final int secondsPerTap;

  const DoubleTapSeekOvals({
    super.key,
    required this.isForward,
    required this.tapCount,
    this.secondsPerTap = 10,
  });

  @override
  Widget build(BuildContext context) {
    final totalSeconds = tapCount * secondsPerTap;
    final color = PixelvibeColors.of(context).playerOverlayText;

    return Align(
      alignment: isForward ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(right: isForward ? 16 : 0, left: isForward ? 0 : 16),
        child: Container(
          width: 80,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isForward ? 40 : 0),
              bottomLeft: Radius.circular(isForward ? 40 : 0),
              topRight: Radius.circular(isForward ? 0 : 40),
              bottomRight: Radius.circular(isForward ? 0 : 40),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isForward ? Icons.fast_forward : Icons.fast_rewind,
                color: color,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                '+${totalSeconds}s',
                style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModeIndicator extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const ModeIndicator({
    super.key,
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: chipColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: chipColor),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: chipColor, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
