import 'package:socket_io/socket_io.dart';
import 'dart:math' as math;

int turn = 0;
List openValues = [];
List openIds = [];
List visibleList = [];
List isBackList = [];
List valueList = [];
List clientList = [];
main() {
  // Dart server
  var io = Server();
  io.on('connection', (client) {
    print(client.id);
    client.on(
      'initServer',
      (_) {
        if (clientList.isEmpty) {
          turn = 0;
          openValues = [];
          openIds = [];
          visibleList = [];
          isBackList = [];
          valueList = [];
          init();
        }
        clientList.add(client.id);
        final stateMap = <String, dynamic>{
          'turn': clientList[turn],
          'openValues': openValues,
          'openIds': openIds,
          'visibleList': visibleList,
          'isBackList': isBackList,
          'valueList': valueList,
          'token': client.id,
        };
        client.emit('initClient', stateMap);
      },
    );
    client.on(
      'disconnect',
      (_) {
        clientList.remove(client.id);
      },
    );
    client.on(
      'back2server',
      (data) {
        isBackList[data['id']] = false;
        openValues.clear();
        openValues.addAll(data['openValues']);
        openIds.clear();
        openIds.addAll(data['openIds']);
        io.sockets.emit('back2client', data);
      },
    );
    client.on(
      'next2server',
      (_) {
        if (openValues[0] == openValues[1]) {
          visibleList[openIds[0]] = false;
          visibleList[openIds[1]] = false;
          reset();
        } else {
          isBackList[openIds[0]] = true;
          isBackList[openIds[1]] = true;
          reset();
          turn++;
        }
        turn = turn % clientList.length;
        final nextMap = {
          'visibleList': visibleList,
          'isBackList': isBackList,
          'turn': clientList[turn],
        };
        io.sockets.emit('next2client', nextMap);
      },
    );
  });
  io.listen(3000);
}

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
