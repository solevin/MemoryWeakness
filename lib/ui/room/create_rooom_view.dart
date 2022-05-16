import 'package:flutter/material.dart';

class CreateRoomViewModel with ChangeNotifier {
    var selectedQuestionQuantity = 3;
    var selectedMaxMember = 3;
    var selectedHP = 3;

  void notify() => notifyListeners();
}