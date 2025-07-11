import 'package:flutter/material.dart';

class TileMapWidget extends StatelessWidget {
  final String tileImageAsset;
  final double tileSize;
  // 0=床, 1=壁
  static const List<List<int>> roomMap = [
    [1,1,1,1,1,1],
    [1,0,0,0,0,1],
    [1,0,0,0,0,1],
    [1,0,0,0,0,1],
    [1,0,0,0,0,1],
    [1,1,1,1,1,1],
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
  Widget build(BuildContext context) {
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
                roomMap[y][x] == 1
                    ? 'assets/material/prison_wall.png'
                    : tileImageAsset,
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
