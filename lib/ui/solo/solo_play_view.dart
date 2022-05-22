import 'package:flutter/material.dart';

class SoloPlayViewModel with ChangeNotifier {
  List<int> pointList = [];
  List<int> hpList = [];
  List<int> grayList = [];
  List<int> valueList = [];
  List<String> pathList = [];
  List<int> openIds = [];
  List<bool> visibleList = [];
  List<int> knownList = [];
  int turn = 0;
  int maxHP = 0;
  int memberQuantity = 0;
  int questionQuantity = 0;
  String turnText = '';
  bool isVisible = false;


  void init() {}

  void notify() => notifyListeners();
}
