import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 状態管理
class CageState extends ChangeNotifier {
  bool isOpened;
  bool isAnimating;

  CageState({this.isOpened = false, this.isAnimating = false});

  Future<void> toggleDoor() async {
    isAnimating = true;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 180));
    isOpened = !isOpened;
    isAnimating = false;
    notifyListeners();
  }
}

// Provider
final cageStateProvider = ChangeNotifierProvider<CageState>((ref) => CageState());
