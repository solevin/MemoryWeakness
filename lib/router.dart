import 'package:memory_weakness/ui/home/home_page.dart';
import 'package:memory_weakness/ui/play/play_page.dart';
import 'package:go_router/go_router.dart';

GoRouter router = GoRouter(
  routes: [
    GoRoute(
      name: 'home',
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      name: 'play',
      path: '/play',
      builder: (context, state) => const PlayPage(),
    ),
    GoRoute(
      name: 'setting',
      path: '/setting',
      builder: (context, state) => const HomePage(),
    ),
  ]
);
