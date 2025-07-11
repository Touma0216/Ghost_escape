import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

// D-Padの方向を示すEnum
enum DPadRegion { up, down, left, right }

class MovementController extends StatefulWidget {
  final ValueChanged<DPadRegion>? onPressed;
  final VoidCallback? onReleased;

  const MovementController({
    super.key,
    this.onPressed,
    this.onReleased,
  });

  @override
  State<MovementController> createState() => _MovementControllerState();
}

class _MovementControllerState extends State<MovementController> {
  DPadRegion? _pressedRegion;
  Timer? _repeatTimer;

  // 歩行間隔(ms)を調整（ここを小さくすると速くなる、大きいと遅くなる）
  static const Duration repeatDelay = Duration(milliseconds: 180);

  void _startRepeat(DPadRegion region) {
    _repeatTimer?.cancel();
    widget.onPressed?.call(region);
    _repeatTimer = Timer.periodic(repeatDelay, (_) {
      widget.onPressed?.call(region);
    });
  }

  void _stopRepeat() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  void _onPanStart(DragStartDetails details, BoxConstraints constraints) {
    final region = _getRegionFromOffset(details.localPosition, constraints.biggest);
    if (region != null) {
      setState(() => _pressedRegion = region);
      _startRepeat(region);
    }
  }

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    final region = _getRegionFromOffset(details.localPosition, constraints.biggest);
    if (region != _pressedRegion) {
      setState(() => _pressedRegion = region);
      _stopRepeat();
      if (region != null) _startRepeat(region);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() => _pressedRegion = null);
    _stopRepeat();
    widget.onReleased?.call();
  }

  void _onPanCancel() {
    setState(() => _pressedRegion = null);
    _stopRepeat();
    widget.onReleased?.call();
  }

  @override
  void dispose() {
    _stopRepeat();
    super.dispose();
  }

  // タッチ位置からDPadの領域を判定するロジック
  DPadRegion? _getRegionFromOffset(Offset offset, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = offset.dx - center.dx;
    final dy = offset.dy - center.dy;

    const double thickness = 26;
    const double totalLength = 72;
    const double innerCutoutRadius = 10;

    if (math.sqrt(dx * dx + dy * dy) < innerCutoutRadius) {
      return null;
    }

    const double halfThickness = thickness / 2;
    const double stickLength = (totalLength / 2);

    if (offset.dy < center.dy - innerCutoutRadius &&
        offset.dy > center.dy - stickLength &&
        offset.dx > center.dx - halfThickness &&
        offset.dx < center.dx + halfThickness) {
      return DPadRegion.up;
    }
    if (offset.dy > center.dy + innerCutoutRadius &&
        offset.dy < center.dy + stickLength &&
        offset.dx > center.dx - halfThickness &&
        offset.dx < center.dx + halfThickness) {
      return DPadRegion.down;
    }
    if (offset.dx < center.dx - innerCutoutRadius &&
        offset.dx > center.dx - stickLength &&
        offset.dy > center.dy - halfThickness &&
        offset.dy < center.dy + halfThickness) {
      return DPadRegion.left;
    }
    if (offset.dx > center.dx + innerCutoutRadius &&
        offset.dx < center.dx + stickLength &&
        offset.dy > center.dy - halfThickness &&
        offset.dy < center.dy + halfThickness) {
      return DPadRegion.right;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    const double size = 80;

    return GestureDetector(
      onPanStart: (details) => _onPanStart(details, BoxConstraints.tightFor(width: size, height: size)),
      onPanUpdate: (details) => _onPanUpdate(details, BoxConstraints.tightFor(width: size, height: size)),
      onPanEnd: _onPanEnd,
      onPanCancel: _onPanCancel,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade400.withOpacity(0.6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CustomPaint(
          painter: _DpadPainter(pressedRegion: _pressedRegion),
          size: Size(size, size),
        ),
      ),
    );
  }
}

// === 十字キー全体を描画するCustomPainter ===
class _DpadPainter extends CustomPainter {
  final DPadRegion? pressedRegion;

  _DpadPainter({this.pressedRegion});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // D-Padの基本設定
    const double thickness = 26;
    const double totalLength = 72;
    const double cornerRadius = 8;
    const double innerCutoutRadius = 10;
    const double centerCircleRadius = 10;
    const double pressDepth = 2;

    final Path dpadBaseRectPath = Path();
    dpadBaseRectPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: thickness, height: totalLength),
      Radius.circular(cornerRadius),
    ));
    dpadBaseRectPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: totalLength, height: thickness),
      Radius.circular(cornerRadius),
    ));
    final Path innerCutoutPath = Path()..addOval(Rect.fromCircle(center: center, radius: innerCutoutRadius));
    final Path combinedBasePath = Path.combine(
      PathOperation.difference,
      dpadBaseRectPath,
      innerCutoutPath,
    );

    final Paint normalPaint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.fill;

    final Paint pressedPaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.fill;

    Offset offsetUp = Offset.zero;
    Offset offsetDown = Offset.zero;
    Offset offsetLeft = Offset.zero;
    Offset offsetRight = Offset.zero;

    if (pressedRegion == DPadRegion.up) {
      offsetUp = const Offset(0, pressDepth);
    } else if (pressedRegion == DPadRegion.down) {
      offsetDown = const Offset(0, -pressDepth);
    } else if (pressedRegion == DPadRegion.left) {
      offsetLeft = const Offset(pressDepth, 0);
    } else if (pressedRegion == DPadRegion.right) {
      offsetRight = const Offset(-pressDepth, 0);
    }

    final Rect upRect = Rect.fromCenter(center: Offset(center.dx, center.dy - (totalLength / 2 - thickness / 2)), width: thickness, height: totalLength / 2);
    final Rect downRect = Rect.fromCenter(center: Offset(center.dx, center.dy + (totalLength / 2 - thickness / 2)), width: thickness, height: totalLength / 2);
    final Rect leftRect = Rect.fromCenter(center: Offset(center.dx - (totalLength / 2 - thickness / 2), center.dy), width: totalLength / 2, height: thickness);
    final Rect rightRect = Rect.fromCenter(center: Offset(center.dx + (totalLength / 2 - thickness / 2), center.dy), width: totalLength / 2, height: thickness);

    Path pressedRegionPath = Path();
    if (pressedRegion == DPadRegion.up) {
      pressedRegionPath.addRRect(RRect.fromRectAndRadius(upRect, Radius.circular(cornerRadius)));
      pressedRegionPath.addRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: thickness, height: thickness / 2), Radius.circular(cornerRadius)));
    } else if (pressedRegion == DPadRegion.down) {
      pressedRegionPath.addRRect(RRect.fromRectAndRadius(downRect, Radius.circular(cornerRadius)));
      pressedRegionPath.addRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: thickness, height: thickness / 2).shift(const Offset(0, thickness / 2)), Radius.circular(cornerRadius)));
    } else if (pressedRegion == DPadRegion.left) {
      pressedRegionPath.addRRect(RRect.fromRectAndRadius(leftRect, Radius.circular(cornerRadius)));
      pressedRegionPath.addRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: thickness / 2, height: thickness), Radius.circular(cornerRadius)));
    } else if (pressedRegion == DPadRegion.right) {
      pressedRegionPath.addRRect(RRect.fromRectAndRadius(rightRect, Radius.circular(cornerRadius)));
      pressedRegionPath.addRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: thickness / 2, height: thickness).shift(const Offset(thickness / 2, 0)), Radius.circular(cornerRadius)));
    }

    Path finalPressedPath = Path.combine(PathOperation.difference, pressedRegionPath, innerCutoutPath);

    if (pressedRegion != null) {
      Path nonPressedCombinedPath = Path.combine(PathOperation.difference, combinedBasePath, finalPressedPath);
      canvas.drawPath(nonPressedCombinedPath, normalPaint);
      canvas.drawPath(finalPressedPath.shift(
        pressedRegion == DPadRegion.up ? offsetUp :
        pressedRegion == DPadRegion.down ? offsetDown :
        pressedRegion == DPadRegion.left ? offsetLeft :
        offsetRight,
      ), pressedPaint);
    } else {
      canvas.drawPath(combinedBasePath, normalPaint);
    }

    final Paint centerCirclePaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, centerCircleRadius, centerCirclePaint);

    final Paint arrowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    const double arrowWidth = 10;
    const double arrowHeight = 6;
    const double arrowOffsetFromEdge = 10;

    // 上方向の矢印
    Path pathUpArrow = Path();
    pathUpArrow.moveTo(center.dx, center.dy - totalLength / 2 + arrowOffsetFromEdge);
    pathUpArrow.lineTo(center.dx - arrowWidth / 2, center.dy - totalLength / 2 + arrowOffsetFromEdge + arrowHeight);
    pathUpArrow.lineTo(center.dx + arrowWidth / 2, center.dy - totalLength / 2 + arrowOffsetFromEdge + arrowHeight);
    pathUpArrow.close();
    canvas.drawPath(pathUpArrow.shift(offsetUp), arrowPaint);

    // 下方向の矢印
    Path pathDownArrow = Path();
    pathDownArrow.moveTo(center.dx, center.dy + totalLength / 2 - arrowOffsetFromEdge);
    pathDownArrow.lineTo(center.dx + arrowWidth / 2, center.dy + totalLength / 2 - arrowOffsetFromEdge - arrowHeight);
    pathDownArrow.lineTo(center.dx - arrowWidth / 2, center.dy + totalLength / 2 - arrowOffsetFromEdge - arrowHeight);
    pathDownArrow.close();
    canvas.drawPath(pathDownArrow.shift(offsetDown), arrowPaint);

    // 左方向の矢印
    Path pathLeftArrow = Path();
    pathLeftArrow.moveTo(center.dx - totalLength / 2 + arrowOffsetFromEdge, center.dy);
    pathLeftArrow.lineTo(center.dx - totalLength / 2 + arrowOffsetFromEdge + arrowHeight, center.dy + arrowWidth / 2);
    pathLeftArrow.lineTo(center.dx - totalLength / 2 + arrowOffsetFromEdge + arrowHeight, center.dy - arrowWidth / 2);
    pathLeftArrow.close();
    canvas.drawPath(pathLeftArrow.shift(offsetLeft), arrowPaint);

    // 右方向の矢印
    Path pathRightArrow = Path();
    pathRightArrow.moveTo(center.dx + totalLength / 2 - arrowOffsetFromEdge, center.dy);
    pathRightArrow.lineTo(center.dx + totalLength / 2 - arrowOffsetFromEdge - arrowHeight, center.dy - arrowWidth / 2);
    pathRightArrow.lineTo(center.dx + totalLength / 2 - arrowOffsetFromEdge - arrowHeight, center.dy + arrowWidth / 2);
    pathRightArrow.close();
    canvas.drawPath(pathRightArrow.shift(offsetRight), arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _DpadPainter && oldDelegate.pressedRegion != pressedRegion;
  }
}
