import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:memory_weakness/ui/play/play_setting_view.dart';
import 'package:memory_weakness/ui/play/play_page.dart';
import 'package:memory_weakness/ui/room/createroom_page.dart';
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
      body: Consumer<SettingViewModel>(
        builder: (context, model, _) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Column(children: roomCard(model, context)),
                buildTaskList(context),
                SizedBox(
                  height: 30.h,
                  width: 100.w,
                  child: GestureDetector(
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.red),
                      child: Center(
                          child: Text(
                        '更新',
                        style: TextStyle(fontSize: 20.sp, color: Colors.white),
                      )),
                    ),
                    onTap: () async {
                      model.socket.emit('getRoom');
                      model.isComplete = false;
                      while (model.isComplete == false) {
                        await Future.delayed(const Duration(milliseconds: 100));
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.h),
                  child: SizedBox(
                    height: 30.h,
                    width: 100.w,
                    child: GestureDetector(
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: Colors.red),
                        child: Center(
                          child: Text(
                            'set',
                            style:
                                TextStyle(fontSize: 20.sp, color: Colors.white),
                          ),
                        ),
                      ),
                      onTap: () async {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .add({
                          'price': 650,
                          'date': FieldValue.serverTimestamp()
                        });
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.h),
                  child: SizedBox(
                    height: 30.h,
                    width: 100.w,
                    child: GestureDetector(
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: Colors.red),
                        child: Center(
                          child: Text(
                            'uid',
                            style:
                                TextStyle(fontSize: 20.sp, color: Colors.white),
                          ),
                        ),
                      ),
                      onTap: () async {
                        String uid = FirebaseAuth.instance.currentUser!.uid;
                        print(uid);
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<SettingViewModel>(
        builder: (context, model, _) {
          return FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push<dynamic>(
                CreateRoomPage.route(),
              );
            },
          );
        },
      ),
    );
  }
}

List<Widget> roomCard(SettingViewModel model, BuildContext context) {
  var panelList = <Widget>[];
  for (int i = 0; i < model.roomList.length; i++) {
    panelList.add(panel(model.roomList[i], model, context));
  }
  return panelList;
}

Widget panel(String name, SettingViewModel model, BuildContext context) {
  return SizedBox(
    child: Card(
      child: GestureDetector(
        child: Text(name),
        onTap: () {
          model.socket.emit('joinServerRoom', name);
          Navigator.of(context).push<dynamic>(
            PlayPage.route(),
          );
        },
      ),
    ),
    height: 50.h,
    width: 200.w,
  );
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
    final currentMemberQuantity = roomSnapshotList[i]['members'].length;
    final maxMemberQuantity = roomSnapshotList[i]['maxMembers'];
    if (currentMemberQuantity > 0 &&
        currentMemberQuantity < maxMemberQuantity) {
      resultList.add(presenceView(roomSnapshotList[i], context));
    }
  }
  return resultList;
}

Widget presenceView(
    QueryDocumentSnapshot<Object?> roomSnapshot, BuildContext context) {
  final maxMembers = roomSnapshot['maxMembers'].toString();
  final questionQuantity = roomSnapshot['questionQuantity'].toString();
  final memberList = roomSnapshot['members'] as List;
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
      final uid = FirebaseAuth.instance.currentUser!.uid;
      memberList.add(uid);
      final addedMemberList = memberList.toSet().toList();
      await FirebaseFirestore.instance
          .collection('room')
          .doc(roomSnapshot.id)
          .update({
        'members': addedMemberList,
      });
      Navigator.of(context).push<dynamic>(
        StandbyRoomPage.route(roomName: roomSnapshot.id),
      );
    },
  );
}
