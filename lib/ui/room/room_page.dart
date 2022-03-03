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
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
              )
            ]),
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
        onTap: () async {
          model.socket.emit('joinServerRoom', name);
          model.isComplete = false;
          while (model.isComplete == false) {
            await Future.delayed(const Duration(milliseconds: 100));
          }
          context.go('/play');
        },
      ),
    ),
    height: 50.h,
    width: 200.w,
  );
}
