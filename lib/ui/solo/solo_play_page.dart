import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:memory_weakness/ui/solo/solo_play_view.dart';
import 'package:memory_weakness/ui/solo/solo_result_page.dart';
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
          if (!model.knownList.contains(id)) {
            model.knownList.add(id);
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
            myHp--;
            model.hpList[model.turn] = myHp;
            if (myHp == 0) {
              model.grayList.add(model.turn);
            }
            var nextTurnIndex = (model.turn + 1) % model.memberQuantity;
            while (model.grayList.contains(nextTurnIndex)) {
              nextTurnIndex = (nextTurnIndex + 1) % model.memberQuantity;
            }
            model.turn = nextTurnIndex;
          }
          model.openIds = [];
          model.isVisible = false;
          model.turnText = model.turn == 0 ? 'Player' : 'CPU${model.turn}';
          model.notify();
          if (model.grayList.length == model.memberQuantity ||
              !model.visibleList.contains(true)) {
            Navigator.of(context).push<dynamic>(
              SoloResultPage.route(),
            );
          }
          if (model.turn != 0) {
            cpuTurn(model, model.turn, context);
          }
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
          var nextTurnIndex = (model.turn + 1) % model.memberQuantity;
          while (model.grayList.contains(nextTurnIndex)) {
            nextTurnIndex = (nextTurnIndex + 1) % model.memberQuantity;
          }
          model.turn = nextTurnIndex;
          model.openIds = [];
          model.isVisible = false;
          model.turnText = model.turn == 0 ? 'Player' : 'CPU${model.turn}';
          model.notify();
          if (model.turn != 0) {
            cpuTurn(model, model.turn, context);
          }
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

Future<void> cpuTurn(
    SoloPlayViewModel model, int cpuIndex, BuildContext context) async {
  if (model.grayList.length == model.memberQuantity ||
      !model.visibleList.contains(true)) {
    Navigator.of(context).push<dynamic>(
      SoloResultPage.route(),
    );
  }
  if (model.knownList.length > model.knownList.toSet().length) {
    await selectCard(model, cpuIndex, context);
  } else {
    await randomSelect(model, cpuIndex, context);
  }
}

Future<void> cpuFace(SoloPlayViewModel model, int id) async {
  model.openIds.add(id);
  if (model.openIds.length == 2) {
    model.isVisible = true;
  }
  if (!model.knownList.contains(id)) {
    model.knownList.add(id);
  }
  await Future.delayed(const Duration(seconds: 3));
  model.notify();
}

Future<void> cpuCheck(SoloPlayViewModel model, BuildContext context) async {
  var myHp = model.hpList[model.turn];
  if (model.valueList[model.openIds[0]] == model.valueList[model.openIds[1]]) {
    model.visibleList[model.openIds[0]] = false;
    model.visibleList[model.openIds[1]] = false;
    final addedPoint = model.pointList[model.turn] + 1;
    model.pointList[model.turn] = addedPoint;
  } else {
    myHp--;
    if (myHp == 0) {
      model.grayList.add(model.turn);
    }
    model.hpList[model.turn] = myHp;
    var nextTurnIndex = (model.turn + 1) % model.memberQuantity;
    while (model.grayList.contains(nextTurnIndex)) {
      nextTurnIndex = (nextTurnIndex + 1) % model.memberQuantity;
    }
    model.turn = nextTurnIndex;
  }
  model.openIds = [];
  model.isVisible = false;
  model.turnText = model.turn == 0 ? 'Player' : 'CPU${model.turn}';
  await Future.delayed(const Duration(seconds: 3));
  model.notify();
  if (model.grayList.length == model.memberQuantity ||
      !model.visibleList.contains(true)) {
    Navigator.of(context).push<dynamic>(
      SoloResultPage.route(),
    );
  } else if (model.turn != 0) {
    await cpuTurn(model, model.turn, context);
  }
}

Future<void> cpuPass(SoloPlayViewModel model, BuildContext context) async {
  var nextTurnIndex = (model.turn + 1) % model.memberQuantity;
  while (model.grayList.contains(nextTurnIndex)) {
    nextTurnIndex = (nextTurnIndex + 1) % model.memberQuantity;
  }
  model.turn = nextTurnIndex;
  model.openIds = [];
  model.isVisible = false;
  model.turnText = model.turn == 0 ? 'Player' : 'CPU${model.turn}';
  await Future.delayed(const Duration(seconds: 3));
  model.notify();
  if (model.turn != 0) {
    await cpuTurn(model, model.turn, context);
  }
}

Future<void> selectCard(
    SoloPlayViewModel model, int cpuIndex, BuildContext context) async {
  int sameValue = getSameValue(model.knownList);
  List<int> tmpList = model.knownList;
  final selectedIndex = tmpList.indexOf(sameValue);
  await cpuFace(model, selectedIndex);
  List<double> switchingPoint =
      getSwitchingPoint(model.difficultyList[cpuIndex]);
  final rand = math.Random();
  final probability = rand.nextDouble();
  if (probability < switchingPoint[0]) {
    final secondIndex = tmpList.indexOf(sameValue, selectedIndex + 1);
    await cpuFace(model, secondIndex);
    await cpuCheck(model, context);
  } else if (probability < switchingPoint[1]) {
    final secondIndex = tmpList.indexOf(sameValue, selectedIndex + 1);
    await cpuFace(model, secondIndex);
    await cpuPass(model, context);
  } else if (probability < switchingPoint[2]) {
    int secondIndex = rand.nextInt(model.questionQuantity * 2);
    while (selectedIndex == secondIndex || !model.visibleList[secondIndex]) {
      secondIndex = rand.nextInt(model.questionQuantity * 2);
    }
    await cpuFace(model, secondIndex);
    await cpuCheck(model, context);
  } else if (probability < switchingPoint[3]) {
    int secondIndex = rand.nextInt(model.questionQuantity * 2);
    while (selectedIndex == secondIndex || !model.visibleList[secondIndex]) {
      secondIndex = rand.nextInt(model.questionQuantity * 2);
    }
    await cpuFace(model, secondIndex);
    await cpuCheck(model, context);
  } else {
    await randomSelect(model, cpuIndex, context);
  }
}

List<double> getSwitchingPoint(int difficulty) {
  List<double> switchingPoint = [];
  switch (difficulty) {
    case 1:
      switchingPoint = [0.15, 0.25, 0.35, 0.5];
      break;
    case 2:
      switchingPoint = [0.4, 0.5, 0.55, 0.65];
      break;
    case 3:
      switchingPoint = [0.65, 0.7, 0.75, 0.8];
      break;
    case 4:
      switchingPoint = [0.9, 0.95, 0.95, 0.95];
      break;
    default:
  }
  return switchingPoint;
}

Future<void> randomSelect(
    SoloPlayViewModel model, int index, BuildContext context) async {
  final rand = math.Random();
  int selectedIndex = rand.nextInt(model.questionQuantity * 2);
  while (!model.visibleList[selectedIndex]) {
    selectedIndex = rand.nextInt(model.questionQuantity * 2);
  }
  await cpuFace(model, selectedIndex);
  bool willMatch = true;

  double probability = (rand.nextInt(10) + 1) * 0.1;
  switch (model.difficultyList[index]) {
    case 1:
      if (probability > 0.6) {
        willMatch = false;
      }
      break;
    case 2:
      if (probability > 0.7) {
        willMatch = false;
      }
      break;
    case 3:
      if (probability > 0.8) {
        willMatch = false;
      }
      break;
    case 4:
      if (probability > 0.9) {
        willMatch = false;
      }
      break;
    default:
  }

  bool isKnown = false;
  final tmpValue = model.valueList[selectedIndex];
  if (model.knownList.contains(selectedIndex)) {
    var tmpList = model.knownList;
    tmpList.remove(selectedIndex);
    final tmpIndex = model.valueList.indexOf(tmpValue, selectedIndex + 1);
    if (model.knownList.contains(tmpIndex)) {
      isKnown = true;
    }
  } else if (model.knownList.contains(tmpValue)) {
    isKnown = true;
  }

  if (isKnown && willMatch) {
    int secondIndex = model.valueList.indexOf(model.valueList[selectedIndex]);
    if (selectedIndex == secondIndex) {
      secondIndex = model.valueList
          .indexOf(model.valueList[selectedIndex], selectedIndex + 1);
    }
    await cpuFace(model, secondIndex);
    await cpuCheck(model, context);
  } else {
    int secondIndex = rand.nextInt(model.questionQuantity * 2);
    while (!model.visibleList[secondIndex] || selectedIndex == secondIndex) {
      secondIndex = rand.nextInt(model.questionQuantity * 2);
    }
    await cpuFace(model, secondIndex);

    probability = rand.nextDouble();
    if (model.valueList[selectedIndex] == model.valueList[secondIndex]) {
      switch (model.difficultyList[index]) {
        case 1:
          if (probability < 0.4) {
            await cpuCheck(model, context);
          } else {
            await cpuPass(model, context);
          }
          break;
        case 2:
          if (probability < 0.6) {
            await cpuCheck(model, context);
          } else {
            await cpuPass(model, context);
          }
          break;
        case 3:
          if (probability < 0.8) {
            await cpuCheck(model, context);
          } else {
            await cpuPass(model, context);
          }
          break;
        case 4:
          if (probability < 1) {
            await cpuCheck(model, context);
          } else {
            await cpuPass(model, context);
          }
          break;
        default:
      }
    } else {
      switch (model.difficultyList[index]) {
        case 1:
          if (probability < 0.3) {
            await cpuCheck(model, context);
          } else {
            await cpuPass(model, context);
          }
          break;
        case 2:
          if (probability < 0.2) {
            await cpuCheck(model, context);
          } else {
            await cpuPass(model, context);
          }
          break;
        case 3:
          if (probability < 0.1) {
            await cpuCheck(model, context);
          } else {
            await cpuPass(model, context);
          }
          break;
        case 4:
          await cpuPass(model, context);
          break;
        default:
      }
    }
  }
}

int getSameValue(List<int> knownList) {
  List<int> tmpList = knownList;
  int sameValue = 0;
  tmpList.sort((num1, num2) => num1 - num2);
  for (int i = 0; i < tmpList.length - 1; i++) {
    if (tmpList[i] == tmpList[i + 1]) {
      sameValue = tmpList[i];
      break;
    }
  }
  return sameValue;
}
