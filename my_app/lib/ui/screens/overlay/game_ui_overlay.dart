// ファイル名: lib/ui/overlay/game_ui_overlay.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'widgets/status_bar.dart';
import 'widgets/character_icon.dart';
import 'widgets/movement_controller.dart';
import 'widgets/action_buttons.dart';
import 'widgets/possession_timer.dart';

class GameUiOverlay extends HookConsumerWidget {
  const GameUiOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // UIパーツを四隅＋上中央に配置（Stack＋Align構成）
    return IgnorePointer(
      ignoring: false,
      child: Stack(
        children: [
          // 左上: メニュー、ほのかアイコン、体力バー
          const Positioned(
            left: 16,
            top: 16,
            child: StatusBar(),
          ),
          // 中央上: 憑依タイマー（ほのか操作時のみ自動表示）
          const Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: PossessionTimer(),
          ),
          // 右上: スタミナバー、操作キャラアイコン
          const Positioned(
            right: 16,
            top: 16,
            child: CharacterIconBar(),
          ),
          // 左下: 十字キー
          const Positioned(
            left: 16,
            bottom: 16,
            child: MovementController(),
          ),
          // 右下: 4ボタン
          const Positioned(
            right: 32,
            bottom: 32,
            child: ActionButtons(),
          ),
        ],
      ),
    );
  }
}
