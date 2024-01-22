import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/loading/expandedwidget.dart';
import 'package:flutter/material.dart';

import '../../constant.dart';
import '../../main.dart';

class Accordion extends StatefulWidget {
  final Widget? child;
  final dynamic title;
  final bool isOpen;
  final List<Widget>? additional;
  final TextStyle? titleStyle;
  final EdgeInsets? titlePadding;
  final ValueChanged<bool>? onChanged;
  final bool atStartExpanded;

  const Accordion({
    Key? key,
    @required this.title,
    @required this.child,
    this.isOpen = false,
    this.additional,
    this.titleStyle,
    this.onChanged,
    this.titlePadding,
    this.atStartExpanded = true,
  }) : super(key: key);

  @override
  _AccordionState createState() => _AccordionState();
}

class _AccordionState extends State<Accordion> {
  bool isOpen = false;

  @override
  void initState() {
    super.initState();
    isOpen = widget.isOpen ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: widget.titlePadding ?? EdgeInsets.zero,
            child: _title,
          ),
          if (widget.child != null)
            ExpandedSection(
              child: widget.child!,
              expand: isOpen,
              atStartExpanded: widget.atStartExpanded,
            ),
        ],
      ),
    );
  }

  Widget get _title {
    if (widget.title is String) return _accordionTap(_heading);
    if (widget.title is Widget) return _accordionTap(widget.title);
    return SB.h10;
  }

  void change() {
    if (mounted)
      setState(() {
        isOpen = !isOpen;
      });
    if (widget.onChanged != null) {
      widget.onChanged!(isOpen);
    }
  }

  Widget _accordionTap(Widget child) {
    return InkWell(
      onTap: () => change(),
      child: child,
    );
  }

  Widget get _heading => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 30,
              width: 30,
              child: PlainButton(
                onPressed: () => change(),
                padding: EdgeInsets.zero,
                child: Icon(isOpen
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_right),
              ),
            ),
            Expanded(
              child: widget.titleStyle != null
                  ? Text(widget.title, style: widget.titleStyle)
                  : title(
                      widget.title,
                      align: TextAlign.start,
                      fontSize: 16,
                    ),
            ),
            if (widget.additional != null && widget.additional!.isNotEmpty) ...[
              SB.w10,
              ...widget.additional!
            ]
          ],
        ),
      );
}
