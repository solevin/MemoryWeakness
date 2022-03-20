import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:memory_weakness/ui/play/play_setting_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RoomPage extends StatelessWidget {
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
                Column(children: roomCard(model, context)),
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
                            .add({'price': 650, 'date': FieldValue.serverTimestamp()});
                      },
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<SettingViewModel>(
        builder: (context, model, _) {
          return FloatingActionButton(
            onPressed: () {
              context.go('/playSetting');
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
          context.go('/play');
        },
      ),
    ),
    height: 50.h,
    width: 200.w,
  );
}
