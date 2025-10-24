import 'package:flutter/material.dart';
import 'package:dailyanimelist/util/responsive_helper.dart';

/// A widget that builds different layouts based on screen size
class AdaptiveLayout extends StatelessWidget {
  final Widget Function(BuildContext) compactBuilder;
  final Widget Function(BuildContext)? mediumBuilder;
  final Widget Function(BuildContext)? expandedBuilder;
  
  const AdaptiveLayout({
    Key? key,
    required this.compactBuilder,
    this.mediumBuilder,
    this.expandedBuilder,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveHelper.getScreenSize(context);
    
    return switch (screenSize) {
      ScreenSize.compact => compactBuilder(context),
      ScreenSize.medium => (mediumBuilder ?? compactBuilder)(context),
      _ => (expandedBuilder ?? mediumBuilder ?? compactBuilder)(context),
    };
  }
}
