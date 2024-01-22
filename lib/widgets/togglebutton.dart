import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:flutter/material.dart';

class ToggleButton extends StatelessWidget {
  final bool toggleValue;
  final ValueChanged<bool> onToggled;
  final EdgeInsetsGeometry padding;
  const ToggleButton(
      {Key? key,
      this.toggleValue = false,
      required this.onToggled,
      this.padding = const EdgeInsets.all(8.0)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: toggleValue,
      onChanged: (value) => onToggled(value),
    );
  }
}

class ButtonSwitch extends StatelessWidget {
  final VoidCallback? onLeft;
  final VoidCallback? onRight;
  final String leftText;
  final String rightText;
  final bool isLeftSelected;
  const ButtonSwitch({
    super.key,
    required this.leftText,
    required this.rightText,
    @required this.onLeft,
    @required this.onRight,
    this.isLeftSelected = true,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = 32.0;
    final colorSize = BorderSide(
      color: Theme.of(context).dividerColor,
      width: 1.0,
    );
    var leftBorder = RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(borderRadius),
        bottomLeft: Radius.circular(borderRadius),
      ),
      side: isLeftSelected ? colorSize : BorderSide.none,
    );
    var leftTW = Text(
      leftText,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 12),
    );
    var rightBorder = RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topRight: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius)),
      side: !isLeftSelected ? colorSize : BorderSide.none,
    );
    var rightTW = Text(
      rightText,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 12),
    );
    const padding = EdgeInsets.symmetric(horizontal: 7);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 66,
          child: isLeftSelected
              ? ShadowButton(
                  padding: padding,
                  shape: leftBorder,
                  onPressed: onLeft,
                  child: leftTW,
                )
              : PlainButton(
                  padding: padding,
                  shape: leftBorder,
                  onPressed: onLeft,
                  child: leftTW,
                ),
        ),
        Container(
          width: 66,
          child: !isLeftSelected
              ? ShadowButton(
                  padding: padding,
                  shape: rightBorder,
                  onPressed: onRight,
                  child: rightTW,
                )
              : PlainButton(
                  padding: padding,
                  shape: rightBorder,
                  onPressed: onRight,
                  child: rightTW,
                ),
        ),
      ],
    );
  }
}
