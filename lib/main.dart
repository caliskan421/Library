import 'package:flutter/material.dart';
import 'package:where_is_library/theme/light_theme.dart';
import 'package:where_is_library/view/router.dart';

void main() {
  runApp(const WhereIsLibraryApp());
}

class WhereIsLibraryApp extends StatelessWidget {
  const WhereIsLibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "Where is Library",
      theme: lightTheme,
      routerConfig: router,
    );
  }
}
