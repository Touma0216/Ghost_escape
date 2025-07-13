import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_app/ui/game/models/player_model.dart';
import 'package:my_app/ui/game/models/cage_state.dart';
import 'package:my_app/ui/game/engine/prison_object_layer.dart';
import 'package:path/path.dart' as path;

abstract class RenderableObject {
  double get x;
  double get y;
  double get sortY;
  Widget buildWidget(double tileSize);
}

class PlayerRenderObject extends RenderableObject {
  final PlayerModel player;

  PlayerRenderObject(this.player);

  @override
  double get x => player.x;

  @override
  double get y => player.y;

  @override
  double get sortY => player.y + player.tileSize;

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
      ),
    );
  }
}

class CageRenderObject extends RenderableObject {
  final CageObject cage;
  final PlayerModel player;

  CageRenderObject(this.cage, this.player);

  @override
  double get x => cage.x;

  @override
  double get y => cage.y;

  @override
  double get sortY {
    final fileName = path.basename(cage.assetPath);
    final isDynamicCage = [
      'cage.png',
      'cage_close.png',
      'cage_open.png',
    ].contains(fileName);

    if (!isDynamicCage) return (cage.y + 1) * 64;

    final cageBottomY = (cage.y + 1) * 64;
    final playerBottomY = player.y + player.tileSize;
    return cageBottomY > playerBottomY ? 0 : 99999;
  }

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

class DepthSortedLayer extends ConsumerWidget {
  final double tileSize;
  final PlayerModel player;
  final List<CageObject> cages;
  final List<RenderableObject> otherObjects; // ← 追加

  const DepthSortedLayer({
    super.key,
    required this.tileSize,
    required this.player,
    required this.cages,
    required this.otherObjects, // ← 追加
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cageState = ref.watch(cageStateProvider);
    List<RenderableObject> objects = [];

    objects.add(PlayerRenderObject(player));

    for (final cage in cages) {
      objects.add(CageRenderObject(cage, player));
    }

    objects.addAll(otherObjects); // ← 他の素材を含める

    objects.sort((a, b) => a.sortY.compareTo(b.sortY));

    return Stack(
      children: objects.map((obj) => obj.buildWidget(tileSize)).toList(),
    );
  }
}
