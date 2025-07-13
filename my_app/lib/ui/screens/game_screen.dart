// ファイルパス: lib/ui/screens/game_screen.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_app/ui/screens/overlay/game_ui_overlay.dart';
import 'package:my_app/ui/game/engine/tile_map_widget.dart';
import 'package:my_app/ui/game/engine/depth_sorted_layer.dart';
import 'package:my_app/ui/game/engine/wall_layer.dart';
import 'package:my_app/ui/game/models/player_model.dart';
import 'package:my_app/ui/game/engine/prison_object_layer.dart';

/// 画面上でのタイル1マスの大きさを計算するProvider。
/// ユーザーの端末サイズに応じて、1マスのピクセルサイズを自動で算出。
/// マップ幅（TileMapWidget.roomWidth）を画面の短辺で割って求める。
final tileSizeProvider = Provider<double>((ref) {
  final size = WidgetsBinding.instance.window.physicalSize /
      WidgetsBinding.instance.window.devicePixelRatio;
  return size.shortestSide / TileMapWidget.roomWidth;
});

/// プレイヤーの位置や状態を保持・制御するプロバイダ。
/// 初期化時に位置とタイルサイズを設定。UIや描画と状態を連携させる。
final playerProvider = ChangeNotifierProvider<PlayerModel>((ref) {
  final tileSize = ref.watch(tileSizeProvider);
  return PlayerModel(x: tileSize * 2, y: tileSize * 2, tileSize: tileSize);
});

/// マップ上に表示する "檻" オブジェクトのリスト。
/// それぞれのX/Y座標と使う画像ファイルパスを指定している。
/// 表示はDepthSortedLayerで行われ、プレイヤーとの重なり順も制御される。
final List<CageObject> cages = [
  CageObject(x: 2, y: 5, assetPath: 'assets/material/cage.png'),
  CageObject(x: 3, y: 5, assetPath: 'assets/material/cage_close.png'),
  CageObject(x: 4, y: 5, assetPath: 'assets/material/cage.png'),
];

/// ゲームのプレイ画面を構成するメインウィジェット。
/// 背景・壁・プレイヤー・檻・UIをすべてレイヤーとして重ねて表示している。
/// また、プレイヤーの位置に応じてカメラ（画面の中心）も移動する。
class GameScreen extends HookConsumerWidget {
  const GameScreen({super.key});

  /// プレイヤーと檻、UIで使う画像アセットをあらかじめキャッシュしておく。
  /// これによりゲームプレイ中の描画遅延やカクつきを防止する。
  void _precacheAllImages(BuildContext context, double tileSize) {
    const dirs = ['down', 'up', 'left', 'right'];
    const frames = [0, 1, 2];
    for (final dir in dirs) {
      for (final frame in frames) {
        precacheImage(
          AssetImage('assets/char/honoka_${dir}_$frame.png'),
          context,
        );
      }
    }
    precacheImage(AssetImage('assets/material/cage.png'), context);
    precacheImage(AssetImage('assets/material/cage_close.png'), context);
    precacheImage(AssetImage('assets/material/cage_open.png'), context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tileSize = ref.watch(tileSizeProvider); // タイル1マスのピクセル幅を取得
    final player = ref.watch(playerProvider); // プレイヤーの状態（位置・向きなど）を取得

    final size = MediaQuery.of(context).size; // 画面サイズを取得
    final screenWidth = size.width;
    final screenHeight = size.height;

    const double zoom = 1.5; // 表示倍率（拡大して表示）

    // マップ全体のピクセル幅・高さを計算（マス数 × タイルサイズ）
    final mapPixelWidth = TileMapWidget.roomWidth * tileSize;
    final mapPixelHeight = TileMapWidget.roomHeight * tileSize;

    // プレイヤーの中央位置（画面の中心に来るように使う）
    final playerCenterX = player.x + tileSize / 2;
    final playerCenterY = player.y + tileSize / 2;
    final halfViewW = screenWidth / (2 * zoom);
    final halfViewH = screenHeight / (2 * zoom);

    // プレイヤー中心に合わせてスクロールのオフセットを設定
    double offsetX = playerCenterX - halfViewW;
    double offsetY = playerCenterY - halfViewH;

    // オフセットがマップ範囲を超えないように制限
    offsetX = offsetX.clamp(
      0.0,
      (mapPixelWidth - screenWidth / zoom).clamp(0.0, double.infinity),
    );
    offsetY = offsetY.clamp(
      0.0,
      (mapPixelHeight - screenHeight / zoom).clamp(0.0, double.infinity),
    );

    // 初回描画後に画像のキャッシュとタイルサイズの同期を行う
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheAllImages(context, tileSize);
      if (player.tileSize != tileSize) {
        ref.read(playerProvider).updateTileSize(tileSize);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Transform.scale(
            scale: zoom, // 拡大スケールを適用
            alignment: Alignment.topLeft,
            child: Transform.translate(
              offset: Offset(-offsetX, -offsetY), // プレイヤー位置に応じてスクロール
              child: Stack(
                children: [
                  // ① 床：タイル状に敷き詰められた背景マップ
                  TileMapWidget(
                    tileImageAsset: 'assets/material/prison_floor.png',
                    tileSize: tileSize,
                  ),

                  // ② 背景の壁（プレイヤーの背後にくる）
                  WallLayer(
                    tileSize: tileSize,
                    wallType: WallType.background,
                  ),

                  // ③ プレイヤー・檻など、Z順制御で前後を整理して描画
                  DepthSortedLayer(
                    tileSize: tileSize,
                    player: player,
                    cages: cages,
                    otherObjects: [],
                  ),

                  // ④ 手前の壁（プレイヤーの前に描画される）
                  WallLayer(
                    tileSize: tileSize,
                    wallType: WallType.foreground,
                  ),
                ],
              ),
            ),
          ),

          // ⑤ UI操作層：移動パッドやステータス表示など
          GameUiOverlay(
            onDPad: (dir) {
              // 操作パッドの方向入力時：プレイヤーをその方向に動かす
              ref.read(playerProvider).move(dir);
            },
            onDPadRelease: () {
              // 操作を離したとき：プレイヤーを停止させる
              ref.read(playerProvider).stop();
            },
          ),
        ],
      ),
    );
  }
}