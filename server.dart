import 'package:socket_io/socket_io.dart';
import 'dart:math' as math;

bool isCanTap = true;
List openValues = [];
List openIds = [];
List visibleList = [];
List isBackList = [];
List valueList = [];
main() {
  // Dart server
  var io = Server();
  var clientsNum = 0;
  io.on('connection', (client) {
    print(clientsNum);
    print(isCanTap);
    print(openValues);
    print(openIds);
    print(visibleList);
    print(isBackList);
    print(valueList);
    client.on(
      'initServer',
      (_) {
        if (clientsNum == 0) {
          print('first');
          isCanTap = true;
          openValues = [];
          openIds = [];
          visibleList = [];
          isBackList = [];
          valueList = [];
          init();
        }
        final stateMap = <String, dynamic>{
          'isCanTap': isCanTap,
          'openValues': openValues,
          'openIds': openIds,
          'visibleList': visibleList,
          'isBackList': isBackList,
          'valueList': valueList,
        };
          print(isCanTap);
          print(openValues);
          print(openIds);
          print(visibleList);
          print(isBackList);
          print(valueList);
        io.sockets.emit('initClient', stateMap);
        clientsNum++;
      },
    );
    client.on(
      'disconnect',
      (_) {
        clientsNum--;
      },
    );
    client.on(
      'back2server',
      (data) {
        print('back2server');
        isBackList[data['id']] = false;
        openValues.clear();
        openValues.addAll(data['openValues']);
        openIds.clear();
        openIds.addAll(data['openIds']);
        isCanTap = data['isCanTap'];
        print(isCanTap);
        print(openValues);
        print(openIds);
        print(visibleList);
        print(isBackList);
        print(valueList);
        io.sockets.emit('back2client', data);
      },
    );
    client.on(
      'next2server',
      (_) {
        print('next2server');
        print(_);
        if (openValues[0] == openValues[1]) {
          visibleList[openIds[0]] = false;
          visibleList[openIds[1]] = false;
          reset();
        } else {
          isBackList[openIds[0]] = true;
          isBackList[openIds[1]] = true;
          reset();
        }
        final nextMap = {
          'visibleList': visibleList,
          'isBackList': isBackList,
        };
        print(isCanTap);
        print(openValues);
        print(openIds);
        print(visibleList);
        print(isBackList);
        print(valueList);
        io.sockets.emit('next2client', nextMap);
      },
    );
  });
  io.listen(3000);
}

void reset() {
  openValues = [];
  openIds = [];
  isCanTap = true;
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
