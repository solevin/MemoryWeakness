import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SettingViewModel with ChangeNotifier {
  int questionNum = 3;
  bool isCanTap = true;
  String token = '';
  String test = '';
  List openValues = [];
  List openIds = [];
  List visibleList = [];
  List isBackList = [];
  List valueList = [];
  IO.Socket socket = IO.io(
    'http://10.7.11.21:3000',
    IO.OptionBuilder()
        .setTransports(['websocket']) // for Flutter or Dart VM
        .disableAutoConnect() // disable auto-connection
        .setExtraHeaders({'foo': 'bar'}) // optional
        .build(),
  );

  void connect() {
    socket.onDisconnect((_) => print('disconnect'));
    socket.connect();
    socket.on(
      'back2client',
      (data) => {
        isBackList[data['id']] = false,
        openValues.clear(),
        openValues.addAll(data['openValues']),
        openIds.clear(),
        openIds.addAll(data['openIds']),
        notify(),
      },
    );
    socket.on(
      'next2client',
      (data) => {
        visibleList.clear(),
        visibleList.addAll(data['visibleList']),
        isBackList.clear(),
        isBackList.addAll(data['isBackList']),
        openValues = [],
        openIds = [],
        checkTurn(data['turn']),
        notify(),
      },
    );
    socket.on(
      'initClientRoom',
      (data) => {
        openValues.clear(),
        openValues.addAll(data['openValues']),
        openIds.clear(),
        openIds.addAll(data['openIds']),
        visibleList.clear(),
        visibleList.addAll(data['visibleList']),
        isBackList.clear(),
        isBackList.addAll(data['isBackList']),
        valueList.clear(),
        valueList.addAll(data['valueList']),
        checkTurn(data['turn']),
        notify(),
      },
    );
    socket.on(
      'initClient',
      (data) => {
        token = data,
        notify(),
      },
    );
    notify();
  }

  void checkTurn(String turn) {
    if (token == turn) {
      isCanTap = true;
      test = 'your turn';
    } else {
      isCanTap = false;
      test = 'other turn';
    }
  }

  void notify() => notifyListeners();
}
