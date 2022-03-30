import 'package:flutter/material.dart';

class CreateRoomViewModel with ChangeNotifier {
    var selectedQuestionQuantity = 3;
    var selectedMemberQuantity = 3;

  void notify() => notifyListeners();
}