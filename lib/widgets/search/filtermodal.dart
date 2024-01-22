import 'package:auto_size_text/auto_size_text.dart';
import 'package:dailyanimelist/pages/settings/optiontile.dart';
import 'package:dailyanimelist/widgets/selectbottom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:dal_commons/dal_commons.dart';

import '../../constant.dart';
import '../../main.dart';
import '../custombutton.dart';

enum FilterType { select, date, multiple, equal, single_list }

class FilterRange {
  final double? maxValue;
  final double? minValue;
  double? startValue;
  double? endValue;
  FilterRange({this.maxValue, this.minValue, this.endValue, this.startValue});
}

class FilterOption {
  final FilterType? type;
  final String? fieldName;
  final String? desc;
  final String? apiFieldName;
  final String? excludeFieldName;
  final String? dependent;
  final String? mutualExclusive;
  final List<String>? values;
  final List<dynamic>? apiValues;
  List<String>? includedOptions;
  List<String>? excludedOptions;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Map<String, Map<String, String>?>? singleList;
  String? value;
  String? modalField;
  FilterOption({
    this.type,
    this.fieldName,
    this.values,
    this.desc,
    this.value,
    this.mutualExclusive,
    this.excludeFieldName,
    this.apiValues,
    this.apiFieldName,
    this.keyboardType,
    this.includedOptions,
    this.inputFormatters,
    this.excludedOptions,
    this.singleList,
    this.dependent,
    this.modalField,
  });

  FilterOption clone() {
    return FilterOption(
      type: type,
      fieldName: fieldName,
      values: values?.toList(),
      desc: desc,
      value: value,
      mutualExclusive: mutualExclusive,
      excludeFieldName: excludeFieldName,
      apiValues: apiValues?.toList(),
      apiFieldName: apiFieldName,
      keyboardType: keyboardType,
      includedOptions: includedOptions?.toList(),
      inputFormatters: inputFormatters?.toList(),
      excludedOptions: excludedOptions?.toList(),
      singleList: cloneMap(singleList),
      dependent: dependent,
      modalField: modalField,
    );
  }

  static Map<String, Map<String, String>?>? cloneMap(Map<String, Map<String, String>?>? input) {
    if (input == null) return null;
    Map<String, Map<String, String>?> output = {};
    input.forEach((key, value) {
      output[key] = value?.map((key, value) => MapEntry(key, value));
    });
    return output;
  }

}

class FilterModal extends StatelessWidget {
  final List<FilterOption> filterOptions;
  final Map<String, FilterOption> filterOutputs;
  final VoidCallback? onClose;
  final VoidCallback? onApply;
  final bool hasApply;
  final bool showText;
  final String? additional;
  final void Function(Map<String, FilterOption>)? onChange;
  final bool showBottombar;
  const FilterModal({
    Key? key,
    required this.filterOptions,
    this.onClose,
    this.onApply,
    this.hasApply = true,
    required this.filterOutputs,
    this.onChange,
    this.showText = false,
    this.showBottombar = true,
    this.additional,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Stack(
      children: [
        ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(top: 10.0, bottom: 120),
          children: [
            if (!hasApply)
              Padding(
                  padding: EdgeInsets.only(
                      right: 15, left: 15, bottom: 25, top: 20.0),
                  child: Text(
                    S.current.Filter_After_search,
                    textAlign: TextAlign.center,
                  )),
            if (showText)
              Padding(
                  padding: EdgeInsets.only(right: 15, left: 15, bottom: 25),
                  child: title(additional ?? "",
                      align: TextAlign.center, fontSize: 16)),
            for (int i = 0; i < filterOptions.length; ++i)
              filterTile(filterOptions.elementAt(i), context),
          ],
        ),
        if (showBottombar)
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                child: Card(
                    child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 7),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShadowButton(
                        child: iconAndText(
                          hasApply ? Icons.cancel : Icons.close,
                          hasApply ? S.current.Cancel : S.current.Close,
                        ),
                        onPressed: onClose,
                      ),
                      const SizedBox(width: 5),
                      if (hasApply)
                        Expanded(
                          child: ShadowButton(
                            child: AutoSizeText(
                              "${S.current.Apply_Filters} ${filterOutputs.isNotEmpty ? '(${filterOutputs.length})' : ''}",
                              style: TextStyle(fontSize: 10.0),
                            ),
                            onPressed: filterOutputs.isEmpty ? null : onApply,
                          ),
                        ),
                      const SizedBox(width: 5),
                      ShadowButton(
                        child: iconAndText(Icons.clear_all, S.current.Clear),
                        onPressed: () => _clearAll(),
                      )
                    ],
                  ),
                )),
              )
            ],
          )
      ],
    ));
  }

  Widget filterTile(FilterOption option, context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(option.fieldName ?? '',
                          style: TextStyle(fontSize: 18.0)),
                      if (option.desc != null)
                        Padding(
                          padding: EdgeInsets.only(left: 15),
                          child: ToolTipButton(
                            message: option.desc!,
                            child: Icon(Icons.info_outline),
                          ),
                        )
                    ],
                  ),
                  if (filterOutputs.containsKey(option.apiFieldName) &&
                      option.type != FilterType.equal)
                    SizedBox(
                      height: 45.0,
                      child: ShadowButton(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        onPressed: () => removeFilter(option),
                        child: iconAndText(Icons.clear, S.current.Clear),
                      ),
                    )
                  else
                    SizedBox(height: 45.0)
                ],
              )),
          const SizedBox(height: 15),
          switchFilterType(option, context),
        ],
      ),
    );
  }

  Widget switchFilterType(FilterOption option, context) {
    String? disabledMessage;
    if (option.dependent != null &&
        !filterOutputs.containsKey(option.dependent)) {
      disabledMessage = S.current.Filter_along_with
          .replaceFirst("*1", '${option.dependent}')
          .replaceFirst("*2", '${option.fieldName}');
    }

    if (option.mutualExclusive != null &&
        filterOutputs.containsKey(option.mutualExclusive)) {
      disabledMessage = S.current.Filter_cannot_with
          .replaceFirst("*1", '${option.fieldName}')
          .replaceFirst(
              "*2", '${filterOutputs[option.mutualExclusive]!.fieldName}');
    }

    if (disabledMessage != null) {
      return Padding(
          padding: EdgeInsets.only(top: 15),
          child: heading(disabledMessage,
              fontSize: 13, alignment: Alignment.center));
    }

    switch (option.type) {
      case FilterType.select:
        return SelectBar(
          options: option.values!,
          selectedOption: filterOutputs[option.apiFieldName]?.value,
          onClear: () => removeFilter(option),
          onChanged: (value) {
            if (value != null) {
              option.value = value;
              filterOutputs[option.apiFieldName!] = option;
              onChange!(filterOutputs);
            }
          },
        );
      case FilterType.multiple:
        return MutiSelectBar(
          options: option.values ?? strList,
          includedOptions:
              filterOutputs[option.apiFieldName]?.includedOptions ?? [],
          excludedOptions:
              filterOutputs[option.apiFieldName]?.excludedOptions ?? [],
          onChanged: (inc, exc) {
            option.includedOptions = inc;
            option.excludedOptions = exc;
            filterOutputs[option.apiFieldName!] = option;
            onChange!(filterOutputs);
          },
          onClear: () => removeFilter(option),
        );
      case FilterType.date:
        DateTime? parsedDate;
        try {
          parsedDate = DateFormat("yyyy-MM-dd")
              .parse(filterOutputs[option.apiFieldName]?.value ?? "");
        } catch (e) {}
        return PlainButton(
          onPressed: () async {
            final datetime = await showDatePicker(
              context: context,
              initialDate: parsedDate ?? DateTime.now(),
              firstDate: DateTime.utc(1970),
              lastDate: DateTime.utc(DateTime.now().year + 1, 6),
              builder: (BuildContext context, Widget? child) {
                return child ?? SB.z;
              },
            );
            if (datetime != null) {
              option.value = DateFormat("yyyy-MM-dd").format(datetime);
              filterOutputs[option.apiFieldName!] = option;
              onChange!(filterOutputs);
            }
          },
          child: iconAndText(
              Icons.date_range,
              formateDate(DateTime.tryParse(
                      filterOutputs[option.apiFieldName]?.value ?? "")) ??
                  "Select a ${option.fieldName}"),
        );
      case FilterType.equal:
        return TextFormFilter(
          option: option,
          onEdit: (data) {
            if (data == null || data.isEmpty) {
              removeFilter(option);
            } else {
              option.value = data;
              filterOutputs[option.apiFieldName!] = option;
              onChange!(filterOutputs);
            }
          },
        );
      case FilterType.single_list:
        return Padding(
          padding: const EdgeInsets.only(top: 10, left: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: option.singleList!.keys.map((e) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title(e.capitalize(), opacity: 0.9, fontSize: 16),
                  SB.h20,
                  SelectBar(
                    options: option.singleList![e]!.values.toList(),
                    selectedOption: option.singleList![e]![
                        filterOutputs[option.apiFieldName]?.value],
                    onClear: () => removeFilter(option),
                    onChanged: (value) {
                      if (value != null) {
                        var index = option.singleList![e]!.values
                            .toList()
                            .indexOf(value);
                        option.value = option.singleList![e]!.keys
                            .toList()
                            .elementAt(index);
                        filterOutputs[option.apiFieldName!] = option;
                        onChange!(filterOutputs);
                      }
                    },
                  ),
                  SB.h20
                ],
              );
            }).toList(),
          ),
        );
      default:
    }
    return OptionTile(
      text: option.fieldName,
    );
  }

  String? formateDate(DateTime? datetime) {
    if (datetime == null) {
      return null;
    }
    return DateFormat.yMMMEd().format(datetime);
  }

  void removeFilter(FilterOption option) {
    String? depName = filterOutputs.remove(option.apiFieldName)?.apiFieldName;
    for (var _option in filterOutputs.values) {
      if (_option.dependent != null && _option.dependent!.equals(depName)) {
        filterOutputs.remove(_option.apiFieldName);
      }
    }
    if (onChange != null) onChange!(filterOutputs);
  }

  void removeFilterAsync(option) async {
    await Future.delayed(const Duration(milliseconds: 300));
    removeFilter(option);
    if (onChange != null) onChange!(filterOutputs);
  }

  void _clearAll() {
    filterOutputs.clear();
    if (onChange != null) onChange!(filterOutputs);
  }
}

class TextFormFilter extends StatefulWidget {
  final FilterOption option;
  final Function(String?)? onEdit;
  final Function(String?)? onFieldSubmitted;
  const TextFormFilter(
      {Key? key, required this.option, this.onEdit, this.onFieldSubmitted})
      : super(key: key);

  @override
  _TextFormFilterState createState() => _TextFormFilterState();
}

class _TextFormFilterState extends State<TextFormFilter> {
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controller.text = widget.option.value ?? "";
    controller.addListener(() {
      if (widget.onEdit != null) widget.onEdit!(controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: widget.option.keyboardType,
                  controller: controller,
                  focusNode: focusNode,
                  inputFormatters: widget.option.inputFormatters ?? [],
                  autofocus: false,
                  onFieldSubmitted: (value) {
                    if (value != null && widget.onFieldSubmitted != null) {
                      widget.onFieldSubmitted!(value);
                    }
                  },
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText:
                        'Type ${widget.option.fieldName?.toLowerCase()} here..',
                    hintStyle: TextStyle(fontSize: 14),
                    errorStyle: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              if (controller.text.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.done),
                  onPressed: () {
                    if (widget.onFieldSubmitted != null) {
                      widget.onFieldSubmitted!(controller.text);
                    }
                    focusNode.unfocus();
                  },
                  iconSize: 16,
                ),
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  controller.text = "";
                },
                iconSize: 16,
              ),
            ],
          )),
    );
  }
}

class CustomTextForm extends StatelessWidget {
  final String value;
  final String fieldName;
  final Function(String?)? onEdit;
  final Function(String?)? onFieldSubmitted;
  CustomTextForm(
      {Key? key,
      this.onEdit,
      this.onFieldSubmitted,
      required this.value,
      required this.fieldName})
      : super(key: key);

  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextFormField(
                  focusNode: focusNode,
                  autofocus: false,
                  initialValue: value ?? "",
                  onFieldSubmitted: (value) {
                    if (value != null && onFieldSubmitted != null) {
                      onFieldSubmitted!(value);
                    }
                  },
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Type ${fieldName.toLowerCase()} here..',
                    hintStyle: TextStyle(fontSize: 14),
                    errorStyle: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.done),
                onPressed: () {
                  focusNode.unfocus();
                },
                iconSize: 16,
              ),
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  if (onFieldSubmitted != null) {
                    onFieldSubmitted!('');
                  }
                },
                iconSize: 16,
              ),
            ],
          )),
    );
  }
}
