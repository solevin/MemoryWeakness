import 'package:flutter/material.dart';

class SettingCpuViewModel with ChangeNotifier {
  int selectedQuestionQuantity = 3;
  int selectedHP = 3;
  int cpuQuantity = 0;
  List<int> difficultyList = [1, 1, 1];

  void init() {
    selectedQuestionQuantity = 3;
    selectedHP = 3;
    cpuQuantity = 0;
    difficultyList = [1, 1, 1];
  }

  void notify() => notifyListeners();
}
