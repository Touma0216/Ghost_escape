// ファイル名: lib/ui/overlay/widgets/status_bar.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/ui_state.dart';

class StatusBar extends HookConsumerWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(gameUiStateProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // メニューボタン
        IconButton(
          icon: const Icon(Icons.menu, size: 32),
          tooltip: 'メニュー',
          onPressed: () {
            ref.read(gameUiStateProvider.notifier).setMenuOpen(!uiState.isMenuOpen);
          },
        ),
        const SizedBox(width: 8),
        // ほのかアイコン
        Column(
          children: [
            // 仮アイコン（後で画像差し替え）
            const Icon(Icons.face, size: 32),
            const SizedBox(height: 4),
          ],
        ),
        const SizedBox(width: 8),
        // 体力バー
        _HonokaHpBar(hp: uiState.honokaHp),
      ],
    );
  }
}

class _HonokaHpBar extends StatelessWidget {
  final double hp; // 0.0~1.0
  const _HonokaHpBar({required this.hp});

  @override
  Widget build(BuildContext context) {
    // バーの色グラデーション（緑→赤）
    Color lerped = Color.lerp(Colors.green, Colors.red, 1 - hp)!;
    return Container(
      width: 140,
      height: 24,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(4),
        color: Colors.red.shade200.withOpacity(0.3),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: hp,
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
