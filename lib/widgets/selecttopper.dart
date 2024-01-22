import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:flutter/material.dart';
import 'package:dal_commons/dal_commons.dart';

import '../main.dart';

Widget _fadeTransition(Widget child, Animation<double> anim) {
  return FadeTransition(
    opacity: Tween<double>(begin: 0, end: 1).animate(anim),
    child: child,
  );
}

Widget _slideTransition(Widget child, Animation<double> anim) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(anim),
    child: child,
  );
}

Widget _scaleTransition(Widget child, Animation<double> anim) {
  return ScaleTransition(
    // opacity: ,
    scale: Tween<double>(begin: 0, end: 1).animate(anim),
    child: child,
  );
}

void showTopSheet({required BuildContext context, required Widget child}) {
  showGeneralDialog(
    barrierLabel: "Barrier",
    barrierDismissible: true,
    context: context,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) {
      return Align(
        alignment: Alignment.topCenter,
        child: Card(child: child),
      );
    },
    transitionBuilder: (_, anim, __, child) {
      return (_fadeTransition(child, anim));
    },
  );
}

class SelectTopper extends StatefulWidget {
  final List<String> options;
  final List<String>? displayValues;
  final String? selectedOption;
  final Function(String)? onChanged;
  final String? popupText;
  const SelectTopper({
    Key? key,
    required this.options,
    this.displayValues,
    this.selectedOption,
    this.onChanged,
    this.popupText,
  }) : super(key: key);

  @override
  _SelectTopperState createState() => _SelectTopperState();
}

class _SelectTopperState extends State<SelectTopper> {
  String? option;

  @override
  void initState() {
    super.initState();
    option = widget.selectedOption;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        if (widget.popupText != null)
          Padding(
            padding: EdgeInsets.only(top: 30),
            child:
                title(widget.popupText, align: TextAlign.center, fontSize: 22),
          ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
          child: Wrap(
            alignment: WrapAlignment.center,
            children: widget.options.asMap().entries.map((e) {
              String displayText = widget.displayValues == null
                  ? widget.options.elementAt(e.key)
                  : widget.displayValues!.elementAt(e.key);
              bool isSelected = (option != null &&
                  option!.equals(widget.options.elementAt(e.key)));
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: ShadowButton(
                  onPressed: () {
                    widget.onChanged!(widget.options.elementAt(e.key));
                    option = widget.options.elementAt(e.key);
                    Navigator.pop(context);
                  },
                  elevation: isSelected ? null : 0.0,
                  backgroundColor: isSelected ? null : Colors.transparent,
                  child: Text(
                    displayText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(isSelected ? 1.0 : 0.5)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
