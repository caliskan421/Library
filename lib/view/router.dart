import 'package:go_router/go_router.dart';
import 'package:where_is_library/view/home/home_view.dart';
import 'package:where_is_library/view/map/map_view.dart';
import 'package:where_is_library/view/map/model/map_extra_model.dart';

enum RouteNames { home, map }

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return HomeView();
      },
    ),
    GoRoute(
      path: '/route',
      name: RouteNames.map.name,
      builder: (context, state) {
        final extra = state.extra as MapExtraModel;
        return MapView(extra: extra);
      },
    ),
  ],
);
