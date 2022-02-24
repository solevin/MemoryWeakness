import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:memory_weakness/ui/play/play_setting_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final _nums = setItems();
    const textColor = Color(0xFF5C4444);
    const backColor = Color(0xFFFFFBE5);
    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTING'),
      ),
      body: Consumer<SettingViewModel>(
        builder: (context, model, _) {
          return Column(
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
                        child: DropdownButton(
                          items: _nums,
                          value: model.questionNum,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                          dropdownColor: backColor,
                          onChanged: (value) => {
                            model.questionNum = value! as int,
                            model.notify(),
                          },
                        ),
                      ),
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
                      decoration: BoxDecoration(color: Colors.orange),
                      child: Center(
                        child: Text(
                          'OK',
                          style: TextStyle(
                            fontSize: 30.sp,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                    onTap: () async{
                      model.connect();
                      await Future.delayed(Duration(seconds: 3));
                      context.go('/play');
                    },
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

List<DropdownMenuItem<int>> setItems() {
  final _nums = <DropdownMenuItem<int>>[];

  _nums
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
  return _nums;
}
