import 'package:flutter/material.dart';
import 'package:my_app/ui/screens/overlay/game_ui_overlay.dart';
import 'package:my_app/ui/game/engine/tile_map_widget.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1: フィールド
          const TileMapWidget(
            tileImageAsset: 'assets/material/prison_floor.png',
            tileSize: 64,
          ),
          // 2: ほのかを中央に仮配置
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 32, // 64px分中央
            top: MediaQuery.of(context).size.height / 2 - 32,
            child: Image.asset(
              'assets/char/honoka_down_1.png',
              width: 64,
              height: 64,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none, // ←ドット絵に必須！
            ),
          ),

          // 3: UIオーバーレイ
          const GameUiOverlay(),
        ],
      ),
    );
  }
}