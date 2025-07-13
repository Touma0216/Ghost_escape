// ファイルパス: lib/main.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'ui/screens/game_screen.dart';

/// アプリのエントリーポイント。
/// runApp() に渡すウィジェットのルートとして、RiverpodのProviderScopeでラップして状態管理を可能にしている。
void main() {
  runApp(
    ProviderScope( // Riverpodの状態管理を全体に適用するためのルートスコープ
      child: PinoNoTegamiApp(),
    ),
  );
}

/// アプリ全体のルートとなるWidget。
/// Material3をベースにしたテーマ設定と、GameScreenを初期表示にしている。
class PinoNoTegamiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ホラーゲーム', // アプリタイトル（Androidのタスク切り替えなどに表示される）
      theme: ThemeData(
        useMaterial3: true, // Material3のスタイルを有効化
        fontFamily: 'Roboto', // 使用するフォントファミリー
        scaffoldBackgroundColor: Colors.white, // 全体の背景色（ゲーム中はあまり見えない）
      ),
      debugShowCheckedModeBanner: false, // デバッグモードバナーを非表示
      home: GameScreen(), // アプリ起動時に表示される画面（ゲーム本体）
    );
  }
}
