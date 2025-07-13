// ファイルパス: lib/ui/overlay/game_ui_overlay.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'widgets/status_bar.dart';
import 'widgets/character_icon.dart';
import 'widgets/movement_controller.dart';
import 'widgets/action_buttons.dart';
import 'widgets/possession_timer.dart';

// ★ここから: コールバック型追加
import 'package:my_app/ui/screens/overlay/widgets/movement_controller.dart';

/// 十字キー操作時に呼び出されるコールバック型
typedef DPadCallback = void Function(DPadRegion direction);

/// 単純なイベント発火用のコールバック型（ボタン離しなど）
typedef VoidCallback = void Function();
// ★ここまで

/// ゲーム中に常時表示されるUIオーバーレイ（ステータス・アイコン・操作ボタンなど）
/// 操作パッドなどの入力に応じて、ゲーム本体のプレイヤー操作を制御する役割も持つ。
class GameUiOverlay extends HookConsumerWidget {
  // ★ここから: コールバックを受け取る

  /// 移動操作（十字キー）が押されたときに発火するコールバック
  final DPadCallback? onDPad;

  /// 十字キーが離されたときに発火するコールバック
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
      ignoring: false, // UI全体にタッチイベントを通す
      child: Stack(
        children: [
          // 上部UI：ステータスバー（左）、憑依タイマー（中央）、キャラアイコン（右）
          Positioned(
            left: 0,
            right: 0,
            top: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左上ステータスバー
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: StatusBar(),
                ),
                const Expanded(child: SizedBox()), // 中央スペーサー

                // 憑依残り時間の表示
                const PossessionTimer(),

                const Expanded(child: SizedBox()), // 中央スペーサー

                // 右上キャラクターアイコン
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: CharacterIconBar(),
                ),
              ],
            ),
          ),

          // 左下：移動用十字キーの表示
          // ★ここから: コールバックをMovementControllerに渡すことで操作イベントを伝達
          Positioned(
            left: 24,
            bottom: 24,
            child: MovementController(
              onPressed: onDPad,      // 押されたときにプレイヤー操作を開始
              onReleased: onDPadRelease, // 離したときにプレイヤーを停止
            ),
          ),
          // ★ここまで

          // 右下：アクションボタン群（調べる・使う等）
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
