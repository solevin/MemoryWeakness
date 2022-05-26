import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:memory_weakness/ui/room/room_list_page.dart';
import 'package:memory_weakness/ui/home/home_page_view.dart';
import 'package:memory_weakness/ui/setting/setting_page.dart';
import 'package:memory_weakness/ui/solo/setting_cpu_view.dart';
import 'package:memory_weakness/ui/solo/setting_cpu_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(
      builder: (_) => const HomePage(),
    );
  }

  const HomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final homePageModel = context.read<HomePageViewModel>();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => checkFirstStartUp(homePageModel));
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  child: Container(
                    width: 250.w,
                    height: 70.h,
                    padding: EdgeInsets.all(5.r),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Text(
                        'Play',
                        style: TextStyle(
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push<dynamic>(
                      RoomPage.route(),
                    );
                  },
                ),
                InkWell(
                  child: Container(
                    width: 250.w,
                    height: 70.h,
                    padding: EdgeInsets.all(5.r),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Text(
                        'Solo',
                        style: TextStyle(
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    context.read<SettingCpuViewModel>().init();
                    Navigator.of(context).push<dynamic>(
                      SettingCpuPage.route(),
                    );
                  },
                ),
                InkWell(
                  child: Container(
                    width: 250.w,
                    height: 70.h,
                    padding: EdgeInsets.all(5.r),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Text(
                        'Setting',
                        style: TextStyle(
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                  ),
                  onTap: () async {
                    final preference = await SharedPreferences.getInstance();
                    Navigator.of(context).push<dynamic>(
                      SettingPage.route(preference: preference),
                    );
                  },
                ),
                InkWell(
                  child: Container(
                    width: 250.w,
                    height: 70.h,
                    padding: EdgeInsets.all(5.r),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Text(
                        'HighScore',
                        style: TextStyle(
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          Consumer<HomePageViewModel>(
            builder: (context, model, _) {
              return Visibility(
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
                          'ユーザー名登録',
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          height: 60.h,
                          width: 280.w,
                          child: TextField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            maxLength: 8,
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
                                ? null
                                : () async {
                                    model.isStack = false;
                                    model.notify();
                                    final preference =
                                        await SharedPreferences.getInstance();
                                    preference.setBool(
                                        "isExperiencedStartUp", true);
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
              );
            },
          )
        ],
      ),
    );
  }
}

Future<void> checkFirstStartUp(HomePageViewModel model) async {
  final preference = await SharedPreferences.getInstance();
  // print(preference.getString("userName"));
  if (preference.getBool("isExperiencedStartUp") != true) {
    model.isStack = true;
    model.notify();
  }
}
