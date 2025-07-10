import 'package:flutter/material.dart';
import 'package:my_app/ui/screens/overlay/widgets/movement_controller.dart';
import 'dart:async';

class PlayerModel extends ChangeNotifier {
  double x;
  double y;
  DPadRegion direction;
  int walkFrame;
  bool isMoving;
  Timer? _idleTimer;

  PlayerModel({
    this.x = 0,
    this.y = 0,
    this.direction = DPadRegion.down,
    this.walkFrame = 0, // 棒立ちから
    this.isMoving = false,
  });

  static const double step = 8;

  void move(DPadRegion dir) {
    direction = dir;

    // 歩行アニメ：右足(1)→左足(2)ループ
    if (!isMoving && walkFrame == 0) {
      walkFrame = 1; // 初動だけ右足
    } else {
      // 歩き出してからは1⇔2
      walkFrame = (walkFrame == 1) ? 2 : 1;
    }
    isMoving = true;
    _cancelIdleTimer();

    switch (dir) {
      case DPadRegion.up:
        y -= step;
        break;
      case DPadRegion.down:
        y += step;
        break;
      case DPadRegion.left:
        x -= step;
        break;
      case DPadRegion.right:
        x += step;
        break;
    }
    notifyListeners();
  }

  void stop() {
    isMoving = false;
    _cancelIdleTimer();

    // 下だけ0.5秒後に棒立ち画像に
    if (direction == DPadRegion.down) {
      _idleTimer = Timer(const Duration(milliseconds: 500), () {
        if (!isMoving) {
          walkFrame = 0;
          notifyListeners();
        }
      });
    } 
    // 右・左・上は「最後の歩行フレーム（1 or 2）」のまま止める
    // つまりwalkFrameを変更しない
    notifyListeners();
  }

  void _cancelIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = null;
  }

  @override
  void dispose() {
    _cancelIdleTimer();
    super.dispose();
  }

String get currentImageAsset {
  String dirStr = '';
  int frame = walkFrame;
  switch (direction) {
    case DPadRegion.up:
      dirStr = 'up';
      if (frame == 0) frame = 1; // 上向きは0画像使わない
      break;
    case DPadRegion.down:
      dirStr = 'down';
      break;
    case DPadRegion.left:
      dirStr = 'left';
      if (frame == 0) frame = 1; // 左向きは0画像使わない
      break;
    case DPadRegion.right:
      dirStr = 'right';
      if (frame == 0) frame = 1; // 右向きは0画像使わない
      break;
  }
  // デバッグ用：print('assets/char/honoka_${dirStr}_$frame.png');
  return 'assets/char/honoka_${dirStr}_$frame.png';
}

}
