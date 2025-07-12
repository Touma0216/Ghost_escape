import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 檻・扉の状態管理
class CageState extends ChangeNotifier {
  bool isOpened;
  bool isAnimating;

  CageState({this.isOpened = false, this.isAnimating = false});

  Future<void> toggleDoor() async {
    if (isAnimating) return;
    isAnimating = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 180));
    isOpened = !isOpened;
    isAnimating = false;
    notifyListeners();
  }
}

final cageStateProvider = ChangeNotifierProvider<CageState>((ref) => CageState());
