import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:memory_weakness/ui/room/create_room_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memory_weakness/ui/room/standby_room_page.dart';
import 'package:memory_weakness/ui/room/room_list_view.dart';
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
      body: Consumer<RoomListViewModel>(builder: (context, model, _) {
        return Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildTaskList(context, model),
              ],
            ),
            inputPassCode(context, model),
          ],
        );
      }),
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

Widget buildTaskList(BuildContext context, RoomListViewModel model) {
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
          children: presenceViewList(roomSnapshotList, context, model),
        ),
      );
    },
  );
}

List<Widget> presenceViewList(
    List<QueryDocumentSnapshot<Object?>> roomSnapshotList,
    BuildContext context,
    RoomListViewModel model) {
  var resultList = <Widget>[];
  for (int i = 0; i < roomSnapshotList.length; i++) {
    final isDisplay = roomSnapshotList[i]['isDisplay'];
    if (isDisplay) {
      resultList.add(presenceView(roomSnapshotList[i], context, model));
    }
  }
  return resultList;
}

Widget presenceView(QueryDocumentSnapshot<Object?> roomSnapshot,
    BuildContext context, RoomListViewModel model) {
  final maxMembers = roomSnapshot['maxMembers'].toString();
  final questionQuantity = roomSnapshot['questionQuantity'].toString();
  final isLocked = roomSnapshot['passCode'].toString().length == 4;
  final roomName = roomSnapshot.id;
  return InkWell(
    child: SizedBox(
      width: 200.w,
      height: 50.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
              'questionQuantity : $questionQuantity  maxMembers : $maxMembers'),
          Icon(isLocked ? Icons.lock : null),
        ],
      ),
    ),
    onTap: () async {
      final currentMemberQuantity = roomSnapshot['members'].length;
      final maxMemberQuantity = roomSnapshot['maxMembers'];
      if (currentMemberQuantity > 0 &&
          currentMemberQuantity < maxMemberQuantity) {
        if (!isLocked) {
          joinRoom(roomSnapshot, roomName, context);
        } else {
          model.isStack = true;
          model.roomName = roomName;
          model.correctPassCode = roomSnapshot['passCode'].toString();
          model.roomSnapshot = roomSnapshot;
          model.notify();
        }
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

Widget inputPassCode(BuildContext context, RoomListViewModel model) {
  return Visibility(
    visible: model.isStack,
    child: Center(
      child: Container(
        height: 230.h,
        width: 320.w,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              spreadRadius: 0.8,
              blurRadius: 8.0,
              offset: Offset(10, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'PassCode',
              style: TextStyle(
                fontSize: 20.sp,
                color: Colors.black,
              ),
            ),
            SizedBox(
              height: 60.h,
              width: 280.w,
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                maxLength: 4,
                style: TextStyle(
                  fontSize: 20.sp,
                  color: Colors.black,
                ),
                onChanged: (text) {
                  model.inputPassCode = text;
                  model.notify();
                },
              ),
            ),
            SizedBox(
              height: 40.h,
              width: 100.w,
              child: ElevatedButton(
                onPressed: model.inputPassCode.length != 4
                    ? null
                    : () async {
                        if (model.correctPassCode == model.inputPassCode) {
                          model.isStack = false;
                          joinRoom(model.roomSnapshot, model.roomName, context);
                        } else {
                          model.isStack = false;
                          model.inputPassCode = '';
                          model.correctPassCode = '';
                          model.notify();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  primary: Colors.yellow,
                ),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 20.sp,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.r),
              child: SizedBox(
                height: 40.h,
                width: 100.w,
                child: ElevatedButton(
                  onPressed: () {
                    model.isStack = false;
                    model.inputPassCode = '';
                    model.correctPassCode = '';
                    model.notify();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.yellow,
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
