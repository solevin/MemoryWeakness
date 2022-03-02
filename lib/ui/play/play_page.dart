import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:memory_weakness/ui/play/play_setting_view.dart';
import 'package:provider/provider.dart';

class PlayPage extends StatelessWidget {
  const PlayPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PLAY'),
      ),
      body: Consumer<SettingViewModel>(
        builder: (context, model, _) {
          return Column(
            children: [
              Text(model.test),
              Wrap(
                alignment: WrapAlignment.start,
                spacing: 8.h,
                children: panels(model),
              ),
              checkButton(model),
            ],
          );
        },
      ),
    );
  }
}

List<Widget> panels(SettingViewModel model) {
  var panelList = <Widget>[];
  for (int i = 0; i < model.questionNum * 2; i++) {
    panelList.add(eachPanel(model, i));
  }
  return panelList;
}

Widget eachPanel(SettingViewModel model, int id) {
  if (model.visibleList[id] == false) {
    return Padding(
      padding: EdgeInsets.all(8.r),
      child: SizedBox(
        width: 40.r,
        height: 40.r,
      ),
    );
  } else {
    if (model.isBackList[id] == true) {
      return Padding(
        padding: EdgeInsets.all(8.r),
        child: back(model, id),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(8.r),
        child: display(model, id),
      );
    }
  }
}

Widget display(SettingViewModel model, int id) {
  return SizedBox(
    width: 40.r,
    height: 40.r,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.amber,
      ),
      child: Text(model.valueList[id].toString()),
    ),
  );
}

Widget back(SettingViewModel model, int id) {
  return SizedBox(
    width: 40.r,
    height: 40.r,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: GestureDetector(
        onTap: () {
          if (model.isCanTap == true) {
            model.isBackList[id] = false;
            model.openValues.add(model.valueList[id]);
            model.openIds.add(id);
            if (model.openValues.length >= 2) {
              model.isCanTap = false;
            }
            final sendBackList = <String, dynamic>{
              'id': id,
              'openValues': model.openValues,
              'openIds': model.openIds,
            };
            model.socket.emit('back2server', sendBackList);
            model.notify();
          }
        },
      ),
    ),
  );
}

Widget checkButton(SettingViewModel model) {
  if (model.openValues.length >= 2) {
    return Padding(
      padding: EdgeInsets.all(8.r),
      child: SizedBox(
        height: 30.h,
        width: 60.w,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.orange,
          ),
          child: GestureDetector(
            child: const Text('OK'),
            onTap: () {
              model.socket.emit('next2server', '');
            },
          ),
        ),
      ),
    );
  } else {
    return Padding(
      padding: EdgeInsets.all(8.r),
      child: SizedBox(
        height: 30.h,
        width: 60.w,
      ),
    );
  }
}
