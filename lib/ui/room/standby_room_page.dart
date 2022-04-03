import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:memory_weakness/ui/home/home_page.dart';
import 'package:memory_weakness/ui/play/play_page.dart';
import 'package:provider/provider.dart';

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
            List<String> memberList =
                roomSnapshotList[roomIndex]['members'].cast<String>();
            memberList.remove(uid);
            final deletedMemberList = memberList.toSet().toList();
            await FirebaseFirestore.instance
                .collection('room')
                .doc(roomSnapshotList[roomIndex].id)
                .update({
              'members': deletedMemberList,
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
        )),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildTaskList(roomName as String),
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
                          'start',
                          style: TextStyle(fontSize: 20.sp, color: Colors.white),
                        ),
                      ),
                    ),
                    onTap: () async {
                      Navigator.of(context).push<dynamic>(
                        PlayPage.route(roomName: roomName),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildTaskList(String roomName) {
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
      final memberSnapshotList = snapshot.data!.docs;
      int roomIndex = 0;
      for (int i = 0; i < memberSnapshotList.length; i++) {
        if (memberSnapshotList[i].id == roomName) {
          roomIndex = i;
        }
      }
      final memberList =
          memberSnapshotList[roomIndex]['members'].cast<String>();
      return SizedBox(
        height: 400.h,
        child: ListView(
          children: memberViewList(memberList),
        ),
      );
    },
  );
}

List<Widget> memberViewList(List<String> memberList) {
  var resultList = <Widget>[];
  for (int i = 0; i < memberList.length; i++) {
    resultList.add(memberView(memberList[i]));
  }
  return resultList;
}

Widget memberView(String roomSnapshot) {
  return Card(
    child: SizedBox(
      width: 200.w,
      height: 50.h,
      child: Center(
        child: Text(roomSnapshot),
      ),
    ),
  );
}
