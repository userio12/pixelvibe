import 'package:flutter/material.dart';

class PulsingOpacity extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minOpacity;
  final double maxOpacity;

  const PulsingOpacity({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2500),
    this.minOpacity = 0.6,
    this.maxOpacity = 1.0,
  });

  @override
  State<PulsingOpacity> createState() => _PulsingOpacityState();
}

class _PulsingOpacityState extends State<PulsingOpacity> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = Tween<double>(begin: widget.minOpacity, end: widget.maxOpacity).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, child) => Opacity(opacity: _opacity.value, child: child),
      child: widget.child,
    );
  }
}

class PulsingScale extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const PulsingScale({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2000),
    this.minScale = 1.0,
    this.maxScale = 1.1,
  });

  @override
  State<PulsingScale> createState() => _PulsingScaleState();
}

class _PulsingScaleState extends State<PulsingScale> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween<double>(begin: widget.minScale, end: widget.maxScale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: widget.child,
    );
  }
}

class ScaleBounce extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;

  const ScaleBounce({
    super.key,
    required this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 150),
  });

  @override
  State<ScaleBounce> createState() => _ScaleBounceState();
}

class _ScaleBounceState extends State<ScaleBounce> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}

class ExpandCollapse extends StatefulWidget {
  final Widget child;
  final bool expanded;
  final Axis axis;
  final Duration duration;

  const ExpandCollapse({
    super.key,
    required this.child,
    required this.expanded,
    this.axis = Axis.horizontal,
    this.duration = const Duration(milliseconds: 250),
  });

  @override
  State<ExpandCollapse> createState() => _ExpandCollapseState();
}

class _ExpandCollapseState extends State<ExpandCollapse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _sizeFactor;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _sizeFactor = CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);
    _opacity = Tween<double>(begin: 0, end: 1).animate(_sizeFactor);
    if (widget.expanded) _controller.value = 1;
  }

  @override
  void didUpdateWidget(ExpandCollapse old) {
    super.didUpdateWidget(old);
    if (widget.expanded != old.expanded) {
      if (widget.expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: widget.axis == Axis.horizontal
          ? Align(
              alignment: Alignment.centerLeft,
              child: AnimatedBuilder(
                animation: _sizeFactor,
                builder: (_, child) => SizedBox(width: _sizeFactor.value * 200, child: child),
                child: Opacity(opacity: _opacity.value, child: widget.child),
              ),
            )
          : Align(
              alignment: Alignment.topCenter,
              child: SizeTransition(
                sizeFactor: _sizeFactor,
                axisAlignment: -1,
                child: Opacity(opacity: _opacity.value, child: widget.child),
              ),
            ),
    );
  }
}
