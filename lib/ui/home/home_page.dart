import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:memory_weakness/ui/room/room_list_page.dart';
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
    return Scaffold(
      body: Center(
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
                    'View',
                    style: TextStyle(
                      fontSize: 20.sp,
                    ),
                  ),
                ),
              ),
              onTap: () {
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
              onTap: () {
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
              onTap: () {
              },
            ),
          ],
        ),
      ),
    );
  }
}
