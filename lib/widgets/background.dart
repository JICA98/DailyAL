import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/theme/theme.dart';
import 'package:flutter/material.dart';

import 'fadingeffect.dart';

class Background extends StatelessWidget {
  final BuildContext context;
  final String? url;
  final double? height;
  final double? width;
  final bool isNetworkImage;
  final bool showLocalFile;
  final bool forceBg;
  final Color? bgColor;
  const Background({
    required this.context,
    this.url,
    this.height,
    this.showLocalFile = false,
    this.forceBg = false,
    this.bgColor,
    this.isNetworkImage = true,
    this.width = double.infinity,
  });
  @override
  Widget build(BuildContext c) {
    return (user.pref.showBg || forceBg || showLocalFile)
        ? Stack(
            children: [
              Container(
                color: bgColor ?? Theme.of(context).scaffoldBackgroundColor,
              ),
              Container(
                width: width,
                height: showLocalFile
                    ? null
                    : (height ?? MediaQuery.of(context).size.height / 1.9),
                child: CustomPaint(
                  foregroundPainter: FadingEffect(
                    color: bgColor ?? Theme.of(context).scaffoldBackgroundColor,
                    start: 200,
                    end: 255,
                  ),
                  child: showLocalFile
                      ? Image.file(
                          File(url!),
                          fit: BoxFit.cover,
                        )
                      : url == null || !isNetworkImage
                          ? Image.asset(
                              url ??
                                  backgroundMap[user.theme.background] ??
                                  "assets/images/fall.jpg",
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: url!,
                              fit: BoxFit.cover,
                            ),
                ),
              )
            ],
          )
        : Container(
            color: bgColor ?? Theme.of(context).scaffoldBackgroundColor,
          );
  }
}
