import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/widgets/shimmecolor.dart';
import 'package:flutter/material.dart';

Widget loadingCardList({
  double? containerHeight,
  double height = 150.0,
  double width = 100.0,
  Axis axis = Axis.horizontal,
  int itemCount = 6,
  EdgeInsetsGeometry listPadding = EdgeInsets.zero,
}) {
  return ShimmerColor(
    Container(
      height: containerHeight,
      child: ListView.builder(
        scrollDirection: axis,
        itemCount: itemCount,
        padding: listPadding,
        itemBuilder: (context, index) => LoadingCard(
          height: height,
          width: width,
        ),
      ),
    ),
  );
}

class LoadingCard extends StatelessWidget {
  final double height;
  final double width;
  const LoadingCard({this.height = 150.0, this.width = 100.0});
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: this.height,
              child: Container(
                width: this.width,
                child: Material(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: this.width,
            ),
          ],
        ));
  }
}
