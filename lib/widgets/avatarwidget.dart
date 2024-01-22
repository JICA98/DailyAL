import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dailyanimelist/cache/cachemanager.dart';
import 'package:dailyanimelist/widgets/common/image_preview.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constant.dart';
import '../main.dart';

class AvatarWidget extends StatelessWidget {
  final double? height, width;
  final Function? onTap;
  final BorderRadius? radius;
  final String? url;
  final bool isNetworkImage;
  final bool? useUserImageOnError;
  final String? username;
  final BoxFit? fit;
  final bool? userRoundBorderforLoading;
  final VoidCallback? onLongPress;
  const AvatarWidget({
    this.height = 100,
    this.width = 100,
    this.onTap,
    this.url,
    this.radius,
    this.onLongPress,
    this.fit = BoxFit.cover,
    this.userRoundBorderforLoading = true,
    this.username,
    this.useUserImageOnError = true,
    this.isNetworkImage = true,
  });
  @override
  Widget build(BuildContext context) {
    if (username != null && url != null) {
      CacheManager.instance.setUserImage(username, url);
    }
    return Container(
        height: height,
        width: width,
        child: InkWell(
          onLongPress: onLongPress != null
              ? onLongPress
              : (url != null ? () => zoomInImage(context, url!, isNetworkImage) : null),
          onTap: onTap == null
              ? null
              : () {
                  onTap!();
                },
          customBorder: RoundedRectangleBorder(
              borderRadius: radius ?? BorderRadius.circular(28)),
          child: username != null && url == null
              ? FutureBuilder<String?>(
                  future: CacheManager.instance.getUserImage(username),
                  builder: (_, snapshot) {
                    if (snapshot.hasData) {
                      return cachedImage(radius, snapshot.data);
                    } else {
                      return url == null || !isNetworkImage
                          ? userImage(radius, url, username: username)
                          : cachedImage(radius, url);
                    }
                  })
              : url == null || !isNetworkImage
                  ? userImage(
                      radius,
                      url,
                      useUserImageOnError: useUserImageOnError,
                    )
                  : cachedImage(
                      radius,
                      url,
                      fit: fit,
                      useUserImageOnError: useUserImageOnError,
                      userRoundBorderforLoading: userRoundBorderforLoading,
                    ),
        ));
  }
}

class AvatarAspect extends StatelessWidget {
  final double aspectRatio;
  final Function? onTap;
  final BorderRadius? radius;
  final String? url;
  final bool localFile;
  final bool isNetworkImage;
  final VoidCallback? onLongPress;
  final bool useUserImageOnError;
  final String? username;
  final bool userRoundBorderforLoading;

  AvatarAspect({
    this.onTap,
    this.url,
    this.aspectRatio = 1.0,
    this.radius,
    this.useUserImageOnError = true,
    this.username,
    this.localFile = false,
    this.onLongPress,
    this.isNetworkImage = true,
    this.userRoundBorderforLoading = false,
  });
  @override
  Widget build(BuildContext context) {
    if (username != null && url != null) {
      CacheManager.instance.setUserImage(username, url);
    }
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius ?? BorderRadius.circular(28),
        child: InkWell(
          onTap: onTap == null
              ? null
              : () {
                  onTap!();
                },
          onLongPress: onLongPress,
          customBorder: RoundedRectangleBorder(
              borderRadius: radius ?? BorderRadius.circular(28)),
          child: localFile
              ? Image.file(
                  File(url!),
                  fit: BoxFit.cover,
                )
              : (username != null && url == null)
                  ? FutureBuilder<String?>(
                      future: CacheManager.instance.getUserImage(username),
                      builder: (_, snapshot) {
                        if (snapshot.hasData) {
                          return cachedImage(radius, snapshot.data);
                        } else {
                          return url == null || !isNetworkImage
                              ? userImage(radius, url,
                                  useUserImageOnError: useUserImageOnError)
                              : cachedImage(radius, url,
                                  useUserImageOnError: useUserImageOnError);
                        }
                      })
                  : url == null || !isNetworkImage
                      ? userImage(radius, url,
                          useUserImageOnError: useUserImageOnError,
                          username: username)
                      : cachedImage(
                          radius,
                          url,
                          useUserImageOnError: useUserImageOnError,
                          userRoundBorderforLoading: userRoundBorderforLoading,
                        ),
        ),
      ),
    );
  }
}

Color randomColor(String username) {
  final cd = username.hashCode;
  return Color.fromARGB(255, cd % 150, cd % 125, cd % 100);
}

Widget userImage(BorderRadius? radius, String? url,
    {useUserImageOnError = true, String? username}) {
  if (useUserImageOnError && username != null) {
    username = username.toLowerCase();
    username = username.substring(0, username.length > 2 ? 2 : 1);
    return Container(
      child: Center(
        child: AutoSizeText(
          username,
          maxLines: 1,
          minFontSize: 10,
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),
      decoration: BoxDecoration(
        color: randomColor(username),
        shape: BoxShape.circle,
      ),
    );
  }
  return Container(
    child: Ink(
      decoration: BoxDecoration(
        borderRadius: radius ?? BorderRadius.circular(28),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage(
            url ??
                (useUserImageOnError
                    ? "assets/images/user-unknown.jpg"
                    : "assets/images/error-image.png"),
          ),
        ),
      ),
    ),
  );
}

Widget cachedImage(
  BorderRadius? radius,
  String? url, {
  useUserImageOnError = true,
  BoxFit? fit = BoxFit.cover,
  userRoundBorderforLoading = true,
}) {
  return CachedNetworkImage(
    imageUrl: url ?? '',
    placeholder: (context, url) => cardLoading(
        borderRadius:
            userRoundBorderforLoading ? BorderRadius.circular(32) : radius),
    errorWidget: (context, url, error) {
      return Container(
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius ?? BorderRadius.circular(28),
            image: DecorationImage(
              fit: fit,
              image: AssetImage(
                (useUserImageOnError
                    ? "assets/images/user_dal.png"
                    : "assets/images/anime-collage.jpg"),
              ),
            ),
          ),
        ),
      );
    },
    imageBuilder: (context, imageProvider) => Ink(
      decoration: BoxDecoration(
          borderRadius: radius ?? BorderRadius.circular(28),
          image: DecorationImage(fit: fit, image: imageProvider)),
    ),
  );
}
