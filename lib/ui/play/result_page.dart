import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:memory_weakness/ui/home/home_page.dart';
import 'package:memory_weakness/ui/play/play_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => initResultPage(roomName));
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('RESULT'),
        ),
        body: Center(
          child: StreamBuilder<QuerySnapshot>(
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
              try {
                final roomSnapshotList = snapshot.data!.docs;
                int roomIndex = 0;
                for (int i = 0; i < roomSnapshotList.length; i++) {
                  if (roomSnapshotList[i].id == roomName) {
                    roomIndex = i;
                  }
                }
                final roomSnapshot = roomSnapshotList[roomIndex];
                return Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200.h,
                        child: ListView(
                          children: ranking(roomSnapshot),
                        ),
                      ),
                      Container(
                        height: 30.h,
                        width: 80.w,
                        color: Colors.amber,
                        child: GestureDetector(
                          onTap: (() async {
                            await backHome(roomName, context);
                          }),
                          child: Center(
                              child: Text(
                            'HOME',
                            style:
                                TextStyle(fontSize: 20.sp, color: Colors.black),
                          )),
                        ),
                      )
                    ],
                  ),
                );
              } catch (e) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

List<Widget> ranking(QueryDocumentSnapshot<Object?> roomSnapshot) {
  List<Widget> ranks = [];
  int memberQuantity = roomSnapshot['members'].length;
  List<int> immutablePoints = roomSnapshot['points'].cast<int>();
  List<int> variablePoints = roomSnapshot['points'].cast<int>();
  final names = roomSnapshot['names'];
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

Future<void> backHome(String roomName, BuildContext context) async {
  final roomQuerySnapshot =
      await FirebaseFirestore.instance.collection('room').get();
  final roomSnapshotList = roomQuerySnapshot.docs;
  int roomIndex = 0;
  for (int i = 0; i < roomSnapshotList.length; i++) {
    if (roomSnapshotList[i].id == roomName) {
      roomIndex = i;
    }
  }
  final uid = FirebaseAuth.instance.currentUser!.uid;
  List<String> memberList;
  memberList = roomSnapshotList[roomIndex]['members'].cast<String>();
  memberList.remove(uid);
  final deletedMemberList = memberList.toSet().toList();
  final preference = await SharedPreferences.getInstance();
  final userName = preference.getString("userName");
  List<String> nameList = roomSnapshotList[roomIndex]['names'].cast<String>();
  nameList.remove(userName);
  final deletedNameList = memberList.toSet().toList();
  await FirebaseFirestore.instance
      .collection('room')
      .doc(roomSnapshotList[roomIndex].id)
      .update({
    'members': deletedMemberList,
    'names': deletedNameList,
  });
  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .update({
    'roomID': "",
  });
  if (memberList.isEmpty) {
    await FirebaseFirestore.instance
        .collection('room')
        .doc(roomSnapshotList[roomIndex].id)
        .delete();
  }
  Navigator.of(context).push<dynamic>(
    HomePage.route(),
  );
}

Future<void> initResultPage(String roomName) async {
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

  final uid = FirebaseAuth.instance.currentUser!.uid;
}

class RoomState{
  List<String>? members;
  List<String>? names;
  List<int>? points;
}
