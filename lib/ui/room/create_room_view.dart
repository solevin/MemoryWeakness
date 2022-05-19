import 'package:flutter/material.dart';

class CreateRoomViewModel with ChangeNotifier {
    int selectedQuestionQuantity = 3;
    int selectedMaxMember = 3;
    int selectedHP = 3;
    bool isLock = false;
    bool isStack = false;
    String passCode = '';

  void notify() => notifyListeners();
}