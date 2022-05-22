import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:memory_weakness/db/meats_dao.dart';
import 'package:memory_weakness/ui/solo/setting_cpu_view.dart';
import 'package:memory_weakness/ui/room/create_room_page.dart';
import 'package:memory_weakness/ui/solo/solo_play_view.dart';
import 'package:memory_weakness/ui/solo/solo_play_page.dart';
import 'package:provider/provider.dart';

class SettingCpuPage extends StatelessWidget {
  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(
      builder: (_) => const SettingCpuPage(),
    );
  }

  const SettingCpuPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final items = setItems();
    final _questionQuantity = items[0];
    final _maxHP = items[1];
    final difficultyList = [items[2], items[2], items[2], items[2]];
    const textColor = Color(0xFF5C4444);
    const backColor = Color(0xFFFFFBE5);
    return Scaffold(
      appBar: AppBar(
        title: const Text('CREATE ROOM'),
      ),
      body: Consumer<SettingCpuViewModel>(
        builder: (context, model, _) {
          return Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '問題数 : ',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 100.w,
                            height: 35.h,
                            child: Center(
                              child: DropdownButton(
                                items: _questionQuantity,
                                value: model.selectedQuestionQuantity,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                                dropdownColor: backColor,
                                onChanged: (value) => {
                                  model.selectedQuestionQuantity =
                                      value! as int,
                                  model.notify(),
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'HP : ',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 100.w,
                            height: 35.h,
                            child: Center(
                              child: DropdownButton(
                                items: _maxHP,
                                value: model.selectedHP,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                                dropdownColor: backColor,
                                onChanged: (value) => {
                                  model.selectedHP = value! as int,
                                  model.notify(),
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  cpu(0, model, difficultyList[0]),
                  cpu(1, model, difficultyList[1]),
                  cpu(2, model, difficultyList[2]),
                  Padding(
                    padding: EdgeInsets.all(8.h),
                    child: SizedBox(
                      height: 40.h,
                      width: 100.w,
                      child: GestureDetector(
                        child: DecoratedBox(
                          decoration: const BoxDecoration(color: Colors.orange),
                          child: Center(
                            child: Text(
                              'Start',
                              style: TextStyle(
                                fontSize: 30.sp,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                        onTap: () async {
                          initSoloPlay(model, context);
                          // await createRoom(
                          //     model.selectedQuestionQuantity,
                          //     model.selectedMaxMember,
                          //     model.selectedHP,
                          //     roomName,
                          //     '');
                          Navigator.of(context).push<dynamic>(
                            SoloPlayPage.route(),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

List<List<DropdownMenuItem<int>>> setItems() {
  final _questionQuantity = <DropdownMenuItem<int>>[];
  final _maxHP = <DropdownMenuItem<int>>[];
  final _difficulty = <DropdownMenuItem<int>>[];

  _questionQuantity
    ..add(
      DropdownMenuItem(
        value: 1,
        child: Text(
          '1',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    )
    ..add(
      DropdownMenuItem(
        value: 2,
        child: Text(
          '2',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    )
    ..add(
      DropdownMenuItem(
        value: 3,
        child: Text(
          '3',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    )
    ..add(
      DropdownMenuItem(
        value: 4,
        child: Text(
          '4',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    );

  _maxHP
    ..add(
      DropdownMenuItem(
        value: 1,
        child: Text(
          '1',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    )
    ..add(
      DropdownMenuItem(
        value: 2,
        child: Text(
          '2',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    )
    ..add(
      DropdownMenuItem(
        value: 3,
        child: Text(
          '3',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    )
    ..add(
      DropdownMenuItem(
        value: 4,
        child: Text(
          '4',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    );

  _difficulty
    ..add(
      DropdownMenuItem(
        value: 1,
        child: Text(
          '弱い',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    )
    ..add(
      DropdownMenuItem(
        value: 2,
        child: Text(
          '普通',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    )
    ..add(
      DropdownMenuItem(
        value: 3,
        child: Text(
          '強い',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    )
    ..add(
      DropdownMenuItem(
        value: 4,
        child: Text(
          '最強',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    );

  return [_questionQuantity, _maxHP, _difficulty];
}

Widget cpu(int index, SettingCpuViewModel model,
    List<DropdownMenuItem<int>> difficulty) {
  if (index < model.cpuQuantity) {
    return Padding(
      padding: EdgeInsets.all(8.r),
      child: Container(
        width: 300.w,
        height: 50.h,
        decoration: BoxDecoration(
          border: Border.all(width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'CPU${index + 1}',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 100.w,
                height: 35.h,
                child: Center(
                  child: DropdownButton(
                    items: difficulty,
                    value: model.difficultyList[index],
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    onChanged: (value) => {
                      model.difficultyList[index] = value! as int,
                      model.notify(),
                    },
                  ),
                ),
              ),
            ),
            GestureDetector(
              child: const Icon(Icons.delete),
              onTap: () {
                model.cpuQuantity--;
                model.difficultyList.removeAt(index);
                model.difficultyList.add(1);
                model.notify();
              },
            ),
          ],
        ),
      ),
    );
  } else if (index == model.cpuQuantity) {
    return Padding(
      padding: EdgeInsets.all(8.r),
      child: GestureDetector(
        child: Container(
          width: 300.w,
          height: 50.h,
          decoration: BoxDecoration(
            border: Border.all(width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Icon(Icons.add),
          ),
        ),
        onTap: () {
          model.cpuQuantity++;
          model.notify();
        },
      ),
    );
  } else {
    return Padding(
      padding: EdgeInsets.all(8.r),
      child: SizedBox(
        width: 300.w,
        height: 50.h,
      ),
    );
  }
}

void initSoloPlay(
    SettingCpuViewModel settingModel, BuildContext context) async {
  final meatDao = MeatDao();
  List<int> valueList = [];
  List<bool> visibleList = [];
  final rand = math.Random();
  final kindList = await meatDao.createKindList();
  var valueLength = settingModel.selectedQuestionQuantity;
  if (settingModel.selectedQuestionQuantity > kindList.length) {
    valueLength = kindList.length;
  }
  valueList = createValueList(valueLength, kindList.length);
  // valueList = await TMP(valueLength, kindList);
  for (int i = 0; i < valueLength * 2; i++) {
    visibleList.add(true);
  }
  for (var i = valueLength * 2 - 1; i > 0; i--) {
    final n = rand.nextInt(i);
    final temp = valueList[i];
    valueList[i] = valueList[n];
    valueList[n] = temp;
  }
  final pathList = await createPathList(valueList, kindList);

  final playModel = context.read<SoloPlayViewModel>();
  playModel.maxHP = settingModel.selectedHP;
  for (int i = 0; i < settingModel.cpuQuantity + 1; i++) {
    playModel.pointList.add(0);
    playModel.hpList.add(playModel.maxHP);
  }
  playModel.valueList = valueList;
  playModel.pathList = pathList;
  playModel.visibleList = visibleList;
  playModel.questionQuantity = settingModel.selectedQuestionQuantity;
  playModel.memberQuantity = settingModel.cpuQuantity + 1;
  playModel.notify();
}
