// ファイル名: lib/ui/screens/game_screen.dart

import 'package:flutter/material.dart';
import 'package:my_app/ui/screens/overlay/game_ui_overlay.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1レイヤー目: ゲーム本体（背景やゲームロジック部分。ここは仮の白背景）
          Positioned.fill(
            child: Container(
              color: Colors.white,
              // ゲーム本体ウィジェットに差し替えOK
              child: const Center(child: Text('Game View (実装領域)', style: TextStyle(fontSize: 18))),
            ),
          ),
          // 2レイヤー目: UIオーバーレイ
          const GameUiOverlay(),
        ],
      ),
    );
  }
}
