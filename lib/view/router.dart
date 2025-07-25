import 'package:go_router/go_router.dart';
import 'package:where_is_library/view/home/home_view.dart';

enum RoutePages { home }

final router = GoRouter(
  initialLocation: '/',
  routes: [GoRoute(path: '/', builder: (context, state) => HomeView())],
);
