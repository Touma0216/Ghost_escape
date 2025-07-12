// lib/ui/game/engine/tile_map_widget.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_app/ui/game/models/cage_state.dart'; // cageStateProvider参照

class TileMapWidget extends ConsumerWidget {
  final String tileImageAsset;
  final double tileSize;

  // 0:床, 1:壁, 2:鉄格子, 3:扉
  static const List<List<int>> roomMap = [
    [1,1,1,1,1,1,1],
    [1,0,0,0,0,0,1],
    [1,0,0,0,0,0,1],
    [1,0,0,0,0,0,1],
    [1,0,0,0,0,0,1],
    [1,1,2,3,2,1,1], // ←左鉄格子,扉,扉,右鉄格子
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
    final t = roomMap[ty][tx];
    // 鉄格子や扉も"壁判定"に含めるならこうする
    return t == 1 || t == 2 || t == 3;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cageState = ref.watch(cageStateProvider); // 扉開閉

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
                  switch(roomMap[y][x]) {
                    case 1: // 壁
                      asset = (x == 0 || x == roomWidth - 1 || y == roomHeight - 1)
                        ? 'assets/material/ceil.png'
                        : 'assets/material/prison_wall.png';
                      break;
                    case 2: // 鉄格子
                      asset = 'assets/material/cage.png';
                      break;
                    case 3: // 扉
                      asset = cageState.isOpened
                        ? 'assets/material/cage_open.png'
                        : 'assets/material/cage_close.png';
                      break;
                    default: // 床
                      asset = tileImageAsset;
                      break;
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
