// lib/ui/screens/game_screen.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_app/ui/screens/overlay/game_ui_overlay.dart';
import 'package:my_app/ui/game/engine/tile_map_widget.dart';
import 'package:my_app/ui/game/models/player_model.dart';

// 画面サイズからtileSizeを計算するProvider
final tileSizeProvider = Provider<double>((ref) {
  final size = WidgetsBinding.instance.window.physicalSize /
      WidgetsBinding.instance.window.devicePixelRatio;
  return size.shortestSide / TileMapWidget.roomWidth;
});

// PlayerModelのProvider
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

    // tileSizeが変わったらplayerにも反映
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheAllImages(context, tileSize);
      if (player.tileSize != tileSize) {
        ref.read(playerProvider).updateTileSize(tileSize);
      }
    });

    return Scaffold(
      body: Stack(
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
