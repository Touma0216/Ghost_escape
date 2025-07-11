// lib/ui/game/models/player_model.dart

import 'package:flutter/material.dart';
import 'package:my_app/ui/screens/overlay/widgets/movement_controller.dart';
import 'package:my_app/ui/game/engine/tile_map_widget.dart';
import 'dart:async';

class PlayerModel extends ChangeNotifier {
  double x;
  double y;
  double tileSize;
  DPadRegion direction;
  int walkFrame;
  bool isMoving;
  Timer? _idleTimer;

  PlayerModel({
    required this.x,
    required this.y,
    required this.tileSize,
    this.direction = DPadRegion.down,
    this.walkFrame = 0,
    this.isMoving = false,
  });

  void move(DPadRegion dir) {
    direction = dir;
    double nextX = x, nextY = y;
    double step = tileSize / 8; // スピードはtileSize比率
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
    // 四隅のどれかが壁タイルなら止める
    final charSize = tileSize;
    final corners = [
      Offset(0, 0),
      Offset(charSize - 1, 0),
      Offset(0, charSize - 1),
      Offset(charSize - 1, charSize - 1),
    ];
    for (final offset in corners) {
      int tx = ((nextX + offset.dx) ~/ tileSize);
      int ty = ((nextY + offset.dy) ~/ tileSize);
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

  // tileSizeの再設定
  void updateTileSize(double newSize) {
    tileSize = newSize;
    notifyListeners();
  }
}
