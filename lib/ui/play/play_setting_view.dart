import 'dart:math' as math;
import 'package:flutter/material.dart';

class SettingViewModel with ChangeNotifier {
  int questionNum = 3;
  bool isCanTap = true;
  List<int> openValues = [];
  List<int> openIds = [];
  List<bool> visibleList = [];
  List<bool> isBackList = [];
  List<int> valueList = [];

  void start() {
    reset();
    isBackList = [];
    visibleList = [];
    final rand = math.Random();
    for (int i = 0; i < questionNum; i++) {
      visibleList.add(true);
      visibleList.add(true);
      isBackList.add(true);
      isBackList.add(true);
      valueList.add(i);
      valueList.add(i);
    }
    for (var i = questionNum - 1; i > 0; i--) {
      final n = rand.nextInt(i + 1);
      final temp = valueList[i];
      valueList[i] = valueList[n];
      valueList[n] = temp;
    }
    notify();
  }

  void reset(){
    openValues = [];
    openIds = [];
    isCanTap = true;
  }

  void notify() => notifyListeners();
}
