import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:memory_weakness/ui/room/create_room_page.dart';
import 'package:memory_weakness/ui/room/standby_room_page.dart';
import 'package:memory_weakness/ui/home/home_page.dart';
import 'package:memory_weakness/ui/play/result_page_view.dart';
import 'package:memory_weakness/ui/room/room_list_page.dart';
import 'package:provider/provider.dart';

class ResultPage extends StatelessWidget {
  static Route<dynamic> route({
    @required String? roomName,
  }) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => const ResultPage(),
      settings: RouteSettings(arguments: roomName),
    );
  }

  const ResultPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final roomName = ModalRoute.of(context)!.settings.arguments as String;
    late RoomState roomState;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      roomState = await initResultPage(roomName);
      context.read<ResultPageViewModel>().isInitialized = true;
      context.read<ResultPageViewModel>().notify();
    });
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('RESULT'),
        ),
        body: Center(
          child: Center(
            child: Column(
              children: [
                Consumer<ResultPageViewModel>(
                  builder: (context, model, _) {
                    try {
                      return SizedBox(
                        height: 200.h,
                        child: ListView(children: ranking(roomState)),
                      );
                    } catch (e) {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(8.r),
                  child: Container(
                    height: 30.h,
                    width: 80.w,
                    color: Colors.amber,
                    child: GestureDetector(
                      onTap: (() async {
                        replay(roomState, context);
                      }),
                      child: Center(
                          child: Text(
                        'REPLAY',
                        style: TextStyle(fontSize: 20.sp, color: Colors.black),
                      )),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.r),
                  child: Container(
                    height: 30.h,
                    width: 80.w,
                    color: Colors.amber,
                    child: GestureDetector(
                      onTap: (() async {
                        await backHome(roomState, context);
                      }),
                      child: Center(
                          child: Text(
                        'HOME',
                        style: TextStyle(fontSize: 20.sp, color: Colors.black),
                      )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<Widget> ranking(RoomState roomState) {
  List<Widget> ranks = [];
  int memberQuantity = roomState.members.length;
  List<int> immutablePoints = roomState.points;
  List<int> variablePoints = roomState.points;
  final names = roomState.names;
  for (int i = 0; i < memberQuantity; i++) {
    final maxValue = variablePoints.reduce(max);
    final tmpIndex = immutablePoints.indexOf(maxValue);
    ranks.add(displayRank(i + 1, names[tmpIndex], maxValue));
  }
  return ranks;
}

Widget displayRank(int rank, String userName, int point) {
  return Padding(
    padding: EdgeInsets.all(8.r),
    child: Center(
      child: Text(
        '$rank. $userName : $point',
        style: TextStyle(fontSize: 20.sp, color: Colors.black),
      ),
    ),
  );
}

Future<void> backHome(RoomState roomState, BuildContext context) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  List<String> leaveList = roomState.leaves;
  leaveList.add(uid);
  if (leaveList.length == roomState.members.length) {
    await FirebaseFirestore.instance
        .collection('room')
        .doc(roomState.roomName)
        .delete();
  } else {
    await FirebaseFirestore.instance
        .collection('room')
        .doc(roomState.roomName)
        .update({
      'leaves': leaveList,
    });
  }
  await FirebaseFirestore.instance.collection('users').doc(uid).update({
    'roomID': "",
  });
  Navigator.of(context).push<dynamic>(
    HomePage.route(),
  );
}

Future<RoomState> initResultPage(String roomName) async {
  final roomQuerySnapshot =
      await FirebaseFirestore.instance.collection('room').get();
  final roomSnapshotList = roomQuerySnapshot.docs;
  int roomIndex = 0;
  for (int i = 0; i < roomSnapshotList.length; i++) {
    if (roomSnapshotList[i].id == roomName) {
      roomIndex = i;
    }
  }
  final roomSnapshot = roomSnapshotList[roomIndex];
  final roomState = RoomState(
    roomName,
    roomSnapshot['members'].cast<String>(),
    roomSnapshot['names'].cast<String>(),
    roomSnapshot['points'].cast<int>(),
    roomSnapshot['leaves'].cast<String>(),
    roomSnapshot['maxMembers'],
    roomSnapshot['questionQuantity'],
    roomSnapshot['maxHP'],
  );
  return roomState;
}

Future<void> replay(RoomState roomState, BuildContext context) async {
  final roomQuerySnapshot =
      await FirebaseFirestore.instance.collection('room').get();
  final newRoomName = roomState.roomName + '+';
  final roomSnapshotList = roomQuerySnapshot.docs;
  final uid = FirebaseAuth.instance.currentUser!.uid;
  List<String> leaveList = roomState.leaves;
  leaveList.add(uid);
  if (leaveList.length == roomState.members.length) {
    await FirebaseFirestore.instance
        .collection('room')
        .doc(roomState.roomName)
        .delete();
  } else {
    await FirebaseFirestore.instance
        .collection('room')
        .doc(roomState.roomName)
        .update({
      'leaves': leaveList,
    });
  }
  for (int i = 0; i < roomSnapshotList.length; i++) {
    if (roomSnapshotList[i].id == newRoomName) {
      joinRoom(roomSnapshotList[i], newRoomName, context);
    }
  }
  createRoom(roomState.questionQuantity, roomState.maxMembers, roomState.maxHP,
      newRoomName, '');
  int i = 0;
  while (i < 10000) {
    try {
      await FirebaseFirestore.instance
          .collection('room')
          .doc(newRoomName)
          .update({
        'isDisplay': false,
      });
      break;
    } catch (e) {
      Future.delayed(const Duration(milliseconds: 1));
      i++;
    }
  }
  Navigator.of(context).push<dynamic>(
    StandbyRoomPage.route(roomName: newRoomName),
  );
}

class RoomState {
  String roomName;
  List<String> members;
  List<String> names;
  List<int> points;
  List<String> leaves;
  int maxMembers;
  int questionQuantity;
  int maxHP;
  RoomState(this.roomName, this.members, this.names, this.points, this.leaves,
      this.maxMembers, this.questionQuantity, this.maxHP);
}
