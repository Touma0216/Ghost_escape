import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TileMapWidget extends ConsumerWidget {
  final String tileImageAsset;
  final double tileSize;

  static const List<List<int>> roomMap = [
    [1,1,1,1,1,1,1],
    [1,0,0,0,0,0,1],
    [1,0,0,0,0,0,1],
    [1,0,0,0,0,0,1],
    [1,0,0,0,0,0,1],
    [1,1,1,1,1,1,1],
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
    // 全部床で描画
    return Stack(
      children: [
        for (int y = 0; y < roomHeight; y++)
          for (int x = 0; x < roomWidth; x++)
            Positioned(
              left: x * tileSize,
              top: y * tileSize,
              width: tileSize,
              height: tileSize,
              child: Image.asset(
                tileImageAsset,
                width: tileSize,
                height: tileSize,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.none,
              ),
            ),
      ],
    );
  }
}
