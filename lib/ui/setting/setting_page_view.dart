import 'package:flutter/material.dart';

class SettingPageViewModel with ChangeNotifier {
  var userName = '';
  var isStack = false;

  void notify() => notifyListeners();
}
