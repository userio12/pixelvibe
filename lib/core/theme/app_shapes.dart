import 'package:flutter/material.dart';

const pillBorder = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(999)),
);

class LeftSideOvalShape extends ShapeBorder {
  const LeftSideOvalShape({this.side});

  final BorderSide? side;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side?.width ?? 0);

  @override
  ShapeBorder scale(double t) => LeftSideOvalShape(side: side?.scale(t));

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final w = side?.width ?? 0;
    return Path()..addRRect(RRect.fromRectAndRadius(rect.deflate(w / 2), const Radius.circular(0)));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side == null) return;
    final paint = side!.toPaint();
    final ovalRect = Rect.fromLTRB(rect.left, rect.top, rect.left + rect.height, rect.bottom);
    canvas.drawOval(ovalRect, paint);
  }
}

class RightSideOvalShape extends ShapeBorder {
  const RightSideOvalShape({this.side});

  final BorderSide? side;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side?.width ?? 0);

  @override
  ShapeBorder scale(double t) => RightSideOvalShape(side: side?.scale(t));

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final w = side?.width ?? 0;
    return Path()..addRRect(RRect.fromRectAndRadius(rect.deflate(w / 2), const Radius.circular(0)));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side == null) return;
    final paint = side!.toPaint();
    final ovalRect = Rect.fromLTRB(rect.right - rect.height, rect.top, rect.right, rect.bottom);
    canvas.drawOval(ovalRect, paint);
  }
}
