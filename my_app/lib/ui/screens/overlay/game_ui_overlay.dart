// ファイル名: lib/ui/overlay/game_ui_overlay.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'widgets/status_bar.dart';
import 'widgets/character_icon.dart';
import 'widgets/movement_controller.dart';
import 'widgets/action_buttons.dart';
import 'widgets/possession_timer.dart';

// ★ここから: コールバック型追加
import 'package:my_app/ui/screens/overlay/widgets/movement_controller.dart';
typedef DPadCallback = void Function(DPadRegion direction);
typedef VoidCallback = void Function();
// ★ここまで

class GameUiOverlay extends HookConsumerWidget {
  // ★ここから: コールバックを受け取る
  final DPadCallback? onDPad;
  final VoidCallback? onDPadRelease;

  const GameUiOverlay({
    super.key,
    this.onDPad,
    this.onDPadRelease,
  });
  // ★ここまで

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
          // ★ここから: コールバックを渡す
          Positioned(
            left: 24,
            bottom: 24,
            child: MovementController(
              onPressed: onDPad,
              onReleased: onDPadRelease,
            ),
          ),
          // ★ここまで
          // 右下: 4ボタン
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
