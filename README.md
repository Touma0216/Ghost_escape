# プロジェクト名: ピノの手紙（Flutter × Riverpod 2D脱出ゲーム）

# 概要
本プロジェクトは、Flutterとhooks_riverpodによって構築された2Dホラー脱出ゲーム「ピノの手紙」の開発リポジトリです。  
プレイヤーは幽霊となったピノを操作し、囚われた少女・ほのかを導き、脱出へと導きます。  
切なさ、守ることしかできないもどかしさ、優しさをテーマにした感情重視のゲームです。

# 世界観・ストーリー
- 舞台は閉ざされた洋館。
- プレイヤーは幽霊ピノとして、物理干渉できないながらも「憑依」によって他者を操作。
- ピノは唯一、ほのかに憑依できる。
- ほのかはピノの存在に気づいていない。
- 敵にも憑依可能。ただし、制限付き（ほのかが敵に発見されていないときに限る）。
- 死の概念はなく、ほのかが倒れるとセーブ地点に戻される。

# ゲームシステム
- 憑依システム：ピノは自分の意思で憑依／離脱できる。
- スタミナ＆体力：ダッシュや憑依にはスタミナや時間制限がある。
- パズルギミック：ibや魔女の家のようなマス操作型の謎解き。
- 敵：音や視覚に反応し、憑依や逃走によって対応可能。
- UI表示：すべて画面にオーバーレイ表示。レスポンシブ対応。

# UI構成（オーバーレイレイヤー）
- 左上：
  - メニューボタン（≡）
  - ほのかの体力バー（緑→赤）
- 右上：
  - 憑依タイマー（憑依中のみ表示）
  - ダッシュスタミナバー（青→黄）
- 左下：
  - 移動用十字スティック（常時表示）
- 右下：
  - アクションボタン4つ（憑依、調べる、ダッシュ、予備）

# ディレクトリ


# 状態管理（hooks_riverpod）
- possessionProvider：現在の操作キャラ（pino, honoka, enemy, none）
- honokaHPProvider：ほのかの体力
- staminaProvider：ダッシュスタミナ
- possessionTimeProvider：憑依制限時間
- その他UI表示制御に必要なboolなどもProviderで制御

# 技術スタック
- Flutter 3.x（UI／ロジック）
- hooks_riverpod（状態管理）
- Dart
- Flame（導入予定、ゲームエンジン部）

# 今後の予定
- 憑依によるギミック解決・敵操作の導入
- セリフ・演出・BGMによるストーリー演出
- セーブ／ロード、ヒント表示機能
- エンディング分岐（予定）

# ライセンス
本プロジェクトは個人開発用です。公開・販売時には適切なライセンスを記述予定。

# ディレクトリ
lib/

  main.dart

  ui/

    game/

      data/

        map_data.dart

      engine/

        depth_sorted_layer.dart

        prison_object_layer.dart

        tile_map_widget.dart

        wall_layer.dart

      models/

        cage_state.dart

        game_state.dart

        player_model.dart

    screens/

      game_screen.dart

      overlay/

        game_ui_overlay.dart

        models/

          ui_state.dart

        widgets/

          action_buttons.dart

          character_icon.dart

          movement_controller.dart

          possession_timer.dart

          status_bar.dart

