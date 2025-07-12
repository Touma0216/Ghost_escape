// lib/ui/game/engine/wall_layer.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_app/ui/game/models/cage_state.dart';
import 'package:my_app/ui/game/engine/tile_map_widget.dart';

class WallLayer extends ConsumerWidget {
  final double tileSize;

  const WallLayer({
    super.key,
    required this.tileSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cageState = ref.watch(cageStateProvider);

    return Stack(
      children: [
        for (int y = 0; y < TileMapWidget.roomHeight; y++)
          for (int x = 0; x < TileMapWidget.roomWidth; x++)
            if (TileMapWidget.roomMap[y][x] == 1) // 壁タイルのみ
              Positioned(
                left: x * tileSize,
                top: y * tileSize,
                width: tileSize,
                height: tileSize,
                child: Builder(
                  builder: (_) {
                    String asset;
                    // 一番下の中央3つは床として扱い、壁を描画しない
                    if (y == TileMapWidget.roomHeight - 1 && (x == 2 || x == 3 || x == 4)) {
                      return const SizedBox.shrink(); // 何も描画しない
                    } else {
                      asset = (x == 0 || x == TileMapWidget.roomWidth - 1 || y == TileMapWidget.roomHeight - 1)
                          ? 'assets/material/ceil.png'
                          : 'assets/material/prison_wall.png';
                    }
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
}