import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/widgets/home/accordion.dart';
import 'package:flutter/material.dart';

import '../../constant.dart';
import '../../main.dart';

class OptionTile extends StatelessWidget {
  final String? text;
  final String? desc;
  final IconData? iconData;
  final VoidCallback? onPressed;
  final Widget? trailing;
  final bool authOnly;
  final bool multiLine;
  final double opacity;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? subtitle;
  final bool smallTiles;
  const OptionTile({
    Key? key,
    this.text,
    this.iconData,
    this.onPressed,
    this.trailing,
    this.desc,
    this.opacity = 1,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    this.multiLine = false,
    this.authOnly = false,
    this.smallTiles = false,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (!authOnly || user.status == AuthStatus.AUTHENTICATED)
        ? ListTile(
            onTap: onPressed,
            horizontalTitleGap: smallTiles ? 10.0 : 20.0,
            minVerticalPadding: smallTiles ? 0.0 : null,
            dense: smallTiles,
            isThreeLine: multiLine,
            contentPadding: smallTiles ? const EdgeInsets.symmetric(horizontal: 20, vertical: 0) : contentPadding,
            trailing: trailing,
            subtitle: subtitle ??
                (desc == null ? null : title(desc, opacity: .7, fontSize: 12)),
            leading: iconData == null ? null : Icon(iconData),
            title: Text(text ?? '',
                style: TextStyle(fontSize: smallTiles ? 13 : 16)),
          )
        : const SizedBox();
  }
}

class AccordionOptionTile extends StatefulWidget {
  final bool isOpen;
  final void Function(bool)? onChanged;
  final Widget child;
  final String text;
  final String? desc;
  final IconData? leading;

  final bool multiLine;
  const AccordionOptionTile(
      {Key? key,
      this.isOpen = false,
      this.onChanged,
      required this.child,
      required this.text,
      this.desc,
      this.leading,
      this.multiLine = false})
      : super(key: key);

  @override
  _AccordionOptionTileState createState() => _AccordionOptionTileState();
}

class _AccordionOptionTileState extends State<AccordionOptionTile> {
  bool isOpen = false;
  @override
  void initState() {
    super.initState();
    isOpen = widget.isOpen ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Accordion(
        isOpen: isOpen,
        onChanged: (value) {
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
          if (mounted)
            setState(() {
              isOpen = value;
            });
        },
        child: widget.child,
        title: Container(
          height: 60,
          child: OptionTile(
            text: widget.text,
            desc: widget.desc,
            multiLine: widget.multiLine,
            iconData: widget.leading,
            trailing: Icon(
              isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 16,
            ),
          ),
        ));
  }
}
