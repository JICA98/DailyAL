import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerConditionally extends StatelessWidget {
  final Widget child;
  final bool showShimmer;
  final Color? baseColor;
  final Color? highlightColor;
  const ShimmerConditionally({
    required this.showShimmer,
    required this.child,
    Key? key,
    this.baseColor,
    this.highlightColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (showShimmer) {
      return ShimmerColor(
        child,
        baseColor: baseColor,
        highlightColor: highlightColor,
      );
    } else {
      return child;
    }
  }
}

class ShimmerColor extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  const ShimmerColor(
    this.child, {
    Key? key,
    this.baseColor,
    this.highlightColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = ShimmerColors.fromContext(context);
    return Shimmer.fromColors(
      child: child,
      baseColor: baseColor ?? colors.baseColor,
      highlightColor: highlightColor ?? colors.highlightColor,
    );
  }
}

class ShimmerColors {
  final Color baseColor;
  final Color highlightColor;
  ShimmerColors({
    required this.baseColor,
    required this.highlightColor,
  });
  factory ShimmerColors.fromContext(BuildContext context) {
    final brightness = currentBrightness(context);
    final isLight = brightness != Brightness.dark;
    return ShimmerColors(
      baseColor: isLight
          ? Colors.grey[200]!
          : Theme.of(context).scaffoldBackgroundColor,
      highlightColor: isLight
          ? Colors.grey[100]!
          : _lighten(Theme.of(context).scaffoldBackgroundColor),
    );
  }

  static Color _lighten(Color c, [int percent = 2]) {
    assert(1 <= percent && percent <= 100);
    var p = percent / 100;
    return Color.fromARGB(
        c.alpha,
        c.red + ((255 - c.red) * p).round(),
        c.green + ((255 - c.green) * p).round(),
        c.blue + ((255 - c.blue) * p).round());
  }
}
