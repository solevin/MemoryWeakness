import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:memory_weakness/ui/home/home_page.dart';
import 'package:memory_weakness/ui/home/home_page_view.dart';
import 'package:memory_weakness/ui/room/create_room_view.dart';
import 'package:memory_weakness/ui/room/room_list_view.dart';
import 'package:memory_weakness/ui/play/result_page_view.dart';
import 'package:memory_weakness/ui/setting/setting_page_view.dart';
import 'package:memory_weakness/ui/solo/setting_cpu_view.dart';
import 'package:memory_weakness/ui/solo/solo_play_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:provider/provider.dart' as provider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signInAnonymously();
  String uid = FirebaseAuth.instance.currentUser!.uid;
  await updateUserPresence(uid);
  runApp(
    ProviderScope(
      child: provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(
            create: (_) => CreateRoomViewModel(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => HomePageViewModel(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => SettingPageViewModel(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => ResultPageViewModel(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => RoomListViewModel(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => SettingCpuViewModel(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => SoloPlayViewModel(),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(360, 690),
          builder: MyApp.new,
        ),
      ),
    ),
  );
}

const materialWhite = MaterialColor(
  0xFFFFFFFF,
  <int, Color>{
    50: Color(0xFFFFFFFF),
    100: Color(0xFFFFFFFF),
    200: Color(0xFFFFFFFF),
    300: Color(0xFFFFFFFF),
    400: Color(0xFFFFFFFF),
    500: Color(0xFFFFFFFF),
    600: Color(0xFFFFFFFF),
    700: Color(0xFFFFFFFF),
    800: Color(0xFFFFFFFF),
    900: Color(0xFFFFFFFF),
  },
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Weakness',
      theme: ThemeData(
        primarySwatch: materialWhite,
      ),
      darkTheme: ThemeData.dark(),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => HomePage(),
      },
    );
  }
}

Future<void> updateUserPresence(String uid) async {
  // プレゼンスをtrueに更新
  await FirebaseDatabase.instance.ref(uid).update(
    {
      'presence': true,
    },
  );

  // アプリの接続が切れ次第、プレゼンスをfalseに更新
  await FirebaseDatabase.instance
      .ref(uid)
      .onDisconnect()
      .update({'presence': false});
}
