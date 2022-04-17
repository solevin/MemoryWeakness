import 'package:flutter/material.dart';

class ResultPageViewModel with ChangeNotifier {
  var isInitialized = false;

  void notify() => notifyListeners();
}
