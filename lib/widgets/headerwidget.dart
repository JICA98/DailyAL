import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../constant.dart';

class HeaderWidget extends StatelessWidget {
  final List<String> header;
  final ValueChanged<int> onPressed;
  final Color? selectedBgColor;
  final Color? defaultBgColor;
  final Color? defaultTextColor;
  final bool applyTextColor;
  final double? fontSize;
  final int selectedIndex;
  final double driftOffset;
  final bool shouldAnimate;
  final double? width, height;
  final ShapeBorder? shape;
  final bool formatText;
  final bool tapToDisable;
  final Color? selectedColor;
  final double unSelectedOpacity;
  final EdgeInsets? listPadding;
  final EdgeInsets? itemPadding;
  final EdgeInsets? contentPadding;
  final ScrollController scrollController = ScrollController();
  final ItemScrollController itemScrollController = ItemScrollController();
  HeaderWidget({
    required this.header,
    required this.onPressed,
    this.defaultBgColor,
    this.selectedIndex = 0,
    this.shouldAnimate = true,
    this.driftOffset = 120.0,
    this.height = 45.0,
    this.width,
    this.shape,
    this.selectedColor,
    this.formatText = false,
    this.listPadding,
    this.unSelectedOpacity = 0.4,
    this.tapToDisable = false,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 17),
    this.contentPadding,
    this.selectedBgColor,
    this.fontSize,
    this.defaultTextColor,
    this.applyTextColor = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: ScrollablePositionedList.builder(
        initialScrollIndex: validIndex(selectedIndex) ? selectedIndex : 0,
        itemCount: header.length,
        scrollDirection: Axis.horizontal,
        itemScrollController: itemScrollController,
        padding: listPadding,
        itemBuilder: (context, index) =>
            headerBodyWidget(header.elementAt(index), index, context),
      ),
    );
  }

  bool validIndex(int? index) {
    return index != null && index >= 0;
  }

  Widget headerBodyWidget(
    String pageName,
    int index,
    BuildContext context,
  ) {
    return Container(
      padding: contentPadding ?? EdgeInsets.symmetric(horizontal: 10),
      child: selectedIndex == index
          ? _selectedButton(index, pageName, context)
          : _defaultButton(index, pageName, context),
    );
  }

  Widget _selectedButton(
    int index,
    String pageName,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: ShadowButton(
        onPressed: () => _onPressed(index),
        shape: shape as OutlinedBorder?,
        padding:
            itemPadding ?? EdgeInsets.symmetric(horizontal: 17, vertical: 2.0),
        backgroundColor: selectedBgColor,
        child: _textWidget(pageName, index, context),
      ),
    );
  }

  void _onPressed(int index) {
    if (shouldAnimate) {
      itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 500),
      );
    }
    if (tapToDisable && index == selectedIndex) {
      onPressed(-1);
    } else {
      onPressed(index);
    }
  }

  Widget _defaultButton(int index, String pageName, BuildContext context) {
    return PlainButton(
      onPressed: () => _onPressed(index),
      shape: shape as OutlinedBorder?,
      padding: itemPadding ?? EdgeInsets.symmetric(horizontal: 17),
      buttonColor: defaultBgColor,
      child: _textWidget(pageName, index, context),
    );
  }

  Widget _textWidget(String pageName, int index, BuildContext context) {
    final colorVal = applyTextColor
        ? defaultTextColor?.value
        : (selectedIndex == index ? selectedColor?.value : null);
    double opacity = selectedIndex == index ? 1.0 : unSelectedOpacity;
    return Text(
      (formatText ? pageName.replaceAll("_", " ") : pageName) ?? '',
      style: (colorVal == null && fontSize == null)
          ? null
          : Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorVal == null
                    ? Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(opacity)
                    : Color(colorVal).withOpacity(opacity),
                fontSize: fontSize,
              ),
    );
  }
}

class IncludeExcludeWidget extends StatelessWidget {
  final List<String> header;
  final List<String> include;
  final List<String> exclude;
  final Function(List<String>, List<String>)? onPressed;
  final Color includeBgColor;
  final Color excludeBgColor;
  final Color defaultBgColor;
  final double fontSize;
  final double driftOffset;
  final bool shouldAnimate;
  final double? width, height;
  final ShapeBorder? shape;
  final bool formatText;
  final bool tapToDisable;
  final Color? selectedColor;
  final EdgeInsets? listPadding;
  final EdgeInsets? itemPadding;
  final EdgeInsets? contentPadding;
  final ScrollController scrollController = ScrollController();
  final ItemScrollController itemScrollController = ItemScrollController();
  IncludeExcludeWidget({
    required this.header,
    this.onPressed,
    this.defaultBgColor = Colors.transparent,
    this.shouldAnimate = true,
    this.driftOffset = 120.0,
    this.height = 30.0,
    this.width,
    this.shape,
    required this.include,
    required this.exclude,
    this.selectedColor,
    this.formatText = false,
    this.listPadding,
    this.tapToDisable = false,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 17),
    this.contentPadding,
    this.includeBgColor = Colors.transparent,
    this.excludeBgColor = Colors.transparent,
    this.fontSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: ScrollablePositionedList.builder(
        initialScrollIndex: 0,
        itemCount: header.length,
        scrollDirection: Axis.horizontal,
        itemScrollController: itemScrollController,
        padding: listPadding,
        itemBuilder: (context, index) => headerBodyWidget(
            header.elementAt(index), index, onPressed,
            contentPadding: contentPadding,
            itemPadding: itemPadding,
            tapToDisable: tapToDisable,
            selectedColor: selectedColor,
            formatText: formatText),
      ),
    );
  }

  bool validIndex(int index) {
    return index != null && index >= 0;
  }

  Widget headerBodyWidget(String pageName, int index,
      Function(List<String>, List<String>)? onPressed,
      {EdgeInsets? contentPadding,
      bool tapToDisable = false,
      EdgeInsets? itemPadding,
      Color? selectedColor,
      bool formatText = false}) {
    return Container(
      padding: contentPadding ?? EdgeInsets.symmetric(horizontal: 10),
      child: PlainButton(
        onPressed: () {
          if (shouldAnimate) {
            itemScrollController.scrollTo(
              index: index,
              duration: const Duration(milliseconds: 500),
            );
          }
          if (exclude.contains(pageName)) {
            exclude.remove(pageName);
          } else if (include.contains(pageName)) {
            include.remove(pageName);
            exclude.add(pageName);
          } else {
            include.add(pageName);
          }
          onPressed!(include, exclude);
        },
        shape: shape,
        padding: itemPadding ?? EdgeInsets.symmetric(horizontal: 17),
        buttonColor: include.contains(pageName)
            ? includeBgColor
            : exclude.contains(pageName)
                ? excludeBgColor
                : defaultBgColor,
        child: title(
            formatText ? pageName.replaceAll("_", " ").capitalize() : pageName,
            colorVal: (include.contains(pageName) || exclude.contains(pageName))
                ? selectedColor?.value
                : null,
            fontSize: fontSize,
            opacity: (include.contains(pageName) || exclude.contains(pageName))
                ? 1
                : 0.7),
      ),
    );
  }
}
