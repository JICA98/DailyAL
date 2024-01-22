import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/pages/settings/optiontile.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/headerwidget.dart';
import 'package:dailyanimelist/widgets/selecttopper.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dailyanimelist/generated/l10n.dart';

class SelectDate extends StatelessWidget {
  final DateTime? selectDate;
  final ValueChanged<DateTime>? onChanged;
  final ValueChanged<String>? onChangedFormatted;
  const SelectDate(
      {Key? key, this.selectDate, this.onChanged, this.onChangedFormatted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final datetime = await showDatePicker(
          context: context,
          initialDate: selectDate ?? DateTime.now(),
          firstDate: DateTime.utc(1970),
          lastDate: DateTime.utc(2030),
          builder: (BuildContext context, Widget? child) {
            return child ?? SB.z;
          },
        );
        if (datetime != null) {
          if (onChanged != null) onChanged!(datetime);
          if (onChangedFormatted != null)
            onChangedFormatted!(DateFormat("yyyy-MM-dd").format(datetime));
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.date_range,
              size: 16,
            ),
            const SizedBox(width: 10),
            title(getFormattedDate(selectDate))
          ],
        ),
      ),
    );
  }

  String getFormattedDate(_selectDate) {
    try {
      return DateFormat("yyyy-MM-dd").format(_selectDate);
    } catch (e) {
      return S.current.Select;
    }
  }
}

enum SelectType { select_sheet, select_top, dropdown }

class SelectButton extends StatefulWidget {
  final List<String> options;
  final List<String>? displayValues;
  final String? selectedOption;
  final Function(String)? onChanged;
  final String? popupText;
  final IconData? iconToUse;
  final bool useIcon;
  final Widget? child;
  final FontStyle? fontStyle;
  final bool reverseIcon;
  final bool showSelectWhenNull;
  final int? colorVal;
  final SelectType selectType;
  final Map<String, IconData>? iconMap;
  final double? iconSize;
  final bool useShadowChild;
  final EdgeInsets? shadowPadding;
  final Offset? dropdownOffset;
  const SelectButton({
    Key? key,
    required this.options,
    this.displayValues,
    this.selectedOption,
    this.popupText,
    this.useIcon = false,
    this.child,
    this.fontStyle,
    this.reverseIcon = true,
    this.colorVal,
    this.selectType = SelectType.select_sheet,
    this.showSelectWhenNull = false,
    this.iconToUse = Icons.category,
    this.onChanged,
    this.iconMap,
    this.iconSize,
    this.useShadowChild = false,
    this.shadowPadding,
    this.dropdownOffset,
  }) : super(key: key);

  @override
  _SelectButtonState createState() => _SelectButtonState();
}

class _SelectButtonState extends State<SelectButton> {
  String? option;

  @override
  void initState() {
    super.initState();
    option = widget.selectedOption;
  }

  @override
  void didUpdateWidget(covariant SelectButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (option != null &&
        widget?.selectedOption != null &&
        option!.notEquals(widget.selectedOption) &&
        mounted) {
      option = widget.selectedOption;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectType == SelectType.dropdown) {
      return _dropdown();
    }
    return _otherSelectOptions();
  }

  PopupMenuButton<String> _dropdown() {
    return PopupMenuButton<String>(
      onSelected: _onValueSelect,
      child: widget.child,
      offset: widget.dropdownOffset ?? Offset.zero,
      itemBuilder: (context) => widget.options
          .map((e) => PopupMenuItem<String>(value: e, child: getIconText(e)))
          .toList(),
    );
  }

  Widget getIconText(String currOption) {
    var iconMap = widget.iconMap;
    var displayText = getDisplayText(currOption);
    if (iconMap != null) {
      var iconData = iconMap[currOption];
      if (iconData != null) {
        return iconAndText(iconData, displayText);
      }
    }
    return Text(displayText);
  }

  Widget _otherSelectOptions() {
    final child = widget.child ??
        (widget.useIcon
            ? Icon(widget.iconToUse, size: widget.iconSize)
            : title(getDisplayText(option),
                fontStyle: widget.fontStyle, colorVal: widget.colorVal));
    if (widget.useShadowChild) {
      return ShadowButton(
        onPressed: _onTap,
        child: child,
        padding: widget.shadowPadding,
      );
    }
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: child,
      ),
    );
  }

  void _onTap() {
    switch (widget.selectType) {
      case SelectType.select_sheet:
        showCustomSheet(
            context: context,
            child: SelectSheet(
              displayValues: widget.displayValues,
              onChanged: _onValueSelect,
              popupText: widget.popupText,
              options: widget.options,
              selectedOption: option,
            ));
        break;
      case SelectType.select_top:
        showTopSheet(
          context: context,
          child: SelectTopper(
            displayValues: widget.displayValues,
            onChanged: _onValueSelect,
            popupText: widget.popupText,
            options: widget.options,
            selectedOption: option,
          ),
        );
        break;
      default:
    }
  }

  void _onValueSelect(String value) {
    if (mounted) {
      widget.onChanged!(value);
      setState(() {
        option = value;
      });
    }
  }

  String getDisplayText(String? selectedOption) {
    if (widget.showSelectWhenNull && selectedOption == null) {
      return S.current.Select;
    }
    String? _option;
    var showValues = widget.displayValues ?? widget.options;
    if (selectedOption != null) {
      var index = widget.options.indexOf(selectedOption);
      index = index == -1 ? 0 : index;
      _option = showValues.elementAt(index);
    }
    return (_option ?? S.current.Select);
  }
}

class SelectSheet extends StatefulWidget {
  final List<String> options;
  final List<String>? displayValues;
  final String? selectedOption;
  final Function(String)? onChanged;
  final String? popupText;
  const SelectSheet(
      {Key? key,
      required this.options,
      this.displayValues,
      this.selectedOption,
      this.popupText,
      this.onChanged})
      : super(key: key);

  @override
  _SelectSheetState createState() => _SelectSheetState();
}

class _SelectSheetState extends State<SelectSheet> {
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
            padding: EdgeInsets.only(top: 30, left: 20.0, right: 20.0),
            child: Text(widget.popupText ?? '',
                style: Theme.of(context).textTheme.titleLarge),
          ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.options.length,
          padding: EdgeInsets.symmetric(vertical: 30),
          itemBuilder: (_, index) {
            String displayText = widget.displayValues == null
                ? widget.options.elementAt(index)
                : widget.displayValues!.elementAt(index);
            return OptionTile(
              // iconData: ,
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              iconData: (option != null &&
                      option!.equals(widget.options.elementAt(index)))
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              onPressed: () {
                widget.onChanged!(widget.options.elementAt(index));
                if (mounted)
                  setState(() {
                    option = widget.options.elementAt(index);
                  });
                Navigator.pop(context);
              },
              text: displayText,
            );
          },
        )
      ],
    );
  }
}

class SelectBar extends StatelessWidget {
  final List<String> options;
  final String? selectedOption;
  final void Function(String?) onChanged;
  final void Function()? onClear;
  final bool shouldBreak;
  final bool disabled;
  final String disabledReason;
  final EdgeInsets? listPadding;
  const SelectBar({
    Key? key,
    required this.options,
    this.selectedOption,
    this.onClear,
    this.disabledReason = "",
    this.disabled = false,
    this.shouldBreak = true,
    required this.onChanged,
    this.listPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (disabled) {
      return showNoContent(text: disabledReason);
    }

    if (options.length > 30 && shouldBreak) {
      var listOne = options.getRange(0, 30).toList();
      var listTwo = options.getRange(30, options.length).toList();
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _selectBarWidget(listOne),
          const SizedBox(height: 15),
          _selectBarWidget(listTwo, listPadEnd: 20)
        ],
      );
    } else {
      return _selectBarWidget(options);
    }
  }

  Widget _selectBarWidget(List<String> list, {double listPadEnd = 0}) {
    return HeaderWidget(
      header: list,
      contentPadding: EdgeInsets.symmetric(horizontal: 3),
      itemPadding: EdgeInsets.symmetric(horizontal: 14.0),
      fontSize: 15,
      shouldAnimate: false,
      formatText: true,
      tapToDisable: true,
      height: 55.0,
      listPadding:
          listPadding ?? EdgeInsets.only(left: 15 + listPadEnd, right: 45),
      selectedIndex: list.indexOf(selectedOption ?? ''),
      onPressed: (index) => index != -1
          ? onChanged(list.elementAt(index))
          : (onClear == null ? () {} : onClear!()),
    );
  }
}

class MutiSelectBar extends StatelessWidget {
  final List<String> options;
  final List<String>? includedOptions;
  final List<String>? excludedOptions;
  final Function(List<String>, List<String>) onChanged;
  final Function() onClear;
  const MutiSelectBar(
      {Key? key,
      required this.options,
      required this.onClear,
      this.excludedOptions,
      this.includedOptions,
      required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (options.length > 30) {
      var listOne = options.getRange(0, 30).toList();
      var listTwo = options.getRange(30, options.length).toList();
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _multiSelectBar(listOne),
          const SizedBox(height: 15),
          _multiSelectBar(listTwo, listPadding: 20.0)
        ],
      );
    } else {
      return _multiSelectBar(options);
    }
  }

  Widget _multiSelectBar(list, {double listPadding = 0}) {
    return IncludeExcludeWidget(
      header: list,
      include: includedOptions ?? [],
      exclude: excludedOptions ?? [],
      contentPadding: EdgeInsets.symmetric(horizontal: 3),
      itemPadding: EdgeInsets.symmetric(horizontal: 8),
      fontSize: 15,
      shouldAnimate: false,
      formatText: true,
      tapToDisable: true,
      listPadding: EdgeInsets.only(left: 15 + listPadding, right: 45),
      includeBgColor: Colors.green.shade900,
      excludeBgColor: Colors.red.shade900,
      onPressed: (include, exclude) => include.isEmpty && exclude.isEmpty
          ? onClear()
          : onChanged(include, exclude),
    );
  }
}
