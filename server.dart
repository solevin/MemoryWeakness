import 'package:socket_io/socket_io.dart';
import 'dart:math' as math;

Map<String, RoomState> roomMap = {};
main() {
  var io = Server();
  io.on('connection', (client) {
    var roomId = '-1';
    client.emit('initClient',client.id);
    client.on(
      'initServerRoom',
      (_) {
        var room = RoomState();
        final roomName = setRoomName();
        room.init();
        room.clientList.add(client.id);
        roomMap.addAll({roomName : room});
        roomId = roomName;
        client.join(roomName);
        final returnMap = {
          'openValues':room.openValues,
          'openIds':room.openIds,
          'visibleList':room.visibleList,
          'isBackList':room.isBackList,
          'valueList':room.valueList,
          'turn':room.clientList[room.turn],
        };
        client.emit('initClientRoom', returnMap);
      },
    );
    client.on(
      'joinServerRoom',
      (joinId) {
        roomId = joinId;
        var afterChange = roomMap[roomId];
        afterChange!.clientList.add(client.id);
        roomMap.update(roomId, (value) => afterChange);
        client.join(roomId);
        final returnMap = {
          'openValues':afterChange.openValues,
          'openIds':afterChange.openIds,
          'visibleList':afterChange.visibleList,
          'isBackList':afterChange.isBackList,
          'valueList':afterChange.valueList,
          'turn':afterChange.clientList[afterChange.turn],
        };
        client.emit('initClientRoom', returnMap);
      },
    );
    client.on(
      'disconnect',
      (_) {
        var afterChange = roomMap[roomId];
        afterChange!.clientList.remove(client.id);
        roomMap.update(roomId, (value) => afterChange);
        if (afterChange.clientList.isEmpty) {
          roomMap.remove(roomId);
        }
      },
    );
    client.on(
      'back2server',
      (data) {
        var afterChange = roomMap[roomId];
        afterChange!.isBackList[data['id']] = false;
        afterChange.openValues.clear();
        afterChange.openValues.addAll(data['openValues']);
        afterChange.openIds.clear();
        afterChange.openIds.addAll(data['openIds']);
        roomMap.update(roomId, (value) => afterChange);
        final returnMap = {
          'id': data['id'],
          'openValues': afterChange.openValues,
          'openIds': afterChange.openIds,
        };
        io.sockets.to(roomId).emit('back2client', returnMap);
      },
    );
    client.on(
      'next2server',
      (_) {
        var afterChange = roomMap[roomId];
        if (afterChange!.openValues[0] == afterChange.openValues[1]) {
          afterChange.visibleList[afterChange.openIds[0]] = false;
          afterChange.visibleList[afterChange.openIds[1]] = false;
          afterChange.reset();
        } else {
          afterChange.isBackList[afterChange.openIds[0]] = true;
          afterChange.isBackList[afterChange.openIds[1]] = true;
          afterChange.reset();
          afterChange.turn++;
        }
        afterChange.turn = afterChange.turn % afterChange.clientList.length;
        roomMap.update(roomId, (value) => afterChange);
        final returnMap = {
          'visibleList': afterChange.visibleList,
          'isBackList': afterChange.isBackList,
          'turn': afterChange.clientList[afterChange.turn],
        };
        io.sockets.to(roomId).emit('next2client', returnMap);
      },
    );
  });
  io.listen(3000);
}

class RoomState {
  int turn = 0;
  List openValues = [];
  List openIds = [];
  List visibleList = [];
  List isBackList = [];
  List valueList = [];
  List clientList = [];

  void reset() {
    openValues = [];
    openIds = [];
  }

  void init() {
    reset();
    isBackList = [];
    visibleList = [];
    final rand = math.Random();
    for (int i = 0; i < 3; i++) {
      visibleList.add(true);
      visibleList.add(true);
      isBackList.add(true);
      isBackList.add(true);
      valueList.add(i);
      valueList.add(i);
    }
    for (var i = 3 - 1; i > 0; i--) {
      final n = rand.nextInt(i + 1);
      final temp = valueList[i];
      valueList[i] = valueList[n];
      valueList[n] = temp;
    }
  }
}

String setRoomName() {
  for (int i = 0;; i++) {
    if (roomMap.containsKey(i.toString()) == false) {
      return i.toString();
    }
  }
}
