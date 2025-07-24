import 'package:flutter/material.dart';

extension ExBuildContext on BuildContext {
  ExMediaQuery get mediaQuery => ExMediaQuery(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  double get appBarTopPadding => mediaQuery.topPadding + 56;

  double get bottomPadding => mediaQuery.bottomPadding;

  bool get isPortrait => MediaQuery.of(this).orientation == Orientation.portrait;

  get isTablet => mediaQuery.shortestSide > 600;

  double get aspectRatio => mediaQuery.width / mediaQuery.height;
}

class ExMediaQuery {
  final BuildContext ctx;

  ExMediaQuery(this.ctx);

  double get width => MediaQuery.of(ctx).size.width;

  double get height => MediaQuery.of(ctx).size.height;

  double get shortestSide => MediaQuery.of(ctx).size.shortestSide;

  double get topPadding => MediaQuery.of(ctx).padding.top;

  double get bottomPadding => MediaQuery.of(ctx).padding.bottom;
}
