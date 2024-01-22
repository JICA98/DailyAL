import 'package:flutter/material.dart';

class InstantPageWidget extends StatefulWidget {
  final int selectedIndex;
  final List<Widget> widgets;
  InstantPageWidget({this.selectedIndex = 0, required this.widgets});

  @override
  _InstantPageWidgetState createState() => _InstantPageWidgetState();
}

class _InstantPageWidgetState extends State<InstantPageWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.widgets.elementAt(widget.selectedIndex);
  }
}
