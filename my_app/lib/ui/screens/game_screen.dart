// lib/ui/screens/game_screen.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_app/ui/screens/overlay/game_ui_overlay.dart';
import 'package:my_app/ui/game/engine/tile_map_widget.dart';
import 'package:my_app/ui/game/models/player_model.dart';

final tileSizeProvider = Provider<double>((ref) {
  final size = WidgetsBinding.instance.window.physicalSize /
      WidgetsBinding.instance.window.devicePixelRatio;
  return size.shortestSide / TileMapWidget.roomWidth;
});

final playerProvider = ChangeNotifierProvider<PlayerModel>((ref) {
  final tileSize = ref.watch(tileSizeProvider);
  return PlayerModel(
    x: tileSize * 2,
    y: tileSize * 2,
    tileSize: tileSize,
  );
});

class GameScreen extends HookConsumerWidget {
  const GameScreen({super.key});

  void _precacheAllImages(BuildContext context, double tileSize) {
    const dirs = ['down', 'up', 'left', 'right'];
    const frames = [0, 1, 2];
    for (final dir in dirs) {
      for (final frame in frames) {
        precacheImage(
          AssetImage('assets/char/honoka_${dir}_$frame.png'),
          context,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tileSize = ref.watch(tileSizeProvider);
    final player = ref.watch(playerProvider);

    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    const double zoom = 1.5;

    // マップのピクセル幅・高さ
    final mapPixelWidth = TileMapWidget.roomWidth * tileSize;
    final mapPixelHeight = TileMapWidget.roomHeight * tileSize;

    // プレイヤーの中心座標（カメラの中心になる点）
    final playerCenterX = player.x + tileSize / 2;
    final playerCenterY = player.y + tileSize / 2;

    // 表示領域の半分（ズーム考慮）
    final halfViewW = screenWidth / (2 * zoom);
    final halfViewH = screenHeight / (2 * zoom);

    // カメラの左上を決定（マップ外に出ないよう clamp）
    double offsetX = playerCenterX - halfViewW;
    double offsetY = playerCenterY - halfViewH;

    // clamp範囲を正確に出す（マップが小さくても絶対に0を超えない）
    offsetX = offsetX.clamp(
      0.0,
      (mapPixelWidth - screenWidth / zoom).clamp(0.0, double.infinity),
    );
    offsetY = offsetY.clamp(
      0.0,
      (mapPixelHeight - screenHeight / zoom).clamp(0.0, double.infinity),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheAllImages(context, tileSize);
      if (player.tileSize != tileSize) {
        ref.read(playerProvider).updateTileSize(tileSize);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Transform.scale(
            scale: zoom,
            alignment: Alignment.topLeft,
            child: Transform.translate(
              offset: Offset(-offsetX, -offsetY),
              child: Stack(
                children: [
                  TileMapWidget(
                    tileImageAsset: 'assets/material/prison_floor.png',
                    tileSize: tileSize,
                  ),
                  Positioned(
                    left: player.x,
                    top: player.y,
                    child: Image.asset(
                      player.currentImageAsset,
                      width: tileSize,
                      height: tileSize,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                      gaplessPlayback: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GameUiOverlay(
            onDPad: (dir) {
              ref.read(playerProvider).move(dir);
            },
            onDPadRelease: () {
              ref.read(playerProvider).stop();
            },
          ),
        ],
      ),
    );
  }
}
