import 'package:flutter/material.dart';
import 'dart:math' as math;

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

  // タッチ開始時の処理
  void _onPanStart(DragStartDetails details, BoxConstraints constraints) {
    _updatePressedRegion(details.localPosition, constraints.biggest);
  }

  // タッチ中の処理
  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    _updatePressedRegion(details.localPosition, constraints.biggest);
  }

  // タッチ終了時の処理
  void _onPanEnd(DragEndDetails details) {
    _clearPressedRegion();
  }

  // タッチキャンセル時の処理
  void _onPanCancel() {
    _clearPressedRegion();
  }

  // 押されている領域を更新
  void _updatePressedRegion(Offset localPosition, Size size) {
    final region = _getRegionFromOffset(localPosition, size);
    if (region != _pressedRegion) {
      setState(() {
        _pressedRegion = region;
      });
      if (region != null) {
        widget.onPressed?.call(region);
      }
    }
  }

  // 押されている領域をクリア
  void _clearPressedRegion() {
    if (_pressedRegion != null) {
      setState(() {
        _pressedRegion = null;
      });
      widget.onReleased?.call();
    }
  }

  // タッチ位置からDPadの領域を判定するロジック
  DPadRegion? _getRegionFromOffset(Offset offset, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = offset.dx - center.dx;
    final dy = offset.dy - center.dy;

    // D-Padの描画パラメータと合わせて調整
    const double thickness = 26; // _DpadPainterと同じ値
    const double totalLength = 72; // _DpadPainterと同じ値
    const double innerCutoutRadius = 10; // _DpadPainterと同じ値

    // 中央の無反応領域 (内側の円形切り欠き部分)
    if (math.sqrt(dx * dx + dy * dy) < innerCutoutRadius) {
      return null;
    }

    // 各方向のスティックの判定領域を計算
    const double halfThickness = thickness / 2;
    const double stickLength = (totalLength / 2); // 中心から端までの長さ

    // 上方向
    if (offset.dy < center.dy - innerCutoutRadius &&
        offset.dy > center.dy - stickLength &&
        offset.dx > center.dx - halfThickness &&
        offset.dx < center.dx + halfThickness) {
      return DPadRegion.up;
    }
    // 下方向
    if (offset.dy > center.dy + innerCutoutRadius &&
        offset.dy < center.dy + stickLength &&
        offset.dx > center.dx - halfThickness &&
        offset.dx < center.dx + halfThickness) {
      return DPadRegion.down;
    }
    // 左方向
    if (offset.dx < center.dx - innerCutoutRadius &&
        offset.dx > center.dx - stickLength &&
        offset.dy > center.dy - halfThickness &&
        offset.dy < center.dy + halfThickness) {
      return DPadRegion.left;
    }
    // 右方向
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
    const double thickness = 26; // 各棒の太さ
    const double totalLength = 72; // 十字の全体的な長さ (中心から端まで)
    const double cornerRadius = 8; // 外側の角丸の半径
    const double innerCutoutRadius = 10; // 中央の丸い切り欠きの半径
    const double centerCircleRadius = 10; // 中央の薄い丸の半径 (innerCutoutRadiusと同じでOK)
    const double pressDepth = 2; // 沈み込みの深さ (ピクセル)

    // 十字キーのベースとなるパスを作成
    final Path dpadBaseRectPath = Path();

    // 縦棒のパス
    dpadBaseRectPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: thickness, height: totalLength),
      Radius.circular(cornerRadius),
    ));

    // 横棒のパス
    dpadBaseRectPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: totalLength, height: thickness),
      Radius.circular(cornerRadius),
    ));

    // 中央の丸い切り欠きを結合する (Subtract mode)
    final Path innerCutoutPath = Path()..addOval(Rect.fromCircle(center: center, radius: innerCutoutRadius));

    final Path combinedBasePath = Path.combine(
      PathOperation.difference, // 差分を取る
      dpadBaseRectPath, // 元の十字のパス
      innerCutoutPath, // 切り抜く丸いパス
    );


    // 十字キーの通常色
    final Paint normalPaint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.fill;

    // 押された時の色（ボタンよりも若干薄い灰色）
    final Paint pressedPaint = Paint()
      ..color = Colors.grey.shade600 // shade700より少し明るい色
      ..style = PaintingStyle.fill;

    // 各スティックが押された場合のオフセットを決定
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

    // 各方向のスティックの領域を定義 (中心から端までの四角形)
    final Rect upRect = Rect.fromCenter(center: Offset(center.dx, center.dy - (totalLength / 2 - thickness / 2)), width: thickness, height: totalLength / 2);
    final Rect downRect = Rect.fromCenter(center: Offset(center.dx, center.dy + (totalLength / 2 - thickness / 2)), width: thickness, height: totalLength / 2);
    final Rect leftRect = Rect.fromCenter(center: Offset(center.dx - (totalLength / 2 - thickness / 2), center.dy), width: totalLength / 2, height: thickness);
    final Rect rightRect = Rect.fromCenter(center: Offset(center.dx + (totalLength / 2 - thickness / 2), center.dy), width: totalLength / 2, height: thickness);

    // 通常時の全体パスを描画 (押されていない部分)
    // 押された部分のパスを作成し、元のパスからその部分を「除外」したものを描画する
    Path nonPressedPath = Path.from(combinedBasePath);
    Paint currentPaint;

    // 押された部分のパスを作成
    Path pressedRegionPath = Path();
    if (pressedRegion == DPadRegion.up) {
      pressedRegionPath.addRRect(RRect.fromRectAndRadius(upRect, Radius.circular(cornerRadius)));
      // 中央の交差部分の上半分も含む
      pressedRegionPath.addRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: thickness, height: thickness / 2), Radius.circular(cornerRadius)));
    } else if (pressedRegion == DPadRegion.down) {
      pressedRegionPath.addRRect(RRect.fromRectAndRadius(downRect, Radius.circular(cornerRadius)));
      // 中央の交差部分の下半分も含む
      pressedRegionPath.addRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: thickness, height: thickness / 2).shift(const Offset(0, thickness / 2)), Radius.circular(cornerRadius)));
    } else if (pressedRegion == DPadRegion.left) {
      pressedRegionPath.addRRect(RRect.fromRectAndRadius(leftRect, Radius.circular(cornerRadius)));
      // 中央の交差部分の左半分も含む
      pressedRegionPath.addRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: thickness / 2, height: thickness), Radius.circular(cornerRadius)));
    } else if (pressedRegion == DPadRegion.right) {
      pressedRegionPath.addRRect(RRect.fromRectAndRadius(rightRect, Radius.circular(cornerRadius)));
      // 中央の交差部分の右半分も含む
      pressedRegionPath.addRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: thickness / 2, height: thickness).shift(const Offset(thickness / 2, 0)), Radius.circular(cornerRadius)));
    }

    // 中央の切り欠きを除外
    Path finalPressedPath = Path.combine(PathOperation.difference, pressedRegionPath, innerCutoutPath);

    // 押された部分と通常部分を分けて描画
    if (pressedRegion != null) {
      // 押されていない部分のパス
      Path nonPressedCombinedPath = Path.combine(PathOperation.difference, combinedBasePath, finalPressedPath);
      canvas.drawPath(nonPressedCombinedPath, normalPaint);

      // 押された部分をオフセットして描画
      canvas.drawPath(finalPressedPath.shift(
        pressedRegion == DPadRegion.up ? offsetUp :
        pressedRegion == DPadRegion.down ? offsetDown :
        pressedRegion == DPadRegion.left ? offsetLeft :
        offsetRight,
      ), pressedPaint);
    } else {
      // 何も押されていない場合は全体を通常色で描画
      canvas.drawPath(combinedBasePath, normalPaint);
    }

    // 中央の薄い丸
    final Paint centerCirclePaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, centerCircleRadius, centerCirclePaint);


    // 各スティック先端の矢印マーク (矢印はスティックの沈み込みに追従するようにオフセット)
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