import 'package:flutter/material.dart';
import '../../constant.dart';

class CustomDropdownButton extends StatelessWidget {
  final String? dropdownValue;
  final Iterable values;
  final Iterable? displayValues;
  final double? height, width;
  final BoxConstraints? constraints;
  final ValueChanged<String?>? onChanged;
  const CustomDropdownButton({
    Key? key,
    this.dropdownValue,
    this.displayValues,
    required this.values,
    this.onChanged,
    this.height = 100,
    this.width,
    this.constraints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _displayValues = displayValues ?? values;
    return Container(
        height: height,
        width: width,
        constraints: constraints,
        child: DropdownButton<String>(
          underline: Container(),
          icon: Container(),
          value: dropdownValue,
          selectedItemBuilder: (context) {
            return _displayValues.map<Widget>((dynamic item) {
              return Container(
                  alignment: Alignment.center,
                  width: width,
                  constraints: constraints,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12)),
                  child: title(item.toString(), opacity: 1));
            }).toList();
          },
          items: values
              .map((e) => DropdownMenuItem(
                    value: e.toString(),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: title(
                          _displayValues
                              .elementAt(values.toList().indexOf(e))
                              ?.toString(),
                          align: TextAlign.center,
                          opacity: 1,
                        ),
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            if (onChanged != null) onChanged!(value);
          },
        ));
  }
}
