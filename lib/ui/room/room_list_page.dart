import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:memory_weakness/ui/room/create_room_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memory_weakness/ui/room/standby_room_page.dart';
import 'package:provider/provider.dart';

class RoomPage extends StatelessWidget {
  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(
      builder: (_) => const RoomPage(),
    );
  }

  const RoomPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Column(children: roomCard(model, context)),
            buildTaskList(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push<dynamic>(
            CreateRoomPage.route(),
          );
        },
      ),
    );
  }
}

Widget buildTaskList(BuildContext context) {
  return StreamBuilder<QuerySnapshot>(
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
      return SizedBox(
        height: 400.h,
        child: ListView(
          children: presenceViewList(roomSnapshotList, context),
        ),
      );
    },
  );
}

List<Widget> presenceViewList(
    List<QueryDocumentSnapshot<Object?>> roomSnapshotList,
    BuildContext context) {
  var resultList = <Widget>[];
  for (int i = 0; i < roomSnapshotList.length; i++) {
    final isDisplay = roomSnapshotList[i]['isDisplay'];
    if (isDisplay) {
      resultList.add(presenceView(roomSnapshotList[i], context));
    }
  }
  return resultList;
}

Widget presenceView(
    QueryDocumentSnapshot<Object?> roomSnapshot, BuildContext context) {
  final maxMembers = roomSnapshot['maxMembers'].toString();
  final questionQuantity = roomSnapshot['questionQuantity'].toString();
  final roomName = roomSnapshot.id;
  return InkWell(
    child: SizedBox(
      width: 200.w,
      height: 50.h,
      child: Center(
        child: Text(
            'questionQuantity : $questionQuantity  maxMembers : $maxMembers'),
      ),
    ),
    onTap: () async {
      final currentMemberQuantity = roomSnapshot['members'].length;
      final maxMemberQuantity = roomSnapshot['maxMembers'];
      if (currentMemberQuantity > 0 &&
          currentMemberQuantity < maxMemberQuantity) {
        joinRoom(roomSnapshot, roomName, context);
      }
    },
  );
}

Future<void> joinRoom(QueryDocumentSnapshot<Object?> roomSnapshot,
    String roomName, BuildContext context) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  List<String> memberList = roomSnapshot['members'].cast<String>();
  List<String> nameList = roomSnapshot['names'].cast<String>();
  List<bool> standbyList = roomSnapshot['standbyList'].cast<bool>();
  List<int> pointList = roomSnapshot['points'].cast<int>();
  List<int> HPs = roomSnapshot['HPs'].cast<int>();
  int maxHP = roomSnapshot['maxHP'];
  memberList.add(uid);
  final addedMemberList = memberList.toSet().toList();

  final preference = await SharedPreferences.getInstance();
  final userName = preference.getString("userName");
  nameList.add(userName!);
  final addedNameList = nameList.toSet().toList();

  standbyList.add(false);
  pointList.add(0);
  HPs.add(maxHP);
  await FirebaseFirestore.instance.collection('room').doc(roomName).update({
    'members': addedMemberList,
    'names': addedNameList,
    'standbyList': standbyList,
    'points': pointList,
    'HPs': HPs,
  });
  await FirebaseFirestore.instance.collection('users').doc(uid).update({
    'roomID': roomName,
  });
  Navigator.of(context).push<dynamic>(
    StandbyRoomPage.route(roomName: roomName),
  );
}
