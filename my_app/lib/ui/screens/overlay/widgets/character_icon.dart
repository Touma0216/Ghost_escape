// ファイル名: lib/ui/overlay/widgets/character_icon.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/ui_state.dart';

class CharacterIconBar extends HookConsumerWidget {
  const CharacterIconBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(gameUiStateProvider);
    final isHonoka = uiState.controlledCharacter == ControlledCharacter.honoka;
    final isPino = uiState.controlledCharacter == ControlledCharacter.pino;

    IconData iconData;
    if (isHonoka) {
      iconData = Icons.face;
    } else if (isPino) {
      iconData = Icons.pets;
    } else {
      iconData = Icons.emoji_people;
    }

    return SizedBox(
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // ここがポイント
        children: [
          // スタミナバー
          _StaminaBar(stamina: uiState.dashStamina),
          const SizedBox(width: 8),
          // アイコン（バーと中心を揃える）
          Align(
            alignment: Alignment.center,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.black12,
              child: Icon(iconData, size: 22, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaminaBar extends StatelessWidget {
  final double stamina; // 0.0~1.0
  const _StaminaBar({required this.stamina});

  @override
  Widget build(BuildContext context) {
    Color lerped = Color.lerp(Colors.blue, Colors.yellow, 1 - stamina)!;
    return Container(
      width: 128,
      height: 18,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.4),
        borderRadius: BorderRadius.circular(4),
        color: Colors.yellow.shade100.withOpacity(0.25),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: stamina,
        child: Container(
          decoration: BoxDecoration(
            color: lerped,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
