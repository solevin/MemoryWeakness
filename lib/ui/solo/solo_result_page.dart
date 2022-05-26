import 'dart:math';
import 'package:flutter/material.dart';
import 'package:memory_weakness/ui/solo/solo_play_page.dart';
import 'package:memory_weakness/ui/solo/solo_play_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:memory_weakness/ui/room/create_room_page.dart';
import 'package:memory_weakness/ui/room/standby_room_page.dart';
import 'package:memory_weakness/ui/home/home_page.dart';
import 'package:memory_weakness/ui/solo/setting_cpu_page.dart';
import 'package:memory_weakness/ui/solo/setting_cpu_view.dart';
import 'package:memory_weakness/ui/play/result_page_view.dart';
import 'package:memory_weakness/ui/room/room_list_page.dart';
import 'package:provider/provider.dart';

class SoloResultPage extends StatelessWidget {
  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(
      builder: (_) => const SoloResultPage(),
    );
  }

  const SoloResultPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('RESULT'),
        ),
        body: Consumer<SoloPlayViewModel>(
          builder: (context, model, _) {
            return Center(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 200.h,
                      child: ListView(
                        children: ranking(model),
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
                            initSoloPlay(
                                context.read<SettingCpuViewModel>(), context);
                            Navigator.of(context).push<dynamic>(
                              SoloPlayPage.route(),
                            );
                          }),
                          child: Center(
                              child: Text(
                            'REPLAY',
                            style:
                                TextStyle(fontSize: 20.sp, color: Colors.black),
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
                          onTap: (() {
                            Navigator.of(context).push<dynamic>(
                              HomePage.route(),
                            );
                          }),
                          child: Center(
                              child: Text(
                            'HOME',
                            style:
                                TextStyle(fontSize: 20.sp, color: Colors.black),
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

List<Widget> ranking(SoloPlayViewModel model) {
  List<Widget> ranks = [];
  // int memberQuantity = roomState.members.length;
  List<int> immutablePoints = model.pointList;
  List<int> variablePoints = model.pointList;
  final names = ['Player', 'CPU1', 'CPU2', 'CPU3'];
  for (int i = 0; i < model.memberQuantity; i++) {
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
