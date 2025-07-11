// lib/ui/overlay/widgets/character_icon.dart

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

    return SizedBox(
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ← スタミナバー等は元のまま
          _StaminaBar(stamina: uiState.dashStamina),
          const SizedBox(width: 8),
          // ここだけ純粋な画像挿入
          if (isHonoka)
            Image.asset(
              'assets/char/pino_icon.png',
              width: 32, // 必要に応じて調整
              height: 32,
              fit: BoxFit.contain,
            )
          else
            Icon(
              isPino ? Icons.pets : Icons.emoji_people,
              size: 28,
              color: Colors.black87,
            ),
        ],
      ),
    );
  }
}

class _StaminaBar extends StatelessWidget {
  final double stamina;
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
