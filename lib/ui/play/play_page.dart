import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayPage extends StatelessWidget {
  static Route<dynamic> route({
    @required String? roomName,
  }) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => const PlayPage(),
      settings: RouteSettings(arguments: roomName),
    );
  }

  const PlayPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final roomName = ModalRoute.of(context)!.settings.arguments;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('room').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            final roomSnapshotList = snapshot.data!.docs;
            int roomIndex = 0;
            for (int i = 0; i < roomSnapshotList.length; i++) {
              if (roomSnapshotList[i].id == roomName) {
                roomIndex = i;
              }
            }
            final roomSnapshot = roomSnapshotList[roomIndex];
            List<int> openIds = roomSnapshot['openIds'].cast<int>();
            final isVisible = openIds.length == 2;
            final turnText = roomSnapshot['turn'] + 'のターン';
            return Padding(
              padding: EdgeInsets.fromLTRB(0, 30.h, 0, 0),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.r),
                    child: Center(
                      child: Text(
                        turnText,
                        style: TextStyle(fontSize: 15.sp, color: Colors.black),
                      ),
                    ),
                  ),
                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 8.h,
                    children: panels(roomSnapshot),
                  ),
                  Visibility(
                    child: checkButton(roomSnapshot),
                    visible: isVisible,
                  ),
                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 8.h,
                    children: scores(roomSnapshot),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

List<Widget> panels(QueryDocumentSnapshot<Object?> roomSnapshot) {
  var panelList = <Widget>[];
  for (int i = 0; i < roomSnapshot['questionQuantity'] * 2; i++) {
    panelList.add(eachPanel(roomSnapshot, i));
  }
  return panelList;
}

Widget eachPanel(QueryDocumentSnapshot<Object?> roomSnapshot, int id) {
  List<int> openList = roomSnapshot['openIds'].cast<int>();
  if (roomSnapshot['visibleList'][id] == false) {
    return Padding(
      padding: EdgeInsets.all(8.r),
      child: SizedBox(
        width: 40.r,
        height: 40.r,
      ),
    );
  } else {
    if (openList.contains(id)) {
      return Padding(
        padding: EdgeInsets.all(8.r),
        child: display(roomSnapshot, id),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(8.r),
        child: back(roomSnapshot, id),
      );
    }
  }
}

Widget display(QueryDocumentSnapshot<Object?> roomSnapshot, int id) {
  return SizedBox(
    width: 40.r,
    height: 40.r,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.amber,
      ),
      child: Text(roomSnapshot['values'][id].toString()),
    ),
  );
}

Widget back(QueryDocumentSnapshot<Object?> roomSnapshot, int id) {
  List<int> openIds = roomSnapshot['openIds'].cast<int>();
  return SizedBox(
    width: 40.r,
    height: 40.r,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: GestureDetector(
        onTap: () async {
          final preference = await SharedPreferences.getInstance();
          final userName = preference.getString("userName");
          if (roomSnapshot['turn'] == userName && openIds.length < 2) {
            openIds.add(id);
            await FirebaseFirestore.instance
                .collection('room')
                .doc(roomSnapshot.id)
                .update({
              'openIds': openIds,
            });
          }
        },
      ),
    ),
  );
}

Widget checkButton(QueryDocumentSnapshot<Object?> roomSnapshot) {
  return Padding(
    padding: EdgeInsets.all(8.r),
    child: Container(
      height: 30.h,
      width: 60.w,
      color: Colors.purple,
      child: GestureDetector(
        child: Text(
          'OK',
          style: TextStyle(fontSize: 20.sp, color: Colors.white),
        ),
        onTap: () async {
          List<bool> visibleList = roomSnapshot['visibleList'].cast<bool>();
          List<int> openIds = roomSnapshot['openIds'].cast<int>();
          List<int> values = roomSnapshot['values'].cast<int>();
          List<int> points = roomSnapshot['points'].cast<int>();
          List<String> leaves = roomSnapshot['leaves'].cast<String>();
          List<String> names = roomSnapshot['names'].cast<String>();
          List<String> members = roomSnapshot['members'].cast<String>();
          var turn = roomSnapshot['turn'];
          if (values[openIds[0]] == values[openIds[1]]) {
            print('aa');
            visibleList[openIds[0]] = false;
            visibleList[openIds[1]] = false;
            final playerIndex = names.indexOf(turn);
            final addedPoint = points[playerIndex] + 1;
            points[playerIndex] = addedPoint;
          } else {
              var nextTurnIndex = (names.indexOf(turn) + 1) % names.length;
              turn = names[nextTurnIndex];
              print(turn);
            while (leaves.contains(members[names.indexOf(turn)])) {
              nextTurnIndex = (names.indexOf(turn) + 1) % names.length;
              turn = names[nextTurnIndex];
            }
          }
          await FirebaseFirestore.instance
              .collection('room')
              .doc(roomSnapshot.id)
              .update({
            'points': points,
            'openIds': [],
            'visibleList': visibleList,
            'turn': turn,
          });
        },
      ),
    ),
  );
}

List<Widget> scores(QueryDocumentSnapshot<Object?> roomSnapshot) {
  var scoreList = <Widget>[];
  for (int i = 0; i < roomSnapshot['members'].length; i++) {
    scoreList.add(eachScore(roomSnapshot, i));
  }
  return scoreList;
}

Widget eachScore(QueryDocumentSnapshot<Object?> roomSnapshot, int id) {
  final name = roomSnapshot['names'][id];
  final point = roomSnapshot['points'][id];
  final leaves = roomSnapshot['leaves'].cast<String>();
  final uid = roomSnapshot['members'][id];
  final isLeaved = leaves.indexOf(uid) >= 0;

  return Text(
    '$name : $point',
    style: TextStyle(
        fontSize: 20.sp, color: isLeaved ? Colors.grey : Colors.black),
  );
}
