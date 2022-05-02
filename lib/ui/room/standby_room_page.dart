import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:memory_weakness/ui/home/home_page.dart';
import 'package:memory_weakness/ui/play/play_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StandbyRoomPage extends StatelessWidget {
  static Route<dynamic> route({
    @required String? roomName,
  }) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => const StandbyRoomPage(),
      settings: RouteSettings(arguments: roomName),
    );
  }

  const StandbyRoomPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final roomName = ModalRoute.of(context)!.settings.arguments as String;
    var isFinished = false;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
            leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () async {
            leaveRoom(roomName, context);
          },
        )),
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
                final uid = FirebaseAuth.instance.currentUser!.uid;
                final roomSnapshot = roomSnapshotList[roomIndex];
                final names = roomSnapshot['names'].cast<String>();
                final members = roomSnapshot['members'].cast<String>();
                final standbyList = roomSnapshot['standbyList'].cast<bool>();
                if (!standbyList.contains(false) && !isFinished) {
                  isFinished = true;
                  WidgetsBinding.instance!.addPostFrameCallback(
                    (_) => Navigator.of(context).pushAndRemoveUntil<dynamic>(
                      PlayPage.route(roomName: roomName),
                      (_) => false,
                    ),
                  );
                }
                final myIndex = members.indexOf(uid);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 400.h,
                      child: ListView(
                        children: memberViewList(names, standbyList),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.h),
                      child: SizedBox(
                        height: 30.h,
                        width: 100.w,
                        child: GestureDetector(
                          child: DecoratedBox(
                            decoration: const BoxDecoration(color: Colors.red),
                            child: Center(
                              child: Text(
                                standbyList[myIndex] ? 'cancel' : 'OK',
                                style: TextStyle(
                                    fontSize: 20.sp, color: Colors.white),
                              ),
                            ),
                          ),
                          onTap: () async {
                            var isDisplay = roomSnapshot['isDisplay'];
                            standbyList[myIndex] = !standbyList[myIndex];
                            if (!standbyList.contains(true)) {
                              isDisplay = false;
                            }
                            await FirebaseFirestore.instance
                                .collection('room')
                                .doc(roomSnapshotList[roomIndex].id)
                                .update({
                              'standbyList': standbyList,
                              'isDisplay': isDisplay,
                            });
                          },
                        ),
                      ),
                    ),
                  ],
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

List<Widget> memberViewList(List<String> names, List<bool> standbyList) {
  var resultList = <Widget>[];
  for (int i = 0; i < names.length; i++) {
    resultList.add(memberView(names[i], standbyList[i]));
  }
  return resultList;
}

Widget memberView(String userName, bool standby) {
  return Card(
    child: SizedBox(
      width: 200.w,
      height: 50.h,
      child: Center(
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.all(8.r),
              child: Text(
                userName,
                style: TextStyle(fontSize: 20.sp, color: Colors.black),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.r),
              child: Text(
                standby ? 'OK' : '',
                style: TextStyle(fontSize: 20.sp, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

//standby_roomでroomを離れる時に使用
//members、names及びpointsの要素を一つ削除し、誰もいなくなる場合roomを削除
Future<void> leaveRoom(String roomName, BuildContext context) async {
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
  List<String> members = roomSnapshotList[roomIndex]['members'].cast<String>();
  members.remove(uid);
  final deletedMemberList = members.toSet().toList();
  final preference = await SharedPreferences.getInstance();
  final userName = preference.getString("userName");
  List<String> names = roomSnapshotList[roomIndex]['names'].cast<String>();
  names.remove(userName);
  final deletedNameList = members.toSet().toList();
  if (deletedMemberList.isNotEmpty) {
    await FirebaseFirestore.instance
        .collection('room')
        .doc(roomSnapshotList[roomIndex].id)
        .update({
      'members': deletedMemberList,
      'names': deletedNameList,
    });
  } else {
    await FirebaseFirestore.instance
        .collection('room')
        .doc(roomSnapshotList[roomIndex].id)
        .delete();
  }
  await FirebaseFirestore.instance.collection('users').doc(uid).update({
    'roomID': "",
  });
  Navigator.of(context).push<dynamic>(
    HomePage.route(),
  );
}
