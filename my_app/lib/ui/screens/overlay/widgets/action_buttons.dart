// ファイル名: lib/ui/overlay/widgets/action_buttons.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/ui_state.dart';

class ActionButtons extends HookConsumerWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(gameUiStateProvider);

    // 各ボタン活性・非活性制御
    final canPossess = uiState.canPossess;
    final canDash = uiState.canDash;
    final canInvestigate = uiState.canInvestigate;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 上段2つ
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionCircleButton(
              icon: Icons.transform,
              label: uiState.controlledCharacter == ControlledCharacter.honoka
                  ? '憑依'
                  : '離脱',
              enabled: canPossess,
              onPressed: () {
                // TODO: 憑依・離脱ロジック
              },
            ),
            const SizedBox(width: 16),
            _ActionCircleButton(
              icon: Icons.search,
              label: '調べる',
              enabled: canInvestigate,
              onPressed: () {
                // TODO: 調べるアクション
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 下段2つ
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionCircleButton(
              icon: Icons.directions_run,
              label: 'ダッシュ',
              enabled: canDash,
              onPressed: () {
                // TODO: ダッシュアクション
              },
            ),
            const SizedBox(width: 16),
            _ActionCircleButton(
              icon: Icons.more_horiz,
              label: 'サブ',
              enabled: true,
              onPressed: () {
                // TODO: サブアクション
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionCircleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onPressed;
  const _ActionCircleButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: enabled ? Colors.white : Colors.grey[300],
          shape: const CircleBorder(),
          elevation: enabled ? 4 : 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: enabled ? onPressed : null,
            child: SizedBox(
              width: 56,
              height: 56,
              child: Icon(
                icon,
                size: 32,
                color: enabled ? Colors.black87 : Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: enabled ? Colors.black87 : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
