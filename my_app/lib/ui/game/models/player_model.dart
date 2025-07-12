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
    double step = tileSize / 8;
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

    // --- 壁判定：上は胸、左右は中心寄り ---
    final charW = tileSize;
    final charH = tileSize;
    final chestY = charH * 0.6; // 胸あたり（画像に応じて調整OK）
    final sideX1 = charW * 0.3; // 体の左端
    final sideX2 = charW * 0.7; // 体の右端

    final wallCheckPoints = [
      // 上：胸ラインだけ
      Offset(sideX1, chestY),
      Offset(sideX2, chestY),
      // 下：左右中央だけ
      Offset(sideX1, charH - 1),
      Offset(sideX2, charH - 1),
    ];

    for (final offset in wallCheckPoints) {
      int tx = ((nextX + offset.dx) ~/ tileSize);
      int ty = ((nextY + offset.dy) ~/ tileSize);
      
      // 檻の特別な当たり判定（y=5, x=2,3,4の位置）
      if (ty == 5 && (tx == 2 || tx == 3 || tx == 4)) {
        // 檻の踏み込み可能範囲を設定（0.0-1.0で檻タイル内の位置）
        const double cageWalkableArea = 1.8; // この値を調整で踏み込み具合を変更
        
        // キャラクターの現在位置が檻タイル内のどの位置にあるかを計算
        double charPosInTile = ((nextY + offset.dy) % tileSize) / tileSize;
        
        // 檻の上部（1.0 - cageWalkableArea以上）の位置では当たり判定
        if (charPosInTile <= (1.0 - cageWalkableArea)) {
          if (TileMapWidget.isWallTile(tx, ty)) return;
        }
        // 下部（cageWalkableArea部分）は通れるのでスキップ
        continue;
      }
      
      // 通常の壁判定
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