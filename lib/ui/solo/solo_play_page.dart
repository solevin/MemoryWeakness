import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:memory_weakness/ui/solo/solo_play_view.dart';
import 'package:provider/provider.dart';

class SoloPlayPage extends StatelessWidget {
  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(
      builder: (_) => const SoloPlayPage(),
    );
  }

  const SoloPlayPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Consumer<SoloPlayViewModel>(
          builder: (context, model, _) {
            return Padding(
              padding: EdgeInsets.fromLTRB(0, 30.h, 0, 0),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.r),
                    child: Center(
                      child: Text(
                        model.turnText,
                        style: TextStyle(fontSize: 15.sp, color: Colors.black),
                      ),
                    ),
                  ),
                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 8.h,
                    children: panels(model),
                  ),
                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 8.h,
                    children: scores(model),
                  ),
                  Visibility(
                    child: checkButton(model, context),
                    visible: model.isVisible,
                  ),
                  Visibility(
                    child: passButton(model, context),
                    visible: model.isVisible,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

List<Widget> panels(SoloPlayViewModel model) {
  var panelList = <Widget>[];
  for (int i = 0; i < model.questionQuantity * 2; i++) {
    panelList.add(eachPanel(model, i));
  }
  return panelList;
}

Widget eachPanel(SoloPlayViewModel model, int id) {
  if (model.visibleList[id] == false) {
    return Padding(
      padding: EdgeInsets.all(8.r),
      child: SizedBox(
        width: 40.r,
        height: 40.r,
      ),
    );
  } else {
    if (model.openIds.contains(id)) {
      return Padding(
        padding: EdgeInsets.all(8.r),
        child: display(model, id),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(8.r),
        child: back(model, id),
      );
    }
  }
}

Widget display(SoloPlayViewModel model, int id) {
  return SizedBox(
    width: 40.r,
    height: 40.r,
    // child: DecoratedBox(
    //   decoration: const BoxDecoration(
    //     color: Colors.amber,
    //   ),
    //   child: Text(roomSnapshot['values'][id].toString()),
    // ),
    child: Image.asset(model.pathList[id]),
  );
}

Widget back(SoloPlayViewModel model, int id) {
  return SizedBox(
    width: 40.r,
    height: 40.r,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: GestureDetector(
        onTap: () async {
          if (model.turn == 0 && model.openIds.length < 2) {
            model.openIds.add(id);
          }
          if (model.openIds.length == 2) {
            model.isVisible = true;
          }
          model.notify();
        },
      ),
    ),
  );
}

Widget checkButton(SoloPlayViewModel model, BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(8.r),
    child: Container(
      height: 30.h,
      width: 60.w,
      color: Colors.purple,
      child: GestureDetector(
        child: Text(
          'Check',
          style: TextStyle(fontSize: 20.sp, color: Colors.white),
        ),
        onTap: () async {
          var myHp = model.hpList[model.turn];
          if (model.valueList[model.openIds[0]] ==
              model.valueList[model.openIds[1]]) {
            model.visibleList[model.openIds[0]] = false;
            model.visibleList[model.openIds[1]] = false;
            final addedPoint = model.pointList[model.turn] + 1;
            model.pointList[model.turn] = addedPoint;
          } else {
            // var nextTurnIndex = (model.turn + 1) % model.memberQuantity;
            // while (model.grayList.contains(nextTurnIndex)) {
            //   nextTurnIndex = (nextTurnIndex + 1) % model.memberQuantity;
            // }
            myHp--;
            if (myHp == 0) {
              model.grayList.add(model.turn);
            }
          }
          model.hpList[model.turn] = myHp;
          model.openIds = [];
          model.isVisible = false;
          model.notify();
        },
      ),
    ),
  );
}

Widget passButton(SoloPlayViewModel model, BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(8.r),
    child: Container(
      height: 30.h,
      width: 60.w,
      color: Colors.purple,
      child: GestureDetector(
        child: Text(
          'Pass',
          style: TextStyle(fontSize: 20.sp, color: Colors.white),
        ),
        onTap: () {
          // List<String> grayList = roomSnapshot['grayList'].cast<String>();
          // List<String> names = roomSnapshot['names'].cast<String>();
          // List<String> members = roomSnapshot['members'].cast<String>();
          // var turn = roomSnapshot['turn'];

          // var nextTurnIndex = (model.turn + 1) % model.memberQuantity;
          // while (model.grayList.contains(nextTurnIndex)) {
          //   nextTurnIndex = (nextTurnIndex + 1) % model.memberQuantity;
          // }
          model.openIds = [];
          model.isVisible = false;
          model.notify();
        },
      ),
    ),
  );
}

List<Widget> scores(SoloPlayViewModel model) {
  var scoreList = <Widget>[];
  for (int i = 0; i < model.memberQuantity; i++) {
    scoreList.add(eachScore(model, i));
  }
  return scoreList;
}

Widget eachScore(SoloPlayViewModel model, int id) {
  // final name = roomSnapshot['names'][id];
  // final point = roomSnapshot['points'][id];
  // final grayList = roomSnapshot['grayList'].cast<String>();
  // final uid = roomSnapshot['members'][id];
  // final hp = roomSnapshot['HPs'][id];
  // final maxHp = roomSnapshot['maxHP'];
  final isLeaved = model.grayList.contains(id);
  final name = id == 0 ? 'Player' : 'CPU$id';

  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: TextStyle(
                fontSize: 20.sp, color: isLeaved ? Colors.grey : Colors.black),
          ),
          Row(
            children: hearts(model.hpList[id], model.maxHP),
          )
        ],
      ),
      Text(
        '${model.pointList[id]}',
        style: TextStyle(
            fontSize: 20.sp, color: isLeaved ? Colors.grey : Colors.black),
      ),
    ],
  );
}

List<Widget> hearts(int hp, int maxHp) {
  List<Widget> hearts = [];
  int i = 0;
  for (; i < hp; i++) {
    hearts.add(const Icon(Icons.favorite));
  }
  for (; i < maxHp; i++) {
    hearts.add(const Icon(Icons.heart_broken));
  }
  return hearts;
}

void cpuTurn(int index){

}
