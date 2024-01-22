import 'package:dailyanimelist/screens/homescreen.dart';
import 'package:flutter/material.dart';

class ContentSwticher extends StatefulWidget {
  final List<Widget> children;
  final int? index;
  const ContentSwticher({Key? key, required this.children, this.index}) : super(key: key);

  @override
  _ContentSwticherState createState() => _ContentSwticherState();
}

class _ContentSwticherState extends State<ContentSwticher>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation animation;
  List<Widget> widgets = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      value: 1.0,
      duration: Duration(milliseconds: 250),
    );
    animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
    widgets = widget.children
        .map((e) => OpacityAnima(child: e, animation: animation))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      children: widgets,
      index: widget.index,
    );
  }
}
