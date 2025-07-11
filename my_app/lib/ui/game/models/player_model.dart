// lib/ui/game/engine/player_model.dart

import 'package:flutter/material.dart';
import 'package:my_app/ui/screens/overlay/widgets/movement_controller.dart';
import 'package:my_app/ui/game/engine/tile_map_widget.dart';
import 'dart:async';

class PlayerModel extends ChangeNotifier {
  double x; // キャラ画像の左上X（ピクセル）
  double y; // キャラ画像の左上Y（ピクセル）
  DPadRegion direction;
  int walkFrame;
  bool isMoving;
  Timer? _idleTimer;

  static const double step = 8;     // 1移動あたりのピクセル
  static const double charSize = 64; // キャラ画像サイズ

  PlayerModel({
    this.x = 64 * 2, // 部屋の中央寄り（6x6部屋ならこれでちょうど内側開始）
    this.y = 64 * 2,
    this.direction = DPadRegion.down,
    this.walkFrame = 0,
    this.isMoving = false,
  });

  void move(DPadRegion dir) {
    direction = dir;

    double nextX = x;
    double nextY = y;
    switch (dir) {
      case DPadRegion.up:
        nextY -= step;
        break;
      case DPadRegion.down:
        nextY += step;
        break;
      case DPadRegion.left:
        nextX -= step;
        break;
      case DPadRegion.right:
        nextX += step;
        break;
    }

    // 四隅のどれかが壁タイルなら止める（左上基準64x64）
    final corners = [
      Offset(0, 0), // 左上
      Offset(charSize - step, 0), // 右上
      Offset(0, charSize - step), // 左下
      Offset(charSize - 1, charSize - 1), // 右下
    ];
    for (final offset in corners) {
      int tx = ((nextX + offset.dx) ~/ 64);
      int ty = ((nextY + offset.dy) ~/ 64);
      if (TileMapWidget.isWallTile(tx, ty)) return;
    }

    // 歩行アニメ
    if (!isMoving && walkFrame == 0) {
      walkFrame = 1;
    } else {
      walkFrame = (walkFrame == 1) ? 2 : 1;
    }
    isMoving = true;
    _cancelIdleTimer();

    x = nextX;
    y = nextY;
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
        if (frame == 0) frame = 1;
        break;
      case DPadRegion.down:
        dirStr = 'down';
        break;
      case DPadRegion.left:
        dirStr = 'left';
        if (frame == 0) frame = 1;
        break;
      case DPadRegion.right:
        dirStr = 'right';
        if (frame == 0) frame = 1;
        break;
    }
    return 'assets/char/honoka_${dirStr}_$frame.png';
  }
}
