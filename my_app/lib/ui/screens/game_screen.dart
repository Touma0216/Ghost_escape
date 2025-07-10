// lib/ui/screens/game_screen.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_app/ui/screens/overlay/game_ui_overlay.dart';
import 'package:my_app/ui/game/engine/tile_map_widget.dart';
import 'package:my_app/ui/game/models/player_model.dart';
import 'package:my_app/ui/screens/overlay/widgets/movement_controller.dart';

// PlayerModelのProvider
final playerProvider = ChangeNotifierProvider((ref) => PlayerModel(
      x: 160,
      y: 160,
    ));

class GameScreen extends HookConsumerWidget {
  const GameScreen({super.key});

  // Flutter 3.7以降対応
  void _precacheAllImages(BuildContext context) {
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
    final player = ref.watch(playerProvider);

    // precacheを必ず最初のビルドで1回だけ実行（毎回やらないように）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheAllImages(context);
    });

    return Scaffold(
      body: Stack(
        children: [
          // 1: フィールド
          const TileMapWidget(
            tileImageAsset: 'assets/material/prison_floor.png',
            tileSize: 64,
          ),
          // 2: ほのか（位置/画像/アニメ連動）
          Positioned(
            left: player.x,
            top: player.y,
            child: Image.asset(
              player.currentImageAsset,
              width: 64,
              height: 64,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
              gaplessPlayback: false, // ←プリキャッシュと併用で残像ゼロ
            ),
          ),
          // 3: UIオーバーレイ（十字キーにコールバック連携!）
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
