// lib/ui/game/engine/depth_sorted_layer.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_app/ui/game/engine/tile_map_widget.dart';
import 'package:my_app/ui/game/engine/prison_object_layer.dart';
import 'package:my_app/ui/game/models/player_model.dart';
import 'package:my_app/ui/game/models/cage_state.dart';

// 描画可能オブジェクトの抽象クラス
abstract class RenderableObject {
  double get x;
  double get y;
  double get sortY; // ソート用のY座標
  Widget buildWidget(double tileSize);
}

// プレイヤーオブジェクト
class PlayerRenderObject extends RenderableObject {
  final PlayerModel player;
  
  PlayerRenderObject(this.player);
  
  @override
  double get x => player.x;
  
  @override
  double get y => player.y;
  
  @override
  double get sortY => player.y + player.tileSize; // プレイヤーの足元でソート
  
  @override
  Widget buildWidget(double tileSize) {
    return Positioned(
      left: x,
      top: y,
      child: Image.asset(
        player.currentImageAsset,
        width: tileSize,
        height: tileSize,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
        gaplessPlayback: false,
      ),
    );
  }
}

// 檻オブジェクト
class CageRenderObject extends RenderableObject {
  final CageObject cage;
  
  CageRenderObject(this.cage);
  
  @override
  double get x => cage.x;
  
  @override
  double get y => cage.y;
  
  @override
  double get sortY => (cage.y + 1) * 64; // 檻の底部でソート（タイル座標をピクセル座標に変換）
  
  @override
  Widget buildWidget(double tileSize) {
    return Positioned(
      left: tileSize * x,
      top: tileSize * y,
      width: cage.width ?? tileSize,
      height: cage.height ?? tileSize,
      child: Image.asset(
        cage.assetPath,
        width: cage.width ?? tileSize,
        height: cage.height ?? tileSize,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
      ),
    );
  }
}

// 壁オブジェクト
class WallRenderObject extends RenderableObject {
  final int tileX;
  final int tileY;
  final String assetPath;
  
  WallRenderObject({
    required this.tileX,
    required this.tileY,
    required this.assetPath,
  });
  
  @override
  double get x => tileX.toDouble();
  
  @override
  double get y => tileY.toDouble();
  
  @override
  double get sortY => (tileY + 1) * 64.0; // 壁の底部でソート（タイル座標をピクセル座標に変換）
  
  @override
  Widget buildWidget(double tileSize) {
    return Positioned(
      left: tileSize * x,
      top: tileSize * y,
      width: tileSize,
      height: tileSize,
      child: Image.asset(
        assetPath,
        width: tileSize,
        height: tileSize,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.none,
      ),
    );
  }
}

class DepthSortedLayer extends ConsumerWidget {
  final double tileSize;
  final PlayerModel player;
  final List<CageObject> cages;

  const DepthSortedLayer({
    super.key,
    required this.tileSize,
    required this.player,
    required this.cages,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cageState = ref.watch(cageStateProvider);
    
    // 全ての描画オブジェクトを収集
    List<RenderableObject> objects = [];
    
    // プレイヤーを追加
    objects.add(PlayerRenderObject(player));
    
    // 檻を追加
    for (final cage in cages) {
      objects.add(CageRenderObject(cage));
    }
    
    // 全ての壁を追加
    for (int y = 0; y < TileMapWidget.roomHeight; y++) {
      for (int x = 0; x < TileMapWidget.roomWidth; x++) {
        if (TileMapWidget.roomMap[y][x] == 1) {
          // 一番下の中央3つは除外（出入り口）
          if (y == TileMapWidget.roomHeight - 1 && (x == 2 || x == 3 || x == 4)) {
            continue;
          }
          
          final asset = (x == 0 || x == TileMapWidget.roomWidth - 1 || y == TileMapWidget.roomHeight - 1)
              ? 'assets/material/ceil.png'
              : 'assets/material/prison_wall.png';
          
          objects.add(WallRenderObject(
            tileX: x,
            tileY: y,
            assetPath: asset,
          ));
        }
      }
    }
    
    // Y座標でソート（上から下へ）
    objects.sort((a, b) => a.sortY.compareTo(b.sortY));
    
    return Stack(
      children: objects.map((obj) => obj.buildWidget(tileSize)).toList(),
    );
  }
}