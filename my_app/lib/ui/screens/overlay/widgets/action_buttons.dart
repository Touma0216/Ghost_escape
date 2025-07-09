// ファイル名: lib/ui/overlay/widgets/action_buttons.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/ui_state.dart';

class ActionButtons extends HookConsumerWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(gameUiStateProvider);

    final double btnRadius = 18; // ボタン半径（36px）
    final double distance = 26;  // ひし形の各方向への距離

    return SizedBox(
      width: btnRadius * 3,
      height: btnRadius * 3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 上
          _DiamondActionButton(
            icon: Icons.transform,
            enabled: uiState.canPossess,
            onPressed: () {},
            offset: Offset(0, -distance),
          ),
          // 右
          _DiamondActionButton(
            icon: Icons.search,
            enabled: uiState.canInvestigate,
            onPressed: () {},
            offset: Offset(distance, 0),
          ),
          // 下
          _DiamondActionButton(
            icon: Icons.directions_run,
            enabled: uiState.canDash,
            onPressed: () {},
            offset: Offset(0, distance),
          ),
          // 左
          _DiamondActionButton(
            icon: Icons.more_horiz,
            enabled: true,
            onPressed: () {},
            offset: Offset(-distance, 0),
          ),
        ],
      ),
    );
  }
}

class _DiamondActionButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;
  final Offset offset;
  const _DiamondActionButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      child: Transform.translate(
        offset: offset,
        child: Material(
          color: enabled ? Colors.white : Colors.grey[300],
          shape: const CircleBorder(),
          elevation: enabled ? 2 : 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: enabled ? onPressed : null,
            child: SizedBox(
              width: 28,
              height: 28,
              child: Icon(
                icon,
                size: 20,
                color: enabled ? Colors.black87 : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
