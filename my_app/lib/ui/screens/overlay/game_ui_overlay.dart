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
    return IgnorePointer(
      ignoring: false,
      child: Stack(
        children: [
          // 上部UI：左右対称Row＋中央タイマー
          Positioned(
            left: 0,
            right: 0,
            top: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: StatusBar(),
                ),
                const Expanded(child: SizedBox()),
                const PossessionTimer(),
                const Expanded(child: SizedBox()),
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: CharacterIconBar(),
                ),
              ],
            ),
          ),
          // 左下: 十字キー
          const Positioned(
            left: 24,
            bottom: 24,
            child: MovementController(),
          ),
          // 右下: 4ボタン（ひし形、スティック中央と完全揃え）
          // bottom値はMovementControllerと同一に
          const Positioned(
            right: 36,
            bottom: 36,
            child: ActionButtons(),
          ),
        ],
      ),
    );
  }
}
