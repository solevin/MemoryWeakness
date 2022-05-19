import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RoomListViewModel with ChangeNotifier {
    bool isStack = false;
    String roomName = '';
    String correctPassCode = '';
    String inputPassCode = '';
    late QueryDocumentSnapshot<Object?> roomSnapshot;

  void notify() => notifyListeners();
}