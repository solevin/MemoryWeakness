import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:memory_weakness/router.dart';
import 'package:memory_weakness/ui/play/play_setting_view.dart';
import 'package:memory_weakness/ui/room/create_rooom_view.dart';
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
            create: (_) => SettingViewModel(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => CreateRoomViewModel(),
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
    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) {
        return MaterialApp.router(
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          title: 'Memory Weakness',
          builder: (context, widget) {
            ScreenUtil.init(
              constraints,
              context: context,
              designSize: const Size(360, 690),
            );
            return widget!;
          },
          theme: ThemeData(
            primarySwatch: materialWhite,
          ),
          darkTheme: ThemeData.dark(),
        );
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
