import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/common/image_preview.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';

class AnimePictures extends StatelessWidget {
  final List<Picture> pictures;
  final double horizPadding;
  const AnimePictures({required this.pictures, required this.horizPadding});

  @override
  Widget build(BuildContext context) {
    Widget avatarWidget(int index) {
      return AvatarWidget(
        width: 200,
        onTap: () {
          zoomInImageList(
            context,
            pictures.map((e) => e.large!).toList(),
          );
        },
        url: pictures[index].large,
        useUserImageOnError: false,
        radius: BorderRadius.circular(6),
        userRoundBorderforLoading: false,
      );
    }

    return Container(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pictures.length,
        padding: EdgeInsets.symmetric(horizontal: 15),
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: avatarWidget(index),
        ),
      ),
    );
  }
}
