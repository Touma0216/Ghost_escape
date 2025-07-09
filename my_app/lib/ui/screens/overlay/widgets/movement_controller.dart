// ファイル名: lib/ui/overlay/widgets/movement_controller.dart

import 'package:flutter/material.dart';

class MovementController extends StatelessWidget {
  const MovementController({super.key});

  @override
  Widget build(BuildContext context) {
    // シンプルな十字型レイアウト（4方向のみ）
    return SizedBox(
      width: 108,
      height: 108,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 上
          Positioned(
            top: 0,
            child: _DirectionButton(
              icon: Icons.keyboard_arrow_up,
              onTap: () {/* TODO: 上移動ロジック */},
            ),
          ),
          // 下
          Positioned(
            bottom: 0,
            child: _DirectionButton(
              icon: Icons.keyboard_arrow_down,
              onTap: () {/* TODO: 下移動ロジック */},
            ),
          ),
          // 左
          Positioned(
            left: 0,
            child: _DirectionButton(
              icon: Icons.keyboard_arrow_left,
              onTap: () {/* TODO: 左移動ロジック */},
            ),
          ),
          // 右
          Positioned(
            right: 0,
            child: _DirectionButton(
              icon: Icons.keyboard_arrow_right,
              onTap: () {/* TODO: 右移動ロジック */},
            ),
          ),
          // 中心（非タップ）
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black12,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _DirectionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.white,
        child: Icon(icon, size: 32, color: Colors.black87),
      ),
    );
  }
}
