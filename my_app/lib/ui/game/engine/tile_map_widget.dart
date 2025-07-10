import 'package:flutter/material.dart';

/// 大きな床画像(tileSize×tileSize)を画面に敷き詰めるウィジェット
class TileMapWidget extends StatelessWidget {
  final String tileImageAsset;
  final double tileSize;

  const TileMapWidget({
    super.key,
    required this.tileImageAsset,
    required this.tileSize, // 例: 1024.0
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // タイル枚数（四隅がはみ出てもOKなよう+1しておく）
    final int horizontalTiles = (size.width / tileSize).ceil() + 1;
    final int verticalTiles = (size.height / tileSize).ceil() + 1;

    return Stack(
      children: [
        for (int y = 0; y < verticalTiles; y++)
          for (int x = 0; x < horizontalTiles; x++)
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
              ),
            ),
      ],
    );
  }
}
