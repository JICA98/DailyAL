import 'package:dailyanimelist/constant.dart';
import 'package:flutter/material.dart';

class SettingsSliverHeader extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? title;
  final PreferredSizeWidget? bottom;
  final bool showBackButton;
  final double height;
  const SettingsSliverHeader({
    Key? key,
    this.title,
    this.showBackButton = true,
    this.bottom,
    this.height = 160,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = currentBrightness(context);
    return WillPopScope(
      onWillPop: () async {
        if (onPressed != null) {
          onPressed!();
        }
        return true;
      },
      child: SliverAppBar(
        automaticallyImplyLeading: showBackButton,
        expandedHeight: height,
        pinned: true,
        bottom: bottom,
        flexibleSpace: FlexibleSpaceBar(
          title: Text(
            title ?? '',
            textAlign: TextAlign.center,
            style: brightness == Brightness.dark
                ? Theme.of(context).appBarTheme.titleTextStyle
                : Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22.0),
          ),
          centerTitle: true,
        ),
      ),
    );
  }
}
