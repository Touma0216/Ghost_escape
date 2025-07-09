// ファイル名: lib/ui/overlay/widgets/character_icon.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/ui_state.dart';

class CharacterIconBar extends HookConsumerWidget {
  const CharacterIconBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(gameUiStateProvider);

    // キャラによってアイコン切替
    final isHonoka = uiState.controlledCharacter == ControlledCharacter.honoka;
    final isPino = uiState.controlledCharacter == ControlledCharacter.pino;

    IconData iconData;
    String label;
    if (isHonoka) {
      iconData = Icons.face;
      label = 'ほのか';
    } else if (isPino) {
      iconData = Icons.pets;
      label = 'ピノ';
    } else {
      iconData = Icons.emoji_people;
      label = '敵';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // スタミナバー
        _StaminaBar(stamina: uiState.dashStamina),
        const SizedBox(width: 12),
        // 操作キャラアイコン
        Column(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.black12,
              child: Icon(iconData, size: 28, color: Colors.black87),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class _StaminaBar extends StatelessWidget {
  final double stamina; // 0.0~1.0
  const _StaminaBar({required this.stamina});

  @override
  Widget build(BuildContext context) {
    // 青→黄
    Color lerped = Color.lerp(Colors.blue, Colors.yellow, 1 - stamina)!;
    return Container(
      width: 90,
      height: 16,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(4),
        color: Colors.yellow.shade100.withOpacity(0.4),
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
