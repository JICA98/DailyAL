import 'package:dailyanimelist/widgets/shimmecolor.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';

class ShimmerWidget extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry? padding;
  ShimmerWidget({this.itemCount = 4, this.padding});
  @override
  Widget build(BuildContext context) {
    final shimmerColors = ShimmerColors.fromContext(context);
    return Shimmer.fromColors(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: itemCount,
          padding: padding,
          itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6)),
              )),
        ),
        baseColor: shimmerColors.baseColor,
        highlightColor: shimmerColors.highlightColor);
  }
}

class ShimmerHorizWidget extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry? listPadding;
  final EdgeInsetsGeometry? itemPadding;
  final Widget? item;
  final double height;

  const ShimmerHorizWidget({
    this.itemCount = 6,
    this.listPadding,
    this.height = 60.0,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 15),
    this.item,
  });

  @override
  Widget build(BuildContext context) {
    final shimmerColors = ShimmerColors.fromContext(context);
    final loadingItem = item ??
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ));
    return Container(
      height: height,
      child: Shimmer.fromColors(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: itemCount,
          padding: listPadding,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) => loadingItem,
        ),
        baseColor: shimmerColors.baseColor,
        highlightColor: shimmerColors.highlightColor,
      ),
    );
  }
}
