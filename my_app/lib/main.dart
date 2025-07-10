// ファイル名: lib/main.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'ui/screens/game_screen.dart';

void main() {
  runApp(
    ProviderScope(
      child: PinoNoTegamiApp(),
    ),
  );
}

class PinoNoTegamiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ホラーゲーム',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}
