import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:memory_weakness/ui/setting/setting_page_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatelessWidget {
  static Route<dynamic> route({
    @required SharedPreferences? preference,
  }) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => const SettingPage(),
      settings: RouteSettings(arguments: preference),
    );
  }

  const SettingPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SharedPreferences preference =
        ModalRoute.of(context)!.settings.arguments as SharedPreferences;
    context.read<SettingPageViewModel>().userName =
        preference.getString("userName") as String;
    return Scaffold(
      appBar: AppBar(title: Text('SETTING')),
      body: Consumer<SettingPageViewModel>(
        builder: (context, model, _) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 50.h,
                      color: Colors.blue,
                      child: GestureDetector(
                        child: Center(
                          child: Text(
                            '名前変更',
                            style:
                                TextStyle(fontSize: 20.sp, color: Colors.white),
                          ),
                        ),
                        onTap: () {
                          model.isStack = true;
                          model.notify();
                        },
                      ),
                    )
                  ],
                ),
              ),
              Visibility(
                visible: model.isStack,
                child: Center(
                  child: Container(
                    height: 170.h,
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
                          'ユーザー名変更',
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          height: 60.h,
                          width: 280.w,
                          child: TextField(
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText:
                                  preference.getString("userName") as String,
                            ),
                            maxLength: 8,
                            showCursor: true,
                            style: TextStyle(
                              fontSize: 20.sp,
                              color: Colors.black,
                            ),
                            onChanged: (text) {
                              model.userName = text;
                              model.notify();
                            },
                          ),
                        ),
                        SizedBox(
                          height: 40.h,
                          width: 100.w,
                          child: ElevatedButton(
                            onPressed: model.userName.isEmpty
                                ? () {
                                    model.isStack = false;
                                    model.notify();
                                  }
                                : () async {
                                    final preference =
                                        await SharedPreferences.getInstance();
                                    final uid =
                                        FirebaseAuth.instance.currentUser!.uid;
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(uid)
                                        .update({
                                      'name': model.userName,
                                    });
                                    model.isStack = false;
                                    model.notify();
                                    preference.setString(
                                        "userName", model.userName);
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
