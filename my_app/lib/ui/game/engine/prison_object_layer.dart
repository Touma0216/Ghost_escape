// lib/ui/game/engine/prison_object_layer.dart

import 'package:flutter/material.dart';

class CageObject {
  final double x, y;
  final String assetPath;
  final double? width, height;
  const CageObject({
    required this.x,
    required this.y,
    required this.assetPath,
    this.width,
    this.height,
  });
}

class PrisonObjectLayer extends StatelessWidget {
  final double tileSize;
  final List<CageObject> cages;

  const PrisonObjectLayer({
    super.key,
    required this.tileSize,
    required this.cages,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (final cage in cages)
          Positioned(
            left: tileSize * cage.x,
            top: tileSize * cage.y,
            width: cage.width ?? tileSize,
            height: cage.height ?? tileSize,
            child: Image.asset(
              cage.assetPath,
              width: cage.width ?? tileSize,
              height: cage.height ?? tileSize,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
            ),
          ),
      ],
    );
  }
}
