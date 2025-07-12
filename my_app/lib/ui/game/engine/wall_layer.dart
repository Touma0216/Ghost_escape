// lib/ui/game/engine/wall_layer.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_app/ui/game/models/cage_state.dart';
import 'package:my_app/ui/game/engine/tile_map_widget.dart';

enum WallType {
  background, // 背景の壁（プレイヤーより手前）
  foreground, // 前景の壁（プレイヤーより奥）
}

class WallLayer extends ConsumerWidget {
  final double tileSize;
  final WallType wallType;

  const WallLayer({
    super.key,
    required this.tileSize,
    required this.wallType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cageState = ref.watch(cageStateProvider);

    return Stack(
      children: [
        for (int y = 0; y < TileMapWidget.roomHeight; y++)
          for (int x = 0; x < TileMapWidget.roomWidth; x++)
            if (TileMapWidget.roomMap[y][x] == 1 && _shouldRenderWall(x, y))
              Positioned(
                left: x * tileSize,
                top: y * tileSize,
                width: tileSize,
                height: tileSize,
                child: Builder(
                  builder: (_) {
                    // 一番下の中央3つは床として扱い、壁を描画しない
                    if (y == TileMapWidget.roomHeight - 1 && (x == 2 || x == 3 || x == 4)) {
                      return const SizedBox.shrink();
                    }
                    
                    final asset = (x == 0 || x == TileMapWidget.roomWidth - 1 || y == TileMapWidget.roomHeight - 1)
                        ? 'assets/material/ceil.png'
                        : 'assets/material/prison_wall.png';
                    
                    return Image.asset(
                      asset,
                      width: tileSize,
                      height: tileSize,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.none,
                    );
                  },
                ),
              ),
      ],
    );
  }
  
  bool _shouldRenderWall(int x, int y) {
    switch (wallType) {
      case WallType.background:
        // 上部の壁のみ（プレイヤーより手前に来る壁）
        return y < TileMapWidget.roomHeight - 2;
      case WallType.foreground:
        // 下部の壁のみ（プレイヤーより奥に来る壁）
        return y >= TileMapWidget.roomHeight - 2;
    }
  }
}