// lib/ui/screens/game_screen.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_app/ui/screens/overlay/game_ui_overlay.dart';
import 'package:my_app/ui/game/engine/tile_map_widget.dart';
import 'package:my_app/ui/game/engine/prison_object_layer.dart';
import 'package:my_app/ui/game/engine/wall_layer.dart';
import 'package:my_app/ui/game/engine/depth_sorted_layer.dart'; // 新規追加
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

// 檻（正方形配置のみ）＋今後の自由追加用リスト
final List<CageObject> cages = [
  CageObject(x: 2, y: 5, assetPath: 'assets/material/cage.png'),
  CageObject(x: 3, y: 5, assetPath: 'assets/material/cage_close.png'),
  CageObject(x: 4, y: 5, assetPath: 'assets/material/cage.png'),
  // 他に家具など自由に追加可
];

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
    // 檻・扉も先読み（推奨）
    precacheImage(AssetImage('assets/material/cage.png'), context);
    precacheImage(AssetImage('assets/material/cage_close.png'), context);
    precacheImage(AssetImage('assets/material/cage_open.png'), context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tileSize = ref.watch(tileSizeProvider);
    final player = ref.watch(playerProvider);

    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    const double zoom = 1.5;

    final mapPixelWidth = TileMapWidget.roomWidth * tileSize;
    final mapPixelHeight = TileMapWidget.roomHeight * tileSize;

    final playerCenterX = player.x + tileSize / 2;
    final playerCenterY = player.y + tileSize / 2;
    final halfViewW = screenWidth / (2 * zoom);
    final halfViewH = screenHeight / (2 * zoom);

    double offsetX = playerCenterX - halfViewW;
    double offsetY = playerCenterY - halfViewH;

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
                  // 1. 床（全マスに敷く）
                  TileMapWidget(
                    tileImageAsset: 'assets/material/prison_floor.png',
                    tileSize: tileSize,
                  ),
                  // 2. 上部の壁（プレイヤーより手前に来る壁）
                  WallLayer(
                    tileSize: tileSize,
                    wallType: WallType.background,
                  ),
                  // 3. 深度ソート済みレイヤー（プレイヤー + 檻 + 下部の壁）
                  DepthSortedLayer(
                    tileSize: tileSize,
                    player: player,
                    cages: cages,
                  ),
                ],
              ),
            ),
          ),
          // UIレイヤー
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