// ファイル名: lib/ui/overlay/models/ui_state.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

// 憑依対象キャラの種別
enum ControlledCharacter { honoka, pino, enemy }

// ゲームUIの状態を集約
@immutable
class GameUiState {
  final ControlledCharacter controlledCharacter; // 操作キャラ
  final double honokaHp; // ほのか体力(0-1)
  final double dashStamina; // ダッシュスタミナ(0-1)
  final int possessionTimer; // 憑依残り秒数
  final bool isMenuOpen; // メニュー表示状態
  final bool canPossess; // 憑依ボタン活性化
  final bool canDash; // ダッシュ可能か
  final bool canInvestigate; // 調べるボタン活性化

  const GameUiState({
    required this.controlledCharacter,
    required this.honokaHp,
    required this.dashStamina,
    required this.possessionTimer,
    required this.isMenuOpen,
    required this.canPossess,
    required this.canDash,
    required this.canInvestigate,
  });

  // コピーwith
  GameUiState copyWith({
    ControlledCharacter? controlledCharacter,
    double? honokaHp,
    double? dashStamina,
    int? possessionTimer,
    bool? isMenuOpen,
    bool? canPossess,
    bool? canDash,
    bool? canInvestigate,
  }) {
    return GameUiState(
      controlledCharacter: controlledCharacter ?? this.controlledCharacter,
      honokaHp: honokaHp ?? this.honokaHp,
      dashStamina: dashStamina ?? this.dashStamina,
      possessionTimer: possessionTimer ?? this.possessionTimer,
      isMenuOpen: isMenuOpen ?? this.isMenuOpen,
      canPossess: canPossess ?? this.canPossess,
      canDash: canDash ?? this.canDash,
      canInvestigate: canInvestigate ?? this.canInvestigate,
    );
  }
}

// UI状態のRiverpodプロバイダー
final gameUiStateProvider =
    StateNotifierProvider<GameUiStateNotifier, GameUiState>((ref) {
  return GameUiStateNotifier();
});

class GameUiStateNotifier extends StateNotifier<GameUiState> {
  GameUiStateNotifier()
      : super(const GameUiState(
          controlledCharacter: ControlledCharacter.honoka,
          honokaHp: 0.7,
          dashStamina: 0.8,
          possessionTimer: 10,
          isMenuOpen: false,
          canPossess: true,
          canDash: true,
          canInvestigate: true,
        ));

  // 状態切り替えメソッド例
  void switchCharacter(ControlledCharacter char) {
    state = state.copyWith(controlledCharacter: char);
  }

  void updateHonokaHp(double hp) {
    state = state.copyWith(honokaHp: hp.clamp(0.0, 1.0));
  }

  void updateDashStamina(double stamina) {
    state = state.copyWith(dashStamina: stamina.clamp(0.0, 1.0));
  }

  void updatePossessionTimer(int sec) {
    state = state.copyWith(possessionTimer: sec);
  }

  void setMenuOpen(bool open) {
    state = state.copyWith(isMenuOpen: open);
  }

  void setCanPossess(bool can) {
    state = state.copyWith(canPossess: can);
  }

  void setCanDash(bool can) {
    state = state.copyWith(canDash: can);
  }

  void setCanInvestigate(bool can) {
    state = state.copyWith(canInvestigate: can);
  }
}
