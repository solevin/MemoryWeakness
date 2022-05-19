import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:memory_weakness/db/meats_dao.dart';
import 'package:memory_weakness/ui/room/create_room_view.dart';
import 'package:memory_weakness/ui/room/standby_room_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class CreateRoomPage extends StatelessWidget {
  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(
      builder: (_) => const CreateRoomPage(),
    );
  }

  const CreateRoomPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final items = setItems();
    final _questionQuantity = items[0];
    final _maxMember = items[1];
    final _maxHP = items[2];
    const textColor = Color(0xFF5C4444);
    const backColor = Color(0xFFFFFBE5);
    return Scaffold(
      appBar: AppBar(
        title: const Text('CREATE ROOM'),
      ),
      body: Consumer<CreateRoomViewModel>(
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
                          '参加人数 : ',
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
                                items: _maxMember,
                                value: model.selectedMaxMember,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                                dropdownColor: backColor,
                                onChanged: (value) => {
                                  model.selectedMaxMember = value! as int,
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
                  Padding(
                    padding: EdgeInsets.all(8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '鍵 : ',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        Switch(
                          value: model.isLock,
                          onChanged: (_) {
                            model.isLock = !model.isLock;
                            model.notify();
                          },
                        ),
                      ],
                    ),
                  ),
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
                              'set',
                              style: TextStyle(
                                fontSize: 30.sp,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                        onTap: () async {
                          if (!model.isLock) {
                            final roomName = await nameNewRoom();
                            await createRoom(
                                model.selectedQuestionQuantity,
                                model.selectedMaxMember,
                                model.selectedHP,
                                roomName,
                                '');
                            Navigator.of(context).push<dynamic>(
                              StandbyRoomPage.route(roomName: roomName),
                            );
                          } else {
                            model.isStack = true;
                            model.notify();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Visibility(
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
                            // inputFormatters: <TextInputFormatter>[
                            //   FilteringTextInputFormatter.digitsOnly
                            // ],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            maxLength: 4,
                            style: TextStyle(
                              fontSize: 20.sp,
                              color: Colors.black,
                            ),
                            onChanged: (text) {
                              model.passCode = text;
                              model.notify();
                            },
                          ),
                        ),
                        SizedBox(
                          height: 40.h,
                          width: 100.w,
                          child: ElevatedButton(
                            onPressed: model.passCode.length != 4
                                ? null
                                : () async {
                                    final roomName = await nameNewRoom();
                                    await createRoom(
                                        model.selectedQuestionQuantity,
                                        model.selectedMaxMember,
                                        model.selectedHP,
                                        roomName,
                                        model.passCode);
                                    Navigator.of(context).push<dynamic>(
                                      StandbyRoomPage.route(roomName: roomName),
                                    );
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
                                model.passCode = '';
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
  final _maxMember = <DropdownMenuItem<int>>[];
  final _maxHP = <DropdownMenuItem<int>>[];

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

  _maxMember
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
  return [_questionQuantity, _maxMember, _maxHP];
}

Future<String> nameNewRoom() async {
  final roomQuerySnapshot =
      await FirebaseFirestore.instance.collection('room').get();
  final roomSnapshotList = roomQuerySnapshot.docs;
  var roomName = '0';
  var roomNameList = [];
  if (roomSnapshotList.isNotEmpty) {
    for (int i = 0; i < roomSnapshotList.length; i++) {
      roomNameList.add(roomSnapshotList[i].id);
    }
    for (int i = 0; i < roomNameList.length; i++) {
      if (!roomNameList.contains(i.toString())) {
        roomName = i.toString();
      }
    }
  }
  return roomName;
}

Future<void> createRoom(int questionQuantity, int maxMembers, int maxHP,
    String roomName, String passCode) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final rand = math.Random();
  List<int> valueList = [];
  var valueLength = questionQuantity;
  var visibleList = [];
  final preference = await SharedPreferences.getInstance();
  final userName = preference.getString("userName");
  final meatDao = MeatDao();
  final kindList = await meatDao.createKindList();
  if (questionQuantity > kindList.length) {
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
  await FirebaseFirestore.instance.collection('room').doc(roomName).set({
    'members': [uid],
    'names': [userName],
    'points': [0],
    'HPs': [maxHP],
    'standbyList': [false],
    'leaves': [],
    'grayList': [],
    'maxMembers': maxMembers,
    'questionQuantity': valueLength,
    'maxHP': maxHP,
    'values': valueList,
    'pathList': pathList,
    'openIds': [],
    'visibleList': visibleList,
    'turn': userName,
    'isDisplay': true,
    'passCode': passCode,
  });
  await FirebaseFirestore.instance.collection('users').doc(uid).update({
    'roomID': roomName,
  });
}

List<int> createValueList(int valueLength, int numOfKind) {
  List<int> valueList = [];
  final rand = math.Random();
  for (int i = 0; i < valueLength; i++) {
    var index = rand.nextInt(numOfKind);
    while (valueList.contains(index)) {
      index = rand.nextInt(numOfKind);
    }
    valueList.add(index);
    valueList.add(index);
  }
  return valueList;
}

Future<List<String>> createPathList(
    List<int> valueList, List<String> kindList) async {
  List<String> pathList = [];
  final rand = math.Random();
  final meatDao = MeatDao();
  for (int i = 0; i < valueList.length; i++) {
    var meat;
    final extractedList = await meatDao.findByKind(kindList[valueList[i]]);
    final index = rand.nextInt(extractedList.length);
    meat = await meatDao.findById(extractedList[index]);
    while (meat == null) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
    final path = 'assets/images/' + meat.name;
    pathList.add(path);
  }
  return pathList;
}
