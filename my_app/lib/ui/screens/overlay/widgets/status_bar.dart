// ファイル名: lib/ui/overlay/widgets/status_bar.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/ui_state.dart';

class StatusBar extends HookConsumerWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(gameUiStateProvider);

    return SizedBox(
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // メニューボタン
          IconButton(
            icon: const Icon(Icons.menu, size: 28),
            tooltip: 'メニュー',
            padding: const EdgeInsets.all(0),
            onPressed: () {
              ref.read(gameUiStateProvider.notifier).setMenuOpen(!uiState.isMenuOpen);
            },
          ),
          const SizedBox(width: 8),
          // ほのかアイコン
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.black12,
            child: Icon(Icons.face, size: 22, color: Colors.black87),
          ),
          const SizedBox(width: 8),
          // 体力バー（短く！）
          _HonokaHpBar(hp: uiState.honokaHp),
        ],
      ),
    );
  }
}

class _HonokaHpBar extends StatelessWidget {
  final double hp; // 0.0~1.0
  const _HonokaHpBar({required this.hp});

  @override
  Widget build(BuildContext context) {
    Color lerped = Color.lerp(Colors.green, Colors.red, 1 - hp)!;
    return Container(
      width: 64,  // ← ここを縮小！（もともと128や140だった場合の半分以下）
      height: 18,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.4),
        borderRadius: BorderRadius.circular(4),
        color: Colors.red.shade200.withOpacity(0.25),
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
