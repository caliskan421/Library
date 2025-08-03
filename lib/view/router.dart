import 'package:go_router/go_router.dart';
import 'package:where_is_library/view/home/home_view.dart';
import 'package:where_is_library/view/map/map_view.dart';

enum RouteNames { home, map }

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => HomeView()),
    GoRoute(path: '/route', name: RouteNames.map.name, builder: (context, state) => MapView()),
  ],
);
