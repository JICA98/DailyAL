import 'package:flutter/material.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../constant.dart';
import '../../main.dart';

class SliderWidget extends StatelessWidget {
  final Iterable itr;
  final String? t;
  final int currItemIndex;
  final double width;
  final double horizontalPadding;
  final double fontSize;
  final ValueChanged<int>? onIndexChange;
  SliderWidget(
      {required this.itr,
      this.t,
      this.currItemIndex = 0,
      this.width = 60,
      this.fontSize = 21,
      this.onIndexChange,
      this.horizontalPadding = 10});
  final ItemScrollController itemScrollController = ItemScrollController();

  scrollTo(index) async {
    await itemScrollController.scrollTo(
        index: index, duration: Duration(milliseconds: 400));
    onIndexChange ?? (index);
  }

  jumpTo(index) async {
    itemScrollController.jumpTo(
      index: index,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 5,
        ),
        title(t, fontSize: fontSize - 2),
        Row(
          children: [
            Expanded(
                child: currItemIndex != 0
                    ? IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.keyboard_arrow_left_outlined),
                        onPressed: () {
                          if (currItemIndex != 0) scrollTo(currItemIndex - 1);
                        },
                      )
                    : const SizedBox(
                        width: 45,
                      )),
            const SizedBox(
              height: 40,
            ),
            Container(
              height: 50,
              width: width,
              child: ScrollablePositionedList.builder(
                itemCount: itr.length,
                padding: EdgeInsets.zero,
                initialScrollIndex: currItemIndex,
                scrollDirection: Axis.horizontal,
                itemScrollController: itemScrollController,
                itemBuilder: (context, index) =>
                    centerWidget(itr.elementAt(index), index),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Expanded(
                child: (currItemIndex != (itr.length - 1))
                    ? IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.keyboard_arrow_right_outlined),
                        onPressed: () {
                          if (currItemIndex != itr.length - 1)
                            scrollTo(currItemIndex + 1);
                        },
                      )
                    : const SizedBox(
                        width: 45,
                      )),
          ],
        )
      ],
    );
  }

  Widget content(index) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Center(
          child: title("${itr.elementAt(index).toString().capitalize()}",
              fontSize: fontSize, opacity: 1),
        ),
      ),
    );
  }

  Widget centerWidget(statusValue, index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: DropdownButton<dynamic>(
        underline: Container(),
        elevation: 0,
        // icon: Icon(Icons.arrow_upward),
        icon: Container(),
        value: statusValue.toString(),
        selectedItemBuilder: (context) {
          return itr.map<Widget>((dynamic item) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Container(
                  alignment: Alignment.center,
                  child: title("${statusValue.toString().capitalize()}",
                      align: TextAlign.center, fontSize: fontSize, opacity: 1)),
            );
          }).toList();
        },
        items: itr
            .map<DropdownMenuItem<dynamic>>((e) => DropdownMenuItem(
                  value: e.toString(),
                  child: Center(
                    child: title(e.toString()),
                  ),
                ))
            .toList(),
        onChanged: (value) {
          scrollTo(itr.toList().indexOf(value));
        },
      ),
    );
  }
}
