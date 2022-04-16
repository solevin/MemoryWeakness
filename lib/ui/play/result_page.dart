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
    final roomName = ModalRoute.of(context)!.settings.arguments;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: () async {
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
              try {
                memberList =
                    roomSnapshotList[roomIndex]['members'].cast<String>();
              } catch (e) {
                memberList = [];
              }
              memberList.remove(uid);
              final deletedMemberList = memberList.toSet().toList();
              final preference = await SharedPreferences.getInstance();
              final userName = preference.getString("userName");
              List<String> nameList =
                  roomSnapshotList[roomIndex]['names'].cast<String>();
              nameList.remove(userName);
              final deletedNameList = memberList.toSet().toList();
              await FirebaseFirestore.instance
                  .collection('room')
                  .doc(roomSnapshotList[roomIndex].id)
                  .update({
                'members': deletedMemberList,
                'names': deletedNameList,
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
            },
          ),
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
  return Center(
    child: Text(
      '$rank. $userName : $point',
      style: TextStyle(fontSize: 20.sp, color: Colors.black),
    ),
  );
}
