// lib/ui/game/engine/tile_map_widget.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_app/ui/game/models/cage_state.dart';

class TileMapWidget extends ConsumerWidget {
  final String tileImageAsset;
  final double tileSize;

  static const List<List<int>> roomMap = [
    [1,1,1,1,1,1,1],
    [1,0,0,0,0,0,1],
    [1,0,0,0,0,0,1],
    [1,0,0,0,0,0,1],
    [1,0,0,0,0,0,1],
    [1,1,1,1,1,1,1], // ←一番下
  ];

  const TileMapWidget({
    super.key,
    required this.tileImageAsset,
    required this.tileSize,
  });

  static int get roomWidth => roomMap[0].length;
  static int get roomHeight => roomMap.length;

  static bool isWallTile(int tx, int ty) {
    if (ty < 0 || ty >= roomMap.length) return true;
    if (tx < 0 || tx >= roomMap[0].length) return true;
    return roomMap[ty][tx] == 1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cageState = ref.watch(cageStateProvider);

    return Stack(
      children: [
        for (int y = 0; y < roomHeight; y++)
          for (int x = 0; x < roomWidth; x++)
            Positioned(
              left: x * tileSize,
              top: y * tileSize,
              width: tileSize,
              height: tileSize,
              child: Builder(
                builder: (_) {
                  String asset;
                  // ↓ここで一番下の中央3つだけ「床画像」に見た目置き換え
                  if (y == roomHeight - 1 && (x == 2 || x == 3 || x == 4)) {
                    asset = tileImageAsset; // 床
                  } else if (roomMap[y][x] == 1) {
                    asset = (x == 0 || x == roomWidth - 1 || y == roomHeight - 1)
                        ? 'assets/material/ceil.png'
                        : 'assets/material/prison_wall.png';
                  } else {
                    asset = tileImageAsset; // 床
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
