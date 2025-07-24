import 'package:flutter/material.dart';

class BaseView<T> extends StatelessWidget {
  const BaseView({
    super.key,
    required this.vm,
    required this.builder,
    this.backgroundColor,
    this.appBar,
    this.appBarTitle,
    this.bottomAppBar,
    this.floatingActionButton,
    this.useSafeArea = true,
    this.endDrawer,
  });

  final T vm;
  final Widget Function(BuildContext ctx, T viewModel) builder;
  final Color? backgroundColor;
  final bool useSafeArea;
  final AppBar? appBar;
  final String? appBarTitle;
  final BottomAppBar? bottomAppBar;
  final Widget? floatingActionButton;
  final Widget? endDrawer;

  @override
  Widget build(BuildContext context) {
    Widget child;

    try {
      child = builder(context, vm);
    } catch (e) {
      child = Center(child: Text(e.toString()));
    }
    if (useSafeArea) {
      child = SafeArea(child: child);
    }

    var appbar = appBar;
    if (appbar == null && appBarTitle != null) {
      appbar = AppBar(
        leading: IconButton(
          icon: Image.asset('assets/icon/arrow_back.png', height: 24, width: 24),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(appBarTitle!, style: Theme.of(context).textTheme.titleLarge),
        centerTitle: false,
        titleSpacing: 0,
      );
    }

    return Scaffold(
      appBar: appbar,
      backgroundColor: backgroundColor,
      bottomNavigationBar: bottomAppBar,
      body: child,
      floatingActionButton: floatingActionButton,
      endDrawer: endDrawer,
    );
  }
}
