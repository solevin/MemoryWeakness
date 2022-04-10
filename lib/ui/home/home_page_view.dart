import 'package:flutter/material.dart';

class HomePageViewModel with ChangeNotifier {
    var isStack = false;
    var userName = '';

  void notify() => notifyListeners();
}