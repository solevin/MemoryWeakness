import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            MenuItem(
              text: 'Play',
              route: '/playSetting',
            ),
            MenuItem(
              text: 'View',
              route: '/view',
            ),
            MenuItem(
              text: 'Setting',
              route: '/',
            ),
            MenuItem(
              text: 'HighScore',
              route: '/highScore',
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  const MenuItem({
    Key? key,
    required this.text,
    required this.route,
  }) : super(key: key);

  final String text;
  final String route;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.go(route);
      },
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
            text,
            style: TextStyle(
              fontSize: 20.sp,
            ),
          ),
        ),
      )
    );
  }
}
